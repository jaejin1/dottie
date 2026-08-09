import 'dart:async';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/router/app_router.dart';
import '../../map_animation/data/sprite_sheet_loader.dart';
import '../../notification/data/push_notification_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  List<Uint8List>? _frames;
  int _frameIdx = 0;
  Timer? _frameTimer;

  static const _frameDuration = Duration(milliseconds: 150);
  static const _minDuration = Duration(milliseconds: 2200);

  // 두 시트 중 랜덤 선택
  static const _sheets = [
    'assets/images/loading1.png',
    'assets/images/loading2.png',
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final path = _sheets[math.Random().nextInt(_sheets.length)];

    // 최소 표시 시간과 프레임 로드를 병렬 실행
    await Future.wait([
      _loadFrames(path),
      Future.delayed(_minDuration),
    ]);

    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    // terminated 상태에서 푸쉬 탭으로 앱이 시작됐는지 — 인증 여부와 무관하게
    // 소비해 비워둔다 (미인증이면 그냥 버림).
    final pendingTap =
        ref.read(pushNotificationServiceProvider).consumePendingInitialTap();

    if (user == null) {
      context.go(AppRoutes.onboarding);
      return;
    }

    context.go(AppRoutes.home);
    // 푸쉬 탭으로 시작됐으면 홈을 베이스로 깔고 그 위에 해당 dot 지도를 얹는다
    // (뒤로가기 시 홈으로 자연 복귀). 홈이 mount 된 다음 frame 에 push.
    if (pendingTap != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(pushNotificationServiceProvider).handleTapData(pendingTap);
      });
    }
  }

  Future<void> _loadFrames(String path) async {
    try {
      final frames = await SpriteSheetLoader.loadHorizontalFrames(
        imgAssetPath: path,
        frameCount: 4,
      );
      if (!mounted) return;
      setState(() => _frames = frames);
      _startFrameTimer();
    } catch (e) {
      debugPrint('[Splash] frame load failed: $e');
    }
  }

  void _startFrameTimer() {
    _frameTimer = Timer.periodic(_frameDuration, (_) {
      if (!mounted) return;
      setState(() => _frameIdx = (_frameIdx + 1) % _frames!.length);
    });
  }

  @override
  void dispose() {
    _frameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 로딩 PNG 가 흰 배경이므로 시스템 배경(웜톤)과 색이 안 부딪히도록 흰색 통일.
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: _frames != null
                  ? Image.memory(
                      _frames![_frameIdx],
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            Text('Dottie', style: AppTypography.brandHero(fontSize: 36)),
            const SizedBox(height: 6),
            Text(
              '같은 하루, 다른 발자국',
              style: GoogleFonts.notoSansKr(
                fontSize: 14,
                color: DottieColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
