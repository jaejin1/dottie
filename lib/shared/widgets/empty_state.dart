import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/constants/typography.dart';

/// 빈 상태 공통 표현 — 부드러운 큰 원형 아이콘 + 제목 + 설명 + 선택 CTA.
///
/// feed/spot/룸/검색 등 모든 빈 상태 화면이 같은 톤을 갖도록 통일.
/// 기존에 화면마다 outlined icon + 작은 텍스트로 다 다르게 표현되던 것 대체.
///
/// 예시:
/// ```dart
/// EmptyState(
///   icon: Icons.place_rounded,
///   title: '가고 싶은 곳을 모아보세요',
///   description: '오른쪽 아래 + 버튼으로 스팟을 추가할 수 있어요',
///   actionLabel: '스팟 추가',
///   onAction: () => ...,
/// )
/// ```
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.iconBackgroundColor,
  });

  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// 아이콘 색. 기본 [DottieColors.primary].
  final Color? iconColor;

  /// 원형 배경 색. 기본 primary alpha 0.08.
  final Color? iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? DottieColors.primary;
    final bg = iconBackgroundColor ?? color.withValues(alpha: 0.08);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(height: Dimensions.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.title(
                fontSize: 15.5,
                color: DottieColors.textPrimary.withValues(alpha: 0.85),
              ).copyWith(letterSpacing: -0.3),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: AppTypography.hint(
                  fontSize: 12.5,
                  color: DottieColors.textPrimary.withValues(alpha: 0.5),
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: Dimensions.lg),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  backgroundColor: DottieColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusMd),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
