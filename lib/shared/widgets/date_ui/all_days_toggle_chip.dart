import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// 누적(전체일) 보기 진입용 글래스 pill 칩. "모든날 기록".
///
/// 룸 / 홈 공통. onTap 에서 누적 화면으로 이동.
class AllDaysToggleChip extends StatelessWidget {
  const AllDaysToggleChip({
    super.key,
    required this.onTap,
    required this.isDaytime,
    this.label = '모든날 기록',
    this.icon = Icons.layers_rounded,
  });

  final VoidCallback onTap;
  final bool isDaytime;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final bg = isDaytime
        ? const Color(0xCC1C1C1E)
        : Colors.white.withAlpha(22);
    final border = isDaytime
        ? Colors.white.withAlpha(20)
        : Colors.white.withAlpha(45);
    const fg = Colors.white;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: bg,
              border: Border.all(color: border, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: fg, size: 14),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: fg,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
