import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../domain/linked_identity.dart';
import 'identities_provider.dart';

/// 설정 → "연결된 계정" 관리 시트.
/// 4종 provider 의 연결 상태를 보여주고 연결/해제한다.
///
/// ⚠️ 현재 UI 진입점 숨김(2026-07): 1차 목표는 "SSO별 계정 분리"라 통합 연동
/// 기능을 노출하지 않는다. 이 위젯 + /identities 데이터 레이어는 완성돼 있으며,
/// settings_screen 의 '연결된 계정' 타일을 복구하면 그대로 활성화된다.
class LinkedAccountsSheet extends StatelessWidget {
  const LinkedAccountsSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: DottieColors.background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => const LinkedAccountsSheet(),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimensions.md, Dimensions.sm, Dimensions.md, Dimensions.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: Dimensions.md),
                decoration: BoxDecoration(
                  color: DottieColors.borderGlass,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('연결된 계정',
                style: GoogleFonts.notoSansKr(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: DottieColors.textPrimary)),
            const SizedBox(height: 4),
            Text('로그인에 사용할 계정을 연결하거나 해제할 수 있어요.',
                style: GoogleFonts.notoSansKr(
                    fontSize: 13, color: DottieColors.textSecondary)),
            const SizedBox(height: Dimensions.md),
            const _IdentitiesList(),
          ],
        ),
      ),
    );
  }
}

class _IdentitiesList extends ConsumerWidget {
  const _IdentitiesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(linkedIdentitiesNotifierProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Text('연결 정보를 불러오지 못했어요.',
                style: GoogleFonts.notoSansKr(
                    fontSize: 13, color: DottieColors.textSecondary)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  ref.invalidate(linkedIdentitiesNotifierProvider),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
      data: (identities) {
        final connected = {for (final i in identities) i.provider: i};
        final onlyOne = identities.length <= 1;
        return Column(
          children: [
            for (final kind in AuthProviderKind.values)
              _ProviderRow(
                kind: kind,
                identity: connected[kind],
                // 마지막 1개는 해제 불가.
                canDisconnect: connected[kind] != null && !onlyOne,
              ),
          ],
        );
      },
    );
  }
}

class _ProviderRow extends ConsumerStatefulWidget {
  const _ProviderRow({
    required this.kind,
    required this.identity,
    required this.canDisconnect,
  });

  final AuthProviderKind kind;
  final LinkedIdentity? identity;
  final bool canDisconnect;

  @override
  ConsumerState<_ProviderRow> createState() => _ProviderRowState();
}

class _ProviderRowState extends ConsumerState<_ProviderRow> {
  bool _busy = false;

  bool get _isNaver => widget.kind == AuthProviderKind.naver;

  @override
  Widget build(BuildContext context) {
    final connected = widget.identity != null;
    final subtitle = _isNaver
        ? '준비 중'
        : connected
            ? (widget.identity!.email ?? '연결됨')
            : '연결 안 됨';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _ProviderIcon(kind: widget.kind),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.kind.label,
                    style: GoogleFonts.notoSansKr(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: DottieColors.textPrimary)),
                const SizedBox(height: 1),
                Text(subtitle,
                    style: GoogleFonts.notoSansKr(
                        fontSize: 12, color: DottieColors.textHint),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          _busy
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : _actionButton(connected),
        ],
      ),
    );
  }

  Widget _actionButton(bool connected) {
    if (_isNaver) {
      return Text('준비 중',
          style: GoogleFonts.notoSansKr(
              fontSize: 13, color: DottieColors.textHint));
    }
    if (connected) {
      return TextButton(
        onPressed: widget.canDisconnect ? _disconnect : null,
        style: TextButton.styleFrom(
          foregroundColor: DottieColors.error,
          disabledForegroundColor: DottieColors.textHint,
        ),
        child: const Text('해제'),
      );
    }
    return TextButton(
      onPressed: _connect,
      style: TextButton.styleFrom(foregroundColor: DottieColors.primary),
      child: const Text('연결'),
    );
  }

  Future<void> _connect() async {
    setState(() => _busy = true);
    try {
      await ref.read(linkedIdentitiesNotifierProvider.notifier).connect(
            widget.kind,
            onConflict: _confirmReplace,
          );
    } on OwnsSharedRoomException {
      _snack('공유 중인 방의 방장이라 통합할 수 없어요. 방을 정리한 뒤 다시 시도해주세요.');
    } on ProviderAlreadyLinkedException {
      _snack('이 로그인 방식에는 이미 다른 계정이 연결돼 있어요.');
    } on ProviderTokenException catch (e) {
      if (!e.cancelled) _snack('연결에 필요한 인증을 가져오지 못했어요.');
    } catch (_) {
      _snack('연결에 실패했어요. 잠시 후 다시 시도해주세요.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disconnect() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${widget.kind.label} 연결 해제'),
        content: Text('${widget.kind.label} 로그인을 이 계정에서 해제할까요?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('해제',
                style: TextStyle(color: DottieColors.error)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(linkedIdentitiesNotifierProvider.notifier)
          .disconnect(widget.kind);
    } on LastIdentityException {
      _snack('마지막 로그인 수단은 해제할 수 없어요.');
    } catch (_) {
      _snack('해제에 실패했어요. 잠시 후 다시 시도해주세요.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// 파괴적 확인 — 대상 계정에 데이터가 있으면 삭제됨을 명시.
  Future<bool> _confirmReplace(IdentityAlreadyLinkedException c) async {
    final n = c.dotCount;
    final body = n > 0
        ? '이 ${widget.kind.label} 계정에는 기록 $n개가 있어요.\n지금 계정에 연결하면 그 기록은 '
            '삭제되며 되돌릴 수 없어요. 계속할까요?'
        : '이 ${widget.kind.label} 계정은 이미 다른 계정에 연결돼 있어요.\n'
            '지금 계정으로 가져오면 그 계정은 삭제됩니다. 계속할까요?';
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('계정 통합'),
        content: Text(body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('삭제하고 연결',
                style: TextStyle(color: DottieColors.error)),
          ),
        ],
      ),
    );
    return ok == true;
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _ProviderIcon extends StatelessWidget {
  const _ProviderIcon({required this.kind});
  final AuthProviderKind kind;

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case AuthProviderKind.kakao:
        return _circle(const Color(0xFFFEE500),
            child: Image.asset('assets/images/kakao_symbol.png',
                width: 16, height: 16));
      case AuthProviderKind.apple:
        return _circle(Colors.black,
            child: const Icon(Icons.apple, size: 18, color: Colors.white));
      case AuthProviderKind.google:
        return _circle(Colors.white,
            border: DottieColors.textHint,
            child: Image.asset('assets/images/google_g.png',
                width: 16, height: 16));
      case AuthProviderKind.naver:
        return _circle(const Color(0xFF03C75A),
            child: Text('N',
                style: GoogleFonts.notoSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)));
    }
  }

  Widget _circle(Color bg, {required Widget child, Color? border}) => Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: border != null ? Border.all(color: border) : null,
        ),
        child: child,
      );
}
