import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/router/app_router.dart';
import '../../auth/presentation/auth_provider.dart';
import '../domain/auto_record_settings.dart';
import 'auto_record_chip.dart';
import 'auto_record_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: DottieColors.background,
      appBar: AppBar(
        title: Text(
          '설정',
          style: GoogleFonts.notoSansKr(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: DottieColors.textPrimary,
            letterSpacing: -1,
            height: 1,
          ),
        ),
        centerTitle: false,
        backgroundColor: DottieColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
        children: [
          _SettingsGroup(
            label: '알림',
            delay: 0,
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: '기록 알림',
                subtitle: '1시간마다 dot 찍기 알림',
                trailing: Switch(
                  value: true,
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
          _SettingsGroup(
            label: '자동 기록',
            delay: 60,
            children: [_AutoRecordTile()],
          ),
          _SettingsGroup(
            label: '위치',
            delay: 120,
            children: [
              _SettingsTile(
                icon: Icons.location_on_outlined,
                title: '위치 권한',
                subtitle: '앱 사용 중 허용',
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: DottieColors.textHint, size: 20),
                onTap: () {},
              ),
            ],
          ),
          _SettingsGroup(
            label: '앱 정보',
            delay: 180,
            children: [
              const _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: '버전',
                subtitle: '1.0.0 (MVP)',
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.description_outlined,
                title: '이용약관',
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: DottieColors.textHint, size: 20),
                onTap: () {},
              ),
            ],
          ),
          _SettingsGroup(
            label: '개발자',
            delay: 240,
            children: [
              _SettingsTile(
                icon: Icons.fingerprint_rounded,
                title: '내 Firebase UID',
                subtitle: FirebaseAuth.instance.currentUser?.uid ?? '미로그인',
                trailing: IconButton(
                  icon: const Icon(Icons.copy_rounded,
                      size: 18, color: DottieColors.textHint),
                  onPressed: () {
                    final uid =
                        FirebaseAuth.instance.currentUser?.uid ?? '';
                    Clipboard.setData(ClipboardData(text: uid));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('UID 복사됨')),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _LogoutButton(
            onTap: () => _confirmLogout(context, ref),
          ).animate().fadeIn(duration: 300.ms, delay: 300.ms),
          const SizedBox(height: Dimensions.xl),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃하시겠어요?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소')),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
            child: const Text('로그아웃',
                style: TextStyle(color: DottieColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── 섹션 그룹 카드 ────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({
    required this.label,
    required this.children,
    required this.delay,
  });

  final String label;
  final List<Widget> children;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 20, 4, 6),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.notoSansKr(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: DottieColors.textHint,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: DottieColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DottieColors.border, width: 0.8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(children: children),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: delay.ms)
        .slideY(begin: 0.06, end: 0, duration: 300.ms, delay: delay.ms, curve: Curves.easeOutCubic);
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 0.8,
      indent: 52,
      color: DottieColors.border,
    );
  }
}

// ── 자동 기록 타일 ────────────────────────────────────────────

class _AutoRecordTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final intervalAsync = ref.watch(autoRecordNotifierProvider);
    final interval = intervalAsync.valueOrNull ?? AutoRecordInterval.manual;
    final isAuto = interval != AutoRecordInterval.manual;

    return _SettingsTile(
      icon: isAuto ? Icons.location_on_rounded : Icons.location_off_outlined,
      iconColor: isAuto ? DottieColors.primary : null,
      title: '자동 위치 기록',
      subtitle: isAuto
          ? '${AutoRecordInterval.label(interval)}마다 자동으로 dot 기록'
          : '꺼짐 · 수동으로만 기록',
      trailing: const Icon(Icons.chevron_right_rounded,
          color: DottieColors.textHint, size: 20),
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: DottieColors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (sheetCtx) => IntervalPickerSheet(
            current: interval,
            ref: ref,
          ),
        );
      },
    );
  }
}

// ── 설정 타일 ─────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (iconColor ?? DottieColors.textSecondary).withAlpha(18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 17,
                  color: iconColor ?? DottieColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: DottieColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 12,
                          color: DottieColors.textHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

// ── 로그아웃 버튼 ──────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: DottieColors.error.withAlpha(12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: DottieColors.error.withAlpha(40), width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, size: 18, color: DottieColors.error),
            const SizedBox(width: 8),
            Text(
              '로그아웃',
              style: GoogleFonts.notoSansKr(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: DottieColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
