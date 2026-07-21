import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../../../room/domain/room_model.dart';

/// 피드 상단 가로 chip — "전체" + 각 방. 단일 선택.
///
/// [selectedRoomId] 가 null 이면 "전체" 선택 상태. 특정 roomId 면 그 방.
/// chip 탭 시 [onSelect] 호출 (null = 전체).
class RoomFilterChips extends StatelessWidget {
  const RoomFilterChips({
    super.key,
    required this.rooms,
    required this.selectedRoomId,
    required this.onSelect,
  });

  final List<Room> rooms;
  final String? selectedRoomId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _Chip(
            label: '전체',
            color: DottieColors.primary,
            selected: selectedRoomId == null,
            onTap: () => onSelect(null),
            showDot: false,
          ),
          for (final r in rooms) ...[
            const SizedBox(width: 8),
            _Chip(
              label: r.name,
              color: DottieColors.accentFor(r.id),
              selected: selectedRoomId == r.id,
              onTap: () => onSelect(r.id),
              showDot: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
    required this.showDot,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: selected ? DottieColors.primary : DottieColors.surfaceVariant,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected
                ? DottieColors.primary
                : DottieColors.border,
            width: 1,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showDot) ...[
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: selected ? Colors.white : color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : DottieColors.textPrimary,
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
