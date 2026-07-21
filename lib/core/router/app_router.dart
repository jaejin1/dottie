import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/consent_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/character/paperdoll/presentation/paperdoll_editor_screen.dart';
import '../../features/character/paperdoll/presentation/paperdoll_provider.dart';
import '../../features/cumulative_map/presentation/room_cumulative_map_screen.dart';
import '../../features/cumulative_map/presentation/user_cumulative_map_screen.dart';
import '../../features/map_animation/presentation/map_animation_screen.dart';
import '../../features/room/presentation/create_room_screen.dart';
import '../../features/room/presentation/room_detail_screen.dart';
import '../../features/room/presentation/room_list_screen.dart';
import '../../features/recording/presentation/today_map_screen.dart';
import '../../features/notification/presentation/notification_screen.dart';
import '../../features/search/presentation/tag_search_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shared_map/presentation/shared_map_screen.dart';
import '../../features/timeline/presentation/timeline_screen.dart';
import '../../features/room/presentation/room_invite_screen.dart';
import '../../features/todo/presentation/course_invite_screen.dart';
import '../../features/todo/presentation/todo_collection_list_screen.dart';
import '../../features/todo/presentation/todo_create_screen.dart';
import '../../features/todo/presentation/todo_edit_screen.dart';
import '../../features/todo/presentation/todo_map_screen.dart';
import '../../shared/widgets/main_shell.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  // 필수 약관 동의 게이트 — 로그인 후 consent_required==true 면 강제 진입.
  static const String consent = '/consent';
  static const String home = '/home';
  static const String recording = '/recording';
  static const String dayDetail = '/day/:id';
  static const String mapAnimation = '/animation/:id';
  static const String rooms = '/rooms';
  static const String roomDetail = '/rooms/:id';
  static const String createRoom = '/rooms/new';
  static const String roomCumulative = '/rooms/:id/all';
  static const String sharedMap = '/rooms/:id/map';
  static const String today = '/today';
  /// 본인 누적 (모든날 본인 기록) 지도. 홈에서 "모든날 기록" 칩으로 진입.
  static const String userCumulative = '/me/cumulative';
  /// fullscreen alias of /rooms/:id/map — shell 밖 화면(예: 검색)에서 push.
  /// shell-nested route 를 shell 밖에서 push 하면 navigator stack 어긋나
  /// 흰 화면이 나는 GoRouter 동작을 회피.
  /// extra: { roomId, date, dotId }
  static const String dotMap = '/dot-map';
  static const String notifications = '/notifications';
  // 검색 — 메인 탭에서 제거됨. 방 리스트 화면 AppBar 의 돋보기 아이콘에서 push.
  // 비로그인 공유 진입은 /share/todo/:token (Phase 3).
  static const String search = '/search';
  static const String todos = '/todos';
  static const String todoCreate = '/todos/new';
  static const String todoDetail = '/todos/:id';
  // 방 초대 링크 — 비로그인 허용 (로그인 유도 후 참여). `invite_code` 를 path 에 포함.
  static const String roomInviteLink = '/invite/room/:code';
  // 코스 초대 링크 — 비로그인 허용.
  static const String courseInviteLink = '/invite/course/:code';
  static const String character = '/character';
  static const String settings = '/settings';
}

/// 정확 매칭 공개 라우트.
final _publicRoutes = {
  AppRoutes.splash,
  AppRoutes.onboarding,
  AppRoutes.login,
};

/// prefix 매칭 공개 라우트. 비로그인 허용 경로.
///
/// **명시적 좁은 prefix 사용** — 신규 비로그인 라우트 추가 시 반드시 명시.
const _publicPrefixes = <String>[
  '/invite/room/',
  '/invite/course/',
];

bool _isPublicLocation(String location) {
  if (_publicRoutes.contains(location)) return true;
  for (final p in _publicPrefixes) {
    if (location.startsWith(p)) return true;
  }
  return false;
}

/// 초대 코드 형식 검증 — 구형 8자 hex 또는 신형 12자 base32(A-Z2-7).
/// app.dart 의 동일 정규식과 맞춤. %2F 등 인코딩 경유 path traversal 차단.
final _inviteCodeRegex = RegExp(r'^(?:[A-Fa-f0-9]{8}|[A-Z2-7]{12})$');
bool _isValidInviteCode(String code) => _inviteCodeRegex.hasMatch(code);

// 각 탭(branch)의 navigator key. 다른 탭에서 특정 탭의 navigator 에 접근할 때
// 사용 (예: 탭 전환 시 이전 탭의 modal sheet/dialog 일괄 닫기, 가이드 재시작
// 시 홈 탭에 열려있는 시트 정리). 같은 인덱스 순서로 `branchNavigatorKeys`
// 리스트로도 노출해 MainShell 에서 currentIndex 로 접근 가능.
final _homeNavKey = GlobalKey<NavigatorState>(debugLabel: 'home-nav');
final _roomsNavKey = GlobalKey<NavigatorState>(debugLabel: 'rooms-nav');
final _todosNavKey = GlobalKey<NavigatorState>(debugLabel: 'todos-nav');
final _characterNavKey = GlobalKey<NavigatorState>(debugLabel: 'character-nav');
final _settingsNavKey = GlobalKey<NavigatorState>(debugLabel: 'settings-nav');

final List<GlobalKey<NavigatorState>> branchNavigatorKeys = [
  _homeNavKey,
  _roomsNavKey,
  _todosNavKey,
  _characterNavKey,
  _settingsNavKey,
];

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: kDebugMode,
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context, listen: false);
    final isAuth = container.read(isAuthenticatedProvider);
    final location = state.matchedLocation;
    final rawUri = state.uri.toString();

    if (kDebugMode) {
      debugPrint(
          '[Router] redirect matchedLocation=$location rawUri=$rawUri '
          'scheme=${state.uri.scheme} host=${state.uri.host}');
    }

    // 외부 deep link 가 raw URI 그대로 routeInformation 으로 유입되는 케이스
    // 정규화. iOS Universal Link 실패 시 BE 가 fallback 으로
    // `dottie://share/todo/<token>` 형태로 보낼 수 있음 — URI parser 가
    // host='share' 로 해석해 일반 in-app 경로(`/share/todo/<token>`) 매칭이
    // 안 됨. matchedLocation 만으론 못 잡는 경우(scheme 가 vain) 대비해
    // state.uri 의 scheme/host 도 함께 검사.
    final isDottieScheme = location.startsWith('dottie://') ||
        rawUri.startsWith('dottie://') ||
        state.uri.scheme == 'dottie';
    if (isDottieScheme) {
      final uri = state.uri.scheme == 'dottie'
          ? state.uri
          : Uri.tryParse(location.startsWith('dottie://') ? location : rawUri);
      if (uri != null) {
        // 1a) `dottie://invite/room/<code>` (host=invite)
        if (uri.host == 'invite' &&
            uri.pathSegments.length >= 2 &&
            uri.pathSegments[0] == 'room') {
          final code = uri.pathSegments[1];
          if (_isValidInviteCode(code)) return '/invite/room/$code';
        }
        // 1b) `dottie://invite/course/<code>` (host=invite)
        if (uri.host == 'invite' &&
            uri.pathSegments.length >= 2 &&
            uri.pathSegments[0] == 'course') {
          final code = uri.pathSegments[1];
          if (_isValidInviteCode(code)) return '/invite/course/$code';
        }
        // 2) `dottie:///invite/room/<code>` or `dottie:///invite/course/<code>` (host 빈값)
        if (uri.pathSegments.length >= 3 &&
            uri.pathSegments[0] == 'invite' &&
            uri.pathSegments[1] == 'room') {
          final code = uri.pathSegments[2];
          if (_isValidInviteCode(code)) return '/invite/room/$code';
        }
        if (uri.pathSegments.length >= 3 &&
            uri.pathSegments[0] == 'invite' &&
            uri.pathSegments[1] == 'course') {
          final code = uri.pathSegments[2];
          if (_isValidInviteCode(code)) return '/invite/course/$code';
        }
      }
      // 알 수 없는 dottie:// 경로 → 홈으로.
      return AppRoutes.home;
    }

    // go_router 14 에서 초기 딥링크 처리 시 rawUri 에 dottie:// 가
    // 포함되지 않더라도 location 경로가 공개 prefix 로 정규화된 경우 허용.
    // (PlatformRouteInformationProvider 가 scheme 을 제거하는 경우 대비)
    if (location.startsWith('/invite/room/') ||
        location.startsWith('/invite/course/')) {
      return null;
    }

    if (!isAuth && !_isPublicLocation(location)) {
      return AppRoutes.onboarding;
    }

    // 필수 약관 동의 게이트 — 로그인됐지만 미동의면 /consent 로 강제.
    // currentDottieUser 로딩 중(null)엔 판단 보류 (로그인 직후 분기가 1차 방어).
    if (isAuth && location != AppRoutes.consent) {
      final user =
          container.read(currentDottieUserProvider).valueOrNull;
      if (user != null && user.consentRequired) {
        return AppRoutes.consent;
      }
    }
    return null;
  },
  errorBuilder: (context, state) {
    final uri = state.uri;

    if (kDebugMode) {
      debugPrint(
          '[Router] errorBuilder uri=$uri scheme=${uri.scheme} '
          'host=${uri.host} segs=${uri.pathSegments}');
    }

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('페이지를 찾을 수 없어요',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text(
                '요청한 경로를 처리할 수 없어요.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 4),
                Text(
                  uri.toString(),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('홈으로'),
              ),
            ],
          ),
        ),
      ),
    );
  },
  routes: [
    // 스플래시
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),

    // 온보딩 & 로그인
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    // 필수 약관 동의 게이트 (로그인 후, 홈 진입 전)
    GoRoute(
      path: AppRoutes.consent,
      builder: (context, state) => const ConsentScreen(),
    ),

    // 오늘 지도 (풀스크린, 쉘 밖)
    GoRoute(
      path: AppRoutes.today,
      builder: (context, state) => const TodayMapScreen(),
    ),

    // 본인 누적 (모든날 본인 기록) — 홈에서 진입.
    GoRoute(
      path: AppRoutes.userCumulative,
      builder: (context, state) => const UserCumulativeMapScreen(),
    ),

    // 룸 dot 지도 — fullscreen alias. 검색 결과처럼 shell 밖 화면에서
    // 특정 dot 으로 진입할 때 사용. extra: {roomId, date, dotId}.
    GoRoute(
      path: AppRoutes.dotMap,
      builder: (context, state) {
        final extra = state.extra as Map?;
        final today =
            DateTime.now().toIso8601String().substring(0, 10);
        return SharedMapScreen(
          roomId: extra?['roomId'] as String? ?? '',
          date: extra?['date'] as String? ?? today,
          focusDotId: extra?['dotId'] as String?,
        );
      },
    ),

    // 지도 애니메이션 (풀스크린, 쉘 밖)
    GoRoute(
      path: AppRoutes.mapAnimation,
      builder: (context, state) {
        final extra = state.extra as Map?;
        return MapAnimationScreen(
          dayLogId: state.pathParameters['id'] ?? '',
          focusDotId: extra?['focusDotId'] as String?,
        );
      },
    ),

    // 알림 (풀스크린, 홈 AppBar 종 아이콘에서 push)
    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationScreen(),
    ),

    // 검색 (풀스크린) — 메인 탭에서 분리. 방 리스트 화면 AppBar 의 돋보기 아이콘에서 push.
    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) => const TagSearchScreen(),
    ),

    // 방 초대 링크 — `/invite/room/:code`.
    // 비로그인 허용 (화면에서 로그인 유도). 로그인 후 "참여하기" 버튼으로 방 참여.
    GoRoute(
      path: AppRoutes.roomInviteLink,
      builder: (context, state) => RoomInviteScreen(
        code: state.pathParameters['code'] ?? '',
      ),
    ),

    // 코스 초대 링크 — `/invite/course/:code`. 비로그인 허용.
    GoRoute(
      path: AppRoutes.courseInviteLink,
      builder: (context, state) => CourseInviteScreen(
        code: state.pathParameters['code'] ?? '',
      ),
    ),

    // 메인 바텀 내비 쉘
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        // 홈 탭 (index 0) — 캘린더(본인 회고) ↔ 피드(시간순 합본) 토글.
        StatefulShellBranch(
          navigatorKey: _homeNavKey,
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const TimelineScreen(),
            ),
          ],
        ),
        // 방 탭 (index 1)
        StatefulShellBranch(
          navigatorKey: _roomsNavKey,
          routes: [
            GoRoute(
              path: AppRoutes.rooms,
              builder: (context, state) => const RoomListScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const CreateRoomScreen(),
                ),
                GoRoute(
                  // 룸 진입 메인: 오늘 날짜의 SharedMapScreen.
                  // 누적(전체일) 보기는 `/rooms/:id/all` 에서 별도 노출.
                  // 멤버/설정/공유 등 기존 기능은 /rooms/:id/info 로 이전.
                  path: ':id',
                  builder: (context, state) {
                    final today = DateTime.now()
                        .toIso8601String()
                        .substring(0, 10);
                    return SharedMapScreen(
                      roomId: state.pathParameters['id'] ?? '',
                      date: today,
                    );
                  },
                  routes: [
                    GoRoute(
                      // 멤버 목록 / 캘린더(레거시) / 공유 등 기존 RoomDetailScreen.
                      path: 'info',
                      builder: (context, state) => RoomDetailScreen(
                        roomId: state.pathParameters['id'] ?? '',
                      ),
                    ),
                    GoRoute(
                      // 누적 (모든날 기록) 지도 — 룸 메인에서 토글로 진입.
                      path: 'all',
                      builder: (context, state) => RoomCumulativeMapScreen(
                        roomId: state.pathParameters['id'] ?? '',
                      ),
                    ),
                    GoRoute(
                      path: 'map',
                      builder: (context, state) {
                        final extra = state.extra as Map?;
                        final date = extra?['date'] as String? ??
                            DateTime.now()
                                .toIso8601String()
                                .substring(0, 10);
                        final focusDotId = extra?['dotId'] as String?;
                        return SharedMapScreen(
                          roomId: state.pathParameters['id'] ?? '',
                          date: date,
                          focusDotId: focusDotId,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _todosNavKey,
          routes: [
            GoRoute(
              path: AppRoutes.todos,
              builder: (context, state) => const TodoCollectionListScreen(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const TodoCreateScreen(),
                ),
                GoRoute(
                  // 컬렉션 상세 (지도 메인 + 리스트 토글 + FAB + ⋯ 메뉴).
                  path: ':id',
                  builder: (context, state) => TodoMapScreen(
                    todoListId: state.pathParameters['id'] ?? '',
                  ),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) => TodoEditScreen(
                        todoListId: state.pathParameters['id'] ?? '',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        // 캐릭터 탭 (index 3)
        StatefulShellBranch(
          navigatorKey: _characterNavKey,
          routes: [
            GoRoute(
              path: AppRoutes.character,
              builder: (context, state) => Consumer(
                builder: (_, ref, __) {
                  final asyncConfig = ref.watch(paperdollProvider);
                  final notifier = ref.read(paperdollProvider.notifier);
                  return asyncConfig.when(
                    loading: () => const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Scaffold(
                      body: Center(child: Text('캐릭터 로드 오류: $e')),
                    ),
                    data: (config) => PaperdollEditorScreen(
                      initialConfig: config,
                      renderer: ref.read(paperdollRendererProvider),
                      onSave: notifier.save,
                      errorMessage: () =>
                          notifier.lastError?.toString() ?? '저장에 실패했어요',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        // 설정 탭
        StatefulShellBranch(
          navigatorKey: _settingsNavKey,
          routes: [
            GoRoute(
              path: AppRoutes.settings,
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);


