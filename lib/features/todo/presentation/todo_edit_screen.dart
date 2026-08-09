import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/media/media_upload_service.dart';
import '../../../shared/utils/error_messages.dart';
import '../../../shared/widgets/dottie_date_picker.dart';
import '../domain/todo_list_model.dart';
import 'todo_provider.dart';

/// 코스 메타 편집 화면 — /todos/:id/edit
///
/// 수정 가능: 이름 / 표지 이모지 / 설명 / 태그 / 코스 유형 / 여행 기간.
class TodoEditScreen extends ConsumerStatefulWidget {
  const TodoEditScreen({super.key, required this.todoListId});
  final String todoListId;

  @override
  ConsumerState<TodoEditScreen> createState() => _TodoEditScreenState();
}

class _TodoEditScreenState extends ConsumerState<TodoEditScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  String? _emoji;
  String _courseType = 'trip';
  bool get _isTrip => _courseType == 'trip';

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 2));

  final Set<String> _selectedTags = {};
  String _visibility = 'private';
  bool get _isPublic => _visibility == 'public';
  String? _coverImageUrl;
  bool _uploadingCover = false;
  bool _initialized = false;
  bool _saving = false;

  static const List<String> _predefinedTags = [
    '데이트', '맛집', '카페', '가족여행', '당일치기', '액티비티', '야경', '여행',
  ];

  static const Map<String, List<String>> _emojiCategories = {
    '추천': ['📍', '⭐', '❤️', '✨', '🔥', '🎯', '📌', '🗺️'],
    '국가/지역': [
      '🇰🇷', '🇯🇵', '🇨🇳', '🇹🇼', '🇹🇭', '🇻🇳', '🇸🇬', '🇮🇩',
      '🇺🇸', '🇨🇦', '🇲🇽', '🇧🇷',
      '🇫🇷', '🇮🇹', '🇪🇸', '🇬🇧', '🇩🇪', '🇨🇭',
      '🇦🇺', '🇳🇿', '🌎',
    ],
    '자연/풍경': [
      '🏔️', '⛰️', '🌋', '🏞️',
      '🏖️', '🏝️', '🌊', '🌅', '🌄',
      '🌳', '🌲', '🌸', '🍁', '🌺', '☀️', '🌙',
    ],
    '도시/건물': [
      '🌃', '🏙️', '🌆', '🌉',
      '🗽', '🗼', '🏯', '🏰', '🏛️', '⛩️', '🕌', '⛪', '🌁',
    ],
    '음식/카페': [
      '🍣', '🍱', '🍜', '🍝', '🍕', '🍔', '🌮', '🥘',
      '🍳', '🥗', '🍲',
      '🍰', '🍩', '🍦', '🍪', '🥐',
      '☕', '🧋', '🍵', '🍷', '🍺', '🍶', '🍹',
    ],
    '쇼핑/문화': [
      '🛍️', '👗', '👜', '💄', '👟', '🎁',
      '🎢', '🎡', '🎭', '🎨', '🎬', '🎤', '🎸', '🎮', '📚',
    ],
    '액티비티': ['⛷️', '🏂', '🏄', '🚴', '🤿', '🏊', '🥾', '🧗', '🎣', '🎿'],
    '숙박/교통': [
      '🏨', '🏠', '⛺', '🏕️', '🛏️',
      '✈️', '🚄', '🚂', '🚢', '🚗', '🚕', '🚲', '🛵',
    ],
  };

  void _initFrom(TodoList list) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = list.name;
    _descController.text = list.description ?? '';
    _emoji = list.coverEmoji ?? '📍';
    _courseType = list.courseType;
    _startDate = list.startDate;
    _endDate = list.endDate;
    _selectedTags
      ..clear()
      ..addAll(list.tags);
    _visibility = list.visibility;
    _coverImageUrl = list.coverImageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(todoListByIdProvider(widget.todoListId));

    return async.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('불러오기 실패: ${userMessageFor(e)}')),
      ),
      data: (list) {
        if (list == null) {
          return const Scaffold(
            body: Center(child: Text('코스를 찾을 수 없어요')),
          );
        }
        _initFrom(list);
        return _buildForm(list);
      },
    );
  }

  Widget _buildForm(TodoList original) {
    final canSave = _nameController.text.trim().isNotEmpty && !_saving;

    return Scaffold(
      backgroundColor: DottieColors.background,
      appBar: AppBar(
        title: const Text(
          '코스 편집',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: DottieColors.textPrimary,
          ),
        ),
        backgroundColor: DottieColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          TextButton(
            onPressed: canSave ? () => _save(original) : null,
            child: Text(
              '저장',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: canSave
                    ? DottieColors.primary
                    : DottieColors.textPrimary.withValues(alpha: 0.3),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            Dimensions.md, Dimensions.md, Dimensions.md, 100),
        children: [
          // 코스 유형
          const _SectionTitle('코스 유형'),
          const SizedBox(height: Dimensions.sm),
          _ModeToggle(
            isTrip: _isTrip,
            onChanged: (v) => setState(() {
              _courseType = v;
              // 모음 → 여행 전환 시 sentinel 날짜(+50년)를 사용 가능한 범위로 리셋
              if (v == 'trip') {
                final lastDate = DateTime.now().add(const Duration(days: 365 * 5));
                if (_startDate.isAfter(lastDate) || _endDate.isAfter(lastDate)) {
                  final today = DateTime.now();
                  _startDate = today;
                  _endDate = today;
                }
              }
            }),
          ),
          const SizedBox(height: Dimensions.lg),

          // 여행 기간
          if (_isTrip) ...[
            const _SectionTitle('여행 기간'),
            const SizedBox(height: Dimensions.sm),
            DateRangeField(
              startDate: _startDate,
              endDate: _endDate,
              onStartTap: () => _pickDate(isStart: true),
              onEndTap: () => _pickDate(isStart: false),
            ),
            const SizedBox(height: Dimensions.lg),
          ],

          // 이름
          const _SectionTitle('이름'),
          const SizedBox(height: Dimensions.sm),
          TextField(
            controller: _nameController,
            maxLength: 50,
            onChanged: (_) => setState(() {}),
            decoration: _inputDecoration(
              hintText: _isTrip ? '예: 도쿄 4박5일' : '예: 강남 맛집 모음',
            ),
            style: const TextStyle(
              fontSize: 15,
              color: DottieColors.textPrimary,
            ),
          ),
          const SizedBox(height: Dimensions.lg),

          // 설명
          const _SectionTitle('설명 (선택)'),
          const SizedBox(height: Dimensions.sm),
          TextField(
            controller: _descController,
            maxLength: 200,
            maxLines: 2,
            decoration: _inputDecoration(
              hintText: '어떤 코스인지 한 줄로 설명해요',
            ),
            style: const TextStyle(
              fontSize: 14,
              color: DottieColors.textPrimary,
            ),
          ),
          const SizedBox(height: Dimensions.lg),

          // 커버 사진
          const _SectionTitle('커버 사진 (선택)'),
          const SizedBox(height: 4),
          Text(
            '둘러보기 카드 배경으로 보여요',
            style: TextStyle(
              fontSize: 11,
              color: DottieColors.textPrimary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: Dimensions.sm),
          _CoverPicker(
            imageUrl: _coverImageUrl,
            uploading: _uploadingCover,
            onPick: _pickAndUploadCover,
            onRemove: () => setState(() => _coverImageUrl = null),
          ),
          const SizedBox(height: Dimensions.lg),

          // 태그
          const _SectionTitle('태그 (최대 5개)'),
          const SizedBox(height: Dimensions.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _predefinedTags
                .map((tag) => _TagChip(
                      label: tag,
                      selected: _selectedTags.contains(tag),
                      onTap: () => setState(() {
                        if (_selectedTags.contains(tag)) {
                          _selectedTags.remove(tag);
                        } else if (_selectedTags.length < 5) {
                          _selectedTags.add(tag);
                        }
                      }),
                    ))
                .toList(),
          ),
          const SizedBox(height: Dimensions.lg),

          // 표지 이모지
          const _SectionTitle('표지 이모지'),
          const SizedBox(height: 4),
          Text(
            '코스를 한눈에 알아볼 수 있게 이모지를 골라요',
            style: TextStyle(
              fontSize: 11,
              color: DottieColors.textPrimary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: Dimensions.md),
          for (final entry in _emojiCategories.entries) ...[
            _CategoryHeader(entry.key),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entry.value
                  .map((e) => _EmojiTile(
                        emoji: e,
                        selected: _emoji == e,
                        onTap: () => setState(() => _emoji = e),
                      ))
                  .toList(),
            ),
            const SizedBox(height: Dimensions.md),
          ],

          // 공개 설정
          const SizedBox(height: Dimensions.md),
          const _SectionTitle('공개 설정'),
          const SizedBox(height: 4),
          Text(
            _isPublic
                ? '다른 사람이 이 코스를 열람하고 좋아요를 누를 수 있어요'
                : '나와 초대한 멤버만 볼 수 있어요',
            style: TextStyle(
              fontSize: 11,
              color: DottieColors.textPrimary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: Dimensions.sm),
          _VisibilityToggle(
            isPublic: _isPublic,
            onChanged: (v) =>
                setState(() => _visibility = v ? 'public' : 'private'),
          ),

          // 코스 삭제
          const SizedBox(height: Dimensions.xl),
          GestureDetector(
            onTap: () => _confirmDelete(original),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: DottieColors.error.withAlpha(12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: DottieColors.error.withAlpha(40), width: 0.8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete_outline_rounded,
                      size: 18, color: DottieColors.error),
                  const SizedBox(width: 8),
                  Text(
                    '코스 삭제',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: DottieColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText}) =>
      InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: DottieColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusMd),
          borderSide: const BorderSide(color: DottieColors.primary, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: Dimensions.md, vertical: 14),
        counterText: '',
      );

  Future<void> _pickDate({required bool isStart}) async {
    final lastDate = DateTime.now().add(const Duration(days: 365 * 5));
    final raw = isStart ? _startDate : _endDate;
    // sentinel 값(+50년) 등 범위 초과 시 clamp
    final initial = raw.isAfter(lastDate) ? lastDate : raw;
    final first = isStart ? DateTime(2000) : _startDate;
    final picked = await showDottieDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: lastDate,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) _endDate = _startDate;
      } else {
        _endDate = picked;
        if (_endDate.isBefore(_startDate)) _startDate = _endDate;
      }
    });
  }

  Future<void> _pickAndUploadCover() async {
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
    final file = await ImagePicker().pickImage(source: source);
    if (file == null || !mounted) return;
    setState(() => _uploadingCover = true);
    // 스코프(purpose=course_cover, todoListId)를 실어 보냄 → BE 가 R2 키를
    // 코스 기준으로 구성(예: todo-lists/{id}/cover/...). 항목 사진(추후)은
    // itemId 까지 실으면 됨.
    final url = await ref.read(mediaUploadServiceProvider).upload(
          file.path,
          purpose: 'course_cover',
          todoListId: widget.todoListId,
          // 커버는 카드 배경/미리보기용 — 저해상도로 용량 절감(preview 화질).
          maxDimension: 720,
          quality: 68,
        );
    if (!mounted) return;
    setState(() {
      _uploadingCover = false;
      if (url != null) _coverImageUrl = url;
    });
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('사진 업로드에 실패했어요')),
      );
    }
  }

  Future<void> _confirmDelete(TodoList original) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dc) => AlertDialog(
        title: const Text('코스 삭제'),
        content: Text(
            "'${original.name}'을 삭제할까요?\n다녀온 곳의 dot 은 그대로 남아요."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dc, false),
              child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(dc, true),
            child: const Text('삭제', style: TextStyle(color: DottieColors.error)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await ref.read(todoNotifierProvider.notifier).deleteTodoList(original.id);
      if (!mounted) return;
      context.go('/todos');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessageFor(e))),
      );
    }
  }

  Future<void> _save(TodoList original) async {
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final startDate = _isTrip ? _startDate : now;
      final endDate = _isTrip
          ? _endDate
          : now.add(const Duration(days: 365 * 50));

      final updated = original.copyWith(
        name: _nameController.text.trim(),
        coverEmoji: _emoji,
        startDate: startDate,
        endDate: endDate,
        courseType: _courseType,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        tags: _selectedTags.toList(),
        visibility: _visibility,
      );
      await ref.read(todoNotifierProvider.notifier).updateTodoList(updated);
      // 커버는 전용 엔드포인트 — 변경됐을 때만 별도 반영(설정/해제).
      if (_coverImageUrl != original.coverImageUrl) {
        await ref
            .read(todoNotifierProvider.notifier)
            .setCover(original.id, _coverImageUrl);
      }
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessageFor(e))),
      );
    }
  }
}

// ── 공용 위젯 ─────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: DottieColors.textPrimary,
        ),
      );
}

/// 커버 사진 선택/미리보기 — 없으면 "사진 추가" 박스, 있으면 16:9 미리보기 +
/// 제거(X)·변경 버튼. 업로드 중엔 스피너.
class _CoverPicker extends StatelessWidget {
  const _CoverPicker({
    required this.imageUrl,
    required this.uploading,
    required this.onPick,
    required this.onRemove,
  });
  final String? imageUrl;
  final bool uploading;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (uploading) {
      return _frame(
        const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    if (!hasImage) {
      return GestureDetector(
        onTap: onPick,
        child: _frame(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined,
                  size: 28,
                  color: DottieColors.textPrimary.withValues(alpha: 0.4)),
              const SizedBox(height: 6),
              Text(
                '사진 추가',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DottieColors.textPrimary.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.radiusMd),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: DottieColors.surfaceVariant,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_outlined,
                    color: DottieColors.textHint),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onRemove,
                child: const CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.black54,
                  child: Icon(Icons.close_rounded, size: 16, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: onPick,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '변경',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _frame(Widget child) => Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: DottieColors.surface,
          borderRadius: BorderRadius.circular(Dimensions.radiusMd),
          border: Border.all(color: DottieColors.border, width: 1),
        ),
        child: child,
      );
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: DottieColors.textPrimary.withValues(alpha: 0.55),
        ),
      );
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.isTrip, required this.onChanged});
  final bool isTrip;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DottieColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
      ),
      child: Row(
        children: [
          _ModeOption(
            label: '✈️  여행 코스',
            subtitle: '기간 설정 · 일자별 정리',
            selected: isTrip,
            onTap: () => onChanged('trip'),
            isFirst: true,
          ),
          _ModeOption(
            label: '📌  상시 모음',
            subtitle: '언제든 추가 가능',
            selected: !isTrip,
            onTap: () => onChanged('collection'),
            isFirst: false,
          ),
        ],
      ),
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.isPublic, required this.onChanged});
  final bool isPublic;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DottieColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
      ),
      child: Row(
        children: [
          _VisibilityOption(
            icon: Icons.lock_outline_rounded,
            label: '비공개',
            selected: !isPublic,
            onTap: () => onChanged(false),
          ),
          _VisibilityOption(
            icon: Icons.public_rounded,
            label: '공개',
            selected: isPublic,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _VisibilityOption extends StatelessWidget {
  const _VisibilityOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: selected
                ? DottieColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            border: Border.all(
              color: selected ? DottieColors.primary : Colors.transparent,
              width: 1.4,
            ),
            borderRadius: BorderRadius.circular(Dimensions.radiusMd),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected
                    ? DottieColors.primary
                    : DottieColors.textPrimary.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.notoSansKr(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? DottieColors.primary
                      : DottieColors.textPrimary.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    required this.isFirst,
  });
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final bool isFirst;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: selected
                ? DottieColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            border: Border.all(
              color: selected ? DottieColors.primary : Colors.transparent,
              width: 1.4,
            ),
            borderRadius: BorderRadius.circular(Dimensions.radiusMd),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: GoogleFonts.notoSansKr(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? DottieColors.primary
                      : DottieColors.textPrimary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: selected
                      ? DottieColors.primary.withValues(alpha: 0.7)
                      : DottieColors.textHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? DottieColors.primary
              : DottieColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? DottieColors.primary : DottieColors.border,
            width: 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color:
                selected ? Colors.white : DottieColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _EmojiTile extends StatelessWidget {
  const _EmojiTile({
    required this.emoji,
    required this.selected,
    required this.onTap,
  });
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? DottieColors.primary.withValues(alpha: 0.12)
              : DottieColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? DottieColors.primary : DottieColors.border,
            width: selected ? 1.6 : 0.6,
          ),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}
