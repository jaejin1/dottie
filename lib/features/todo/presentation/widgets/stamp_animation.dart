import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';

/// 도장 찍는 스탬프 애니메이션 — 체크인 성공 시 풀스크린 오버레이로 띄움.
///
/// 흐름:
///   1. 가운데에 흰 원이 빠르게 페이드인
///   2. 큰 ✓ 아이콘이 회전하며 들어오고 살짝 흔들림 (도장 찍는 느낌)
///   3. 장소 이름이 아래에서 슬라이드 업
///   4. 약 1.6초 후 자동 dismiss
class StampAnimation extends StatefulWidget {
  const StampAnimation({super.key, this.placeName});

  final String? placeName;

  /// 1.6초 동안 표시 후 자동 dismiss.
  static Future<void> show(BuildContext context, {String? placeName}) async {
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => StampAnimation(placeName: placeName),
    );
  }

  @override
  State<StampAnimation> createState() => _StampAnimationState();
}

class _StampAnimationState extends State<StampAnimation> {
  @override
  void initState() {
    super.initState();
    // initState 안에서 timer 등록 — context across async 회피.
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      Navigator.of(context).maybePop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 스탬프 원
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: DottieColors.primary.withValues(alpha: 0.25),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
                border: Border.all(
                  color: DottieColors.primary,
                  width: 4,
                ),
              ),
              child: Center(
                child: const Icon(
                  Icons.check_rounded,
                  size: 110,
                  color: DottieColors.primary,
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.2, 0.2),
                      end: const Offset(1.0, 1.0),
                      duration: 320.ms,
                      curve: Curves.elasticOut,
                    )
                    .rotate(
                      begin: -0.18,
                      end: 0,
                      duration: 320.ms,
                      curve: Curves.easeOut,
                    ),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 280.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 160.ms)
                .shake(
                  delay: 320.ms,
                  duration: 200.ms,
                  hz: 8,
                  rotation: 0.04,
                ),
            const SizedBox(height: 28),

            // "다녀왔어요!" 텍스트
            Text(
              '다녀왔어요!',
              style: GoogleFonts.notoSansKr(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
            )
                .animate(delay: 240.ms)
                .fadeIn(duration: 280.ms)
                .slideY(
                  begin: 0.3,
                  end: 0,
                  duration: 280.ms,
                  curve: Curves.easeOutCubic,
                ),

            // 장소 이름
            if (widget.placeName != null && widget.placeName!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  widget.placeName!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
                  .animate(delay: 340.ms)
                  .fadeIn(duration: 320.ms)
                  .slideY(begin: 0.3, end: 0, duration: 320.ms),
            ],
          ],
        ),
      ),
    );
  }
}
