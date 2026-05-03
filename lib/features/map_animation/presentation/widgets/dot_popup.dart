import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../recording/domain/dot_model.dart';

class DotPopup extends StatefulWidget {
  const DotPopup({super.key, required this.dot, required this.onDismiss});

  final Dot dot;
  final VoidCallback onDismiss;

  @override
  State<DotPopup> createState() => _DotPopupState();
}

class _DotPopupState extends State<DotPopup>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();

    // 3초 후 자동 닫기
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _dismiss();
    });
  }

  void _dismiss() async {
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTap: _dismiss,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 220),
            padding: const EdgeInsets.all(Dimensions.md),
            decoration: BoxDecoration(
              color: DottieColors.surface,
              borderRadius: BorderRadius.circular(Dimensions.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 사진 썸네일
                if (widget.dot.photoUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSm),
                    child: Image.network(
                      widget.dot.photoUrl!,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : const SizedBox(
                              height: 120,
                              child: Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                            ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.sm),
                ],

                // 장소명 + 시간
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        color: DottieColors.primary, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.dot.placeName ?? '이 곳',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  DottieDateUtils.toTimeString(widget.dot.timestamp),
                  style: const TextStyle(
                      fontSize: 11, color: DottieColors.textSecondary),
                ),

                // 감정 이모지
                if (widget.dot.emotion != null) ...[
                  const SizedBox(height: 4),
                  Text(widget.dot.emotion!,
                      style: const TextStyle(fontSize: 20)),
                ],

                // 메모
                if (widget.dot.memo != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.dot.memo!,
                    style: const TextStyle(
                        fontSize: 12, color: DottieColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                Align(
                  alignment: Alignment.centerRight,
                  child: Text('닫기',
                      style: TextStyle(
                          fontSize: 10, color: DottieColors.textHint)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
