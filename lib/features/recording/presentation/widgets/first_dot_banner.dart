import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../settings/domain/auto_record_settings.dart';
import '../../../settings/presentation/auto_record_chip.dart';
import '../../../settings/presentation/auto_record_provider.dart';

class FirstDotBanner {
  /// 오늘 첫 dot 직후 표시. 사용자가 자동 기록 설정을 원하면 true 반환.
  static Future<bool> show(BuildContext context) async {
    return await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const _FirstDotBannerContent(),
        ) ??
        false;
  }
}

class _FirstDotBannerContent extends ConsumerWidget {
  const _FirstDotBannerContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      padding: const EdgeInsets.fromLTRB(
          Dimensions.lg, Dimensions.lg, Dimensions.lg, Dimensions.lg),
      decoration: BoxDecoration(
        color: DottieColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusLg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: DottieColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ).animate().fadeIn(duration: 200.ms),
          const SizedBox(height: Dimensions.lg),

          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: DottieColors.primary.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_rounded,
                color: DottieColors.primary, size: 32),
          )
              .animate()
              .fadeIn(duration: 300.ms, delay: 60.ms)
              .scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 300.ms,
                  delay: 60.ms),
          const SizedBox(height: Dimensions.md),

          Text(
            '오늘 처음 dot을 남기시네요! 🎉',
            style: GoogleFonts.notoSansKr(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: DottieColors.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(duration: 280.ms, delay: 120.ms)
              .slideY(begin: 0.1, end: 0, duration: 280.ms, delay: 120.ms),
          const SizedBox(height: Dimensions.sm),

          Text(
            '자동 기록을 켜면 하루 동안\n주기적으로 위치를 자동으로 dot으로 남겨드려요.',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: DottieColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 280.ms, delay: 160.ms),
          const SizedBox(height: Dimensions.xl),

          // 자동 기록 설정 버튼
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: DottieColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                ),
              ),
              child: Text(
                '자동 기록 설정하기',
                style: GoogleFonts.notoSansKr(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ).animate().fadeIn(duration: 280.ms, delay: 220.ms),
          const SizedBox(height: Dimensions.sm),

          // 수동으로 할게요
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                '괜찮아요, 수동으로 할게요',
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
                  color: DottieColors.textSecondary,
                ),
              ),
            ),
          ).animate().fadeIn(duration: 280.ms, delay: 260.ms),
        ],
      ),
    );
  }
}

/// 첫 dot 배너 결과를 받아 자동 기록 설정 시트까지 연결하는 헬퍼
Future<void> showFirstDotFlow(BuildContext context, WidgetRef ref) async {
  final wantsAuto = await FirstDotBanner.show(context);
  if (!wantsAuto || !context.mounted) return;

  final interval =
      ref.read(autoRecordNotifierProvider).valueOrNull ?? AutoRecordInterval.manual;
  showModalBottomSheet(
    context: context,
    backgroundColor: DottieColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => IntervalPickerSheet(current: interval, ref: ref),
  );
}
