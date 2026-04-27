# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 앱 개요

Dottie — 하루 동안의 위치를 시간별로 기록(dot)하고, 지도 위에 캐릭터가 움직이는 애니메이션을 자동 생성하는 Flutter 앱. 전체 기능 스펙과 Phase별 개발 계획은 `dottie-fe-spec.md`를 참조한다.

## Agent Skills 구조

이 프로젝트에는 `.claude/` 아래 재사용 가능한 skills, agents, commands, references가 구성되어 있다. **새 작업을 시작하기 전에 반드시 `.claude/agents/README.md`를 읽어 agents 사용 방법과 orchestration 패턴을 숙지한다.**

```
.claude/
├── agents/         → 전문 페르소나 (code-reviewer, test-engineer, security-auditor)
│   └── README.md   → ⚠️ 반드시 읽기 — 페르소나 사용 규칙 및 orchestration 패턴
├── commands/       → 슬래시 커맨드 (/spec, /plan, /build, /test, /review, /ship)
├── skills/         → 단계별 워크플로우 스킬 (SKILL.md per directory)
└── references/     → 보조 체크리스트 (testing, performance, security, accessibility)
```

### Skills by Phase

| Phase | Skills |
|-------|--------|
| **Define** | `spec-driven-development` |
| **Plan** | `planning-and-task-breakdown` |
| **Build** | `incremental-implementation`, `test-driven-development`, `context-engineering`, `source-driven-development`, `frontend-ui-engineering`, `api-and-interface-design` |
| **Verify** | `debugging-and-error-recovery` |
| **Review** | `code-review-and-quality`, `code-simplification`, `security-and-hardening`, `performance-optimization` |
| **Ship** | `git-workflow-and-versioning`, `ci-cd-and-automation`, `documentation-and-adrs`, `shipping-and-launch` |

### Agents 사용 규칙 요약

- **페르소나는 다른 페르소나를 호출하지 않는다.** 조합은 슬래시 커맨드나 사용자가 담당한다.
- 단일 관점의 리뷰 → 페르소나 직접 호출 (예: "이 PR 리뷰해줘" → `code-reviewer`)
- 독립적인 병렬 조사 → `/ship` (code-reviewer + security-auditor + test-engineer 동시 실행)
- 순서가 필요한 작업 → `/spec` → `/plan` → `/build` → `/test` → `/review` 순차 실행

> 자세한 orchestration 패턴과 decision matrix는 `.claude/agents/README.md` 참조.

## 주요 명령어

```bash
# 앱 실행 (Mapbox 토큰 필수)
flutter run --dart-define=MAPBOX_ACCESS_TOKEN=<token>

# 코드 생성 (freezed / riverpod_generator / drift 모델 변경 후 반드시 실행)
dart run build_runner build --delete-conflicting-outputs

# 정적 분석
flutter analyze

# 테스트
flutter test
flutter test test/path/to/test.dart  # 단일 파일
```

## 아키텍처

`features/` 아래 기능별 슬라이스 구조. 각 feature는 `data/` → `domain/` → `presentation/` 레이어를 따른다.

```
lib/
├── core/
│   ├── config/        # AppConfig (dart-define), MapboxConfig
│   ├── constants/     # DottieColors, Dimensions
│   ├── database/      # drift AppDatabase (DotTable, DayLogTable)
│   ├── network/       # Dio ApiClient (AuthInterceptor), ApiEndpoints
│   ├── router/        # GoRouter + AppRoutes 상수
│   ├── theme/         # AppTheme.light
│   └── utils/
├── features/
│   ├── auth/          # Firebase Auth, 소셜 로그인, DottieUser
│   ├── recording/     # Dot 수집 (알림 → 위치 1회 수집 방식)
│   ├── timeline/      # DayLog 목록, 캘린더 뷰
│   ├── map_animation/ # 핵심 화면 — 캐릭터가 dot을 시간순으로 이동
│   ├── room/          # 공유 방 CRUD
│   ├── shared_map/    # 멀티 캐릭터 합본 지도
│   ├── character/     # 캐릭터 커스터마이징
│   └── settings/
└── shared/
    ├── widgets/       # DottieButton, DottieAppBar, LoadingIndicator
    └── extensions/    # ContextExtensions
```

## 코드 생성 규칙

- 모델 클래스는 **freezed** + **json_serializable** 사용. `part '*.freezed.dart'`와 `part '*.g.dart'`를 선언해야 함.
- Riverpod provider는 **riverpod_generator** (`@riverpod` 어노테이션). `part '*.g.dart'` 필요.
- drift DB 테이블 변경 시 `schemaVersion` 증가 + 마이그레이션 작성.
- `.freezed.dart`, `.g.dart` 파일은 직접 수정하지 않는다.

## 환경변수 (dart-define)

| 키 | 기본값 | 설명 |
|----|--------|------|
| `MAPBOX_ACCESS_TOKEN` | `''` | Mapbox 공개 토큰 |
| `API_URL` | `http://localhost:8080/v1` | 백엔드 API URL |
| `ENV` | `dev` | `dev` / `prod` |

## Firebase 설정

`firebase_options.dart`가 아직 없음. 사용 전 `flutterfire configure` 실행 필요. 그 전까지 `main.dart`의 Firebase 초기화 코드는 주석 처리된 상태.

## 인증 흐름

소셜 로그인(카카오/Apple/Google) → OAuth 토큰 → Go 백엔드 `/auth/login` → Firebase Custom Token → `signInWithCustomToken`. Firebase ID Token은 `flutter_secure_storage`의 `firebase_id_token` 키에 저장되며 Dio `AuthInterceptor`가 자동으로 헤더에 주입.

## 오프라인 우선 전략

Dot은 로컬 drift DB에 먼저 저장(`synced=false`), 네트워크 가능 시 `/dots/batch`로 서버 동기화. `getUnsyncedDots()`로 미동기화 항목 조회.

## Android 빌드 주의

`flutter_local_notifications` 때문에 `android/app/build.gradle.kts`에 `isCoreLibraryDesugaringEnabled = true`와 `desugar_jdk_libs` 의존성이 필요. 이미 설정됨.
