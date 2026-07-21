import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';

/// 외부 skipWidget 을 숨기기 위한 빈 위젯 — 모든 TutorialCoachMark 에 전달.
const Widget tourSkipIcon = SizedBox.shrink();

/// 투어 각 step의 말풍선 콘텐츠.
class TourContent extends StatelessWidget {
  const TourContent({
    super.key,
    required this.message,
    this.description,
    this.actionLabel,
    this.onAction,
    this.stepCurrent,
    this.stepTotal,
    this.onSkip,
  });

  final String message;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final int? stepCurrent;
  final int? stepTotal;
  /// 카드 우상단 건너뛰기 버튼 콜백. null 이면 버튼 미표시.
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1B1A).withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // step indicator dots + skip button (같은 행)
            if (stepCurrent != null && stepTotal != null || onSkip != null) ...[
              Row(
                children: [
                  if (stepCurrent != null && stepTotal != null)
                    ...List.generate(stepTotal!, (i) {
                      final isActive = i == stepCurrent! - 1;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 5),
                        width: isActive ? 16 : 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: isActive
                              ? DottieColors.primary
                              : Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  const Spacer(),
                  if (onSkip != null)
                    GestureDetector(
                      onTap: onSkip,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '건너뛰기',
                              style: GoogleFonts.notoSansKr(
                                color: Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.close_rounded,
                                color: Colors.white38, size: 11),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            Text(
              message,
              style: GoogleFonts.notoSansKr(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                height: 1.5,
                letterSpacing: -0.3,
              ),
            ),

            if (description != null) ...[
              const SizedBox(height: 6),
              Text(
                description!,
                style: GoogleFonts.notoSansKr(
                  color: Colors.white60,
                  fontSize: 13,
                  height: 1.55,
                ),
              ),
            ],

            if (actionLabel != null) ...[
              const SizedBox(height: 18),
              _ActionButton(label: actionLabel!, onTap: onAction),
            ],
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 250.ms, curve: Curves.easeOut)
          .slideY(begin: 0.08, end: 0, duration: 280.ms, curve: Curves.easeOutCubic),
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
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
        scale: 1.0 + _pulse.value * 0.025,
        child: child,
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
          decoration: BoxDecoration(
            color: DottieColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: DottieColors.primary.withValues(alpha: 0.45),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.notoSansKr(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded,
                  color: Colors.white, size: 15),
            ],
          ),
        ),
      ),
    );
  }
}
