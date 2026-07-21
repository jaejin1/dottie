import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../domain/room_model.dart';
import '../room_provider.dart';

/// 중앙 다이얼로그 — 2단계 인-다이얼로그 전환:
/// ① 방 이름 입력 → ② 생성 후 초대 코드 노출 + 복사.
class RoomCreateDialog extends ConsumerStatefulWidget {
  const RoomCreateDialog({super.key});

  static Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const RoomCreateDialog(),
    );
  }

  @override
  ConsumerState<RoomCreateDialog> createState() => _RoomCreateDialogState();
}

class _RoomCreateDialogState extends ConsumerState<RoomCreateDialog> {
  final _nameController = TextEditingController();
  bool _loading = false;
  Room? _createdRoom;
  String? _inviteCode;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isDone => _inviteCode != null;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: DottieColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusLg),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Dimensions.md + 4,
              Dimensions.md + 4, Dimensions.md + 4, Dimensions.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _isDone ? _buildDonePhase() : _buildInputPhase(),
          ),
        ),
      ),
    );
  }

  // ── 1단계: 이름 입력 ──────────────────────────────────

  List<Widget> _buildInputPhase() {
    return [
      Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: DottieColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '방 만들기',
            style: GoogleFonts.notoSansKr(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: DottieColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        '함께할 친구들의 작은 마당',
        style: GoogleFonts.notoSansKr(
          fontSize: 12,
          color: DottieColors.textSecondary,
        ),
      ),
      const SizedBox(height: Dimensions.md),
      TextField(
        controller: _nameController,
        autofocus: true,
        maxLength: 20,
        decoration: InputDecoration(
          hintText: '예: 나와 여자친구',
          hintStyle: const TextStyle(color: DottieColors.textHint),
          counterText: '',
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 14),
          filled: true,
          fillColor: DottieColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusMd),
            borderSide:
                const BorderSide(color: DottieColors.primary, width: 2),
          ),
        ),
      ),
      const SizedBox(height: Dimensions.sm),
      // 우하단 컴팩트 액션
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _loading ? null : () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          const SizedBox(width: 4),
          FilledButton(
            onPressed: _loading ? null : _create,
            style: FilledButton.styleFrom(
                backgroundColor: DottieColors.primary),
            child: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('만들기'),
          ),
        ],
      ),
    ];
  }

  // ── 2단계: 초대 코드 노출 ─────────────────────────────

  List<Widget> _buildDonePhase() {
    final name = _createdRoom?.name ?? '';
    return [
      Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: DottieColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "'$name'",
              style: GoogleFonts.notoSansKr(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: DottieColors.textPrimary,
                letterSpacing: -0.4,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Text(
        '이 코드를 친구에게 공유하세요',
        style: GoogleFonts.notoSansKr(
          fontSize: 12,
          color: DottieColors.textSecondary,
        ),
      ),
      const SizedBox(height: Dimensions.md),
      Container(
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.md, vertical: Dimensions.md),
        decoration: BoxDecoration(
          color: DottieColors.surfaceVariant,
          borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        ),
        child: Center(
          child: Text(
            _inviteCode!,
            style: GoogleFonts.robotoMono(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 6,
              color: DottieColors.primary,
            ),
          ),
        ),
      ),
      const SizedBox(height: Dimensions.sm),
      // 우하단 컴팩트 액션 — 복사 / 확인
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            onPressed: _copy,
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('복사'),
          ),
          const SizedBox(width: 4),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
                backgroundColor: DottieColors.primary),
            child: const Text('확인'),
          ),
        ],
      ),
    ];
  }

  // ── 액션 ──────────────────────────────────────────────

  Future<void> _create() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방 이름을 입력해주세요')),
      );
      return;
    }

    setState(() => _loading = true);
    final room =
        await ref.read(roomNotifierProvider.notifier).createRoom(name);
    if (!mounted) return;

    if (room == null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방 만들기에 실패했어요')),
      );
      return;
    }

    String inviteCode;
    try {
      final result = await ref
          .read(roomNotifierProvider.notifier)
          .generateInviteCode(room.id);
      inviteCode = result.code;
    } catch (_) {
      inviteCode = room.inviteCode ?? '';
    }

    if (!mounted) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = false;
      _createdRoom = room;
      _inviteCode = inviteCode;
    });
  }

  void _copy() {
    if (_inviteCode == null) return;
    Clipboard.setData(ClipboardData(text: _inviteCode!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('코드가 복사됐어요!')),
    );
  }
}
