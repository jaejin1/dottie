import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../../../core/constants/colors.dart';
import '../../../onboarding/domain/onboarding_step.dart';
import '../../../onboarding/presentation/onboarding_tour_provider.dart';
import '../../../onboarding/presentation/tour_content.dart';
import '../../../settings/domain/auto_record_settings.dart';
import '../../../settings/presentation/auto_record_chip.dart';
import '../../../settings/presentation/auto_record_provider.dart';
import '../dot_input_sheet.dart';
import '../recording_provider.dart';
import 'first_dot_banner.dart';

/// dot 추가 FAB + 자동 기록 설정 미니 액션 통합 SpeedDial
class RecordingSpeedDial extends ConsumerStatefulWidget {
  const RecordingSpeedDial({super.key});

  @override
  ConsumerState<RecordingSpeedDial> createState() =>
      _RecordingSpeedDialState();
}

class _RecordingSpeedDialState extends ConsumerState<RecordingSpeedDial>
    with SingleTickerProviderStateMixin {
  final _fabKey = GlobalKey();
  bool _isExpanded = false;
  bool _tourShown = false;
  TutorialCoachMark? _coachMark;
  ProviderSubscription<OnboardingStep>? _tourSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowFabTour());
    _tourSub = ref.listenManual(onboardingTourProvider, (prev, next) {
      // Reset when tour restarts
      if (next == OnboardingStep.idle || next == OnboardingStep.dotFab) {
        _tourShown = false;
      }
      if (next == OnboardingStep.dotFab && !_tourShown) {
        _tourShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showFabCoachMark();
        });
      }
    });
  }

  @override
  void dispose() {
    _tourSub?.close();
    _coachMark?.finish();
    super.dispose();
  }

  void _maybeShowFabTour() {
    if (!mounted || _tourShown) return;
    if (ref.read(onboardingTourProvider) == OnboardingStep.dotFab) {
      _tourShown = true;
      _showFabCoachMark();
    }
  }

  void _showFabCoachMark() {
    _coachMark = TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: 'dotFab',
          keyTarget: _fabKey,
          shape: ShapeLightFocus.Circle,
          radius: 40,
          paddingFocus: 12,
          enableOverlayTab: false,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (_, controller) => TourContent(
                message: '지금 있는 곳을\ndot으로 기록해보세요',
                description: '+ 버튼을 탭하면 현재 위치가 기록돼요',
                actionLabel: '기록하기',
                onAction: () => controller.next(),
                stepCurrent: 1,
                stepTotal: 5,
                onSkip: controller.skip,
              ),
            ),
          ],
        ),
      ],
      colorShadow: const Color(0xFF0A0908),
      opacityShadow: 0.78,
      focusAnimationDuration: const Duration(milliseconds: 350),
      pulseAnimationDuration: const Duration(milliseconds: 900),
      unFocusAnimationDuration: const Duration(milliseconds: 200),
      skipWidget: tourSkipIcon,
      onFinish: () {
        if (!mounted) return;
        if (ref.read(onboardingTourProvider) != OnboardingStep.dotFab) return;
        ref.read(onboardingTourProvider.notifier).advance().then((_) {
          if (mounted) _openDotInputForTour();
        });
      },
      onSkip: () {
        ref.read(onboardingTourProvider.notifier).skip();
        return true;
      },
    );
    _coachMark!.show(context: context, rootOverlay: true);
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() => _isExpanded = !_isExpanded);
  }

  void _collapse() {
    if (_isExpanded) setState(() => _isExpanded = false);
  }

  /// 투어 step 1 진행 중 sheet 열기 — first_dot_banner skip
  Future<void> _openDotInputForTour() async {
    if (!mounted) return;
    await DotInputSheet.show(context);
    // sheet 닫힘: dotSheet → mapHint (캘린더 아이콘 안내)
    if (mounted &&
        ref.read(onboardingTourProvider) == OnboardingStep.dotSheet) {
      await ref.read(onboardingTourProvider.notifier).advance();
    }
  }

  Future<void> _openDotInput() async {
    _collapse();

    final isFirstDot = await DotInputSheet.show(context);

    if (isFirstDot && mounted) {
      final currentStep = ref.read(onboardingTourProvider);
      final tourActive =
          currentStep != OnboardingStep.idle &&
          currentStep != OnboardingStep.done;
      if (!tourActive) {
        await showFirstDotFlow(context, ref);
      }
    }
  }

  void _openAutoRecordSettings() {
    _collapse();
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

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(activeRecordingProvider).isLoading;

    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _collapse,
              behavior: HitTestBehavior.translucent,
            ),
          ),

        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 자동 기록 설정 미니 액션
            _AutoRecordMiniAction(
              isVisible: _isExpanded,
              onTap: _openAutoRecordSettings,
            ),
            const SizedBox(height: 10),

            // 메인 FAB (탭: dot 추가, 롱프레스: 자동 기록 설정 펼치기)
            GestureDetector(
              onLongPress: _toggle,
              child: SizedBox(
                width: 64,
                height: 64,
                child: FloatingActionButton(
                  key: _fabKey,
                  heroTag: 'record_main_fab',
                  onPressed: isLoading
                      ? null
                      : () {
                          if (_isExpanded) {
                            _collapse();
                          } else {
                            _openDotInput();
                          }
                        },
                  backgroundColor: isLoading
                      ? DottieColors.surfaceVariant
                      : DottieColors.primary,
                  elevation: 4,
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          transitionBuilder: (child, anim) => ScaleTransition(
                            scale: anim,
                            child: FadeTransition(opacity: anim, child: child),
                          ),
                          child: Icon(
                            _isExpanded
                                ? Icons.close_rounded
                                : Icons.add_location_alt_rounded,
                            key: ValueKey(_isExpanded),
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── 자동 기록 설정 미니 액션 ───────────────────────────────────

class _AutoRecordMiniAction extends ConsumerWidget {
  const _AutoRecordMiniAction({
    required this.isVisible,
    required this.onTap,
  });

  final bool isVisible;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interval = ref.watch(autoRecordNotifierProvider).valueOrNull ??
        AutoRecordInterval.manual;
    final isAuto = interval != AutoRecordInterval.manual;
    final label =
        isAuto ? '자동 ${AutoRecordInterval.label(interval)}' : '자동 기록 설정';

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: IgnorePointer(
        ignoring: !isVisible,
        child: GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: DottieColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: DottieColors.border, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(16),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  label,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: DottieColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isAuto
                      ? DottieColors.primary.withAlpha(220)
                      : DottieColors.surfaceVariant,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isAuto
                      ? Icons.location_on_rounded
                      : Icons.location_off_outlined,
                  color: isAuto ? Colors.white : DottieColors.textHint,
                  size: 20,
                ),
              ),
            ],
          ),
        )
            .animate(target: isVisible ? 1 : 0)
            .slideY(
                begin: 0.5,
                end: 0,
                duration: 220.ms,
                curve: Curves.easeOutCubic)
            .fadeIn(duration: 200.ms),
      ),
    );
  }
}
