# per-user 고정(pin) 분리 — BE 핸드오프

> **문제**: 코스/항목 고정이 `todo_lists.is_pinned/pin_order`, `todo_items.is_pinned/pin_order`
> **전역 컬럼**에 저장돼 있어, 공유(협업) 코스에서 여러 계정이 같은 값을 덮어쓴다.
> 고정은 본질적으로 **개인 화면 정렬 취향**이므로 per-user 로 분리한다.
> **응답 JSON 계약(`is_pinned`/`pin_order`)은 그대로 유지**하되 값은 **호출자(caller) 기준**으로 계산해 반환한다 → FE 파싱 변경 없음.

---

## 1. 스키마 — per-user 고정 테이블 2개 신규

```sql
-- migration NNNN_per_user_pin.up.sql

CREATE TABLE todo_list_pins (
  user_id      UUID    NOT NULL REFERENCES users(id)      ON DELETE CASCADE,
  todo_list_id UUID    NOT NULL REFERENCES todo_lists(id) ON DELETE CASCADE,
  pin_order    INTEGER NOT NULL DEFAULT 0,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, todo_list_id)
);
CREATE INDEX idx_todo_list_pins_user ON todo_list_pins(user_id, pin_order);

CREATE TABLE todo_item_pins (
  user_id      UUID    NOT NULL REFERENCES users(id)      ON DELETE CASCADE,
  todo_item_id UUID    NOT NULL REFERENCES todo_items(id) ON DELETE CASCADE,
  todo_list_id UUID    NOT NULL REFERENCES todo_lists(id) ON DELETE CASCADE, -- 코스별 순서 계산용
  pin_order    INTEGER NOT NULL DEFAULT 0,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, todo_item_id)
);
CREATE INDEX idx_todo_item_pins_user_list ON todo_item_pins(user_id, todo_list_id, pin_order);
```

`ON DELETE CASCADE` 로 코스/항목/유저 삭제 시 pin 자동 정리. **탈퇴·삭제 시 별도 정리 코드 불필요.**

### 기존 전역 컬럼 데이터 이관 (1회)

전역 pin 은 소유자(owner)의 개인 pin 이었다고 보고 이관한다:

```sql
INSERT INTO todo_list_pins (user_id, todo_list_id, pin_order, created_at)
SELECT owner_id, id, pin_order, NOW()
FROM todo_lists WHERE is_pinned = TRUE
ON CONFLICT DO NOTHING;

INSERT INTO todo_item_pins (user_id, todo_item_id, todo_list_id, pin_order, created_at)
SELECT tl.owner_id, ti.id, ti.todo_list_id, ti.pin_order, NOW()
FROM todo_items ti
JOIN todo_lists tl ON tl.id = ti.todo_list_id
WHERE ti.is_pinned = TRUE
ON CONFLICT DO NOTHING;
```

기존 `todo_lists.is_pinned/pin_order`, `todo_items.is_pinned/pin_order` 컬럼은 **삭제하지 말고 deprecate**(더 이상 쓰기/읽기 안 함). 롤백 여지를 위해 컬럼 drop 은 다음 릴리스로 미룬다.

---

## 2. 쓰기 경로 — 고정 전용 엔드포인트

### 2-1. 코스 고정 — `PATCH /v1/todo-lists/:id/pin` (기존 엔드포인트 재활용)

- **권한**: `resolveListMember` (멤버면 누구나 자기 화면에 고정 가능) — 이미 적용됨.
- **요청 본문 변경**: `pin_order` 제거, `is_pinned` 만. **순서는 BE 가 계산**(FE 의 unix-초 방식 폐기).
  ```json
  { "is_pinned": true }
  ```
- **동작**:
  - `is_pinned=true` → upsert:
    ```sql
    INSERT INTO todo_list_pins (user_id, todo_list_id, pin_order)
    VALUES ($caller, $listId,
      (SELECT COALESCE(MAX(pin_order),0)+1 FROM todo_list_pins WHERE user_id=$caller))
    ON CONFLICT (user_id, todo_list_id) DO NOTHING;
    ```
  - `is_pinned=false` → `DELETE FROM todo_list_pins WHERE user_id=$caller AND todo_list_id=$listId;`
- **응답**: 기존과 동일하게 `TodoListResponse` 반환하되 `is_pinned`/`pin_order` 는 **caller 기준**(아래 §3).

### 2-2. 항목 고정 — `PATCH /v1/todo-lists/:listId/items/:itemId/pin` (신규)

- **권한**: `resolveListMember` (읽기 권한이면 개인 고정 허용 — viewer 도 자기 화면 정렬 가능하게 할지는 정책 선택. 최소 member 이상 권장).
- **요청 본문**: `{ "is_pinned": true }`
- **동작**: 위와 동일 패턴, 순서는 **코스 내 per-user** 로 계산:
  ```sql
  -- pin
  INSERT INTO todo_item_pins (user_id, todo_item_id, todo_list_id, pin_order)
  VALUES ($caller, $itemId, $listId,
    (SELECT COALESCE(MAX(pin_order),0)+1 FROM todo_item_pins
     WHERE user_id=$caller AND todo_list_id=$listId))
  ON CONFLICT (user_id, todo_item_id) DO NOTHING;
  -- unpin
  DELETE FROM todo_item_pins WHERE user_id=$caller AND todo_item_id=$itemId;
  ```
- **응답**: `TodoItemResponse` (caller 기준 `is_pinned`/`pin_order`).

### 2-3. 일반 항목 PATCH 에서 pin 제거 ⚠️ 중요

`PATCH /v1/todo-lists/:listId/items/:itemId` (일반 편집)의 **`is_pinned` 처리 로직을 삭제**한다.
현재 FE 는 항목 편집(메모/좌표/순서 변경) 시 `is_pinned` 를 항상 함께 보내는데, 이게 전역 pin 을
덮어써 "꼬임"의 직접 원인이었다. per-user 분리 후에도 일반 편집이 pin 을 건드리면 안 됨.

- `PatchTodoItemParams` 에서 `is_pinned`/`pin_order` 제거 (또는 무시).
- `UpdateTodoItem` SQL 의 `is_pinned=$, pin_order=$` 제거.
- pin 변경은 오직 §2-2 전용 엔드포인트로만.

---

## 3. 읽기 경로 — caller 기준 pin join

목록/상세/항목 응답에서 `is_pinned`/`pin_order` 를 **호출자의 per-user pin 테이블 LEFT JOIN** 으로 채운다.

### 코스 목록/상세 (`GET /v1/todo-lists`, `GET /v1/todo-lists/:id`)

```sql
-- todo_lists 조회에 caller pin LEFT JOIN
SELECT tl.*,
       (lp.user_id IS NOT NULL) AS is_pinned,
       COALESCE(lp.pin_order, 0) AS pin_order
FROM todo_lists tl
LEFT JOIN todo_list_pins lp
       ON lp.todo_list_id = tl.id AND lp.user_id = $caller
WHERE ...
```

- `toTodoListResponse` 는 그대로 두되, `l.IsPinned/l.PinOrder` 대신 join 결과값을 넣는다.
- sqlc 상 편의를 위해 목록/상세 쿼리를 caller 파라미터 받는 형태로 수정하거나, 조회 후
  `todo_list_pins WHERE user_id=$caller AND todo_list_id = ANY(ids)` 를 별도 조회해 map 으로 머지해도 됨.

### 항목 목록 (상세 응답의 `items[]`)

```sql
SELECT ti.*,
       (ip.user_id IS NOT NULL) AS is_pinned,
       COALESCE(ip.pin_order, 0) AS pin_order
FROM todo_items ti
LEFT JOIN todo_item_pins ip
       ON ip.todo_item_id = ti.id AND ip.user_id = $caller
WHERE ti.todo_list_id = $listId
ORDER BY ...
```

- `GetMaxPinOrder`(항목) 는 이제 **per-user** 여야 하므로 §2-2 의 per-user MAX 쿼리로 대체.

---

## 4. 정리 대상

| 항목 | 조치 |
|---|---|
| `todo_lists.is_pinned/pin_order` | deprecate (쓰기/읽기 중단, 컬럼은 다음 릴리스에 drop) |
| `todo_items.is_pinned/pin_order` | 동일 |
| `PinList` repo/service | per-user upsert/delete 로 교체 |
| `PatchItem` 의 pin 분기 (`service todo_service.go` 약 649-660) | 삭제 |
| `UpdateTodoItem` SQL 의 is_pinned/pin_order | 삭제 |
| `GetMaxPinOrder` (item) | per-user 버전으로 교체 |
| 목록/상세/항목 조회 쿼리 | caller pin LEFT JOIN 추가 |

---

## 5. FE-facing 계약 요약 (BE 가 지켜야 할 것)

- 응답 필드명 **불변**: `is_pinned`(bool), `pin_order`(int). 단 **값은 caller 기준**.
- `PATCH /todo-lists/:id/pin` 본문: `{ "is_pinned": bool }` (pin_order 안 받음 — 받아도 무시).
- 신규 `PATCH /todo-lists/:listId/items/:itemId/pin` 본문: `{ "is_pinned": bool }`.
- 일반 항목 PATCH 응답의 `is_pinned/pin_order` 도 caller 기준으로 정확히 반환(편집이 pin 을 바꾸지 않음).
- `pin_order` 는 per-user 오름차순(먼저 고정한 게 작은 값). FE 는 `pin_order ASC` 로 정렬.

---

## 6. FE 변경 (내가 처리 — BE 참고용)

- 항목 고정: `updateItem`(일반 PATCH) 대신 신규 pin 엔드포인트 호출로 분리 → 편집이 pin clobber 안 함.
- 코스/항목 고정 토글에서 `pin_order` 전송 제거(BE 계산).
- 병합의 `localMeta?.isPinned ?? server` → **서버 권위**로 교체(per-user 라 서버가 정답).
- drift 로컬 캐시는 유지하되, pin 은 서버 응답값을 신뢰(오프라인 낙관적 토글은 다음 sync 에 정정).
