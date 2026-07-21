# BE 작업 요청 — 약관 정적 페이지 호스팅

> dottie-api · 2026-07-11
> HTML 파일 3종은 완성본으로 함께 전달 (`docs/legal/html/`). 서빙 라우트만 추가하면 됨.

## 목적

- FE 동의 게이트/설정 탭의 "보기" 링크가 이 URL들을 가리킴 (이미 구현·대기 중)
- App Store / Play 제출 시 Privacy Policy URL 필수 입력란에 사용
- 위치기반서비스사업 신고 서류에 약관 URL/사본 첨부

## 라우트 (3개, 인증 불필요·공개)

| URL | 파일 |
|-----|------|
| `GET /terms` | `terms.html` (서비스 이용약관) |
| `GET /privacy` | `privacy.html` (개인정보처리방침) |
| `GET /location-terms` | `location-terms.html` (위치기반서비스 이용약관) |

- 도메인: `https://app.dottie.today` 기준 (FE `AppConfig.webHost` 와 일치)
- **v1 API prefix 밖**, 인증 미들웨어 밖에 등록 (비로그인 접근 필수 — 스토어 심사봇이 접근함)

## 구현 제안 (Go echo)

HTML 3개를 바이너리에 embed 하면 배포 파일 관리가 없어 가장 간단:

```go
//go:embed static/legal/*.html
var legalFS embed.FS

// server.go 라우트 등록부 (authMW 밖)
e.FileFS("/terms", "static/legal/terms.html", legalFS)
e.FileFS("/privacy", "static/legal/privacy.html", legalFS)
e.FileFS("/location-terms", "static/legal/location-terms.html", legalFS)
```

- 파일 위치 제안: `internal/server/static/legal/` (embed 경로에 맞게 조정)
- Content-Type 은 echo 가 .html 로 자동 설정
- 캐시: 기본값으로 충분 (약관 개정이 잦지 않음). 개정 시 재배포로 갱신

## HTML 파일

- `docs/legal/html/terms.html` / `privacy.html` / `location-terms.html`
- self-contained (외부 CSS/JS 없음, 모바일 대응) — 그대로 복사해서 사용
- **`[대괄호]` 플레이스홀더 채운 뒤 배포할 것**:
  - 공통: `[상호명]` `[대표자명]` `[사업장 주소]` `[사업자등록번호]` `[이메일 주소]` `[시행일]`
  - location-terms: `[신고 완료 후 기재]` (위치기반사업 신고번호 — 신고 전 배포 시 "신고 접수 중" 등으로 표기 가능)

## 배포 순서 (중요)

1. 플레이스홀더 채우기 (사업자등록 완료 후)
2. **이 정적 페이지 배포** ← FE 빌드 6 배포보다 먼저
3. FE 빌드 6 배포 → 동의 게이트 활성화 (게이트의 "보기" 링크가 살아있어야 동의 유효성 확보)

## 확인 방법

- 비로그인 브라우저에서 `https://app.dottie.today/terms|privacy|location-terms` 3개 열림
- 모바일 화면에서 표(개인정보처리방침 국외이전 표)가 깨지지 않는지
