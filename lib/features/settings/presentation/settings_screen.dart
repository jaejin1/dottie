import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/router/app_router.dart';
import '../../auth/presentation/auth_provider.dart';
// 계정 연동(SSO 통합) UI 는 1차 목표(SSO별 계정 분리)에선 숨김 — 아래 설정
// 화면의 '연결된 계정' 타일 주석 참고. 오픈 시 이 import 복구:
// import '../../auth/presentation/linked_accounts_sheet.dart';
import '../../notification/data/notification_preferences.dart';
import '../../onboarding/presentation/onboarding_tour_provider.dart';
import '../domain/auto_record_settings.dart';
import 'auto_record_chip.dart';
import 'auto_record_provider.dart';

/// 앱 버전 — pubspec 이 단일 source of truth. 표시 형식 "x.y.z (build)".
/// 하드코딩을 없애 스토어 빌드 버전과 항상 일치시킨다.
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: DottieColors.background,
      appBar: AppBar(
        title: Text('설정', style: AppTypography.tabHeader()),
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
            children: const [
              _CommentNotifTile(),
              _Divider(),
              _NewDotNotifTile(),
            ],
          ),
          _SettingsGroup(
            label: '자동 기록',
            delay: 60,
            children: [_AutoRecordTile()],
          ),
          const _SettingsGroup(
            label: '위치',
            delay: 120,
            children: [_LocationPermissionTile()],
          ),
          _SettingsGroup(
            label: '도움말',
            delay: 150,
            children: [
              _TourRestartTile(),
            ],
          ),
          _SettingsGroup(
            label: '계정',
            delay: 165,
            children: [
              // ── 계정 연동(SSO 통합) — 진입점 숨김 (2026-07) ──────────────
              // 기능은 구현 완료돼 있음: LinkedAccountsSheet + /identities API
              // (연결/해제/파괴적 흡수). 다만 1차 목표는 "카카오·애플·구글을
              // SSO별로 각각 다른 계정으로 인식(분리)" 이라, 통합 연동 UI 는
              // 지금은 노출하지 않는다. 나중에 통합 기능을 오픈할 때 아래를
              // 복구하고 linked_accounts_sheet import 를 되살리면 된다:
              //   _SettingsTile(
              //     icon: Icons.link_rounded, title: '연결된 계정',
              //     trailing: const Icon(Icons.chevron_right_rounded,
              //         color: DottieColors.textHint, size: 20),
              //     onTap: () => LinkedAccountsSheet.show(context)),
              //   const _Divider(),
              const _UserIdTile(),
            ],
          ),
          _SettingsGroup(
            label: '법적 정보 및 기타',
            delay: 180,
            children: [
              _SettingsTile(
                icon: Icons.shield_outlined,
                title: '약관 및 개인정보 처리 동의',
                trailing: const _Chevron(),
                onTap: () => Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const LegalConsentScreen(),
                  ),
                ),
              ),
            ],
          ),
          if (kDebugMode)
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
          const SizedBox(height: Dimensions.md),
          // 회원 탈퇴 — 최하단. 빨간색 강조 + 2단계 경고 다이얼로그로 오작동 방어.
          // 스토어 (App Store / Play Store) 정책상 계정 삭제 기능 필수.
          _DeleteAccountButton(
            onTap: () => _confirmDeleteAccount(context, ref),
          ).animate().fadeIn(duration: 300.ms, delay: 360.ms),
          const SizedBox(height: Dimensions.xl),
          // 앱 버전 + 오픈소스 라이선스 — 최하단 plain 표기 (토스식).
          Center(
            child: Text(
                '앱 버전 ${ref.watch(appVersionProvider).valueOrNull ?? ''}',
                style: const TextStyle(
                    fontSize: 11, color: DottieColors.textHint)),
          ),
          const SizedBox(height: 10),
          Center(
            child: GestureDetector(
              onTap: () => _showLicenses(
                  context, ref.read(appVersionProvider).valueOrNull ?? ''),
              child: const Text('오픈소스 라이선스 보기',
                  style: TextStyle(
                    fontSize: 12,
                    color: DottieColors.textSecondary,
                    decoration: TextDecoration.underline,
                    decorationColor: DottieColors.textHint,
                  )),
            ),
          ),
          const SizedBox(height: Dimensions.lg),
        ],
      ),
    );
  }

  /// 오픈소스 라이선스 — Flutter 기본 [LicensePage] 를 앱 테마(크림 배경 /
  /// 탠저린 강조 / 웜 그레이 텍스트 / jua 헤더)로 감싸 톤을 맞춘다.
  void _showLicenses(BuildContext context, String version) {
    final base = Theme.of(context);
    final textTheme = GoogleFonts.notoSansKrTextTheme(base.textTheme).apply(
      bodyColor: DottieColors.textPrimary,
      displayColor: DottieColors.textPrimary,
    );
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => Theme(
          data: base.copyWith(
            scaffoldBackgroundColor: DottieColors.background,
            cardColor: DottieColors.surface,
            dividerColor: DottieColors.border,
            textTheme: textTheme,
            colorScheme: base.colorScheme.copyWith(
              primary: DottieColors.primary,
              surface: DottieColors.background,
              onSurface: DottieColors.textPrimary,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: DottieColors.background,
              foregroundColor: DottieColors.textPrimary,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: false,
              titleTextStyle: AppTypography.tabHeader(),
              iconTheme: const IconThemeData(color: DottieColors.textPrimary),
            ),
          ),
          child: LicensePage(
            applicationName: 'Dottie',
            applicationVersion: version,
            applicationLegalese: '© 2026 Dottie',
            applicationIcon: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: DottieColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
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

  /// 회원 탈퇴 — **2단계 경고** 후 BE DELETE /v1/users/me 호출.
  ///
  /// 1단계: 영구 삭제 안내 + 어떤 데이터가 사라지는지 명시
  /// 2단계: 정말 진행할지 최종 확인 — "탈퇴" 버튼이 빨간색
  /// 진행 중 로딩 다이얼로그 → 성공 시 로그인 화면 / 실패 시 SnackBar.
  Future<void> _confirmDeleteAccount(
      BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();

    // 1단계 — 영구 삭제 안내
    final continueToFinal = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: const Text(
          '회원 탈퇴 시 다음 데이터가 모두 영구 삭제됩니다.\n\n'
          '• 작성한 dot 과 사진\n'
          '• 공유 받은 / 가입한 방\n'
          '• 댓글과 알림 기록\n'
          '• 캐릭터 및 프로필 설정\n\n'
          '삭제된 데이터는 되돌릴 수 없습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              '계속',
              style: TextStyle(color: DottieColors.error),
            ),
          ),
        ],
      ),
    );
    if (continueToFinal != true || !context.mounted) return;

    // 2단계 — 최종 확인
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('정말 탈퇴하시겠어요?'),
        content: const Text('확인을 누르면 즉시 모든 데이터가 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: DottieColors.error),
            child: const Text(
              '탈퇴',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    await _performDeleteAccount(context, ref);
  }

  Future<void> _performDeleteAccount(
      BuildContext context, WidgetRef ref) async {
    // pop 후에도 안전한 messenger 미리 확보
    final messenger = ScaffoldMessenger.of(context);

    // 로딩 다이얼로그 — 사용자가 진행 중인지 인지. barrierDismissible=false 로
    // 실수로 빠져나가는 것 방지.
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: DottieColors.error),
      ),
    );

    try {
      await ref.read(authNotifierProvider.notifier).deleteAccount();
      if (!context.mounted) return;
      // 로딩 다이얼로그 닫기
      Navigator.of(context, rootNavigator: true).pop();
      // 로그인 화면으로 — go 가 stack 교체.
      context.go(AppRoutes.login);
      messenger.showSnackBar(
        const SnackBar(content: Text('탈퇴가 완료되었습니다')),
      );
    } on AccountDeleteException catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      final msg = e.networkError
          ? '네트워크 오류 — 잠시 후 다시 시도해 주세요'
          : e.message ?? '탈퇴 처리에 실패했어요 (${e.code ?? e.statusCode ?? "알 수 없음"})';
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('탈퇴 중 오류가 발생했어요')),
      );
    }
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

/// 우측 이동(>) 아이콘 — 이동 가능한 설정 타일 공통.
class _Chevron extends StatelessWidget {
  const _Chevron();

  @override
  Widget build(BuildContext context) => const Icon(
        Icons.chevron_right_rounded,
        color: DottieColors.textHint,
        size: 20,
      );
}

/// 내 사용자 ID(BE UUID) — 문의/DB 조회용. 탭 또는 복사 버튼으로 클립보드 복사.
class _UserIdTile extends ConsumerWidget {
  const _UserIdTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // BE user id(= room.ownerId, dots.user_id 조인 키). 로드 전이면 Firebase UID 폴백.
    final beId = ref.watch(currentDottieUserProvider).valueOrNull?.uid;
    final id = beId ?? FirebaseAuth.instance.currentUser?.uid ?? '';
    void copy() {
      if (id.isEmpty) return;
      Clipboard.setData(ClipboardData(text: id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사용자 ID가 복사됐어요')),
      );
    }

    return _SettingsTile(
      icon: Icons.badge_outlined,
      title: '내 사용자 ID',
      subtitle: id.isEmpty ? '불러오는 중…' : id,
      onTap: id.isEmpty ? null : copy,
      trailing: id.isEmpty
          ? null
          : IconButton(
              icon: const Icon(Icons.copy_rounded,
                  size: 18, color: DottieColors.textHint),
              onPressed: copy,
            ),
    );
  }
}

/// 위치 권한 타일 — 현재 권한 상태를 표시하고, 탭하면 시스템 설정 앱 열기.
///
/// Geolocator.checkPermission() 으로 현재 상태 fetch (FutureBuilder).
/// 시스템 설정에서 돌아오면 사용자가 위치 권한을 변경했을 수 있으므로
/// app 이 foreground 로 돌아올 때 다시 빌드되도록 [WidgetsBindingObserver]
/// 또는 페이지 재진입 시 자동 refresh.
class _LocationPermissionTile extends StatefulWidget {
  const _LocationPermissionTile();

  @override
  State<_LocationPermissionTile> createState() =>
      _LocationPermissionTileState();
}

class _LocationPermissionTileState extends State<_LocationPermissionTile>
    with WidgetsBindingObserver {
  late Future<LocationPermission> _permFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _permFuture = Geolocator.checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 시스템 설정에서 권한 변경 후 돌아오면 갱신.
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _permFuture = Geolocator.checkPermission();
      });
    }
  }

  String _subtitleFor(LocationPermission? perm) {
    return switch (perm) {
      null => '확인 중...',
      LocationPermission.always => '항상 허용',
      LocationPermission.whileInUse => '앱 사용 중 허용',
      LocationPermission.denied => '거부됨 — 탭해서 설정에서 허용',
      LocationPermission.deniedForever => '차단됨 — 탭해서 설정에서 허용',
      LocationPermission.unableToDetermine => '확인 불가',
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocationPermission>(
      future: _permFuture,
      builder: (context, snap) {
        final perm = snap.data;
        return _SettingsTile(
          icon: Icons.location_on_outlined,
          title: '위치 권한',
          subtitle: _subtitleFor(perm),
          trailing: const Icon(Icons.chevron_right_rounded,
              color: DottieColors.textHint, size: 20),
          onTap: () => openAppSettings(),
        );
      },
    );
  }
}

// ── 알림 토글 타일 ────────────────────────────────────────────
//
// foreground 알림만 클라이언트 단에서 차단 (background/terminated 는 OS 가
// 이미 표시한 후라 막을 수 없음). Phase 2 에 BE preferences 동기화 시 완전 차단.

/// 토글 시 BE PATCH → 성공 시 notifier 가 state 갱신 → Switch 가 새 값 반영.
/// 실패 (BE 400/401 등) 시 throw → catch 해서 snackbar 표시.
/// BE 미배포 / 네트워크 오류는 remote source 가 흡수해 로컬만 갱신 — 에러 X.
///
/// switch 자체가 watch 한 state 의 값을 따라가므로 실패 시 UI 자동 롤백 (state 가
/// 안 바뀌어 이전 값 그대로 그려짐).
class _CommentNotifTile extends ConsumerWidget {
  const _CommentNotifTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPreferencesNotifierProvider);
    final prefs = prefsAsync.valueOrNull;
    return _SettingsTile(
      icon: Icons.mode_comment_outlined,
      title: '댓글 알림',
      subtitle: prefs == null
          ? '불러오는 중…'
          : '내 dot 에 댓글이 달리면 알려요',
      trailing: prefs == null
          ? const _TileLoadingDot()
          : Switch(
              value: prefs.commentOnMyDot,
              onChanged: (v) => _togglePref(
                context: context,
                ref: ref,
                apply: () => ref
                    .read(notificationPreferencesNotifierProvider.notifier)
                    .setCommentOnMyDot(v),
              ),
            ),
    );
  }
}

class _NewDotNotifTile extends ConsumerWidget {
  const _NewDotNotifTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPreferencesNotifierProvider);
    final prefs = prefsAsync.valueOrNull;
    return _SettingsTile(
      icon: Icons.notifications_active_outlined,
      title: '새 dot 알림',
      subtitle: prefs == null
          ? '불러오는 중…'
          : '같은 방 멤버가 새 dot 을 찍으면 알려요',
      trailing: prefs == null
          ? const _TileLoadingDot()
          : Switch(
              value: prefs.newDotInMyRoom,
              onChanged: (v) => _togglePref(
                context: context,
                ref: ref,
                apply: () => ref
                    .read(notificationPreferencesNotifierProvider.notifier)
                    .setNewDotInMyRoom(v),
              ),
            ),
    );
  }
}

/// 알림 토글 초기 로딩 — Switch 가 비활성 회색이면 "꺼짐" 으로 오해할 위험.
/// 작은 spinner 로 명시적 "로드 중" 시그널.
class _TileLoadingDot extends StatelessWidget {
  const _TileLoadingDot();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: DottieColors.primary,
      ),
    );
  }
}

Future<void> _togglePref({
  required BuildContext context,
  required WidgetRef ref,
  required Future<void> Function() apply,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await apply();
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('알림 설정을 저장하지 못했어요. 잠시 후 다시 시도해주세요'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// ── 투어 재시작 타일 ───────────────────────────────────────────

class _TourRestartTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingsTile(
      icon: Icons.tour_outlined,
      title: '앱 사용법 다시 보기',
      subtitle: '처음 시작 가이드를 다시 볼 수 있어요',
      trailing: const Icon(Icons.chevron_right_rounded,
          color: DottieColors.textHint, size: 20),
      onTap: () {
        // 홈 branch 에 열려있는 modal sheet/dialog/popup 정리 — dot 입력 시트
        // 등이 열려있던 상태에서 가이드를 재시작해도 spotlight 와 겹치지 않음.
        branchNavigatorKeys[0].currentState
            ?.popUntil((route) => route is! PopupRoute);
        // 홈 탭으로 전환
        context.go(AppRoutes.home);
        // 한 프레임 후 투어 재시작 — 홈 화면이 렌더된 뒤 spotlight 표시
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(onboardingTourProvider.notifier).restart();
        });
      },
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

// ── 회원 탈퇴 버튼 ─────────────────────────────────────────────
//
// 로그아웃 버튼보다 시각적 무게 강조 — 더 짙은 빨간 fill + 흰 텍스트.
// 실수로 누르기 어렵게 + 누른 후엔 2단계 다이얼로그가 추가 확인.

class _DeleteAccountButton extends StatelessWidget {
  const _DeleteAccountButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: DottieColors.error.withAlpha(28),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: DottieColors.error.withAlpha(80), width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_remove_rounded,
                size: 18, color: DottieColors.error),
            const SizedBox(width: 8),
            Text(
              '회원 탈퇴',
              style: GoogleFonts.notoSansKr(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: DottieColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 약관 및 개인정보 처리 동의 화면 ─────────────────────────────
//
// 설정 → "약관 및 개인정보 처리 동의" 진입 시 열리는 상세 화면(토스식).
// 상단에 내가 동의한 약관과 동의 일시를 보여주고, 각 항목을 누르면 약관
// 원문을 인앱 브라우저로 한 단계 더 들어가 열람한다.
//
// GET /users/me/consents — 동의 이력(문서/버전/일시). 필수 약관 철회는
// 서비스 이용 불가와 동일하므로 별도 철회 버튼 대신 회원 탈퇴 안내로 갈음
// (위치기반 약관 제7조와 일치).

class LegalConsentScreen extends StatelessWidget {
  const LegalConsentScreen({super.key});

  /// 표시 순서 고정. `path` 가 있으면 원문 열람 가능(인앱 브라우저),
  /// null 이면(만 14세 확인 등) 동의 사실만 표시.
  static const _docs = <({String type, String label, String? path})>[
    (type: 'terms', label: '서비스 이용약관', path: '/terms'),
    (type: 'privacy', label: '개인정보처리방침', path: '/privacy'),
    (type: 'location', label: '위치기반 서비스 이용약관', path: '/location-terms'),
    (type: 'age14', label: '만 14세 이상 확인', path: null),
  ];

  /// doc_type → 최신 동의 레코드. 같은 문서가 여러 버전 있으면 가장 나중 동의만.
  Future<Map<String, Map<String, dynamic>>> _fetch() async {
    final res = await ApiClient.instance.get('/users/me/consents');
    final list = (res.data['data'] ?? res.data) as List? ?? const [];
    final byType = <String, Map<String, dynamic>>{};
    for (final e in list) {
      final m = (e as Map).cast<String, dynamic>();
      final t = m['doc_type']?.toString();
      if (t == null) continue;
      final prev = byType[t];
      if (prev == null) {
        byType[t] = m;
        continue;
      }
      final a = DateTime.tryParse(m['agreed_at']?.toString() ?? '');
      final b = DateTime.tryParse(prev['agreed_at']?.toString() ?? '');
      if (a != null && b != null && a.isAfter(b)) byType[t] = m;
    }
    return byType;
  }

  void _openInApp(String url) {
    launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DottieColors.background,
      appBar: AppBar(
        backgroundColor: DottieColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          '약관 및 개인정보 처리 동의',
          style: GoogleFonts.notoSansKr(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: DottieColors.textPrimary,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, Map<String, dynamic>>>(
        future: _fetch(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final byType = snap.hasError
              ? const <String, Map<String, dynamic>>{}
              : (snap.data ?? const <String, Map<String, dynamic>>{});
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Text(
                '동의 내역',
                style: GoogleFonts.notoSansKr(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: DottieColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              if (snap.hasError)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    '동의 일시를 불러오지 못했어요. 약관은 아래에서 확인할 수 있어요.',
                    style: TextStyle(
                        fontSize: 12, color: DottieColors.textSecondary),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: DottieColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < _docs.length; i++) ...[
                      if (i > 0)
                        const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: DottieColors.border),
                      _ConsentRow(
                        doc: _docs[i],
                        consent: byType[_docs[i].type],
                        onOpen: _docs[i].path == null
                            ? null
                            : () => _openInApp(
                                '${AppConfig.webHost}${_docs[i].path}'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '필수 약관 동의 철회는 회원 탈퇴를 통해 할 수 있어요.',
                style: TextStyle(
                  fontSize: 11,
                  color: DottieColors.textPrimary.withValues(alpha: 0.45),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// [LegalConsentScreen] 의 약관 1행 — 문서명 + 동의 일시 + (열람 가능 시) 화살표.
class _ConsentRow extends StatelessWidget {
  const _ConsentRow({
    required this.doc,
    required this.consent,
    required this.onOpen,
  });

  final ({String type, String label, String? path}) doc;
  final Map<String, dynamic>? consent;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final agreedAt =
        DateTime.tryParse(consent?['agreed_at']?.toString() ?? '');
    final subtitle = agreedAt != null
        ? '${DottieDateUtils.toDateString(agreedAt)} '
            '${DottieDateUtils.toTimeString(agreedAt)} 동의'
        : '동의 완료';
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded,
                size: 18, color: DottieColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.label,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DottieColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: DottieColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (onOpen != null) const _Chevron(),
          ],
        ),
      ),
    );
  }
}
