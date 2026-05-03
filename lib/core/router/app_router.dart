import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/character/paperdoll/presentation/paperdoll_editor_screen.dart';
import '../../features/character/paperdoll/presentation/paperdoll_provider.dart';
import '../../features/map_animation/presentation/map_animation_screen.dart';
import '../../features/room/presentation/create_room_screen.dart';
import '../../features/room/presentation/room_detail_screen.dart';
import '../../features/room/presentation/room_list_screen.dart';
import '../../features/recording/presentation/today_map_screen.dart';
import '../../features/notification/presentation/notification_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shared_map/presentation/shared_map_screen.dart';
import '../../features/timeline/presentation/timeline_screen.dart';
import '../../shared/widgets/main_shell.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String home = '/home';
  static const String recording = '/recording';
  static const String dayDetail = '/day/:id';
  static const String mapAnimation = '/animation/:id';
  static const String rooms = '/rooms';
  static const String roomDetail = '/rooms/:id';
  static const String createRoom = '/rooms/new';
  static const String sharedMap = '/rooms/:id/map';
  static const String today = '/today';
  static const String notifications = '/notifications';
  static const String character = '/character';
  static const String settings = '/settings';
}

final _publicRoutes = {
  AppRoutes.splash,
  AppRoutes.onboarding,
  AppRoutes.login,
};

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: kDebugMode,
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context, listen: false);
    final isAuth = container.read(isAuthenticatedProvider);
    final location = state.matchedLocation;

    if (!isAuth && !_publicRoutes.contains(location)) {
      return AppRoutes.onboarding;
    }
    return null;
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

    // 오늘 지도 (풀스크린, 쉘 밖)
    GoRoute(
      path: AppRoutes.today,
      builder: (context, state) => const TodayMapScreen(),
    ),

    // 지도 애니메이션 (풀스크린, 쉘 밖)
    GoRoute(
      path: AppRoutes.mapAnimation,
      builder: (context, state) => MapAnimationScreen(
        dayLogId: state.pathParameters['id'] ?? '',
      ),
    ),

    // 메인 바텀 내비 쉘
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        // 홈 탭 (index 0)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const TimelineScreen(),
            ),
          ],
        ),
        // 방 탭 (index 1)
        StatefulShellBranch(
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
                  path: ':id',
                  builder: (context, state) => RoomDetailScreen(
                    roomId: state.pathParameters['id'] ?? '',
                  ),
                  routes: [
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
        // 알림 탭 (index 2)
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.notifications,
              builder: (context, state) => const NotificationScreen(),
            ),
          ],
        ),
        // 캐릭터 탭 (index 3)
        StatefulShellBranch(
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


