import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../shared/widgets/dottie_button.dart';
import 'recording_provider.dart';

const _emotions = ['😊', '😴', '🎉', '🍽️', '☕', '🏃', '😤', '🥰'];

class DotInputSheet extends ConsumerStatefulWidget {
  const DotInputSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DotInputSheet(),
    );
  }

  @override
  ConsumerState<DotInputSheet> createState() => _DotInputSheetState();
}

class _DotInputSheetState extends ConsumerState<DotInputSheet> {
  final _memoController = TextEditingController();
  String? _selectedEmotion;
  String? _photoPath;
  bool _isSaving = false;

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeRecordingProvider).valueOrNull;
    final isCapturing = session?.isCapturingLocation ?? false;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(
          Dimensions.md, Dimensions.md, Dimensions.md, Dimensions.md + bottomPadding),
      decoration: BoxDecoration(
        color: DottieColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusLg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 핸들
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: DottieColors.textHint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.md),

          // 제목
          const Text(
            'dot 찍기 🔵',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: Dimensions.sm),

          // 현재 위치 상태
          if (isCapturing)
            const Row(children: [
              SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 8),
              Text('위치 수집 중...', style: TextStyle(color: DottieColors.textSecondary)),
            ])
          else
            const Row(children: [
              Icon(Icons.location_on_rounded, color: DottieColors.primary, size: 16),
              SizedBox(width: 4),
              Text('현재 위치 자동 수집', style: TextStyle(color: DottieColors.textSecondary)),
            ]),
          const SizedBox(height: Dimensions.md),

          // 감정 이모지
          const Text('지금 기분은?',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: Dimensions.sm),
          Wrap(
            spacing: 8,
            children: _emotions
                .map((e) => GestureDetector(
                      onTap: () => setState(() =>
                          _selectedEmotion = _selectedEmotion == e ? null : e),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _selectedEmotion == e
                              ? DottieColors.primary.withAlpha(38)
                              : DottieColors.surfaceVariant,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSm),
                          border: _selectedEmotion == e
                              ? Border.all(color: DottieColors.primary)
                              : null,
                        ),
                        child: Text(e, style: const TextStyle(fontSize: 22)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: Dimensions.md),

          // 메모
          TextField(
            controller: _memoController,
            decoration: const InputDecoration(
              hintText: '한 줄 메모 (선택)',
              prefixIcon: Icon(Icons.edit_outlined),
            ),
            maxLines: 1,
          ),
          const SizedBox(height: Dimensions.sm),

          // 사진 추가
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(_photoPath != null ? '사진 선택됨 ✓' : '사진 추가 (선택)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: DottieColors.primary,
              side: const BorderSide(color: DottieColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusMd)),
            ),
          ),
          const SizedBox(height: Dimensions.lg),

          // 저장 버튼
          DottieButton(
            label: 'dot 찍기',
            isLoading: _isSaving,
            onTap: _saveDot,
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) setState(() => _photoPath = file.path);
  }

  Future<void> _saveDot() async {
    setState(() => _isSaving = true);
    final dot = await ref.read(activeRecordingProvider.notifier).captureDot(
          memo: _memoController.text.trim().isEmpty
              ? null
              : _memoController.text.trim(),
          emotion: _selectedEmotion,
        );
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(dot != null
              ? 'dot을 찍었어요! ${dot.placeName ?? ''} 📍'
              : '위치 수집에 실패했습니다.'),
        ),
      );
    }
  }
}
