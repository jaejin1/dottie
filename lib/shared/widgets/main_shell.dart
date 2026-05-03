import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../../core/constants/colors.dart';
import '../../core/router/app_router.dart';
import '../../features/notification/presentation/notification_provider.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BottomNav(
        currentIndex: navigationShell.currentIndex,
        onTap: (idx) => _onTap(idx, ref),
      ),
    );
  }

  void _onTap(int index, WidgetRef ref) {
    // 알림 탭 진입 시 최신 알림 강제 fetch.
    // (StatefulShellRoute가 화면을 메모리에 유지하므로 init은 한 번만 호출됨)
    if (index == 2) {
      ref.read(notificationProvider.notifier).refresh();
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _BottomNav extends ConsumerWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(
      notificationProvider.select(
        (s) => s.valueOrNull?.where((n) => !n.isRead).length ?? 0,
      ),
    );

    return Container(
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
              icon: Badge(
                isLabelVisible: unread > 0,
                label: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: const TextStyle(fontSize: 10),
                ),
                child: const Icon(
                    Icons.notifications_outlined, size: 21),
              ),
              activeIcon: Badge(
                isLabelVisible: unread > 0,
                label: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: const TextStyle(fontSize: 10),
                ),
                child:
                    const Icon(Icons.notifications_rounded, size: 21),
              ),
              title: Text('알림', style: _labelStyle),
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
  AppRoutes.notifications,
  AppRoutes.character,
  AppRoutes.settings,
];
