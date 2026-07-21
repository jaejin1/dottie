import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_provider.dart';
import 'features/notification/data/notification_preferences.dart';
import 'features/notification/data/push_notification_service.dart';
import 'features/notification/presentation/notification_provider.dart';

class DottieApp extends ConsumerStatefulWidget {
  const DottieApp({super.key});

  @override
  ConsumerState<DottieApp> createState() => _DottieAppState();
}

class _DottieAppState extends ConsumerState<DottieApp> {
  late final AppLifecycleListener _lifecycleListener;
  AppLinks? _appLinks;
  StreamSubscription<Uri>? _linkSub;

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
    // FCM 초기화 (메시지 핸들러 + initial message 처리). 권한/토큰 등록은
    // 인증된 사용자에 대해서만 — 아래 build 의 ref.listen + 여기서 첫 호출.
    final pushSvc = ref.read(pushNotificationServiceProvider);
    pushSvc.initialize();
    // 앱이 이미 로그인된 상태로 시작했으면 (autoLogin 등) 즉시 토큰 등록 +
    // 알림 환경설정 BE 동기화.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(isAuthenticatedProvider)) {
        pushSvc.registerTokenForCurrentUser();
        ref
            .read(notificationPreferencesNotifierProvider.notifier)
            .syncFromServer();
      }
    });

    // 딥링크 수신 — 공유 토큰 등 외부 URL 진입 처리.
    // 실제 universal/app link 활성화는 iOS Info.plist + Android Manifest 설정 후 동작.
    // 그 전엔 noop (수신 이벤트 없음). 시스템 share 시트로 직접 받는 흐름엔 영향 없음.
    _appLinks = AppLinks();
    _appLinks!.getInitialLink().then((uri) {
      if (uri != null) _handleIncomingUri(uri);
    });
    _linkSub = _appLinks!.uriLinkStream.listen(
      _handleIncomingUri,
      onError: (e) {
        if (kDebugMode) debugPrint('[AppLinks] error: $e');
      },
    );
  }

  /// 들어온 URI 를 적절한 in-app 라우트로 변환.
  ///
  /// 지원: `https://app.dottie.today/invite/room/:code`, `/invite/course/:code`,
  ///       `dottie://invite/room/:code`, `dottie://invite/course/:code`.
  ///
  /// 보안 가드:
  /// - scheme: `https` 또는 `dottie` 만 허용
  /// - host: https 인 경우 `app.dottie.today` / `dottie.today` 만 허용 (dottie:// 는 host 검사 skip)
  /// - token: 영숫자 + `_-` 16~64자 (BE 의 ULID/nanoid 계약 + 여유)
  /// - 토큰 포함 URL 은 release 빌드에서 로그 금지 (kDebugMode 가드)
  void _handleIncomingUri(Uri uri) {
    if (kDebugMode) {
      // 디버그에서만 — 토큰 자체는 마스킹 (앞 4자리만).
      final segs = uri.pathSegments;
      final maskedToken = segs.length >= 3 && segs.length > 2
          ? '${segs[2].substring(0, segs[2].length.clamp(0, 4))}***'
          : '';
      debugPrint(
          '[AppLinks] incoming scheme=${uri.scheme} host=${uri.host} '
          'path=/${segs.take(2).join('/')}/$maskedToken');
    }

    // scheme 검증
    const allowedSchemes = {'https', 'dottie'};
    if (!allowedSchemes.contains(uri.scheme)) return;

    // https 의 경우 host 화이트리스트
    if (uri.scheme == 'https') {
      const allowedHosts = {'app.dottie.today', 'dottie.today'};
      if (!allowedHosts.contains(uri.host)) return;
    }

    // path segments 정규화.
    //   https://app.dottie.today/invite/room/:code → segments=['invite','room',':code']
    //   dottie://invite/room/:code → host=invite, segments=['room',':code']
    final segments = uri.pathSegments;
    final String? roomCode;
    final String? courseCode;

    if (uri.scheme == 'https' &&
        segments.length >= 3 &&
        segments[0] == 'invite' &&
        segments[1] == 'room') {
      roomCode = segments[2];
      courseCode = null;
    } else if (uri.scheme == 'dottie' &&
        uri.host == 'invite' &&
        segments.length >= 2 &&
        segments[0] == 'room') {
      roomCode = segments[1];
      courseCode = null;
    } else if (uri.scheme == 'https' &&
        segments.length >= 3 &&
        segments[0] == 'invite' &&
        segments[1] == 'course') {
      roomCode = null;
      courseCode = segments[2];
    } else if (uri.scheme == 'dottie' &&
        uri.host == 'invite' &&
        segments.length >= 2 &&
        segments[0] == 'course') {
      roomCode = null;
      courseCode = segments[1];
    } else {
      return;
    }

    // 초대 코드 — 구형 8자 hex(예: A3F2C819) 또는 신형 12자 base32(예: 3GU4CF5BX2Y3).
    final inviteRe = RegExp(r'^(?:[A-Fa-f0-9]{8}|[A-Z2-7]{12})$');

    if (roomCode != null) {
      if (!inviteRe.hasMatch(roomCode)) {
        if (kDebugMode) {
          debugPrint('[AppLinks] invalid room invite code shape — ignored');
        }
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) appRouter.push('/invite/room/${roomCode!.toUpperCase()}');
      });
      return;
    }

    if (courseCode != null) {
      if (!inviteRe.hasMatch(courseCode)) {
        if (kDebugMode) {
          debugPrint('[AppLinks] invalid course invite code shape — ignored');
        }
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) appRouter.push('/invite/course/${courseCode!.toUpperCase()}');
      });
      return;
    }
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 인증 상태 변화에 따라 FCM 토큰 register/unregister.
    // 첫 호출은 initState 의 postFrameCallback 에서 처리 (fireImmediately 대체).
    ref.listen<bool>(
      isAuthenticatedProvider,
      (prev, next) {
        final svc = ref.read(pushNotificationServiceProvider);
        if (prev == false && next == true) {
          svc.registerTokenForCurrentUser();
          // 새 user 로그인 → 그 user 의 BE prefs 로 재 sync (캐시는 이전 user 의
          // 값일 수 있음).
          ref
              .read(notificationPreferencesNotifierProvider.notifier)
              .syncFromServer();
        } else if (prev == true && next == false) {
          svc.unregisterToken();
        }
      },
    );

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
