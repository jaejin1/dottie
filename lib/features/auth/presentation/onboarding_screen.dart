import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/router/app_router.dart';
import 'auth_provider.dart';

// 로그인 전 워크스루는 제거 — 사용법은 로그인 후 앱 내 투어가 안내한다.
// /onboarding 경로 호환을 위해 LoginScreen 별칭만 유지.

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) => const LoginScreen();
}

// ─── 로그인 화면 ──────────────────────────────────────────────

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isLoading = false;

  Future<void> _login(Future<bool> Function() loginFn) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final success = await loginFn();
      if (success && mounted) {
        // 필수 약관 미동의 유저는 동의 게이트로 (라우터 redirect 가 2차 방어).
        final user =
            await ref.read(currentDottieUserProvider.future);
        if (!mounted) return;
        context.go(user?.consentRequired == true
            ? AppRoutes.consent
            : AppRoutes.home);
      } else if (mounted) {
        final authState = ref.read(authNotifierProvider);
        if (authState is AsyncError) {
          _showError(_friendlyError(authState.error));
        }
      }
    } catch (e) {
      if (mounted) _showError(_friendlyError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(Object error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'user-disabled' => '비활성화된 계정이에요.',
        'network-request-failed' => '네트워크 연결을 확인해주세요.',
        'too-many-requests' => '잠시 후 다시 시도해주세요.',
        _ => '로그인에 실패했어요. 다시 시도해주세요.',
      };
    }
    if (error is DioException) return '서버 연결에 실패했어요. 잠시 후 다시 시도해주세요.';
    return '로그인에 실패했어요. 다시 시도해주세요.';
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authNotifierProvider.notifier);
    return Scaffold(
      backgroundColor: DottieColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.xl),
          child: Column(
            children: [
              const Spacer(),
              // 브랜드 마크 — dot 자취 (발자국 컨셉)
              const _DotTrailMark(size: 140),
              const SizedBox(height: Dimensions.lg),
              Text('Dottie', style: AppTypography.brandHero(fontSize: 38)),
              const SizedBox(height: Dimensions.xs),
              Text(
                '같은 하루, 다른 발자국',
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
                  color: DottieColors.textSecondary,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: Dimensions.md),
                  child: CircularProgressIndicator(),
                ),

              // 카카오 — 공식 디자인 가이드 준수 커스텀 버튼.
              // 컨테이너 #FEE500 / radius 12px, 공식 말풍선 심볼(#000),
              // 라벨 #000 85% "카카오 로그인".
              _SocialLoginButton(
                color: const Color(0xFFFEE500),
                textColor: const Color(0xD9000000), // #000 85%
                radius: 12,
                icon: Image.asset(
                  'assets/images/kakao_symbol.png',
                  width: 18,
                  height: 18,
                ),
                label: '카카오 로그인',
                onTap: _isLoading ? null : () => _login(auth.loginWithKakao),
              ),
              const SizedBox(height: Dimensions.sm),

              _SocialLoginButton(
                color: Colors.black,
                textColor: Colors.white,
                radius: 12,
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.apple, size: 24, color: Colors.white),
                ),
                label: 'Apple로 로그인',
                onTap: _isLoading ? null : () => _login(auth.loginWithApple),
              ),
              const SizedBox(height: Dimensions.sm),

              // Google — 공식 브랜드 가이드 스타일 (흰 배경 / #747775 테두리 /
              // #1f1f1f 텍스트 / 공식 G 로고). 프레임은 카카오·애플과 동일 폭·높이.
              _SocialLoginButton(
                color: Colors.white,
                textColor: const Color(0xFF1F1F1F),
                // 공식 Google 'G' 로고 PNG. 파일이 없으면 텍스트 G 로 폴백.
                icon: Image.asset(
                  'assets/images/google_g.png',
                  width: 20,
                  height: 20,
                  errorBuilder: (_, __, ___) => const _GoogleG(size: 20),
                ),
                // Google 가이드: 승인된 문구만 허용 ("Google 계정으로 로그인"
                // /가입/계속). 임의 축약("Google 로그인") 불가.
                label: 'Google 계정으로 로그인',
                radius: 12,
                onTap: _isLoading ? null : () => _login(auth.loginWithGoogle),
                border: Border.all(color: const Color(0xFF747775)),
              ),

              const SizedBox(height: Dimensions.xl),
              const Text('로그인하면 서비스 이용약관 및 개인정보처리방침에 동의하게 됩니다',
                  style: TextStyle(fontSize: 11, color: DottieColors.textHint),
                  textAlign: TextAlign.center),
              const SizedBox(height: Dimensions.md),
            ],
          ),
        ),
      ),
    );
  }
}

/// dot 자취 브랜드 마크 — 작은 점들이 곡선을 그리며 메인 dot으로 이어진다.
/// "하루 동안의 이동을 점으로 기록"하는 앱 컨셉을 시각화.
class _DotTrailMark extends StatelessWidget {
  const _DotTrailMark({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _DotTrailPainter()),
    );
  }
}

class _DotTrailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 메인 dot — 우하단, 은은한 glow
    final mainCenter = Offset(w * 0.62, h * 0.68);
    final mainRadius = w * 0.20;

    canvas.drawCircle(
      mainCenter,
      mainRadius * 1.55,
      Paint()
        ..color = DottieColors.primary.withValues(alpha: 0.14)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    canvas.drawCircle(
      mainCenter,
      mainRadius,
      Paint()..color = DottieColors.primary,
    );
    // 하이라이트 — 입체감
    canvas.drawCircle(
      Offset(mainCenter.dx - mainRadius * 0.3,
          mainCenter.dy - mainRadius * 0.35),
      mainRadius * 0.32,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );

    // 자취 dot들 — 좌상단에서 곡선을 그리며 메인 dot으로
    final trail = [
      (Offset(w * 0.14, h * 0.16), w * 0.045, 0.30),
      (Offset(w * 0.30, h * 0.24), w * 0.055, 0.45),
      (Offset(w * 0.26, h * 0.46), w * 0.065, 0.60),
      (Offset(w * 0.42, h * 0.52), w * 0.080, 0.80),
    ];
    for (final (center, radius, opacity) in trail) {
      canvas.drawCircle(
        center,
        radius,
        Paint()..color = DottieColors.primary.withValues(alpha: opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Google 브랜드 컬러 'G' — 로고 에셋 없이 텍스트로 표현.
class _GoogleG extends StatelessWidget {
  const _GoogleG({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      'G',
      style: TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF4285F4),
        height: 1,
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.color,
    required this.textColor,
    required this.icon,
    required this.label,
    required this.onTap,
    this.border,
    this.radius = Dimensions.radiusMd,
  });

  final Color color;
  final Color textColor;
  final Widget icon;
  final String label;
  final VoidCallback? onTap;
  final BoxBorder? border;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: border,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 10),
              Text(
                label,
                // 카카오 가이드: 레이블 자간 변경 금지 → letterSpacing 미적용.
                style: GoogleFonts.notoSansKr(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
