import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/router/app_router.dart';
import 'package:go_router/go_router.dart';

/// 온보딩 투어 완료 후 표시하는 축하 오버레이.
/// [show]는 현재 context 위에 fullscreen dialog를 올린다.
class TourCompletionOverlay {
  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.0),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => const _CompletionPage(),
      transitionBuilder: (_, anim, __, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: child,
      ),
    );
  }
}

class _CompletionPage extends StatefulWidget {
  const _CompletionPage();

  @override
  State<_CompletionPage> createState() => _CompletionPageState();
}

class _CompletionPageState extends State<_CompletionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.of(context, rootNavigator: true).pop();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
      backgroundColor: const Color(0xFF0F0E0D),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 별 이모지 아이콘
                _StarBurst()
                    .animate()
                    .scale(
                      begin: const Offset(0.3, 0.3),
                      end: const Offset(1.0, 1.0),
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 32),

                Text(
                  '준비 완료!',
                  style: GoogleFonts.notoSansKr(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 12),

                Text(
                  '이제 여러분의 하루를\nDottie로 기록해보세요',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansKr(
                    color: Colors.white70,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                  ),
                )
                    .animate(delay: 450.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 10),

                Text(
                  '친구와 방을 만들어 함께 기록할 수도 있어요',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansKr(
                    color: Colors.white38,
                    fontSize: 13,
                    height: 1.5,
                  ),
                )
                    .animate(delay: 550.ms)
                    .fadeIn(duration: 400.ms),

                const SizedBox(height: 48),

                _StartButton(onTap: _goHome)
                    .animate(delay: 700.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

// ── 별 버스트 아이콘 ──────────────────────────────────────────

class _StarBurst extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 글로우 배경
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  DottieColors.primary.withValues(alpha: 0.35),
                  DottieColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
          // 원형 테두리
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: DottieColors.primary.withValues(alpha: 0.15),
              border: Border.all(
                color: DottieColors.primary.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
          ),
          // 이모지
          const Text('✦', style: TextStyle(fontSize: 36, color: Colors.white)),
        ],
      ),
    );
  }
}

// ── 시작 버튼 ─────────────────────────────────────────────────

class _StartButton extends StatefulWidget {
  const _StartButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Transform.scale(
        scale: 1.0 + _pulse.value * 0.02,
        child: child,
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
          decoration: BoxDecoration(
            color: DottieColors.primary,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: DottieColors.primary.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '시작하기',
                style: GoogleFonts.notoSansKr(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
