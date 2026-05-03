import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import 'room_provider.dart';

class CreateRoomScreen extends ConsumerStatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  ConsumerState<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends ConsumerState<CreateRoomScreen> {
  final _nameController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DottieColors.background,
      appBar: AppBar(
        backgroundColor: DottieColors.surface,
        elevation: 0,
        title: const Text('방 만들기',
            style: TextStyle(
                color: DottieColors.textPrimary,
                fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: DottieColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(Dimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: Dimensions.md),
            const Text('방 이름',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DottieColors.textPrimary)),
            const SizedBox(height: Dimensions.sm),
            TextField(
              controller: _nameController,
              autofocus: true,
              maxLength: 20,
              decoration: InputDecoration(
                hintText: '예: 나와 여자친구, 등산 모임',
                hintStyle: const TextStyle(color: DottieColors.textHint),
                filled: true,
                fillColor: DottieColors.surface,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusMd),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusMd),
                  borderSide: const BorderSide(
                      color: DottieColors.primary, width: 2),
                ),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _loading ? null : _createRoom,
              style: FilledButton.styleFrom(
                backgroundColor: DottieColors.primary,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusMd),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('방 만들기',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: Dimensions.md),
          ],
        ),
      ),
    );
  }

  Future<void> _createRoom() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _loading = true);
    final room = await ref.read(roomNotifierProvider.notifier).createRoom(name);
    setState(() => _loading = false);

    if (!mounted) return;

    if (room == null) {
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
    _showInviteDialog(context, room.name, inviteCode);
  }

  void _showInviteDialog(
      BuildContext context, String roomName, String inviteCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text('\'$roomName\' 생성 완료!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('초대 코드를 친구에게 공유하세요',
                style: TextStyle(color: DottieColors.textSecondary)),
            const SizedBox(height: Dimensions.md),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.lg, vertical: Dimensions.md),
              decoration: BoxDecoration(
                color: DottieColors.surfaceVariant,
                borderRadius:
                    BorderRadius.circular(Dimensions.radiusMd),
              ),
              child: Text(
                inviteCode,
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 6,
                    color: DottieColors.primary),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: inviteCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('코드가 복사됐어요!')),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('복사'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext); // 다이얼로그 닫기
              context.pop();               // CreateRoomScreen → 방 목록
            },
            style: FilledButton.styleFrom(
                backgroundColor: DottieColors.primary),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
