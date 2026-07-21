import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/dimensions.dart';
import '../../data/paperdoll_renderer.dart';
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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: DottieColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 30,
                color: DottieColors.textHint,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '준비 중이에요',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: DottieColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '곧 새로운 옵션을 만나볼 수 있어요',
              style: TextStyle(
                fontSize: 12,
                color: DottieColors.textHint,
              ),
            ),
          ],
        ),
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

/// LPC sprite sheet에서 정면(row 2) 첫 프레임만 잘라 보여주는 썸네일.
///
/// `Image.asset`은 시트 전체(832x256)를 그대로 보여주므로 부적합.
/// 실제 캐릭터 영역(64x64 frame)만 crop해 표시한다.
class _Thumbnail extends StatefulWidget {
  const _Thumbnail({required this.assetPath});
  final String assetPath;

  @override
  State<_Thumbnail> createState() => _ThumbnailState();
}

class _ThumbnailState extends State<_Thumbnail> {
  ui.Image? _image;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _Thumbnail old) {
    super.didUpdateWidget(old);
    if (old.assetPath != widget.assetPath) {
      _image = null;
      _failed = false;
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final data = await rootBundle.load(widget.assetPath);
      final image = await decodeImageFromList(data.buffer.asUint8List());
      if (!mounted) return;
      setState(() => _image = image);
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return const Center(
        child: Icon(Icons.image_outlined,
            size: 24, color: DottieColors.textHint),
      );
    }
    if (_image == null) {
      return const SizedBox.shrink();
    }
    return CustomPaint(
      painter: _SpriteFramePainter(
        image: _image!,
        frameW: 64,
        frameH: 64,
        frameIndex: 0,
        frameRow: kLpcFrontFacingRow,
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _SpriteFramePainter extends CustomPainter {
  _SpriteFramePainter({
    required this.image,
    required this.frameW,
    required this.frameH,
    required this.frameIndex,
    required this.frameRow,
  });

  final ui.Image image;
  final int frameW;
  final int frameH;
  final int frameIndex;
  final int frameRow;

  @override
  void paint(Canvas canvas, Size size) {
    final maxRow = (image.height ~/ frameH) - 1;
    final safeRow = frameRow.clamp(0, maxRow < 0 ? 0 : maxRow);
    final src = Rect.fromLTWH(
      (frameIndex * frameW).toDouble(),
      (safeRow * frameH).toDouble(),
      frameW.toDouble(),
      frameH.toDouble(),
    );
    // contain fit — 정사각형 프레임을 정사각형 영역에 맞춤
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..filterQuality = FilterQuality.none
      ..isAntiAlias = false;
    canvas.drawImageRect(image, src, dst, paint);
  }

  @override
  bool shouldRepaint(_SpriteFramePainter old) =>
      old.image != image ||
      old.frameIndex != frameIndex ||
      old.frameRow != frameRow;
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
