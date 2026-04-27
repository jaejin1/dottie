import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/timeline/presentation/timeline_screen.dart';

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
  static const String character = '/character';
  static const String settings = '/settings';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const _SplashPlaceholder(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const _PlaceholderScreen(title: '로그인'),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const TimelineScreen(),
    ),
    GoRoute(
      path: AppRoutes.mapAnimation,
      builder: (context, state) => _PlaceholderScreen(
          title: '지도 애니메이션 (${state.pathParameters['id']})'),
    ),
    GoRoute(
      path: AppRoutes.rooms,
      builder: (context, state) => const _PlaceholderScreen(title: '방 목록'),
    ),
    GoRoute(
      path: AppRoutes.character,
      builder: (context, state) => const _PlaceholderScreen(title: '캐릭터'),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const _PlaceholderScreen(title: '설정'),
    ),
  ],
);

class _SplashPlaceholder extends StatefulWidget {
  const _SplashPlaceholder();

  @override
  State<_SplashPlaceholder> createState() => _SplashPlaceholderState();
}

class _SplashPlaceholderState extends State<_SplashPlaceholder> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go(AppRoutes.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('🔵', style: TextStyle(fontSize: 64)),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title 화면 구현 예정')),
    );
  }
}
