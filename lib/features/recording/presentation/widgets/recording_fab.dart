import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../recording_provider.dart';

class RecordingFab extends ConsumerWidget {
  const RecordingFab({super.key, required this.onDotTap});
  final VoidCallback onDotTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(activeRecordingProvider);

    return sessionAsync.when(
      data: (session) {
        final isRecording = session != null;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRecording) ...[
              FloatingActionButton.small(
                heroTag: 'dot_fab',
                onPressed: onDotTap,
                backgroundColor: DottieColors.primary,
                child: const Icon(Icons.add_location_alt_rounded,
                    color: Colors.white),
              ),
              const SizedBox(height: 8),
            ],
            FloatingActionButton.extended(
              heroTag: 'record_fab',
              onPressed: () => isRecording
                  ? _confirmStop(context, ref)
                  : _startRecording(context, ref),
              backgroundColor:
                  isRecording ? DottieColors.error : DottieColors.primary,
              icon: Icon(
                isRecording ? Icons.stop_rounded : Icons.fiber_manual_record,
                color: Colors.white,
              ),
              label: Text(
                isRecording ? '기록 끝내기' : '기록 시작',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
      loading: () => const FloatingActionButton.extended(
        onPressed: null,
        label: Text('로딩 중...'),
        icon: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Colors.white)),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Future<void> _startRecording(BuildContext context, WidgetRef ref) async {
    // TODO: 실제 userId는 auth provider에서 가져오기
    await ref.read(activeRecordingProvider.notifier).startRecording('temp_user');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오늘 하루를 기록할게요! 🔵')),
      );
    }
  }

  Future<void> _confirmStop(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('기록 끝내기'),
        content: const Text('오늘의 기록을 마무리할까요?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('끝내기',
                  style: TextStyle(color: DottieColors.error))),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(activeRecordingProvider.notifier).endRecording();
    }
  }
}
