# BE 작업 요청 — 코스 유형(course_type) 서버 저장

> dottie-api · 2026-07-08
>
> 현재 `모음/여행` 구분은 FE 로컬 전용 필드라서 캐시 유실(재설치·DB 재생성·
> 공유받은 멤버 기기)마다 여행으로 초기화되는 버그가 있었음. FE 는 임시로
> "endDate 가 +50년 sentinel 이면 모음" 추론을 넣어둔 상태 — 서버 저장이 정석.

## 배경 (현재 동작)

- 모음(collection) 생성/수정 시 FE 가 `end_date = 생성일 + 50년` sentinel 저장
- 여행(trip)은 실제 여행 기간 저장
- `course_type` 자체는 BE 에 없음 → FE drift 로컬 DB 에만 저장
- FE 임시 추론: `endDate - startDate > 3650일 → 'collection'`
  (`lib/features/todo/data/todo_repository.dart` `_inferCourseType`)

## 1. 마이그레이션 (000021 제안)

```sql
ALTER TABLE todo_lists
    ADD COLUMN course_type VARCHAR(12) NOT NULL DEFAULT 'trip'
        CHECK (course_type IN ('trip', 'collection'));

-- 기존 데이터 백필 — sentinel(기간 10년 초과)이면 모음.
UPDATE todo_lists
SET course_type = 'collection'
WHERE end_date - start_date > 3650;
```

## 2. API 변경

### 요청 — Create / Update 에 `course_type` 추가 (옵션 필드)

```json
POST /v1/todo-lists          { ..., "course_type": "collection" }
PATCH /v1/todo-lists/:id     { ..., "course_type": "trip" }
```

- 생략 시: Create 는 `'trip'`, Update 는 기존값 유지
- `'trip' | 'collection'` 외 값 → 400 `BAD_REQUEST`

### 응답 — TodoListResponse 에 `course_type` 포함

모든 코스 응답(목록/상세/join/import/초대 preview)에:

```json
{ "id": "...", "name": "...", "course_type": "collection", ... }
```

## 3. FE 연동 계획 (BE 완료 후 내가 처리)

- `TodoList` 모델의 `courseType`에 `@JsonKey(name: 'course_type')` 연결
- create/update 요청에 `course_type` 전송
- `_inferCourseType` 추론 제거 (또는 구버전 BE 폴백으로 유지)
- sentinel(+50년) 저장은 당분간 유지 — 구버전 앱 호환. 추후 제거 검토

## 4. 참고 — 하는 김에 같이 하면 좋은 것 (선택)

- **description / tags / visibility 도 로컬 전용**임 (`todo_lists` 에 없음).
  FE drift 에만 저장되므로 같은 캐시 유실 시나리오에서 사라진다.
  코스 설명/태그를 서버에 저장하려면:
  ```sql
  ALTER TABLE todo_lists
      ADD COLUMN description TEXT,
      ADD COLUMN tags JSONB NOT NULL DEFAULT '[]',
      ADD COLUMN visibility VARCHAR(10) NOT NULL DEFAULT 'private';
  ```
  + Create/Update/응답 필드 추가. (FE 는 이미 create 요청에 description/tags/
  visibility 를 보내고 있어서 — BE 가 현재 무시 중 — 받기만 하면 됨)

## 완료 기준

1. 마이그레이션 적용 (배포 전 `make migrate-up` — deploy 는 마이그레이션 안 돌림 주의)
2. 모음 코스 생성 → GET 응답에 `"course_type": "collection"`
3. 기존 sentinel 코스(으으으 등)가 백필로 `collection` 조회되는지 확인
