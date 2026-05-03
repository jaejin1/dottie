import 'dart:async';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/router/app_router.dart';
import '../../map_animation/data/sprite_sheet_loader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
    context.go(user != null ? AppRoutes.home : AppRoutes.onboarding);
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
      backgroundColor: DottieColors.background,
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
            Text(
              'Dottie',
              style: GoogleFonts.notoSansKr(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: DottieColors.primary,
                letterSpacing: -1,
              ),
            ),
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
