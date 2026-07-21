import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../core/constants/colors.dart';
import '../../core/router/app_router.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/onboarding/domain/onboarding_step.dart';
import '../../features/onboarding/presentation/onboarding_tour_provider.dart';
import '../../features/onboarding/presentation/tour_content.dart';
import '../providers/tab_retap_bus.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  bool _bottomTabTourShown = false;
  TutorialCoachMark? _coachMark;
  ProviderSubscription<OnboardingStep>? _tourSub;
  ProviderSubscription<AsyncValue<dynamic>>? _userSub;

  final _bottomNavKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _userSub = ref.listenManual(currentDottieUserProvider, (prev, next) {
      final uid = next.valueOrNull?.uid;
      if (uid != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) ref.read(onboardingTourProvider.notifier).init(uid);
        });
      }
    }, fireImmediately: true);

    _tourSub = ref.listenManual(onboardingTourProvider, (prev, next) {
      if (next == OnboardingStep.idle || next == OnboardingStep.dotFab) {
        _bottomTabTourShown = false;
      }
      if (next == OnboardingStep.bottomTabRoom && !_bottomTabTourShown) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showBottomTabCoachMark();
        });
      }
      if (next == OnboardingStep.character) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.navigationShell.goBranch(tabRoots.indexOf(AppRoutes.character));
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tourSub?.close();
    _userSub?.close();
    _coachMark?.finish();
    super.dispose();
  }

  void _onTap(int index) {
    HapticFeedback.lightImpact();
    final isReTap = index == widget.navigationShell.currentIndex;

    // 탭 전환 시: 떠나는(이전) branch 에 열려있는 modal sheet/dialog/popup 을
    // 모두 닫음. 사용자가 dot 입력 시트 등을 열어둔 채 다른 탭으로 이동하면,
    // 다시 돌아올 때 그 시트가 그대로 남아있어 어색하고 (가이드 재시작 등과)
    // 겹쳐 보임. PopupRoute (ModalBottomSheetRoute, DialogRoute 등의 부모) 가
    // 아닌 첫 번째 route 까지만 pop 하므로 GoRoute 페이지는 건드리지 않음.
    if (!isReTap) {
      final prevNav =
          branchNavigatorKeys[widget.navigationShell.currentIndex].currentState;
      prevNav?.popUntil((route) => route is! PopupRoute);
    }

    if (isReTap) {
      final path = tabRoots[index];
      ref.read(tabReTapBusProvider(path).notifier).notify();
    }
    widget.navigationShell.goBranch(index, initialLocation: isReTap);
  }

  void _showBottomTabCoachMark() {
    if (_bottomTabTourShown) return;
    if (_bottomNavKey.currentContext == null) return;
    _bottomTabTourShown = true;
    _coachMark = TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: 'bottomNavRoom',
          keyTarget: _bottomNavKey,
          shape: ShapeLightFocus.RRect,
          radius: 16,
          paddingFocus: 6,
          enableOverlayTab: false,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (_, controller) => TourContent(
                message: '하단 탭에서 \'방\'으로\n이동할 수 있어요',
                description: '친구와 같은 지도를 공유하는 공간이에요',
                actionLabel: '방으로 이동',
                onAction: () => controller.next(),
                stepCurrent: 4,
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
        // 방 탭으로 이동 + 다음 스텝으로 진행
        widget.navigationShell.goBranch(tabRoots.indexOf(AppRoutes.rooms));
        ref.read(onboardingTourProvider.notifier).advance(); // bottomTabRoom → room
      },
      onSkip: () {
        ref.read(onboardingTourProvider.notifier).skip();
        return true;
      },
    );
    _coachMark!.show(context: context, rootOverlay: true);
  }

  @override
  Widget build(BuildContext context) {
    // 투어 진행 중 Bottom Nav 탭 방지
    final isTourActive = ref.watch(
      onboardingTourProvider.select(
        (s) => s != OnboardingStep.idle && s != OnboardingStep.done,
      ),
    );

    return Scaffold(
      body: widget.navigationShell,
      // tour 중에는 IgnorePointer 로 탭을 차단 + 바깥 GestureDetector 가 탭을
      // 가로채 "가이드를 따라주세요" snackbar 안내. (탭이 그냥 무반응이면 사용자
      // 입장에서 답답함.)
      bottomNavigationBar: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: isTourActive ? () => _showTourBlockedToast(context) : null,
        child: IgnorePointer(
          ignoring: isTourActive,
          child: _BottomNav(
            currentIndex: widget.navigationShell.currentIndex,
            onTap: _onTap,
            navKey: _bottomNavKey,
          ),
        ),
      ),
    );
  }

  void _showTourBlockedToast(BuildContext context) {
    HapticFeedback.lightImpact();
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('가이드를 따라 진행해주세요'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _BottomNav extends ConsumerWidget {
  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    this.navKey,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final GlobalKey? navKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      key: navKey,
      decoration: const BoxDecoration(
        color: DottieColors.surface,
        border: Border(
          top: BorderSide(color: DottieColors.border, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A2A2620),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SalomonBottomBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: Colors.transparent,
          selectedItemColor: DottieColors.primary,
          unselectedItemColor: DottieColors.textHint,
          selectedColorOpacity: 0.12,
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          itemPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.auto_stories_outlined, size: 21),
              activeIcon: const Icon(Icons.auto_stories_rounded, size: 21),
              title: Text('홈', style: _labelStyle),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.people_outline_rounded, size: 21),
              activeIcon: const Icon(Icons.people_rounded, size: 21),
              title: Text('방', style: _labelStyle),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.place_outlined, size: 21),
              activeIcon: const Icon(Icons.place_rounded, size: 21),
              title: Text('스팟', style: _labelStyle),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.face_retouching_natural, size: 21),
              activeIcon:
                  const Icon(Icons.face_retouching_natural, size: 21),
              title: Text('캐릭터', style: _labelStyle),
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.tune_outlined, size: 21),
              activeIcon: const Icon(Icons.tune_rounded, size: 21),
              title: Text('설정', style: _labelStyle),
            ),
          ],
        ),
      ),
    )
        .animate()
        .slideY(
            begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 300.ms);
  }

  TextStyle get _labelStyle => GoogleFonts.notoSansKr(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      );
}

// 탭별 초기 경로
const List<String> tabRoots = [
  AppRoutes.home,
  AppRoutes.rooms,
  AppRoutes.todos,
  AppRoutes.character,
  AppRoutes.settings,
];
