# BE 작업 요청 — 소셜 계정 통합·연결(Account Linking) API

> dottie-api · 2026-07-11
>
> 목표: 카카오·네이버·애플·구글 4종 로그인을 **"같은 나(1 user)"** 로 인식하고,
> 설정에서 연결된 로그인 방식을 조회·연결·해제할 수 있게 한다.
>
> **현재 문제**: 애플·구글은 Firebase 네이티브 provider라 "이메일당 1계정"으로
> 자동 병합되지만, 카카오는 BE custom token 으로 **별도 유저**가 만들어져 분리된다.
> 네이버(예정)도 Firebase provider가 아니라 동일 문제. → **신원(identity) 소유권을
> Firebase 이메일 병합이 아니라 BE로 통일**해야 4종을 일관되게 묶을 수 있다.

## 설계 원칙

1. **신원은 BE가 소유** — 모든 로그인이 `/auth/login`을 거쳐 BE가 provider 신원을
   내부 user에 매핑하고 **Firebase custom token**을 발급한다. (애플·구글도 카카오처럼
   custom token 방식으로 통일 — 아래 §4)
2. **명시적 연결(explicit linking)** — 자동 이메일 병합은 쓰지 않는다. 이유:
   - 애플 "이메일 가리기" → relay 이메일이라 구글과 이메일이 달라 자동병합 불가.
   - 검증 안 된 이메일 자동병합은 **계정 탈취** 위험.
   - 카카오·네이버는 Firebase 이메일 병합 자체가 안 됨.
   → 연결은 **이미 로그인한 본인**이 설정에서 추가하는 방식만 허용.
   → 연결하려는 소셜 계정이 **이미 데이터 있는 별도 계정(B)** 이면, **명시적 경고+확인
     후 B 를 파괴적으로 삭제**하고 로그인만 흡수한다(§3-3, §4-1). 조용한 삭제·자동
     흡수는 금지.
3. **Firebase Console 설정**: Authentication → Settings → **"Multiple accounts per
   email address"** 로 변경 (이메일 자동병합 끔 — 신원 병합은 BE가 담당).

## 1. 마이그레이션 (000023 제안)

```sql
-- 기존 users 는 내부 유저(=" 나"). 그대로 사용.
-- 로그인 방식(provider identity)을 별도 테이블로 분리.
CREATE TABLE user_identities (
    id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    provider         VARCHAR(10) NOT NULL
                       CHECK (provider IN ('kakao','naver','apple','google')),
    provider_user_id TEXT NOT NULL,          -- provider 고유 ID (sub/id)
    email            TEXT,                    -- 참고용 (병합 키로 쓰지 않음)
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- 같은 provider 계정은 전 서비스에서 한 user 에만 연결 가능
    UNIQUE (provider, provider_user_id)
);
CREATE INDEX idx_user_identities_user ON user_identities(user_id);
```

- **기존 데이터 백필**: 현재 users 각각에 대해, 가입에 쓴 provider 로 identity 1행 생성.
  (users 에 기존 provider/provider_user_id 컬럼이 있으면 그걸로, Firebase UID 기반이면
  Firebase 에서 provider 조회하여 채움.) 백필 후 앱은 재로그인 없이 동작.
- 탈퇴 시 CASCADE 삭제.

## 2. Provider 토큰 검증 (BE가 각 provider 토큰을 서버 검증)

`/auth/login`·`/auth/identities` 요청의 `token`을 provider별로 검증해
`provider_user_id`(고유 ID) + `email`을 추출:

| provider | 받는 값 | 검증 방법 | provider_user_id |
|---|---|---|---|
| kakao | access token | `GET https://kapi.kakao.com/v2/user/me` (Bearer) | 응답 `id` |
| naver | access token | `GET https://openapi.naver.com/v1/nid/me` (Bearer) | 응답 `response.id` |
| apple | identity token(JWT) + authorization code | Apple 공개키로 JWT 서명·`aud`(번들ID/Service ID)·`exp` 검증 | JWT `sub` |
| google | id token(JWT) | Google tokeninfo 또는 공개키로 검증, `aud`=우리 client id | JWT `sub` |

- 검증 실패 → `401 UNAUTHORIZED`.
- 애플은 `sub`가 **앱마다 고정·유저마다 고유**하므로 안정적 키. 이메일은 첫 로그인만 오니
  키로 쓰지 말 것(§설계원칙 2).

## 3. API

### 3-1. `POST /v1/auth/login` (인증 불필요) — 로그인/가입

요청:
```json
{ "provider": "kakao|naver|apple|google", "token": "<provider token>",
  "authorization_code": "<apple 만>" }
```

처리:
1. provider 토큰 검증 → `(provider, provider_user_id, email)`.
2. `user_identities` 에서 `(provider, provider_user_id)` 조회:
   - **있으면** → 그 `user_id`.
   - **없으면** → 신규 `users` 생성 + `user_identities` 1행 생성.
3. 그 user 의 **Firebase custom token** 발급.

응답:
```json
{ "data": {
    "firebase_custom_token": "<token>",
    "user": { ...UserResponse..., "is_new": true }
} }
```

- `is_new`: 이번에 새로 만든 user 면 true (FE 온보딩 분기용, 선택).
- FE는 `firebase_custom_token` 으로 `signInWithCustomToken`.

### 3-2. `GET /v1/users/me/identities` (인증 필수) — 연결된 계정 목록

```json
{ "data": [
    { "provider": "google", "email": "me@gmail.com", "connected_at": "2026-07-01T..." },
    { "provider": "apple",  "email": null,           "connected_at": "2026-07-11T..." }
] }
```

- 설정 "연결된 계정" 화면이 이걸로 provider별 연결 상태 표시.

### 3-3. `POST /v1/users/me/identities` (인증 필수) — 계정 연결

요청:
```json
{ "provider": "...", "token": "...", "authorization_code": "<apple>",
  "replace_existing": false }
```

처리 (2단계: 경고 → 확인):
1. **현재 로그인 user(A)** 확인 (Authorization 헤더).
2. provider 토큰 검증 → `(provider, provider_user_id)`.
3. `user_identities` 에 그 `(provider, provider_user_id)` 가:
   - **미연결** → A 에 identity 추가 → `200`, 갱신된 목록.
   - **이미 A 에 연결** → `200` (멱등).
   - **다른 user(B) 에 연결**:
     - B 가 **다른 멤버 있는 공유 room 의 owner** → `409 OWNS_SHARED_ROOM`
       (통합 시 타인 방이 소멸하므로 차단 — §4-1 참고). **흡수 불가.**
     - `replace_existing != true` (기본) → `409 IDENTITY_ALREADY_LINKED` +
       바디에 B 요약을 실어 FE 가 파괴적 확인 다이얼로그를 띄우게 함:
       ```json
       { "error": { "code": "IDENTITY_ALREADY_LINKED",
         "target": { "has_data": true,
                     "summary": { "dot_count": 42, "room_count": 3 } } } }
       ```
     - `replace_existing == true` (사용자가 경고 확인 후 재전송) →
       **B 계정 전체 삭제(§4-1 CASCADE) + 해당 identity 를 A 로 재귀속** →
       `200`, 갱신된 목록. (아래 원자성 주의)

> **원자성**: `replace_existing` 처리는 **단일 트랜잭션**으로
> (identity 를 A 로 UPDATE + user B 삭제) 처리. 중간 실패 시 전부 롤백.
> "로그인만 흡수, A 데이터 유지, B 데이터 파기" — A 의 dot/room 등은 그대로 둔다.

### 3-4. `DELETE /v1/users/me/identities/:provider` (인증 필수) — 연결 해제

- 처리: U 의 해당 provider identity 삭제.
- **가드**: 마지막 남은 1개는 삭제 불가 → `409 LAST_IDENTITY`
  (로그인 수단이 0개가 되면 계정 접근 불가 — 반드시 1개 이상 유지).

### 3-5. `UserResponse` — 변경 없음 (참고)
기존 필드 유지. 연결 상태는 §3-2 별도 조회.

## 4-1. B 계정 흡수 시 삭제 범위 & 방장 엣지

`replace_existing == true` 로 B 를 흡수할 때 **B 소유 데이터 전부 CASCADE 삭제**:
- B 의 `user_identities` 행(재귀속되는 1개 제외), `dots`, `day_logs`, `todo_lists`/
  `todo_items`, room **멤버십**, 알림/동의 등 B.user_id 에 매인 모든 행.
- A 의 데이터는 **일절 건드리지 않음** (로그인 수단만 흡수).

**⚠️ room 소유권 방어**: B 가 **owner 인 room 에 B 외 다른 멤버가 있으면**, B 삭제가
그 방을 소멸/고아화시켜 **타인에게 피해**를 준다. 그러므로:
- 이 경우 흡수를 **차단** → `409 OWNS_SHARED_ROOM`.
- 사용자가 그 방을 넘기거나(방장 위임) 정리한 뒤 다시 시도하도록 안내.
- 혼자만 있는 방 / B 가 멤버로만 참여한 방은 정상 삭제 대상.

## 4. FE 연동 계획 (BE 완료 후 처리)

- **애플·구글 로그인 방식 통일**: 현재 `signInWithCredential`(네이티브) →
  카카오처럼 **provider 토큰을 `/auth/login`에 보내고 `firebase_custom_token` 받아
  `signInWithCustomToken`** 으로 변경. (`auth_provider.dart` loginWithApple/Google)
  - 애플: `identityToken` + `authorizationCode` 를 BE로. (nonce 검증은 BE가 JWT로)
  - 구글: `idToken` 을 BE로.
- **네이버 로그인 추가**: `loginWithNaver` (네이버 SDK → access token → `/auth/login`).
- **설정 "연결된 계정" 화면**: `GET /identities` 로 목록, provider별 "연결/해제" 버튼.
  - 연결: 해당 provider 로그인 플로우 → 토큰 → `POST /identities`.
  - 해제: `DELETE /identities/:provider` (마지막 1개면 버튼 비활성).
- **에러 처리**:
  - `409 IDENTITY_ALREADY_LINKED` → **파괴적 확인 다이얼로그**:
    "이 [카카오] 계정에는 기록 N개가 있어요. 지금 계정에 연결하면 그 기록은
    **삭제되며 되돌릴 수 없어요.** 계속할까요?" (바디 `target.summary` 로 N 표시) →
    확인 시 `replace_existing: true` 로 재요청.
  - `409 OWNS_SHARED_ROOM` → "공유 중인 방의 방장이라 통합할 수 없어요. 방을 정리하거나
    방장을 넘긴 뒤 다시 시도해주세요." (흡수 불가, 재요청 없음).
  - `409 LAST_IDENTITY` → "마지막 로그인 수단은 해제할 수 없어요".

## 5. 마이그레이션 순서 (무중단)

1. `user_identities` 테이블 + 백필 배포 (읽기 안 함, 안전).
2. `/auth/login` 을 identity 기반으로 전환 + `/identities` 3종 배포.
3. Firebase Console "Multiple accounts per email address" 로 변경.
4. FE: 애플·구글을 custom token 방식으로 전환 배포 + 설정 연결 화면.
   - **주의**: 3번(이메일 자동병합 끔)은 FE가 custom token 방식으로 넘어온 뒤 켜야
     기존 애플·구글 유저의 UID 연속성이 깨지지 않음. 백필에서 기존 Firebase UID를
     user 에 보존해 custom token 발급 시 **동일 UID** 로 minting 하면 무중단.

## 완료 기준
1. 4종 provider 로그인이 모두 `/auth/login` → custom token 경유, 같은 소셜 계정은 항상 같은 user.
2. 설정에서 연결 목록 조회 + 연결/해제 동작 (마지막 1개 보호).
3. 기존 데이터 계정 흡수: 경고·확인(`replace_existing`) 후 B 파괴적 삭제 + 로그인만 A로 이전,
   A 데이터 보존. 공유 방 방장(B)인 경우 `409 OWNS_SHARED_ROOM` 차단.
4. 기존 유저 재로그인 없이 동작 (UID·데이터 연속성 유지).
