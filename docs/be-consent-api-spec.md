# BE 작업 요청 — 약관 동의 수집·저장 API

> dottie-api · 2026-07-11
>
> 위치기반서비스 신고 요건: 동의는 위치 수집의 법적 근거이며, 동의 이력을
> 증빙 가능하게 보관해야 함. FE는 병렬로 구현 중 — 아래 응답 스펙만 맞으면
> BE 배포 즉시 게이트가 활성화됨 (미배포 상태에선 FE 게이트 자동 비활성).

## 1. 마이그레이션 (000022 제안) — 이력 보존형 (append-only)

```sql
CREATE TABLE user_consents (
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    doc_type    VARCHAR(20) NOT NULL
                  CHECK (doc_type IN ('terms','privacy','location','age14')),
    doc_version VARCHAR(10) NOT NULL,   -- '1.0'
    agreed_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_user_consents_user ON user_consents(user_id, doc_type, agreed_at DESC);
```

- **append-only** — 약관 개정 재동의 시 UPDATE 가 아니라 새 행 INSERT.
  신고·분쟁 대응 시 "언제 어떤 버전에 동의했는지" 이력이 증빙이 됨.
- 탈퇴 시 CASCADE 삭제 (개인정보 파기 원칙과 일치)

## 2. 서버 상수 — 필수 동의 문서·버전

```go
// 약관 개정 시 버전만 올리면 전 유저에게 재동의 게이트가 자동 작동.
var requiredConsents = map[string]string{ // doc_type → 필수 버전
    "terms":    "1.0", // 서비스 이용약관
    "privacy":  "1.0", // 개인정보처리방침
    "location": "1.0", // 위치기반서비스 이용약관
    "age14":    "1.0", // 만 14세 이상 확인
}
```

## 3. API

### 3-1. `UserResponse` 확장 (기존 응답에 필드 추가)

```go
type UserResponse struct {
    ...기존 필드...
    ConsentRequired bool `json:"consent_required"`
}
```

- 판정: 유저의 doc_type 별 **최신** 동의(`agreed_at DESC LIMIT 1`)의 버전이
  requiredConsents 4종과 모두 일치 → `false`, 하나라도 미동의/구버전 → `true`
- 적용 위치: `GET /v1/users/me` + `POST /v1/auth/login` 응답의 `user`
  (둘 다 `toUserResponse()` 경유하므로 한 곳 수정으로 커버 — 단 user 조회 시
  consents 조인/조회 1회 추가 필요)
- FE 는 이 필드 하나로 게이트 분기 — 추가 API 호출 없음

### 3-2. `POST /v1/users/me/consents` (인증 필수)

요청:
```json
{
  "consents": [
    { "doc_type": "terms",    "doc_version": "1.0" },
    { "doc_type": "privacy",  "doc_version": "1.0" },
    { "doc_type": "location", "doc_version": "1.0" },
    { "doc_type": "age14",    "doc_version": "1.0" }
  ]
}
```

- 검증: requiredConsents 의 **4종이 모두 포함 + 버전 일치** 아니면
  400 `{ "error": { "code": "CONSENT_INCOMPLETE", "message": "..." } }`
  (부분 동의 불가 — 전부 필수 문서)
- 처리: 각 항목 INSERT (append)
- 응답: `{ "data": { "consent_required": false } }`

### 3-3. (선택) `GET /v1/users/me/consents` — 운영/CS 용 동의 이력

```json
{ "data": [ { "doc_type": "terms", "doc_version": "1.0", "agreed_at": "..." }, ... ] }
```

## 4. 구현 참고

- 배선 패턴은 `notification_preferences` 와 동일:
  `db/queries/user_consents.sql` → sqlc → `internal/repository/consent_repo.go`
  → `internal/service/consent_service.go` → user_handler 에 라우트 추가
- sqlc 쿼리 제안:
  - `CreateUserConsent :one` (INSERT RETURNING)
  - `GetLatestUserConsents :many` — user 의 doc_type 별 최신 행:
    ```sql
    SELECT DISTINCT ON (doc_type) * FROM user_consents
    WHERE user_id = $1 ORDER BY doc_type, agreed_at DESC;
    ```
- **배포 순서**: 마이그레이션(`make migrate-up`) → deploy. (deploy 는
  마이그레이션을 안 돌리므로 순서 주의 — course_type 때와 동일)

## 5. FE 연동 상태 (참고)

- `DottieUser.consentRequired` — `consent_required` 파싱, **필드 부재 시 false**
  → BE 미배포여도 기존 로그인 흐름 그대로 (게이트 비활성)
- 로그인 성공 후 + 라우터 redirect 에서 `consent_required == true` → `/consent`
  동의 화면 강제 → 4종 체크 → 3-2 POST → 홈 진입
- FE 문서 버전 상수 `kConsentDocVersion = '1.0'` — requiredConsents 와 동기 유지
