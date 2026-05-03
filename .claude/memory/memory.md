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
- ✅ **Phase 3 완료** — 지도 애니메이션
- ✅ **Phase 4 완료** — 소셜 (방 & 공유)
- ✅ **Phase 5 완료** — 폴리싱

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

## Phase 3 구현 파일 목록
- `lib/features/map_animation/domain/animation_frame.dart` — CharacterState enum, AnimationFrame/Sequence (freezed)
- `lib/features/map_animation/data/animation_builder.dart` — AnimationBuilder.build(dots), interpolate(seq, progress), 250ms/실제분
- `lib/features/map_animation/presentation/animation_provider.dart` — AnimationController (Ticker 기반), PlaySpeed x1/x2/x4
- `lib/features/map_animation/presentation/map_animation_screen.dart` — Mapbox 전체화면 + LineLayer 궤적 + Stack 캐릭터 오버레이 + AnimationControls
- `lib/features/map_animation/presentation/widgets/character_overlay.dart` — CharacterOverlayWidget + _CharacterPainter (bounce 애니메이션)
- `lib/features/map_animation/presentation/widgets/dot_popup.dart` — Dot 도착 팝업 (scale+fade, 3초 자동 닫기)

## Phase 4 구현 파일 목록
- `lib/features/room/data/room_remote_source.dart` — Room API 호출 (Dio)
- `lib/features/room/data/room_repository.dart` — Room CRUD, mock fallback 2개 방 (나와 여자친구, 등산 모임)
- `lib/features/room/presentation/room_provider.dart` — roomListProvider, roomDetailProvider, RoomNotifier
- `lib/features/room/presentation/room_list_screen.dart` — 방 목록 + 초대코드 참여 다이얼로그
- `lib/features/room/presentation/create_room_screen.dart` — 방 만들기 + 초대코드 표시
- `lib/features/room/presentation/room_detail_screen.dart` — 멤버 목록, 캘린더(mock 점), 기록 공유 버튼
- `lib/features/shared_map/domain/shared_map_model.dart` — MemberTrack, CharacterPosition, MeetingEvent (freezed)
- `lib/features/shared_map/data/shared_map_builder.dart` — SharedMapBuilder.build(), interpolateAll(), detectMeetings() (100m)
- `lib/features/shared_map/presentation/shared_map_provider.dart` — SharedMapNotifier (Ticker 기반)
- `lib/features/shared_map/presentation/shared_map_screen.dart` — 멀티캐릭터 Mapbox 화면, 만남 하트 이모지 오버레이

## 중요 설정
- **Firebase:** `flutterfire configure` 실행 후 main.dart 주석 해제 필요
- **Mapbox 토큰:** `--dart-define=MAPBOX_ACCESS_TOKEN=...` 으로 주입
- **API URL:** `--dart-define=API_URL=http://localhost:8080/v1` (기본값)
- **코드 생성:** `dart run build_runner build --delete-conflicting-outputs`
- **ScreenUtil 기준:** 390x844 (iPhone 14)

## Phase 5 구현 파일 목록
- `lib/features/auth/presentation/onboarding_screen.dart` — 3페이지 PageView 온보딩 + LoginScreen (카카오/Apple/Google 실제 OAuth 연동)
- `lib/features/auth/presentation/auth_provider.dart` — AuthNotifier (loginWithKakao/Apple/Google, signOut), kakao hide User 충돌 방지
- `lib/features/character/presentation/character_provider.dart` — CharacterNotifier (GET /users/me 초기화, PUT /users/me/character 저장)
- `lib/features/character/presentation/character_editor_screen.dart` — 색상 5개+악세서리 3개+표정 3개 선택, CharacterOverlayWidget 실시간 미리보기
- `lib/features/settings/presentation/settings_screen.dart` — 알림 토글, authNotifierProvider.signOut() 로그아웃, 버전 표시
- `lib/shared/widgets/main_shell.dart` — StatefulShellRoute 바텀 내비(홈/방/캐릭터/설정 4탭)
- `lib/shared/widgets/error_view.dart` — 아이콘+메시지+재시도 버튼
- `lib/shared/widgets/skeleton_loader.dart` — SkeletonBox/SkeletonCard/SkeletonList (shimmer 없이 fade 애니메이션)
- `lib/shared/widgets/offline_banner.dart` — connectivity_plus 연동 오프라인 배너
- `lib/core/utils/connectivity_service.dart` — connectivityStreamProvider, isOnlineProvider
- `lib/core/router/app_router.dart` — StatefulShellRoute로 전면 재작성, 온보딩/로그인/캐릭터/설정 연결

## BE 연동 완료 (Phase 6)
- **BE-1** `animation_provider.dart` — getDayLogDots(dayLogId) 실제 API, _mockDots 제거
- **BE-2** `shared_map_provider.dart` — GET /rooms/:id/shared-map API 연동, encounters→MeetingEvent 파싱, character_config.color→colorKey 매핑
- **BE-3** `auth_provider.dart` — 카카오(accessToken→customToken), Apple/Google(Firebase→idToken→POST /auth/login) 실제 OAuth
- **BE-4** `character_provider.dart` — GET /users/me 서버 초기화, DioException mock 제거
- **BE-5** `room_detail_screen.dart` — activeRecordingProvider.dayLogId 실제 연결

## BE API 응답 형식
- 모든 응답: `{ "data": { ... } }` 래퍼
- Dot 필드: snake_case (place_name, day_log_id, place_category, photo_url)
- CharacterConfig: `color`, `accessory`, `expression` (FE는 colorKey, accessoryKey, expressionKey)
- SharedMap: `members[].character_config.color`, `encounters[].user_ids`, `encounters[].location.lat/lng`
- 소셜 로그인: `POST /auth/login` → `{ "data": { "custom_token": "..." } }` (카카오만)

## 아키텍처 패턴 (Phase 3~4에서 확립)
- `AnimationBuilder.interpolate()` — progress(0~1) → (lat, lng, CharacterState, frameIndex, isArrived) 반환
- Mapbox Stack Overlay 방식: `pixelForCoordinate()` → screen coords → `Positioned` widget (16ms 주기 Timer)
- `ref.onDispose(() => _ticker?.dispose())` — Riverpod Notifier에서 Ticker 정리 방법 (override dispose 사용 불가)
- `CharacterConfig` 위치: `lib/features/auth/domain/user_model.dart` (colorKey, accessoryKey, expressionKey)
- `characterColorMap` 위치: `lib/core/constants/colors.dart`
- Room mock data: 'mock_room_1'(나와 여자친구, blue+coral), 'mock_room_2'(등산 모임, blue+mint+lavender)
- GoRouter 중첩 라우트: rooms → :id → map 구조로 SharedMap 접근

## 알려진 패턴/주의사항
- `@riverpod` 함수에서 `Ref` 파라미터 사용 시 반드시 `flutter_riverpod` import 필요
- flutter_local_notifications 18.x: `zonedSchedule`에 `uiLocalNotificationDateInterpretation` 파라미터 필수
- `withOpacity` deprecated → `withAlpha` 사용
- android/app/build.gradle.kts: `isCoreLibraryDesugaringEnabled = true` + `desugar_jdk_libs` 의존성 설정됨

## 패키지 버전 (pubspec.yaml)
- connectivity_plus: ^6.1.4 (Phase 5에서 추가)
- mapbox_maps_flutter: ^2.5.0
- firebase_core: ^3.13.1, firebase_auth: ^5.5.2
- flutter_riverpod: ^2.6.1, riverpod_annotation: ^2.6.1
- go_router: ^14.8.1, dio: ^5.8.0+1
- drift: ^2.22.1, flutter_local_notifications: ^18.0.1, timezone: ^0.10.1
- freezed_annotation: ^2.4.4, geolocator: ^13.0.2

## Android/iOS 설정
- `android/app/src/main/AndroidManifest.xml` — 위치/알림/카메라 권한 추가됨
- `ios/Runner/Info.plist` — 위치/카메라/사진 권한 + 카카오 URL Scheme 추가됨