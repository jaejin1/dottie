# 스팟(코스) 공유 심화 + 공개 디스커버리 — BE 핸드오프 문서

> **요약**: "스팟" 탭 = 코스(todo-lists) 기능. 이미 초대 협업(owner/member/viewer) + `room_id` 링크 + `share_token`/`is_imported` 까지 BE 에 갖춰져 있다. (주의: `visibility`/`tags`/`description`/`cover_image_url` 은 FE 로컬 전용, BE 미구현 — Phase 2 에서 BE 컬럼 신규 추가.) 이 위에 3단계로 (1) **방 멤버가 연결된 스팟을 자동으로 함께 편집**, (2) **코스 좋아요 + 공개 전환**, (3) **공개 코스 디스커버리/트렌딩**을 얹는다. 각 Phase 독립 배포 가능. FE는 Phase 1 준비 완료(아래 §9).

## 규약 (전 Phase 공통)

- 응답 envelope: `{ "data": ... }`. 리스트는 `{ "data": { "<items>": [...], "next_cursor": "..." } }`.
- 인증: Firebase ID Token `Authorization: Bearer`. 공개(no-auth) 엔드포인트는 명시.
- 타임스탬프: RFC3339 UTC.
- 페이지네이션: opaque cursor (기존 `/rooms/:id/cumulative-dots`, `/feed` 패턴 동일).
- 에러: `{ "error": { "code": "...", "message": "..." } }`.

---

## 1. 기획 컨텍스트

### 현재 상태 (이미 구현돼 있어 재사용)
- **스팟 = 코스**: `TodoList`(trip=여행일정 / collection=상시 모음) + `TodoItem`(갈 곳). 체크인으로 실제 Dot 생성.
- **협업**: `POST /todo-lists/:id/course-invite`(role), `POST /todo-lists/join`, `members[]`(role: owner/member/viewer). Room 초대 패턴 미러.
- **Room↔코스 링크**: `TodoList.room_id`(nullable), `PATCH /todo-lists/:id/room`, `GET /rooms/:id/todo-lists`. 한 방 → 여러 코스, 코스 → 최대 한 방.
- **공개 토대 (BE 실재)**: `share_token`(+ `/v1/public/todo-lists/:token` read-only preview), `is_imported`. 이 둘만 BE `todo_lists` 에 실제로 있음.
- ⚠️ **BE 미구현(FE 로컬 전용)**: `visibility` / `tags` / `description` / `cover_image_url` 는 **FE 모델·drift 로컬 테이블에만** 존재("v5 메타 정보 (BE 동기화 예정)")하고 **BE `todo_lists` 엔 없음**. → Phase 2 에서 **BE 컬럼으로 신규 추가**해야 함(단순 재사용 아님). `region` / `like_count` 도 신규.

### 목표
1. 코스가 방에 연결되면 **그 방의 모든 멤버가 별도 코스 초대 없이 함께 편집**(협업 완성).
2. 코스를 **공개**로 전환하고 **좋아요**를 받음(디스커버리 데이터 토대).
3. 공개 코스를 **지역·태그별 좋아요 랭킹**으로 탐색(트렌딩).

### 핵심 설계 결정 (확정)
| 결정 | 선택 | 이유 |
|---|---|---|
| 공개·트렌딩 단위 | **코스** (개별 장소 X) | "어떤 지역 어떤 여행일정" 트렌딩에 부합. 기존 course 모델 확장으로 끝남 |
| 방 멤버 권한 | **자동 editor 참여** | 별도 코스 초대 없이 "같이 쓰는" 경험 |
| 방 멤버십 저장 | **런타임 계산(effective)** — 데이터 복제 X | 방 join/leave 와 자동 동기화, 저장 grant 없음 |
| 명시 역할 우선순위 | **명시 course 역할 > room 파생 역할** | owner가 명시 viewer 지정한 사람을 room 때문에 editor로 승격 X |
| 좋아요 모델 | 코스당 유저 1표(`course_likes` UNIQUE) | 표준 |
| 복제 | 신규 `POST /todo-lists/:id/clone` (`is_imported=true`) | 공개 코스를 내 코스로 가져오기 |

---

## 2. Phase 1 — Room↔스팟 통합 (방 멤버 자동 편집)

**스키마 변경 없음.** effective membership 을 요청마다 계산한다.

### 접근 주체 정의
어떤 코스 C에 대해 사용자 U의 **접근 = editor** 조건:
```
U == C.owner_id
  OR U ∈ C.members (명시 course 멤버, 이때 역할은 members[].role 그대로 — viewer면 viewer)
  OR (C.room_id != null AND U ∈ members(C.room_id) AND U ∉ C.members)   ← room 파생 editor
```
- **명시 course 멤버십이 있으면 그 역할이 우선**(viewer면 viewer 유지). room 파생 editor는 **명시 멤버십이 없는** 방 멤버에게만 부여.

### 엔드포인트 변경
1. **`GET /v1/todo-lists`** (내 목록): 반환 집합에 `room_id ∈ (내가 멤버인 방)` 인 코스를 **추가**. (owner ∪ course-member ∪ room-linked)
2. **`GET /v1/todo-lists/:id`**: 위 접근 주체면 200. 각 코스 응답의 `members[]` 에 **room 파생 멤버를 role=`member`(editor)로 병합**해서 내려줄 것(권장). → FE `my_role`/`canEdit` 무변경 + 카드 멤버 표시 자연스러움.
   - 병합 시 각 멤버에 출처 구분이 필요하면 optional `"via": "room" | "course"` 추가(FE는 없어도 동작).
3. **write authz 확장** — 아래를 **editor(= 접근 주체)** 에게 허용:
   - `POST/PATCH/DELETE /v1/todo-lists/:id/items`, `PUT .../items/reorder`
   - `POST/DELETE .../items/:itemId/check-in`
   - `GET /v1/todo-lists/:id/route`
   - `PATCH /v1/todo-lists/:id` (코스 메타: name/dates/description/tags/cover 등)
4. **owner 전용 유지**(방 멤버여도 불가): `DELETE /v1/todo-lists/:id`(삭제), `PATCH .../room`(연결/해제), `POST .../course-invite`(초대), `DELETE .../members/:userId`(kick).
5. **회수**: `room_id` 를 null 로 바꾸거나(연결 해제) 사용자가 방을 leave/kick 당하면 room 파생 접근 즉시 소멸(요청마다 재계산이므로 자동).

### 엣지 결정 (확정)
- 방 멤버가 코스 **메타(name/dates 등)** 편집: **허용**(editor = 아이템+메타). ✅
- 방 멤버가 코스 삭제/연결해제/초대/kick: **불가**(owner-only). ✅
- 명시 viewer + 같은 방 멤버: **viewer 유지**(명시 course 역할 우선). ✅

### 역할 관리 권한 (별도 "room 관리자 override" 불필요)
- **연결 권한**: 코스의 `room_id` 설정(`PATCH /todo-lists/:id/room`)은 **코스 owner** 만, 그리고
  **본인이 멤버인 방**으로만 링크 가능. FE 링크 UI 는 room owner 가 *자기 소유 코스*를 방에
  연결하는 흐름이라, **실무상 (연결된 코스 owner) == (방 관리자)** 가 성립.
- 따라서 방 관리자가 특정 멤버를 그 코스에서 **뷰어로 제한**하고 싶으면, 기존 코스 역할
  시스템에서 그 사람을 **명시 viewer 로 지정**하면 되고 "명시 우선" 규칙이 이를 보장.
  → room 측에 별도 역할 변경 API 를 만들지 않는다(이중 권한 회피). 미래에 "코스 owner ≠ 방
  관리자" 케이스가 생기면 그때 재검토.

### 에러
- 접근 불가 코스 조회/편집: `403 NOT_COURSE_MEMBER` (기존 코드 재사용).
- owner 전용 작업을 editor가 시도: `403 NOT_COURSE_OWNER`.

---

## 3. Phase 2 — 코스 좋아요(하트) + 공개 전환

### 데이터 모델 (todo_lists 신규 컬럼 다수 — 아래 전부 BE 에 없음, 추가 필요)
- **`todo_lists.visibility`** (text, default `"private"`) — **BE 미존재, 신규**. 값 `"private"` / `"public"`. (FE 로컬엔 이미 있음 → 동기화만 맞추면 됨.)
- **`todo_lists.tags`** (text[] 또는 JSON, default `[]`) — **BE 미존재, 신규**. Phase 3 태그 필터용.
- **`todo_lists.description`** (text, nullable) — **BE 미존재, 신규**.
- **`todo_lists.cover_image_url`** (text, nullable) — **BE 미존재, 신규**(카드 커버).
- **`todo_lists.region`** (text, nullable) — **신규**. 대표 지역(예: "서울 마포구"). item 장소들의 최빈 시/구로 계산(아이템 변경 시 재계산). Phase 3 필터용.
- **`todo_lists.like_count`** (int, default 0) — **신규**. denormalized counter (like/unlike 시 ±1). 트렌딩 정렬 위해 컬럼 권장.
- **`course_likes`** 테이블 신규: `(course_id, user_id, created_at)`, `UNIQUE(course_id, user_id)`, FK course_id → todo_lists (ON DELETE CASCADE).
- ⚠️ `visibility`/`tags`/`description`/`cover_image_url` 4개는 이미 FE 모델·로컬 drift 에 존재하나 **BE round-trip 이 안 됨**(BE 가 이 필드를 저장/반환 안 함). 이번에 BE 저장·반환을 붙여야 FE 값이 서버에 실제 반영됨.

### 엔드포인트
1. **`POST /v1/todo-lists/:id/like`** — 좋아요. 멱등(이미 좋아요면 200 그대로). 응답:
   ```json
   { "data": { "like_count": 42, "liked_by_me": true } }
   ```
2. **`DELETE /v1/todo-lists/:id/like`** — 취소. 멱등. 응답: `{ "data": { "like_count": 41, "liked_by_me": false } }`.
3. **코스 응답 확장** (`GET /todo-lists`, `GET /todo-lists/:id`, discover, public): `like_count`(int), `liked_by_me`(bool) 추가.
4. **공개 전환 + 메타 저장**: `PATCH /v1/todo-lists/:id` 가 이제 `visibility`("public"|"private"), 그리고 신규 메타 `tags`/`description`/`cover_image_url` 도 수용·저장·반환. `visibility` 변경은 **owner-only**(나머지 메타는 editor).
5. **공개 코스 read**: `visibility == "public"` 이면 **비멤버도** `GET /v1/todo-lists/:id` read-only 허용(편집/아이템 API는 여전히 editor-only). `private` 코스를 비멤버가 조회 → `403 COURSE_NOT_PUBLIC`.
   - (기존 `/v1/public/todo-lists/:token` 은 유지 — 링크 공유용. 공개 코스는 id로도 열람 가능하게.)

### 권한
- 좋아요/취소: 그 코스를 **볼 수 있는 인증 사용자**(public 코스 또는 접근 주체). 비공개+비멤버 → 403.
- 공개 전환: owner-only.

### 좋아요 알림 (선택)
- 코스 owner에게 "N님이 회원님의 코스를 좋아합니다" 알림(기존 notifications 인프라 재사용). MVP에선 생략 가능.

---

## 4. Phase 3 — 공개 디스커버리 / 트렌딩

> **확정 결정 (3건)** — 착수 전 합의됨:
> 1. **트렌딩 = 미리 계산한 `trending_score` 컬럼 + keyset.** 라이브 pow() 계산 금지.
> 2. **region 필터 = 이번 보류.** discover 에 `region` 파라미터 넣지 않음. (Phase 3.5+ 좌표 reverse-geocode 로 국제 대응해 추가.)
> 3. **tags = 컬럼 추가 + tag 필터 지원.** (Phase 2 에서 미룬 `tags` round-trip 을 여기서 함께 붙임.)

공통: **모든 엔드포인트 인증 필수**(Firebase Bearer). 앱은 로그인 게이트라 비인증 진입 없음 → `liked_by_me` 항상 정확.

#### 4.1 `GET /v1/discover/courses` — 공개 코스 랭킹
- Query:
  - `sort` = `trending`(기본) | `new`
  - `tag` (optional, 단일 태그. tags 배열 contains) — 값은 FE 고정 taxonomy: `데이트`·`맛집`·`카페`·`가족여행`·`당일치기`·`액티비티`·`야경`·`여행`
  - `type` (optional) = `trip` | `collection`
  - `cursor` (opaque), `limit`(기본 20, **최대 50**)
  - ~~`region`~~ — **이번 제외**(결정 2). 응답엔 `region`(현재 null) 표시만 남김.
- **대상**: `visibility='public'` 코스만. **제외 규칙 변경(2026-08-03)**: 요청자가 **비-owner 멤버**(= 남이 만든 코스에 초대돼 참여 중)인 코스만 제외. **요청자 본인이 owner 인 공개 코스는 포함** — 작성자가 자기 공개 코스가 노출되는지 직접 확인/브라우징할 수 있도록. (기존 "owner 또는 member 제외" 에서 완화.)
  - 요약: `visibility='public' AND NOT (요청자가 이 코스의 non-owner member)`.
- 응답:
  ```json
  { "data": { "courses": [ {
      "id": "...", "name": "...", "cover_emoji": "🗼",
      "cover_image_url": "https://.../cover.jpg",
      "course_type": "trip", "region": null, "tags": ["카페","데이트"],
      "spot_count": 8, "like_count": 42, "liked_by_me": false,
      "owner_nickname": "다정", "owner_color_hex": "#FF9F45",
      "updated_at": "2026-08-01T10:00:00Z"
  } ], "next_cursor": "opaque_or_null" } }
  ```
  - **⚠️ 추가 요청(2026-08-03)**: 아래 2개 필드를 응답에 포함해 주세요. FE 는 이미 읽도록 돼 있어 내려주면 바로 반영됩니다.
    - `owner_color_hex` (string|null): **작성자 캐릭터 색 hex**(`users.character_config.color_hex`). 카드 아바타 색에 사용. 없으면 null → FE 가 accent 폴백. (지금 미전송이라 아바타가 작성자 색이 아닌 문제.)
    - `cover_image_url` (string|null): 코스 커버 사진 URL. 있으면 카드 상단 배경으로 렌더. → §3 "커버 이미지" 참고(신규 컬럼 + 소유자 업로드).
  - `owner_nickname` 필수. `spot_count`: 코스 아이템 수. **`items[]` 전체는 미포함**(카드용). 상세는 §3.5.
  - 빈 결과: `courses: []`, `next_cursor: null`. 잘못된 `type`/깨진 `cursor` → 400 `BAD_REQUEST`.
- **트렌딩 스코어 (결정 1 — 미리 계산):** `todo_lists.trending_score REAL` 컬럼 유지.
  - 값: `like_count / pow(age_hours + 2, 1.5)` (HN 스타일).
  - 갱신: (a) like/unlike 시 즉시 재계산, (b) cron 15~30분마다 age 감쇠 반영 배치(public 만).
  - 정렬/페이지: `sort=trending` → `(trending_score DESC, id DESC)` **keyset**(쿼리당 pow 없음, 세션 내 드리프트 없음). `sort=new` → `(created_at DESC, id DESC)` keyset.

#### 4.2 상세 (기존 재사용)
- `GET /v1/todo-lists/:id` — Phase 2 public read(§3.5) 그대로. 비멤버가 public 코스 200(read-only), 응답에 `owner_id`·`members[]`·`like_count`·`liked_by_me`·`is_imported` 포함 → FE 가 "clone 버튼 노출 여부"(내가 owner/member 가 아닐 때만)를 이걸로 판정.

#### 4.3 `POST /v1/todo-lists/:id/clone` — 가져오기(복제) [신규]
- Body: 없음 (또는 optional `{ "name": "..." }` — 미지정 시 원본 이름 그대로).
- 전제: 원본이 `public` 이거나 요청자가 접근 주체(member/owner). 아니면 **403 `COURSE_NOT_PUBLIC`**.
- 동작: 원본을 **요청자 소유 새 코스**로 복사.
  - 복사: `name`·`cover_emoji`·`cover_image_url`·`description`·`tags`·`course_type`·`start_date`/`end_date`, 그리고 **모든 items**(`latitude`/`longitude`/`place_*`/`day_index`/`order_in_day`/`notes`/`emotion`/`planned_at`).
  - 초기화/제외: `id` 신규, `owner_id`=나, `members=[나:owner]`, `room_id=null`, `visibility='private'`, `share_token=null`, `like_count=0`/`trending_score=0`, `is_imported=true`, **item 의 check-in 상태(`check_in_dot_id`/`checked_in_at`) 제외**(계획만 복사).
- 응답: **BE 최종 201** + 새 `TodoList`(items 포함, `is_imported:true`/`visibility:"private"`/`room_id:null`). FE 는 받은 id 로 상세 진입.
- 멱등 아님(호출마다 새 사본). FE 가 busy 가드로 중복 방지.

#### 4.4 `POST /v1/todo-lists/:id/report` — 신고 [신규]
- Body: `{ "reason": "스팸", "detail": "광고성 코스" }`. **BE 최종**: `reason` **자유 텍스트 필수 ≤100자**(enum 아님 — FE 는 한글 라벨 직송), `detail` 선택 ≤1000자.
- 전제: 그 코스를 볼 수 있는 인증 사용자(public 또는 접근 주체). 비공개+비멤버 → 403 `COURSE_NOT_PUBLIC`. 빈 reason/길이초과 → 400.
- 응답: `{ "data": { "success": true } }`(200). 같은 (user, course) 재신고는 **no-op 200**(멱등).
- 운영용 공개 코스 숨김/차단(관리자)은 별도 — 공개 런칭 전 최소 신고 수집 + 수동 숨김 경로만 확보.

#### 4.5 Rate limit (BE 최종)
- discover 60회/20s · clone 20회/5s · report 20회/5s. 초과 → 429 `RATE_LIMIT_EXCEEDED`.
- FE: discover 429 는 에러뷰(재시도), loadMore 429 는 조용히 중단, clone/report 429 는 스낵바.

#### 에러 코드 (Phase 3 추가)
| status | code | 상황 |
|---|---|---|
| 403 | `COURSE_NOT_PUBLIC` | 비공개 코스를 비멤버가 clone/report/조회 (Phase 2 재사용) |
| 400 | `BAD_REQUEST` | 잘못된 `sort`/`type`/`reason` 값, `limit`>50 |
| 404 | `TODO_LIST_NOT_FOUND` | 없는/삭제된 코스 clone/report |
| 429 | `RATE_LIMIT_EXCEEDED` | clone/report 과다 |

#### 4.6b 진행 상태 (2026-08-03 BE 회신 반영)
- ✅ **완료(배포 후 적용)**: `POST /media/upload` 에 선택 필드 `purpose`+`todo_list_id` 추가. `purpose=course_cover` 시 R2 키 `todo-lists/{id}/cover/{uuid}.{ext}`. 발급 조건: 요청자가 그 코스 멤버(owner/코스멤버/방연결 시 방멤버). 에러 `FORBIDDEN`(403)·`TODO_LIST_NOT_FOUND`(404)·`BAD_REQUEST`(400, todo_list_id 누락/알 수 없는 purpose)·`INVALID_ID`(400). dot 업로드는 무변경(하위호환). item_id/`course_item` 은 미구현.
  - FE: 커버 업로드가 `purpose=course_cover`+`todo_list_id` 전송(item_id 미전송) — **정합**. 업로드 에러는 `MediaUploadService` 가 null 반환 → "업로드 실패" 스낵바.
- ✅ **커버 저장 — 전용 엔드포인트 `PATCH /todo-lists/:id/cover` (BE 확정, 필드명 `cover_image_url` 확정)**:
  - 설정 `{ "cover_image_url": "<R2 public_url>" }` / 해제 `{ "cover_image_url": null }`. 응답 200 = 갱신된 코스(`cover_image_url` 포함). 권한 editor(owner/멤버/방멤버).
  - 업로드 시 **같은 `todo_list_id` 로 발급받은 R2 URL** 이어야 함(다른 코스·dot URL → 403). 에러 `INVALID_COVER_URL`(400)·`FORBIDDEN`(403)·`TODO_LIST_NOT_FOUND`(404).
  - 조회 응답 변경: `GET /todo-lists`·`GET /todo-lists/:id`·`GET /discover/courses` 카드에 `cover_image_url` 추가(없으면 null).
  - **FE 정합**: 편집 저장 시 (1) `upload(purpose=course_cover, todo_list_id)` → `public_url`, (2) 커버가 바뀐 경우에만 `PATCH /:id/cover { cover_image_url }`(설정/해제). 일반 `PATCH /:id`·create·sync 는 커버 미전송. `INVALID_COVER_URL` → "커버 이미지를 다시 업로드해 주세요" 스낵바. 로컬은 `remote.coverImageUrl ?? local` 로 보존(오프라인/전환기 방어).

#### 4.6 미디어 업로드 스코프 (R2 오브젝트 키) — BE 작업
현재 `POST /media/upload` 는 `{content_type, file_size}` 만 받아 presigned `upload_url`+`public_url` 을 돌려주고, **R2 키(경로)는 BE 가 결정**한다. 코스(스팟) 기준으로 이미지를 묶고 추후 항목 사진까지 담으려면, FE 가 **스코프 힌트**를 함께 보내니 BE 가 이를 이용해 키를 구성해 달라.

**FE 가 보내는 추가 필드**(있을 때만, 하위호환 — 없으면 기존 기본 위치):
```json
POST /v1/media/upload
{ "content_type": "image/jpeg", "file_size": 12345,
  "purpose": "course_cover", "todo_list_id": "<uuid>", "item_id": "<uuid?>" }
```
- `purpose`: `course_cover` | `course_item` | (dot 은 미전송)
- `todo_list_id`: 코스(스팟) id — 코스 기준 base
- `item_id`: 코스 내 항목 id — 항목 사진(추후)용

**제안 R2 레이아웃**(BE 최종 결정):
```
todo-lists/{todo_list_id}/cover/{uuid}.{ext}          ← 코스 커버/배경
todo-lists/{todo_list_id}/items/{item_id}/{uuid}.{ext} ← 항목 사진(추후)
dots/{user_id}/{uuid}.{ext} (또는 현행 유지)           ← dot 사진
```
- 권한: `purpose=course_*` 는 요청자가 그 코스 **owner/member(editor)** 여야 발급. 아니면 403.
- 코스 삭제 시 `todo-lists/{id}/*` 프리픽스 정리(비동기 GC) 권장.
- dot 은 스코프 미전송이라 **기존 동작 그대로**(변경 불필요).

> FE 는 이미 커버 업로드에 `purpose=course_cover`+`todo_list_id` 를 전송한다. BE 가 키만 이 규칙으로 구성하면 됨. 항목 사진 업로드 UI 는 추후.

---

## 5. 데이터 모델 변경 요약 (마이그레이션 순서)

| Phase | 변경 | 위험 |
|---|---|---|
| 1 | **없음** (authz 로직만) | 낮음 — 안전 |
| 2 | `todo_lists` 컬럼 신규 6개: `visibility`(default 'private'), `tags`, `description`, `cover_image_url`, `region`, `like_count`(default 0) + `course_likes` 테이블 신규 | 낮음 (전부 additive) |
| 3 | `todo_lists.trending_score REAL`(default 0) 컬럼 신규(결정 1) + discover 쿼리·인덱스, `tags` 필터(결정 3), clone/report 엔드포인트 | 중 |

권장 인덱스(Phase 3):
- `todo_lists(visibility, trending_score desc, id desc)` — `sort=trending` keyset.
- `todo_lists(visibility, created_at desc, id desc)` — `sort=new` keyset.
- tag 필터: `tags` 저장 방식에 맞춰 GIN(jsonb/array) 또는 조인 테이블 인덱스.
- `region` 인덱스는 이번 제외(결정 2).

---

## 6. 검증 시나리오

- **Phase 1**: 방 멤버(비-코스멤버) 계정 → `GET /todo-lists` 에 연결 코스 포함, 열람/아이템 추가/체크인 200. 명시 viewer 는 편집 403. `room_id=null` 또는 방 leave 후 그 코스 접근 403 + 목록에서 사라짐. owner 아닌 방 멤버의 삭제/초대 403.
- **Phase 2**: like → like_count +1, 재요청 멱등. unlike → -1. 공개 전환 후 비멤버 `GET /todo-lists/:id` 200(read-only), 아이템 편집 403. 비공개 코스 비멤버 조회 403 COURSE_NOT_PUBLIC.
- **Phase 3**: `discover?sort=trending` → `trending_score` 정렬(라이브 계산 아님), cron 갱신 후 순위 반영. `sort=new` 최신순. `tag`/`type` 필터(region 제외). cursor keyset — 같은 세션 내 페이지 드리프트 없음. **내가 owner 인 공개 코스는 내 둘러보기에도 노출**(비-owner 멤버 코스만 제외). clone → 내 소유 private 코스 생성(items 복사, 체크인 제외). report 200.

---

## 7. FE 대응 상태 (참고 — FE는 우리 쪽)

- **Phase 1**: 준비 완료. 리스트에 클라 멤버십 필터 없음, `my_role` 기본 `member`라 `canEdit` 이미 true, room 상세 "연결된 여행 계획" 전 멤버 개방. 코스 카드에 "🏠 방" 뱃지 추가 완료. **BE 배포만 되면 동작.**
- **Phase 2**: **FE 구현 완료** (확정 API 기준). `TodoList` 에 `like_count`/`liked_by_me`/`region` 필드 추가(codegen), drift `like_count`/`region` 컬럼 영속(schema v14). `POST`/`DELETE /todo-lists/:id/like` 연동, 코스 상세 AppBar 에 좋아요 버튼(공개 코스에서만 노출)+낙관적 토글, 편집 화면에 공개/비공개 토글(owner 진입 전용, `PATCH visibility`). 에러코드 `COURSE_NOT_PUBLIC`/`NOT_COURSE_OWNER` 처리. **"가져오기"(clone)는 Phase 3 로 이관** — 이번 BE 배포에 clone 엔드포인트 없고 Phase 2 엔 비멤버 진입점(디스커버리)도 없어 read-only 뷰어 게이트(FAB 숨김)로 충분. **BE 배포만 되면 동작.**
  - `tags` round-trip: **BE 배포 완료**(Phase 3 create/PATCH 수용 + 모든 응답 반환, 최대 10·각 20자·dedup). FE 편집화면은 5개·고정 taxonomy 로 제한(부분집합 — 무충돌). `description` 은 계속 FE 로컬 전용(BE 미저장).
- **Phase 3**: **FE 구현 완료** (BE 배포 전 선행 — discover 404 시 빈 목록 degrade). 신규 `lib/features/discover/` (DiscoverCourse 모델·DiscoverRemoteSource·DiscoverFeed 페이지네이션 provider·둘러보기 화면). 스팟 탭 AppBar "둘러보기"(explore) → `/todos/discover`. 정렬 인기/최신 토글 + 태그 칩(단일) + 2열 그리드 + 커서 무한스크롤 + 당겨 새로고침. 카드 탭 → `/todos/:id`(public read). 상세에 남의 공개 코스 방문자용 **가져오기(clone)+신고(⋯)** 액션, owner/member 아닌 public 코스에서만 노출. clone/report 는 `TodoRemoteSource`/`TodoRepository`/`TodoNotifier` 에 배선.
  - **BE 최종 계약 반영**: report `reason` 은 한글 라벨 자유텍스트 직송(enum 아님), clone 201, rate-limit 429 처리(discover 에러뷰 / loadMore 조용히 중단 / clone·report 스낵바).
  - **좋아요는 둘러보기 카드에서만**(인스타 방식) — 상세엔 좋아요 버튼 없음. 카드 하트 낙관적 토글(위젯 테스트 `test/features/discover/discover_like_test.dart` 로 회귀 방지).
  - **⚠️ BE 추가 요청 2건** (§4.1): discover 응답에 (1) `owner_color_hex`(작성자 캐릭터 색 — 현재 미전송이라 아바타가 카드별 accent 폴백), (2) `cover_image_url`(카드 배경 사진). FE 는 둘 다 이미 렌더 준비됨.
  - **커버 사진**: 소유자가 코스 편집 화면에서 업로드(image_picker → 기존 `/media/upload` presigned 재사용 → `cover_image_url`). create/PATCH `todo-lists` 에 `cover_image_url` 전송 추가. → **BE 가 컬럼 저장 + 모든 코스 응답·discover 에 반환** 해야 round-trip 완성.
  - **주의(FE 방어)**: `getTodoListById(id, viewerUid)` — 내가 owner/member 아닌 남의 공개 코스는 **로컬 drift 저장 skip**(안 하면 `getAllTodoLists` 경유로 내 스팟 목록에 잠깐 섞임). BE 무관, FE 캐시 정책.
  - **양쪽 배포 완료 시 검증**: discover 정렬/태그/페이지네이션, clone → 내 private 사본 생성 후 진입, report 접수.
