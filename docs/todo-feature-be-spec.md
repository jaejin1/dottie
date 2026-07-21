# 할일(Todo) 기능 — BE 핸드오프 문서

> **요약**: Dottie 에 "미래 dot" 을 미리 찍어서 여행 계획을 짜고, 그날이 되면 도착 인증(체크인) 스탬프를 받는 기능 추가. 계획 지도는 비로그인 사용자에게 링크로 공유 가능. FE Phase 1 (로컬 only) 구현 완료. BE 는 Phase 2 (sync) / Phase 3 (비로그인 공유) 작업 필요.
>
> **2026-05 업데이트** — FE 가 "갈곳 모음" UX 로 피벗. 데이터 모델 / endpoint 스펙은 동일하게 유지 (column 만 의미 변화). 신규 BE 작업은 §10 `/v1/places/search` lat/lng 옵셔널화 1건. 자세한 항목은 마지막 [BE 확인/작업 사항](#11-be-확인작업-사항-2026-05-15-기준) 섹션 참조.

---

## 1. 기획 컨텍스트 (왜 이 기능이 필요한가)

### 배경

- 현재 Dottie 는 *오늘 시점*의 dot 만 기록 가능 (`DateTime.now()` 하드코딩). 사용자(20~30대, 여행 좋아하는 층)는 **여행 출발 전에 미리 계획**을 짜는 용도로도 쓰고 싶음.
- 사용자 본인 피드백: "기록이 은근 귀찮다" — 입력 마찰이 큼. 그러나 *계획*은 능동적이고 재미 요소가 있어 마찰이 훨씬 낮음 → 같은 코드베이스로 *다른 사용 동기* 를 한 번에 노릴 수 있음.
- 부수 효과: "어디 가고 어디 가야 하는지" 라이프 체크리스트로도 사용 가능 (반드시 여행 용도만은 아님).

### 핵심 사용자 시나리오

1. **여행 계획**: "도쿄 4박5일" 생성 → 지도 long-press 또는 검색으로 갈 곳 미리 찍기 → 일자별/시간별 정리 → 와이프/친구에게 링크 공유
2. **도착 인증**: 실제 여행일이 되면 그 장소 근처 가서 도착 인증 → 스탬프 애니메이션 → 정상 dot 으로 자동 변환되어 기존 trail/공유 흐름에 편입
3. **체크리스트**: 평소 "가보고 싶은 카페 리스트" 같이 등록만 해두고 천천히 체크인

### 핵심 설계 결정 (이미 확정)

| 결정 | 선택 | 이유 |
|---|---|---|
| 새 객체 vs Dot 확장 | **새 객체 `TodoList` + `TodoItem`** | 다일/다지점 묶음 단위 자연스러움. 기존 Dot 흐름 깨지지 않음. 체크인 = 명확한 상태 전이 |
| 체크인 방식 | **정상 Dot 1건 생성 + TodoItem.checkInDotId 로 링크** | TodoItem 자체는 보존 → 계획 vs 실제 회고 가능. dot 은 기존 trail/공유에 자동 편입 |
| 위치 검증 | **GPS 200m (기존 B8 거리검증 재사용)** + override | UX 일관성, override 확인 다이얼로그로 유연성 보장 |
| 시간 입력 | **일자 + 시간** (default 09:00) | 분 단위는 과함. 라이프로깅 톤에 맞춤 |
| 공유 권한 | **읽기 전용** | Phase 2 협업 모드는 별도. 공유는 "보여주기" 용도 |
| 공유 만료 | **24시간 (테스트용)** | 추후 30일 등으로 조정. default 값 한 곳만 바꾸면 됨 |
| 진입 동선 | **메인 탭 "검색" 제거 → "할일" 탭 신설**. 검색은 방 리스트 상단 돋보기 아이콘으로 이동 | 사용자 결정 |
| 사진 첨부 (체크인 시) | **옵션** | 강제하면 마찰 ↑ |

### Phase 별 범위

- **Phase 1 (완료, FE 로컬 only)** — 본인 디바이스에서 생성/입력/지도/리스트/체크인. 서버 X
- **Phase 2 (BE 작업 #1, 시급)** — 서버 sync, 멀티 디바이스 동기화. 협업 X
- **Phase 3 (BE 작업 #2)** — 비로그인 공유 토큰 + `/v1/public/*` read-only endpoint
- **차후** — 협업 (`member_ids`), 알림, Flutter Web 비로그인 뷰

### 개념 모델

```
User
 └─ TodoList ("도쿄 4박5일", 2026-06-01~05)
     ├─ TodoItem (day 0: 도쿄타워 09:00, notes, place_id) — 미체크인
     ├─ TodoItem (day 0: 시부야 14:00) — 체크인 ✓ → Dot(2026-06-01T14:23Z)
     └─ TodoItem (day 1: ...)
```

체크인 화살표는 **단방향**: TodoItem → Dot (`checkInDotId`). Dot 은 TodoItem 을 모름. Dot 삭제 시 BE 가 `check_in_dot_id` 를 NULL 로 cleanup 권장.

---

## 2. BE 작업 개요

- **할일 (TodoList)** — 여행 / 일정 묶음. "도쿄 4박5일" 같은 단위.
- **할일 항목 (TodoItem)** — 가야 할 장소 1건. plannedAt 도래 시 체크인 가능.
- **체크인** — 도착 인증. 정상 Dot 1건을 생성하고 그 dot.id 를 TodoItem 에 링크.
- **공유** — 단일 TodoList 를 토큰 기반으로 비로그인 사용자에게 read-only 공개. 기본 만료 **1일** (테스트용, 추후 30일 등으로 조정 예정).

## 데이터 모델 (DB 권장 스키마)

### todo_lists

| 컬럼 | 타입 | nullable | 설명 |
|---|---|---|---|
| id | text (uuid) | NO | PK |
| owner_id | text | NO | 사용자 UID |
| name | text | NO | 이름 (max 50자) |
| cover_emoji | text | YES | 표지 이모지 |
| start_date | date | NO | 시작일 |
| end_date | date | NO | 종료일 (start 이상) |
| share_token | text | YES | 공개 공유 토큰 (생성 시) — UNIQUE |
| share_token_expires_at | timestamptz | YES | 토큰 만료 |
| created_at | timestamptz | NO |  |
| updated_at | timestamptz | NO | last-writer-wins 충돌 해소 키 |

### todo_items

| 컬럼 | 타입 | nullable | 설명 |
|---|---|---|---|
| id | text (uuid) | NO | PK |
| todo_list_id | text | NO | FK → todo_lists.id (ON DELETE CASCADE) |
| latitude | numeric | NO |  |
| longitude | numeric | NO |  |
| place_name | text | YES |  |
| place_category | text | YES |  |
| place_id | text | YES | place 검색 시 BE place_id |
| planned_at | timestamptz | NO | RFC3339, UTC |
| day_index | integer | NO | start_date 기준 0,1,2... (정규화 키) |
| order_in_day | integer | NO | 같은 day_index 내 드래그 순서 |
| notes | text | YES | 메모 (max 300자) |
| emotion | text | YES | 4자 유니코드 |
| check_in_dot_id | text | YES | 체크인 시 생성된 dots.id 약한 참조 (FK 아님 — dot 삭제 시 NULL 처리 권장) |
| checked_in_at | timestamptz | YES |  |
| created_at | timestamptz | NO |  |
| updated_at | timestamptz | NO |  |

**인덱스**:
- `todo_lists (owner_id, start_date DESC)` — 목록 조회
- `todo_lists (share_token)` UNIQUE WHERE share_token IS NOT NULL — 공유 lookup
- `todo_items (todo_list_id, day_index, order_in_day)` — 정렬된 조회
- `todo_items (check_in_dot_id)` — Dot 삭제 시 역참조 NULL 처리에 사용

## 응답 envelope

기존 패턴 그대로 — 모든 응답은 `{"data": ...}` 로 래핑. 에러는 `{"error": {"code", "message"}}`.

## Endpoint

### 1. POST /v1/todo-lists — 생성

**Auth**: required

**Request**:
```json
{
  "name": "도쿄 4박5일",
  "cover_emoji": "🇯🇵",
  "start_date": "2026-06-01",
  "end_date": "2026-06-05"
}
```

**Response 201**:
```json
{
  "data": {
    "id": "uuid",
    "owner_id": "...",
    "name": "도쿄 4박5일",
    "cover_emoji": "🇯🇵",
    "start_date": "2026-06-01",
    "end_date": "2026-06-05",
    "items": [],
    "share_token": null,
    "share_token_expires_at": null,
    "created_at": "2026-05-14T00:00:00Z",
    "updated_at": "2026-05-14T00:00:00Z"
  }
}
```

**Validation**:
- `name`: 1~50자
- `end_date >= start_date`
- 기간 30일 초과 시 400 (UX 가드, 옵션)

---

### 2. GET /v1/todo-lists — 내 목록

**Auth**: required

**Query**: 없음 (페이지네이션은 추후).

**Response 200**:
```json
{
  "data": [
    {
      "id": "...",
      "owner_id": "...",
      "name": "...",
      "cover_emoji": "...",
      "start_date": "...",
      "end_date": "...",
      "items": [],   // ★ 목록 응답엔 items 비워서 가벼움. 상세는 별도.
      "share_token": null,
      "share_token_expires_at": null,
      "created_at": "...",
      "updated_at": "..."
    }
  ]
}
```

---

### 3. GET /v1/todo-lists/:id — 상세

**Auth**: required (owner 만)

**Response 200**:
```json
{
  "data": {
    "id": "...",
    "owner_id": "...",
    "name": "...",
    ...,
    "items": [
      {
        "id": "...",
        "todo_list_id": "...",
        "latitude": 37.5665,
        "longitude": 126.9780,
        "place_name": "서울시청",
        "place_category": "관공서",
        "place_id": "place-uuid",
        "planned_at": "2026-06-01T00:00:00Z",
        "day_index": 0,
        "order_in_day": 0,
        "notes": "체크인 첫 장소",
        "emotion": "😊",
        "check_in_dot_id": null,
        "checked_in_at": null,
        "created_at": "...",
        "updated_at": "..."
      }
    ]
  }
}
```

**Errors**:
- 404 NOT_FOUND
- 403 FORBIDDEN (owner 아님)

---

### 4. PATCH /v1/todo-lists/:id — 메타 수정

**Auth**: required (owner)

**Request** (부분 필드, 모두 optional):
```json
{
  "name": "도쿄 5박6일",
  "cover_emoji": "🗼",
  "start_date": "2026-06-01",
  "end_date": "2026-06-06"
}
```

**Response 200**: 수정된 TodoList (items 미포함).

**참고**: `start_date` 변경 시 BE 가 자동으로 `day_index` 재계산 권장 (옵션). FE 에서도 가능.

---

### 5. DELETE /v1/todo-lists/:id

**Auth**: required (owner)

CASCADE 로 모든 todo_items 삭제. 체크인된 dot 자체는 그대로 보존 (Dot 은 별도 엔티티).

**Response 204**.

---

### 6. POST /v1/todo-lists/:id/items — 항목 추가

**Auth**: required (owner)

**Request**:
```json
{
  "latitude": 35.6586,
  "longitude": 139.7454,
  "place_name": "도쿄 타워",
  "place_category": "관광지",
  "place_id": "place-uuid",
  "planned_at": "2026-06-01T01:00:00Z",
  "day_index": 0,
  "order_in_day": 0,
  "notes": null,
  "emotion": null
}
```

**Response 201**: 생성된 TodoItem.

**Validation**:
- `planned_at` 의 날짜가 [start_date, end_date] 범위 안인지 확인 (느슨 검사 권장 — FE 가 day_index 보내므로 day_index 가 우선).
- `day_index` 가 (end - start) 범위 내인지.

---

### 7. PATCH /v1/todo-lists/:id/items/:itemId — 항목 수정

**Auth**: required (owner)

**Request**: 부분 필드. `order_in_day` 단독 변경은 재정렬 별도 endpoint 권장 (아래 #8).

**Response 200**: 수정된 TodoItem.

---

### 8. PUT /v1/todo-lists/:id/items/reorder — 드래그 재정렬

**Auth**: required (owner)

같은 dayIndex 내 항목 순서 변경. transaction 으로 일괄 갱신.

**Request**:
```json
{
  "day_index": 0,
  "ordered_item_ids": ["item-1", "item-2", "item-3"]
}
```
→ ordered 순서대로 `order_in_day` 0, 1, 2 로 갱신.

**Response 200**: 갱신된 항목 list (그 dayIndex 만).

---

### 9. DELETE /v1/todo-lists/:id/items/:itemId

**Auth**: required (owner)

**Response 204**.

---

### 10. POST /v1/todo-lists/:id/items/:itemId/check-in — 도착 인증

**Auth**: required (owner)

FE 가 먼저 `POST /v1/dots` 로 Dot 1건 생성한 뒤 그 `dot_id` 를 보냄.

**Request**:
```json
{
  "dot_id": "dot-uuid"
}
```

**Response 200**:
```json
{
  "data": {
    "id": "item-uuid",
    "check_in_dot_id": "dot-uuid",
    "checked_in_at": "2026-06-01T01:23:45Z",
    ...
  }
}
```

**Validation**:
- `dot_id` 가 호출자 소유의 dot 인지
- 이미 체크인된 항목이면 409 ALREADY_CHECKED_IN
- 항목의 `planned_at` 이 미래면 400 NOT_YET (옵션 — UX 게이트는 FE 에서 강제)

**대안 (Phase 2 후반 검토)**: FE 가 dot 생성 + 체크인을 한 번에 보내는 통합 endpoint
`POST /v1/todo-lists/:id/items/:itemId/check-in-with-dot`
— body 에 dot 필드 모두 포함 → BE 가 트랜잭션으로 dot 생성 + 링크. 멱등성 좋음.

---

### 11. DELETE /v1/todo-lists/:id/items/:itemId/check-in — 체크인 취소

**Auth**: required (owner)

`check_in_dot_id`, `checked_in_at` 을 NULL 로. Dot 자체는 보존 (사용자가 별도 삭제 가능).

**Response 200**: 갱신된 TodoItem.

---

### 12. POST /v1/todo-lists/:id/share-token — 공유 토큰 발급

**Auth**: required (owner)

**Request**: (옵션)
```json
{ "ttl_hours": 24 }
```
미지정 시 default = **24시간 (테스트 용)**. 추후 30일 등으로 변경 시 default 값만 조정.

**Response 201**:
```json
{
  "data": {
    "token": "ULID 또는 nanoid (>=20자)",
    "expires_at": "2026-05-15T00:00:00Z",
    "share_url": "https://app.dottie.kr/share/todo/{token}"
  }
}
```

**참고**:
- 토큰은 충분히 길게 (브루트포스 방지). ULID 또는 nanoid(21) 추천.
- 호출마다 새 토큰 발급 권장 (기존 토큰 자동 만료).

---

### 13. DELETE /v1/todo-lists/:id/share-token — 공유 해제

**Auth**: required (owner)

`share_token`, `share_token_expires_at` 모두 NULL 로.

**Response 204**.

---

### 14. GET /v1/public/todo-lists/:token — **비로그인 read-only 조회** ⚠️ 핵심

**Auth**: **NOT required** (AuthInterceptor 가 이 path 만은 Bearer 헤더 제외해야 함)

**Response 200**:
```json
{
  "data": {
    "id": "...",
    "name": "도쿄 4박5일",
    "cover_emoji": "🇯🇵",
    "start_date": "...",
    "end_date": "...",
    "owner_nickname": "재진",   // ★ owner_id 노출 X, 닉네임만
    "items": [...],           // 위 TodoItem 과 동일하지만 check_in_dot_id 는 hash 또는 boolean 으로 마스킹 권장
    "shared_at": "...",       // 공유 시작 시각 (UI 표시용, 옵션)
    "expires_at": "..."
  }
}
```

**Errors**:
- 404 NOT_FOUND — token 매칭 실패
- 410 GONE — token 만료 (TTL 지남)

**보안 고려**:
- 토큰 추측 방지: ULID/nanoid 충분히 길게.
- Rate limit: 같은 IP 에서 무차별 토큰 시도 차단.
- 응답 캐싱: short TTL (예: 60s) — BE 부하 절감.

---

## AuthInterceptor 화이트리스트 (FE 측 변경)

`/v1/public/*` 경로는 Bearer 헤더 안 붙도록 화이트리스트 처리 필요. 현재 FE 코드에서 `lib/core/network/api_client.dart` 의 `AuthInterceptor.onRequest` 에 추가:

```dart
final isPublic = options.path.startsWith('/public/');
if (isPublic) {
  // 비로그인 공유 경로 — Bearer 헤더 안 붙임.
  return handler.next(options);
}
// ... 기존 토큰 주입 로직
```

## 에러 코드

| HTTP | code | 설명 |
|---|---|---|
| 400 | INVALID_DATE_RANGE | end_date < start_date |
| 400 | NOT_YET | 미래 planned_at 항목 체크인 시도 (옵션) |
| 401 | UNAUTHORIZED | 인증 필요 |
| 403 | FORBIDDEN | 본인 소유 아님 |
| 404 | NOT_FOUND | id / token 매칭 실패 |
| 409 | ALREADY_CHECKED_IN | 이미 체크인된 항목 |
| 410 | GONE | 공유 토큰 만료 |
| 422 | INVALID_INPUT | 일반 validation 실패 |

## 타임존 규칙 (CLAUDE.md 일치)

- 모든 timestamp 는 **RFC3339 UTC** (`...Z` 접미사).
- `planned_at` 도 UTC 로 저장/응답. FE 가 표시 시 `.toLocal()` 변환.
- `start_date` / `end_date` 는 **date only** (`YYYY-MM-DD`). 타임존 무관, 사용자 OS 기준 날짜.

## 마이그레이션 노트

- 기존 dot/daylog 테이블 변경 없음.
- todo_lists, todo_items 신규 추가만.
- Dot 삭제 시 `todo_items.check_in_dot_id` 를 NULL 로 cleanup 하는 후처리 trigger 또는 service 로직 권장 (orphan 방지).

## Phase 3 차후 확장 (협업)

Phase 2 default 로 "공유받은 사용자는 같이 표시" 가정 (사용자 결정). 협업 모드는 다음 단계에서:

- `todo_lists.member_ids: list<text>` 추가
- 초대 코드 / 직접 사용자 검색으로 멤버 추가
- PATCH 권한을 멤버에게도 부여 (owner-only 항목 제외)
- 변경 시 알림 push

## 작업 우선순위 (BE)

| 우선순위 | 단계 | 범위 | 의존 |
|---|---|---|---|
| 🔴 P0 | **Phase 2.1** | Endpoint 1~9 (TodoList / TodoItem CRUD + reorder) | 없음 |
| 🟠 P1 | **Phase 2.2** | Endpoint 10, 11 (체크인 / 취소) + Dot 삭제 cleanup trigger | dots 테이블 |
| 🟡 P2 | **Phase 3.1** | Endpoint 12~14 (공유 토큰 + public read) | Phase 2.1 |
| ⚪ P3 (차후) | Phase 3.2 | 협업 / 멤버 모델 / 알림 | Phase 2 전체 |

각 단계 완료 후 FE 의 `todo_repository.dart` 의 `syncUnsynced` 메서드를 활성화하면 됨 (현재 stub).

## 작업 체크리스트 (BE 엔지니어용)

### Phase 2.1 (P0) — CRUD
- [ ] 마이그레이션: `todo_lists` + `todo_items` 테이블 생성. 인덱스 포함
- [ ] Endpoint 1 (POST /v1/todo-lists)
- [ ] Endpoint 2 (GET /v1/todo-lists) — items 비워서 가벼움
- [ ] Endpoint 3 (GET /v1/todo-lists/:id) — items 포함
- [ ] Endpoint 4 (PATCH /v1/todo-lists/:id)
- [ ] Endpoint 5 (DELETE /v1/todo-lists/:id) — CASCADE
- [ ] Endpoint 6 (POST /v1/todo-lists/:id/items)
- [ ] Endpoint 7 (PATCH /v1/todo-lists/:id/items/:itemId)
- [ ] Endpoint 8 (PUT /v1/todo-lists/:id/items/reorder) — transaction
- [ ] Endpoint 9 (DELETE /v1/todo-lists/:id/items/:itemId)

### Phase 2.2 (P1) — 체크인
- [ ] Endpoint 10 (POST .../check-in) — dot 소유권 검증
- [ ] Endpoint 11 (DELETE .../check-in)
- [ ] Dot 삭제 시 `todo_items.check_in_dot_id` NULL cleanup (trigger 또는 service)

### Phase 3.1 (P2) — 비로그인 공유
- [ ] Endpoint 12 (POST .../share-token) — ULID/nanoid 21자
- [ ] Endpoint 13 (DELETE .../share-token)
- [ ] **Endpoint 14 (GET /v1/public/todo-lists/:token)** — ⚠️ Auth 미들웨어에서 `/v1/public/*` 제외
- [ ] Rate limit: 같은 IP `/v1/public/*` 무차별 요청 차단
- [ ] 응답 캐싱 (선택, 60s TTL)

---

## FE 현재 작업 상태

- ✅ Phase 1 (로컬 only) 전부 완료.
- ✅ DB 스키마 v3 → v4 (TodoListTable + TodoItemTable 추가).
- ✅ Freezed 모델 (TodoList, TodoItem).
- ✅ Repository + Provider (체크인 / 재정렬 / CRUD).
- ✅ UI: 목록 / 생성 / 상세 (지도 탭 + 리스트 탭).
- ✅ TodoItemInputSheet, TodoItemDetailSheet, CheckInButton, StampAnimation.
- ✅ 메인 탭 검색 → 할일로 교체, 검색은 방 리스트 상단 아이콘으로 이동.
- ✅ Phase 2 — TodoRemoteSource + Repository BE 통합 완료. 14개 endpoint sync.
- ✅ Phase 3.1 — 공유 토큰 UI + 비로그인 라우트 + `share_plus` + `app_links`.
- ✅ **"갈곳 모음" 피벗 (2026-05)** — 기간/일자 UI 제거, 지도 메인 + 클러스터링, 컬렉션 selector. DB 스키마 변경 X.

---

## 11. BE 확인/작업 사항 (2026-05-15 기준)

이 섹션은 BE 엔지니어 핸드오프용 체크리스트. 현재 FE 가 BE 와 통신 시도 중인데 일부 endpoint 가 404 응답 — **실제 라우트 배포 상태 확인 필요**.

### ✅ 신규 작업 1건 — 완료 (2026-05-15)

#### 10. `GET /v1/places/search` — lat/lng 옵셔널화 — **완료**

**합의된 동작**:
| FE 흐름 | 호출 | BE / 카카오 동작 | 결과 |
|---|---|---|---|
| dot 기록 (500m 인증) | `?q=카페&latitude=37.5&longitude=127.0` | x/y/radius=500 전송 | 좌표 500m 반경 |
| 갈곳 추가 (국내 전국) | `?q=강남역` (좌표 미전달) | x/y/radius 모두 생략 | 카카오 키워드 한국 전역 |

**해외 검색은 보류** — 카카오 Local Search 한계로 "도쿄 타워" / "에펠탑" 등 0/빈약 결과. UI 에 "해외 미지원" 안내 표시 (FE 측 처리 완료).

**FE 후속 변경 (완료)**:
- `PlacesRemoteSource.search` — lat/lng `double?` 로 옵셔널화. null 이면 query 파라미터 자체 미포함
- `PlaceSearchSheet` — lat/lng nullable + 모드별 안내 문구 (좌표 있으면 "현재 위치 근처", 없으면 "국내 전국. 해외 미지원")
- 호출처 분기:
  - `TodoMapScreen._addItem` / `TodoItemInputSheet._pickPlace` → null 전달 (전국)
  - `DotInputSheet._pickPlace` → 좌표 그대로 (500m, 기존 인증 흐름)

**예시 호출**:
```bash
# 전국 검색 (좌표 없음)
GET /v1/places/search?q=시부야
→ 200: 도쿄 시부야 결과 (해외 포함)

GET /v1/places/search?q=강남역
→ 200: 강남역 / 강남역 인근 결과 (전국 어디든)

# 근처 검색 (좌표 있음 — 기존 동작)
GET /v1/places/search?q=카페&latitude=37.5&longitude=127.0
→ 200: 그 좌표 500m 내 카페만
```

**FE 후속 작업**: BE 옵셔널화 완료 후, FE 는 `PlaceSearchSheet` 의 lat/lng 를 nullable 화 + 갈곳 추가 시 null 전달 (`lib/features/cumulative_map/presentation/widgets/place_search_sheet.dart` + `lib/features/cumulative_map/data/places_remote_source.dart`).

---

### 🔵 점검 필요 (이전 완료 보고 했지만 404 발생 중)

지난 BE 작업 후 FE 가 `GET /v1/todo-lists` 호출 → 현재 **404 응답**. 라우트 미배포 또는 path prefix 미스매치 의심.

#### 1차 확인 — 인증 정상 동작
```bash
curl -H "Authorization: Bearer <id_token>" <API_URL>/users/me
# → 200 + 사용자 데이터 — 정상이라면 BE 자체는 동작, todo-lists 만 미배포
```

#### 2차 확인 — todo-lists 라우트 14개

| | endpoint | 메서드 | 비인증 | 점검 |
|---|---|---|---|---|
| 1 | `/v1/todo-lists` | POST | | [ ] |
| 2 | `/v1/todo-lists` | GET | | [ ] **현재 404** |
| 3 | `/v1/todo-lists/:id` | GET | | [ ] |
| 4 | `/v1/todo-lists/:id` | PATCH | | [ ] |
| 5 | `/v1/todo-lists/:id` | DELETE | | [ ] |
| 6 | `/v1/todo-lists/:id/items` | POST | | [ ] |
| 7 | `/v1/todo-lists/:id/items/:item_id` | PATCH | | [ ] |
| 8 | `/v1/todo-lists/:id/items/reorder` | PUT | | [ ] |
| 9 | `/v1/todo-lists/:id/items/:item_id` | DELETE | | [ ] |
| 10 | `/v1/todo-lists/:id/items/:item_id/check-in` | POST | | [ ] |
| 11 | `/v1/todo-lists/:id/items/:item_id/check-in` | DELETE | | [ ] |
| 12 | `/v1/todo-lists/:id/share-token` | POST | | [ ] |
| 13 | `/v1/todo-lists/:id/share-token` | DELETE | | [ ] |
| 14 | `/v1/public/todo-lists/:token` | GET | ✅ 비인증 | [ ] |

#### 빠른 verification 스크립트

```bash
TOKEN="<your-id-token>"
API="<your-api-url>"  # 예: https://api.dottie.kr/v1

# (a) 컬렉션 list — 가장 시급
echo "── GET /todo-lists ──"
curl -s -o /dev/null -w "%{http_code}\n" -H "Authorization: Bearer $TOKEN" "$API/todo-lists"
# 기대: 200

# (b) 컬렉션 생성
echo "── POST /todo-lists ──"
curl -s -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"name":"테스트","cover_emoji":"📍","start_date":"2026-05-15","end_date":"2076-05-15"}' \
  "$API/todo-lists" | head -c 300; echo
# 기대: 201 + 생성된 TodoList JSON

# (c) 공개 endpoint — Bearer 없이
echo "── GET /public/todo-lists/INVALID_TOKEN ──"
curl -s -o /dev/null -w "%{http_code}\n" "$API/public/todo-lists/invalidtoken000000"
# 기대: 404 (토큰 매칭 실패) — 401 이면 Auth 미들웨어가 /public/* 화이트리스트 안 됨
```

> **만약 (a) 가 404**: BE 측에서 `/v1/todo-lists` 핸들러가 라우터에 등록 안 됐을 가능성. main 브랜치에 머지되고 배포까지 됐는지 확인 필요.
>
> **만약 (c) 가 401**: BE Auth 미들웨어가 `/v1/public/*` 경로를 인증 면제 화이트리스트에 추가 안 함. 등록 필요.

---

### 🟢 FE 피벗으로 추가된 데이터 의미 변화 (BE 영향 없음 — 정보용)

피벗 후 FE 가 BE 에 보내는 값의 의미가 살짝 바뀜. BE 측 검증 로직이 이를 거부하지 않으면 OK:

| 필드 | 변화 | 확인 |
|---|---|---|
| `day_index` | 항상 `0` 으로 전달 (단일 list 모드) | 기존 검증의 `INVALID_DAY_INDEX` 가 0 거부하면 안 됨. 범위 `[0, end-start)` 안에 0 포함되니 자동 OK 일 것 |
| `planned_at` | 항상 `now()` 자동 (미래/과거 의미 없어짐) | BE 검증 X — 단순 timestamp 저장만 |
| `start_date` / `end_date` | 자동 `now()` ~ `now() + 50yr` (UI X) | 기존 검증 그대로 — 30일 초과 거절 (`DATE_RANGE_TOO_LONG`) 이 있다면 **이 제한 완화 또는 제거 필요** ⚠️ |
| 체크인 시 `planned_at` | 미래여도 인증 가능 | BE 가 `NOT_YET` (400) 던지면 안 됨. 옵션이었으므로 기본 비활성으로 두면 OK |

⚠️ **`DATE_RANGE_TOO_LONG` 제한 (기존 30일)** — FE 가 자동으로 50년 범위를 보냄. 이 검증을 *완화* 하거나 *제거* 필요. 그렇지 않으면 컬렉션 생성 자체가 422 로 실패.

---

### ⚪ 변경 없음 (이미 합의된 영역 — 점검 불필요)

- 응답 envelope `{"data": ...}`
- 데이터 모델 (TodoList / TodoItem 컬럼)
- 에러 코드 체계
- Share token TTL default 24h (테스트용)
- Public rate limit (60req/분/IP)
- Dot 삭제 시 `check_in_dot_id` NULL cleanup trigger

---

### 🚨 가장 시급한 P0

1. **`GET /v1/todo-lists` 가 404 인 원인 파악** — 라우트 배포 확인 또는 path prefix 확인
2. **`DATE_RANGE_TOO_LONG` 30일 제한 제거** — FE 가 50년 보내므로 컬렉션 생성 422 실패 위험
3. ~~`/v1/places/search` lat/lng 옵셔널화~~ — ✅ 완료 (2026-05-15, §10 참고)

위 2개가 풀리면 사용자 본인이 "갈곳 모음" 전체 흐름을 자기 디바이스에서 테스트 가능.
