# Dottie 프로젝트 메모리

## 프로젝트 개요
- **앱명:** Dottie (도티) — "같은 하루, 다른 발자국"
- **타입:** Flutter 모바일 앱 (iOS/Android)
- **기술 스택:** Flutter 3.38.9 / Dart 3.10.8, Mapbox, Firebase Auth, Riverpod 2.x, drift
- **번들 ID:** com.dottie.dottie
- **스펙 파일:** `dottie-fe-spec.md`

## Phase 진행 상황
- ✅ **Phase 1 완료** — 코어 인프라 세팅
- ✅ **Phase 2 완료** — 기록 기능
- ⬜ Phase 3 — 지도 애니메이션
- ⬜ Phase 4 — 소셜 (방 & 공유)
- ⬜ Phase 5 — 폴리싱

## Phase 2 구현 파일 목록
- `lib/features/recording/data/location_service.dart` — geolocator 위치 수집
- `lib/features/recording/data/geocoding_service.dart` — Mapbox 역지오코딩
- `lib/features/recording/data/notification_service.dart` — 1시간 간격 알림
- `lib/features/recording/data/dot_local_source.dart` — drift CRUD
- `lib/features/recording/data/dot_remote_source.dart` — API 호출
- `lib/features/recording/data/dot_repository.dart` — 통합 레포지토리
- `lib/features/recording/domain/recording_session.dart` — 기록 세션 상태 (freezed)
- `lib/features/recording/presentation/recording_provider.dart` — ActiveRecording notifier
- `lib/features/recording/presentation/dot_input_sheet.dart` — dot 찍기 바텀시트
- `lib/features/recording/presentation/widgets/recording_fab.dart` — FAB
- `lib/features/timeline/presentation/timeline_provider.dart` — DayLog 목록 provider
- `lib/features/timeline/presentation/timeline_screen.dart` — 캘린더 + 리스트 뷰

## 중요 설정
- **Firebase:** `flutterfire configure` 실행 후 main.dart 주석 해제 필요
- **Mapbox 토큰:** `--dart-define=MAPBOX_ACCESS_TOKEN=...` 으로 주입
- **API URL:** `--dart-define=API_URL=http://localhost:8080/v1` (기본값)
- **코드 생성:** `dart run build_runner build --delete-conflicting-outputs`
- **ScreenUtil 기준:** 390x844 (iPhone 14)

## 알려진 패턴/주의사항
- `@riverpod` 함수에서 `Ref` 파라미터 사용 시 반드시 `flutter_riverpod` import 필요
- flutter_local_notifications 18.x: `zonedSchedule`에 `uiLocalNotificationDateInterpretation` 파라미터 필수
- `withOpacity` deprecated → `withAlpha` 사용
- android/app/build.gradle.kts: `isCoreLibraryDesugaringEnabled = true` + `desugar_jdk_libs` 의존성 설정됨

## 패키지 버전 (pubspec.yaml)
- mapbox_maps_flutter: ^2.5.0
- firebase_core: ^3.13.1, firebase_auth: ^5.5.2
- flutter_riverpod: ^2.6.1, riverpod_annotation: ^2.6.1
- go_router: ^14.8.1, dio: ^5.8.0+1
- drift: ^2.22.1, flutter_local_notifications: ^18.0.1, timezone: ^0.10.1
- freezed_annotation: ^2.4.4, geolocator: ^13.0.2

## Android/iOS 설정
- `android/app/src/main/AndroidManifest.xml` — 위치/알림/카메라 권한 추가됨
- `ios/Runner/Info.plist` — 위치/카메라/사진 권한 + 카카오 URL Scheme 추가됨