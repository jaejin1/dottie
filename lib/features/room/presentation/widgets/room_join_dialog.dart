import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

/// 초대 링크 또는 코드로 방 참여 다이얼로그.
///
/// URL을 붙여넣으면 코드를 파싱하고 [RoomInviteScreen]으로 이동한다.
/// 코드만 입력해도 동일하게 처리.
class RoomJoinDialog extends StatefulWidget {
  const RoomJoinDialog({super.key});

  static Future<void> show(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (_) => const RoomJoinDialog(),
    );
  }

  @override
  State<RoomJoinDialog> createState() => _RoomJoinDialogState();
}

class _RoomJoinDialogState extends State<RoomJoinDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// URL에서 코드를 파싱. URL이 아니면 입력값 그대로 코드로 사용.
  String _extractCode(String input) {
    final trimmed = input.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.host.isNotEmpty) {
      // https://app.dottie.today/invite/room/:code 또는 딥링크
      final segs = uri.pathSegments;
      final invIdx = segs.indexOf('invite');
      if (invIdx >= 0 && invIdx + 2 < segs.length && segs[invIdx + 1] == 'room') {
        return segs[invIdx + 2];
      }
    }
    return trimmed;
  }

  void _confirm() {
    final code = _extractCode(_controller.text);
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('초대 링크 또는 코드를 입력해주세요')),
      );
      return;
    }
    if (!RegExp(r'^[A-Za-z0-9\-_]{1,100}$').hasMatch(code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('올바른 초대 링크 또는 코드를 입력해주세요')),
      );
      return;
    }
    Navigator.pop(context);
    context.push('/invite/room/$code');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: DottieColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusLg),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimensions.md + 4, Dimensions.md + 4, Dimensions.md + 4, Dimensions.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                  '초대 링크로 참여',
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
              '친구가 보내준 초대 링크 또는 코드를 붙여넣어 주세요',
              style: GoogleFonts.notoSansKr(
                fontSize: 12,
                color: DottieColors.textSecondary,
              ),
            ),
            const SizedBox(height: Dimensions.md),
            TextField(
              controller: _controller,
              autofocus: true,
              onSubmitted: (_) => _confirm(),
              decoration: InputDecoration(
                hintText: '초대 링크 또는 코드',
                hintStyle: const TextStyle(color: DottieColors.textHint),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('취소'),
                ),
                const SizedBox(width: 4),
                FilledButton(
                  onPressed: _confirm,
                  style: FilledButton.styleFrom(
                      backgroundColor: DottieColors.primary),
                  child: const Text('확인'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
