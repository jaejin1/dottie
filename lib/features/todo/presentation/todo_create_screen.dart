import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../shared/utils/error_messages.dart';
import '../../../shared/widgets/dottie_date_picker.dart';
import 'todo_provider.dart';

/// 새 코스 생성 화면.
///
/// 모드 선택: [여행 코스 | 상시 모음]
/// 여행 코스: 기간 picker (start ~ end)
/// 상시 모음: 기간 없음
/// 이름 + 표지 이모지 + 한 줄 설명 + 태그
class TodoCreateScreen extends ConsumerStatefulWidget {
  const TodoCreateScreen({super.key});

  @override
  ConsumerState<TodoCreateScreen> createState() => _TodoCreateScreenState();
}

class _TodoCreateScreenState extends ConsumerState<TodoCreateScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  String? _emoji = '📍';
  bool _saving = false;

  // 모드
  String _courseType = 'trip';
  bool get _isTrip => _courseType == 'trip';

  // 날짜 (trip 모드)
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 2));

  // 태그 (미리 정의 카테고리)
  final Set<String> _selectedTags = {};
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
    '액티비티': [
      '⛷️', '🏂', '🏄', '🚴', '🤿', '🏊',
      '🥾', '🧗', '🎣', '🎿',
    ],
    '숙박/교통': [
      '🏨', '🏠', '⛺', '🏕️', '🛏️',
      '✈️', '🚄', '🚂', '🚢', '🚗', '🚕', '🚲', '🛵',
    ],
  };

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _nameController.text.trim().isNotEmpty && !_saving;

    return Scaffold(
      backgroundColor: DottieColors.background,
      appBar: AppBar(
        title: const Text('새 코스',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: DottieColors.textPrimary,
            )),
        backgroundColor: DottieColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          TextButton(
            onPressed: canSave ? _save : null,
            child: Text(
              '만들기',
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
            Dimensions.md, Dimensions.md, Dimensions.md, Dimensions.xl),
        children: [
          // ── 모드 선택 ──
          const _SectionTitle('코스 유형'),
          const SizedBox(height: Dimensions.sm),
          _ModeToggle(
            isTrip: _isTrip,
            onChanged: (v) => setState(() => _courseType = v),
          ),
          const SizedBox(height: Dimensions.lg),

          // ── 여행 기간 (trip 모드만) ──
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

          // ── 이름 ──
          const _SectionTitle('이름'),
          const SizedBox(height: Dimensions.sm),
          TextField(
            controller: _nameController,
            autofocus: true,
            maxLength: 50,
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) {},
            decoration: _inputDecoration(
              hintText: _isTrip ? '예: 도쿄 4박5일' : '예: 강남 맛집 모음',
            ),
            style: const TextStyle(
              fontSize: 15,
              color: DottieColors.textPrimary,
            ),
          ),
          const SizedBox(height: Dimensions.lg),

          // ── 한 줄 설명 ──
          const _SectionTitle('설명 (선택)'),
          const SizedBox(height: Dimensions.sm),
          TextField(
            controller: _descController,
            maxLength: 200,
            maxLines: 2,
            textInputAction: TextInputAction.done,
            decoration: _inputDecoration(
              hintText: '어떤 코스인지 한 줄로 설명해요',
            ),
            style: const TextStyle(
              fontSize: 14,
              color: DottieColors.textPrimary,
            ),
          ),
          const SizedBox(height: Dimensions.lg),

          // ── 태그 ──
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

          // ── 표지 이모지 ──
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
          borderSide:
              const BorderSide(color: DottieColors.primary, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: Dimensions.md, vertical: 14),
        counterText: '',
      );

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final first = isStart ? DateTime.now() : _startDate;
    final picked = await showDottieDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
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

  Future<void> _save() async {
    setState(() => _saving = true);
    String? id;
    try {
      final now = DateTime.now();
      final startDate = _isTrip ? _startDate : now;
      final endDate = _isTrip ? _endDate : now.add(const Duration(days: 365 * 50));
      id = await ref.read(todoNotifierProvider.notifier).createTodoList(
            name: _nameController.text.trim(),
            coverEmoji: _emoji,
            startDate: startDate,
            endDate: endDate,
            courseType: _courseType,
            description: _descController.text.trim().isEmpty
                ? null
                : _descController.text.trim(),
            tags: _selectedTags.toList(),
          );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessageFor(e))),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (id != null) {
      await ref.read(selectedTodoListIdProvider.notifier).select(id);
      if (!mounted) return;
      // 생성 후 바로 코스 상세로 push — 첫 스팟 추가 유도.
      context.pushReplacement('/todos/$id');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('생성에 실패했어요. 잠시 후 다시 시도해 주세요.')),
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
              ? DottieColors.primary.withValues(alpha: 0.12)
              : DottieColors.surface,
          border: Border.all(
            color: selected ? DottieColors.primary : DottieColors.border,
            width: selected ? 1.4 : 0.6,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '# $label',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? DottieColors.primary : DottieColors.textSecondary,
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
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? DottieColors.primary.withValues(alpha: 0.12)
              : DottieColors.surface,
          border: Border.all(
            color: selected ? DottieColors.primary : DottieColors.border,
            width: selected ? 1.6 : 0.6,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}
