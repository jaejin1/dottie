import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';

/// dot 입력 시트의 "지금 기분은?" 영역.
///
/// 안 B — 8개 고정 + 더보기 칩.
/// 더보기는 카테고리 섹션이 있는 풀 그리드 모달.
class EmotionPicker extends StatelessWidget {
  const EmotionPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  /// 현재 선택된 이모지. null = 미선택.
  final String? selected;
  final ValueChanged<String?> onChanged;

  /// 화면에 기본 노출되는 quick 이모지. 화면 폭이 좁아 다 안 보이면 가로 스크롤.
  /// 더보기는 오른쪽 끝에 고정.
  static const List<String> quickEmotions = [
    '😊', '😴', '🎉', '☕', '🥰',
  ];

  /// 더보기 시트의 카테고리.
  static const Map<String, List<String>> allEmotions = {
    '기분': [
      '😊', '😄', '😌', '😍', '🥰', '😎', '🤩', '🥳',
      '😴', '😑', '😶', '🙂', '😅', '😂', '🤔', '😏',
      '😤', '😠', '😢', '😭', '😩', '🥺', '😨', '🤯',
      '🥶', '🤒', '🤕', '😷', '🤧', '😵',
    ],
    '활동': [
      '🍽️', '☕', '🍺', '🍷', '🍔', '🍕', '🍜', '🍦',
      '🏃', '🚶', '💪', '🛌', '📖', '🎮', '🎬', '🎵',
      '🛍️', '✏️', '💻', '📱', '🎨', '📷', '🎤', '🧘',
      '🚿', '🧹',
    ],
    '이벤트': [
      '🎉', '🎂', '✈️', '🚗', '🚌', '🚇', '🏖️', '🏔️',
      '❤️', '💼', '🎓', '💍', '🎁', '🏆', '🎯', '🎪',
    ],
    '날씨': [
      '☀️', '🌤️', '⛅', '☁️', '🌧️', '⛈️', '🌨️', '❄️',
      '🌸', '🍂', '🌈', '🌙', '⭐',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final quick = _quickChips();
    // 칩들이 전체 너비를 균등하게 채우도록 Row + Expanded 사용.
    return SizedBox(
      height: 46,
      child: Row(
        children: [
          for (int i = 0; i < quick.length; i++) ...[
            Expanded(child: quick[i]),
            const SizedBox(width: 7),
          ],
          _moreChip(context),
        ],
      ),
    );
  }

  /// 8개 quick chips. 선택된 이모지가 quickEmotions 에 없으면 그것도 chip 으로 추가 노출.
  List<Widget> _quickChips() {
    final list = [...quickEmotions];
    if (selected != null && !list.contains(selected)) {
      list.insert(0, selected!);
    }
    return list
        .asMap()
        .entries
        .map((entry) => _EmotionChip(
              emoji: entry.value,
              isSelected: selected == entry.value,
              onTap: () => onChanged(selected == entry.value ? null : entry.value),
              animationDelayMs: 160 + entry.key * 20,
            ))
        .toList();
  }

  Widget _moreChip(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await _MoreEmotionsSheet.show(context, selected: selected);
        if (picked != null) onChanged(picked);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: DottieColors.surfaceVariant,
          borderRadius: BorderRadius.circular(Dimensions.radiusSm),
          border: Border.all(color: DottieColors.border, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded,
                size: 18, color: DottieColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              '더보기',
              style: GoogleFonts.notoSansKr(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: DottieColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 240.ms, delay: 320.ms);
  }
}

class _EmotionChip extends StatelessWidget {
  const _EmotionChip({
    required this.emoji,
    required this.isSelected,
    required this.onTap,
    required this.animationDelayMs,
  });

  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final int animationDelayMs;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? DottieColors.primary.withAlpha(38)
              : DottieColors.surfaceVariant,
          borderRadius: BorderRadius.circular(Dimensions.radiusSm),
          border: isSelected
              ? Border.all(color: DottieColors.primary, width: 1.5)
              : Border.all(color: DottieColors.border, width: 0.8),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 22)),
      ),
    ).animate().fadeIn(
          duration: 240.ms,
          delay: animationDelayMs.ms,
        );
  }
}

/// 카테고리 섹션이 있는 풀 그리드 시트.
class _MoreEmotionsSheet extends StatelessWidget {
  const _MoreEmotionsSheet({required this.selected});
  final String? selected;

  static Future<String?> show(BuildContext context, {String? selected}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MoreEmotionsSheet(selected: selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(
          Dimensions.md, Dimensions.md, Dimensions.md, Dimensions.md),
      decoration: BoxDecoration(
        color: DottieColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusLg),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: DottieColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.md),
          Text(
            '기분 고르기',
            style: GoogleFonts.notoSansKr(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: DottieColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: Dimensions.sm),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: EmotionPicker.allEmotions.entries
                    .map((e) => _CategorySection(
                          title: e.key,
                          emojis: e.value,
                          selected: selected,
                          onPick: (emoji) =>
                              Navigator.pop(context, emoji),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.title,
    required this.emojis,
    required this.selected,
    required this.onPick,
  });

  final String title;
  final List<String> emojis;
  final String? selected;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.notoSansKr(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: DottieColors.textSecondary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 6,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: emojis
                .map((e) => GestureDetector(
                      onTap: () => onPick(e),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected == e
                              ? DottieColors.primary.withAlpha(38)
                              : DottieColors.surfaceVariant,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusSm),
                          border: selected == e
                              ? Border.all(
                                  color: DottieColors.primary, width: 1.5)
                              : Border.all(
                                  color: DottieColors.border, width: 0.8),
                        ),
                        child: Text(e,
                            style: const TextStyle(fontSize: 22)),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
