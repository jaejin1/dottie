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

### freezed + JsonKey 규칙

BE는 snake_case 필드를 사용한다. freezed 모델에서 필드 이름 매핑 시 **`@JsonKey(name: 'snake_case')`를 개별 파라미터에 붙인다.**

```dart
// ✅ 올바른 방법 — 개별 @JsonKey
@freezed
class Room with _$Room {
  const factory Room({
    @JsonKey(name: 'owner_id') required String ownerId,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Room;
}

// ❌ 절대 사용 금지 — freezed와 중복 생성 충돌
@JsonSerializable(fieldRename: FieldRename.snake)
@freezed
class Room with _$Room { ... }
```

`@JsonSerializable(fieldRename:)` 를 freezed 클래스에 붙이면 `_$RoomFromJson` 함수가 중복 생성되어 `duplicate_definition` 컴파일 오류가 발생한다.

## 환경변수 (dart-define)

| 키 | 기본값 | 설명 |
|----|--------|------|
| `MAPBOX_ACCESS_TOKEN` | `''` | Mapbox 공개 토큰 |
| `API_URL` | `http://localhost:8080/v1` | 백엔드 API URL |
| `ENV` | `dev` | `dev` / `prod` |

## Firebase 설정

`firebase_options.dart`는 `flutterfire configure`로 생성 완료. `GoogleService-Info.plist`(iOS), `google-services.json`(Android) 모두 설정됨.

## 인증 흐름

소셜 로그인(카카오/Apple/Google) → OAuth 토큰 → Go 백엔드 `/auth/login` → Firebase Custom Token → `signInWithCustomToken`. Firebase ID Token은 `flutter_secure_storage`의 `firebase_id_token` 키에 저장되며 Dio `AuthInterceptor`가 자동으로 헤더에 주입.

## 오프라인 우선 전략

Dot은 로컬 drift DB에 먼저 저장(`synced=false`), 네트워크 가능 시 `/dots/batch`로 서버 동기화. `getUnsyncedDots()`로 미동기화 항목 조회.

## Android 빌드 주의

`flutter_local_notifications` 때문에 `android/app/build.gradle.kts`에 `isCoreLibraryDesugaringEnabled = true`와 `desugar_jdk_libs` 의존성이 필요. 이미 설정됨.

## BE API 연동 규칙

### 응답 언래핑

모든 BE 응답은 `{ "data": ... }` 로 감싸져 있다. 파싱 시 반드시 언래핑한다.

```dart
// ✅ 단일 객체
final json = (res.data['data'] ?? res.data) as Map<String, dynamic>;
return Model.fromJson(json);

// ✅ 리스트
final list = (res.data['data'] ?? res.data) as List;
return list.map((e) => Model.fromJson(e as Map<String, dynamic>)).toList();
```

`res.data` 를 직접 `Model.fromJson`에 넘기면 `owner_id` 같은 최상위 키를 찾지 못해 null / cast 오류가 발생한다.

### 타임스탬프 직렬화

BE는 RFC3339 형식을 요구한다. Dart `DateTime.toIso8601String()`은 타임존 없는 로컬 시간(`2026-04-30T15:30:10.000`)을 반환하므로 반드시 `.toUtc().toIso8601String()`을 사용한다.

```dart
// ✅ UTC 변환 후 직렬화 → "2026-04-30T15:30:10.000000Z"
'timestamp': dot.timestamp.toUtc().toIso8601String()

// ❌ 타임존 없는 로컬 시간 → BE에서 INVALID_TIMESTAMP 400 오류
'timestamp': dot.timestamp.toIso8601String()
```

서버에서 받은 타임스탬프는 `DateTime.parse()`로 파싱하면 `isUtc=true` 인 UTC DateTime 이 된다.

### 타임스탬프 표시 — 항상 사용자 OS 타임존으로 변환

**`DateFormat.format(dt)` 은 UTC DateTime 을 변환 없이 UTC 시각 그대로 출력한다.** BE가 보낸 `...Z` 타임스탬프를 그대로 포맷하면 한국 사용자에게도 UTC 시각이 보이는 버그가 생긴다.

화면 표시용 시간 포맷은 반드시 `DottieDateUtils` 의 `toTimeString` / `toDateString` / `toKoreanDate` 를 사용한다. 내부에서 `.toLocal()` 을 호출해 OS 타임존으로 변환해 포맷한다.

```dart
// ✅ DottieDateUtils 사용 — 자동으로 OS 타임존 변환
DottieDateUtils.toTimeString(comment.createdAt)  // 한국이면 KST, LA면 PST

// ❌ DateFormat 직접 사용 — UTC DateTime을 UTC 시각으로 출력
DateFormat('HH:mm').format(comment.createdAt)

// ✅ 직접 변환할 때도 .toLocal() 명시
'${dt.toLocal().hour.toString().padLeft(2, '0')}:${dt.toLocal().minute}'
```

`.toLocal()` 은 idempotent — 이미 local DateTime 이면 no-op. 항상 안전하게 호출 가능. Dart 가 디바이스 OS 타임존을 자동 사용하므로 사용자별 별도 설정 불필요.

### GeoJSON 직렬화

Dart `Map`을 Mapbox GeoJSON에 넘길 때 반드시 `jsonEncode()`를 사용한다.

```dart
// ✅
data: jsonEncode({'type': 'Feature', 'geometry': { ... }})

// ❌ — Dart Map.toString()은 유효한 JSON이 아님
data: myMap.toString()
```

## Mapbox 사용 규칙

### 스타일 로드 타이밍

`onMapCreated`는 스타일 로드 전에 발생한다. Source/Layer 추가는 반드시 `onStyleLoadedListener` 콜백에서만 한다.

데이터(Riverpod)와 스타일 로드 순서가 불확실하므로 **두 개의 플래그 + `ref.listen` 패턴**을 사용한다.

```dart
bool _styleLoaded = false;
bool _mapSetupDone = false;

// 스타일 로드 완료 시
onStyleLoadedListener: (_) async {
  _styleLoaded = true;
  await _trySetupMap();
},

// 데이터 도착 시
ref.listen(someProvider, (_, __) => _trySetupMap());

Future<void> _trySetupMap() async {
  if (_mapSetupDone || !_styleLoaded || _mapboxMap == null) return;
  final data = ref.read(someProvider);
  if (data == null) return;
  _mapSetupDone = true;
  // source / layer 추가
}
```

### 캐릭터 위치 표시

Flutter `Positioned` 오버레이 + `pixelForCoordinate()`로 캐릭터를 화면에 올리지 않는다. 비동기 변환 타이밍 문제로 위치가 틀리거나 빈 화면이 된다.

대신 **`addStyleImage` + `SymbolLayer`** 를 지리 좌표 기반으로 추가하고, 100ms 타이머로 `setStyleSourceProperty`를 호출해 GeoJSON 소스를 갱신한다. data-driven expression `'["get", "icon"]'`으로 상태별 이미지를 한 번에 교체한다.

```dart
// ① CharacterState마다 이미지 등록 — PNG 포맷 필수 (rawRgba는 Android에서 NPE)
final img = await CharacterRenderer.render(color: color, state: state, size: 120.0);
final byteData = await img.toByteData(format: ui.ImageByteFormat.png); // ← png
await map.style.addStyleImage('char-${state.name}', 2.0,
  MbxImage(width: 120, height: 120, data: byteData!.buffer.asUint8List()),
  false, [], [], null);

// ② GeoJSON source + data-driven SymbolLayer
await map.style.addSource(GeoJsonSource(id: 'char-src',
  data: jsonEncode({'type':'Feature','geometry':{'type':'Point','coordinates':[lng,lat]},
    'properties':{'icon':'char-idle'}})));
await map.style.addLayer(SymbolLayer(id: 'char-layer', sourceId: 'char-src',
  iconImage: '["get", "icon"]',   // data-driven: feature.properties.icon 값 사용
  iconAnchor: IconAnchor.BOTTOM, iconAllowOverlap: true, iconIgnorePlacement: true));

// ③ 100ms 타이머로 위치+상태 한 번에 갱신
await map.style.setStyleSourceProperty('char-src', 'data',
  jsonEncode({'type':'Feature','geometry':{'type':'Point','coordinates':[lng,lat]},
    'properties':{'icon':'char-walking'}}));
```

> **`ui.ImageByteFormat.rawRgba` 사용 금지.** Mapbox Android 플러그인 내부에서 `BitmapFactory.decodeByteArray()`로 디코딩하는데, raw RGBA는 PNG/JPEG가 아니라 null Bitmap → NPE 발생. 반드시 `ui.ImageByteFormat.png` 사용.

## 에러 핸들링 패턴

### Remote source — 오프라인 폴백 vs 서버 에러 구분

네트워크 오류(오프라인)는 null 반환으로 로컬 폴백하고, 서버가 실제 응답한 에러(4xx/5xx)는 re-throw해야 한다.

```dart
// ✅ 오프라인 폴백 O, 서버 에러 전파 O
Future<String?> startRecording(String date) async {
  try {
    final res = await _dio.post(...);
    return res.data['data']['id'] as String?;
  } on DioException catch (e) {
    if (e.response != null) rethrow; // 서버 응답 있음 → 호출자에게 전달
    return null;                     // 네트워크 오류 → 로컬 폴백
  }
}

// ❌ 모든 예외를 삼키면 409 같은 비즈니스 에러도 무시됨
Future<String?> startRecording(String date) async {
  try {
    ...
  } catch (_) {
    return null; // 409도 null로 처리 → 오류 없이 로컬 기록만 생성됨
  }
}
```

### Provider — 비즈니스 에러를 AsyncError로 올리지 않기

`AsyncValue.error`는 UI 전체를 에러 상태로 바꾼다(FAB 사라짐 등). 사용자에게 토스트/스낵바로 알릴 수 있는 예상 가능한 에러는 별도 Exception 클래스로 throw하고, state는 이전 정상 상태로 복원한다.

```dart
// ✅ 409 → state를 null로 복원 후 typed exception throw
} on DioException catch (e, st) {
  if (e.response?.statusCode == 409) {
    state = const AsyncValue.data(null); // FAB 유지
    Error.throwWithStackTrace(const AlreadyRecordingException(), st);
  }
  state = AsyncValue.error(e, st);
}

// FAB에서 catch해서 스낵바로 표시
try {
  await ref.read(provider.notifier).startRecording();
} on AlreadyRecordingException {
  ScaffoldMessenger.of(context).showSnackBar(...);
}
```

### drift — AppDatabase 싱글턴

`AppDatabase`를 `autoDispose` provider 안에서 직접 생성하면 provider가 재생성될 때마다 새 DB 인스턴스가 만들어져 "multiple databases" 경고 + 레이스 컨디션이 발생한다. 반드시 `keepAlive: true` 싱글턴으로 분리한다.

```dart
// ✅ keepAlive 싱글턴
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) => AppDatabase();

@riverpod
DotLocalSource dotLocalSource(Ref ref) =>
    DotLocalSource(ref.watch(appDatabaseProvider));

// ❌ autoDispose 안에서 직접 생성
@riverpod
DotLocalSource dotLocalSource(Ref ref) =>
    DotLocalSource(AppDatabase()); // 매 호출마다 새 DB 인스턴스
```

## Flutter/Dart 패턴 주의

### Dialog context

`showDialog`의 `builder` 안에서 `Navigator.pop`을 호출할 때 반드시 builder 전용 context를 사용한다.

```dart
// ✅
showDialog(
  context: context,
  builder: (dialogContext) => AlertDialog(
    actions: [
      TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text('취소')),
    ],
  ),
);

// ❌ — 외부 context로 pop하면 GoRouter 스택을 잘못 건드려 assertion 오류 발생
builder: (_) => AlertDialog(
  actions: [TextButton(onPressed: () => Navigator.pop(context), ...)],
),
```
