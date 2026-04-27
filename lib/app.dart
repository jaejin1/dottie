import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class DottieApp extends ConsumerWidget {
  const DottieApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 14 기준
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Dottie',
          theme: AppTheme.light,
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
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
