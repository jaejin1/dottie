import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../shared/widgets/dottie_button.dart';
import 'recording_provider.dart';

const _emotions = ['😊', '😴', '🎉', '🍽️', '☕', '🏃', '😤', '🥰'];

class DotInputSheet extends ConsumerStatefulWidget {
  const DotInputSheet({super.key});

  /// 저장 성공 후 오늘 첫 dot이면 true 반환
  static Future<bool> show(BuildContext context) async {
    return await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const DotInputSheet(),
        ) ??
        false;
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
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: DottieColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ).animate().fadeIn(duration: 200.ms),
          const SizedBox(height: Dimensions.md),

          // 제목
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
                'dot 찍기',
                style: GoogleFonts.notoSansKr(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: DottieColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 280.ms, delay: 60.ms)
              .slideY(begin: 0.1, end: 0, duration: 280.ms, delay: 60.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: Dimensions.sm),

          // 현재 위치 상태
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isCapturing
                ? Row(
                    key: const ValueKey('capturing'),
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: DottieColors.primary,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('위치 수집 중...',
                          style: GoogleFonts.notoSansKr(
                              fontSize: 13, color: DottieColors.textSecondary)),
                    ],
                  )
                : Row(
                    key: const ValueKey('idle'),
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: DottieColors.primary, size: 15),
                      const SizedBox(width: 4),
                      Text('현재 위치 자동 수집',
                          style: GoogleFonts.notoSansKr(
                              fontSize: 13, color: DottieColors.textSecondary)),
                    ],
                  ),
          )
              .animate()
              .fadeIn(duration: 280.ms, delay: 100.ms),
          const SizedBox(height: Dimensions.md),

          // 감정 이모지
          Text('지금 기분은?',
              style: GoogleFonts.notoSansKr(
                  fontWeight: FontWeight.w600, fontSize: 14, color: DottieColors.textPrimary))
              .animate()
              .fadeIn(duration: 280.ms, delay: 140.ms),
          const SizedBox(height: Dimensions.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _emotions
                .asMap()
                .entries
                .map((entry) => GestureDetector(
                      onTap: () => setState(() =>
                          _selectedEmotion = _selectedEmotion == entry.value ? null : entry.value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _selectedEmotion == entry.value
                              ? DottieColors.primary.withAlpha(38)
                              : DottieColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(Dimensions.radiusSm),
                          border: _selectedEmotion == entry.value
                              ? Border.all(color: DottieColors.primary, width: 1.5)
                              : Border.all(color: DottieColors.border, width: 0.8),
                        ),
                        child: Text(entry.value, style: const TextStyle(fontSize: 22)),
                      ),
                    ).animate().fadeIn(
                          duration: 240.ms,
                          delay: (160 + entry.key * 20).ms,
                        ))
                .toList(),
          ),
          const SizedBox(height: Dimensions.md),

          // 메모
          TextField(
            controller: _memoController,
            decoration: const InputDecoration(
              hintText: '한 줄 메모 (선택)',
              prefixIcon: Icon(Icons.edit_outlined, size: 18),
            ),
            maxLines: 1,
          )
              .animate()
              .fadeIn(duration: 280.ms, delay: 280.ms)
              .slideY(begin: 0.06, end: 0, duration: 280.ms, delay: 280.ms),
          const SizedBox(height: Dimensions.sm),

          // 사진 추가
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.add_a_photo_outlined, size: 18),
            label: Text(_photoPath != null ? '사진 선택됨 ✓' : '사진 추가 (선택)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: DottieColors.primary,
              side: const BorderSide(color: DottieColors.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusMd)),
            ),
          )
              .animate()
              .fadeIn(duration: 280.ms, delay: 320.ms),
          const SizedBox(height: Dimensions.lg),

          // 저장 버튼
          DottieButton(
            label: 'dot 찍기',
            isLoading: _isSaving,
            onTap: _saveDot,
          )
              .animate()
              .fadeIn(duration: 280.ms, delay: 360.ms)
              .slideY(begin: 0.08, end: 0, duration: 280.ms, delay: 360.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('카메라로 찍기'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('앨범에서 선택'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source);
    if (file != null) setState(() => _photoPath = file.path);
  }

  Future<void> _saveDot() async {
    setState(() => _isSaving = true);
    final result = await ref.read(activeRecordingProvider.notifier).captureDot(
          memo: _memoController.text.trim().isEmpty
              ? null
              : _memoController.text.trim(),
          emotion: _selectedEmotion,
          photoLocalPath: _photoPath,
        );
    if (mounted) {
      Navigator.pop(context, result.isFirst && result.dot != null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.dot != null
              ? 'dot을 찍었어요! ${result.dot!.placeName ?? ''} 📍'
              : '위치 수집에 실패했습니다.'),
        ),
      );
    }
  }
}
