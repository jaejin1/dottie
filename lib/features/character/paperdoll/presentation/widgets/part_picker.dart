import 'package:flutter/material.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/dimensions.dart';
import '../../domain/paperdoll_parts.dart';

/// 부위 옵션 그리드. 썸네일 PNG가 없으면 ID 텍스트로 표시.
class PartPicker extends StatelessWidget {
  const PartPicker({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onSelected,
  });

  final List<PartItem> items;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(Dimensions.lg),
        child: Text('이 부위는 아직 옵션이 없어요'),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(Dimensions.md),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: Dimensions.sm,
        mainAxisSpacing: Dimensions.sm,
        childAspectRatio: 0.85,
      ),
      itemCount: items.length,
      itemBuilder: (_, idx) {
        final item = items[idx];
        final isSelected = item.id == selectedId;
        return GestureDetector(
          onTap: () => onSelected(item.id),
          child: Container(
            decoration: BoxDecoration(
              color: DottieColors.surface,
              borderRadius: BorderRadius.circular(Dimensions.radiusMd),
              border: Border.all(
                color: isSelected
                    ? DottieColors.primary
                    : DottieColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _Thumbnail(assetPath: item.thumbnail()),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: DottieColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.assetPath});
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      filterQuality: FilterQuality.none,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.image_outlined,
            size: 24, color: DottieColors.textHint),
      ),
    );
  }
}

/// 색상 팔레트 (tintable 슬롯에서만 노출).
/// security-auditor 권고: 자유 hex 입력 대신 사전 정의 팔레트 사용.
class ColorPalettePicker extends StatelessWidget {
  const ColorPalettePicker({
    super.key,
    required this.palette,
    required this.selected,
    required this.onSelected,
  });

  final List<String> palette; // hex strings, e.g., '#FF6B6B'
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.md, vertical: Dimensions.sm),
      child: Wrap(
        spacing: Dimensions.sm,
        runSpacing: Dimensions.sm,
        children: [
          _ColorChip(
            color: null,
            isSelected: selected == null,
            onTap: () => onSelected(null),
          ),
          ...palette.map((hex) => _ColorChip(
                color: _parse(hex),
                isSelected: selected?.toLowerCase() == hex.toLowerCase(),
                onTap: () => onSelected(hex),
              )),
        ],
      ),
    );
  }

  Color _parse(String hex) {
    final v = int.tryParse(hex.substring(1), radix: 16) ?? 0;
    return Color(0xFF000000 | v);
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color ?? DottieColors.surfaceVariant,
          border: Border.all(
            color: isSelected ? DottieColors.primary : DottieColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: color == null
            ? const Icon(Icons.do_not_disturb_alt,
                size: 16, color: DottieColors.textHint)
            : null,
      ),
    );
  }
}

/// 기본 팔레트 — security-auditor 권고대로 자유 hex 대신 사전 정의값 사용.
const List<String> kDefaultColorPalette = [
  '#5C3A21', // 다크 브라운
  '#A87455', // 미디엄 브라운
  '#E8C547', // 옐로우
  '#D64545', // 레드
  '#3F5BA9', // 블루
  '#2E7D5B', // 그린
  '#7C3AA8', // 퍼플
  '#222222', // 블랙
  '#F5F5F5', // 화이트
];
