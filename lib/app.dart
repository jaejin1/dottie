import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/notification/presentation/notification_provider.dart';

class DottieApp extends ConsumerStatefulWidget {
  const DottieApp({super.key});

  @override
  ConsumerState<DottieApp> createState() => _DottieAppState();
}

class _DottieAppState extends ConsumerState<DottieApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    Animate.defaultDuration = const Duration(milliseconds: 280);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
    );
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        if (ref.read(isAuthenticatedProvider)) {
          ref.read(notificationProvider.notifier).refresh();
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 14 기준
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MaterialApp.router(
          title: 'Dottie',
          theme: AppTheme.light,
          themeMode: ThemeMode.light,
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: const Locale('ko', 'KR'),
          supportedLocales: const [
            Locale('ko', 'KR'),
            Locale('en', 'US'),
          ],
        );
      },
    );
  }
}
