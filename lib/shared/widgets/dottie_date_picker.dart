import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';

/// 모던 바텀시트 캘린더. 오늘 날짜 강조, 선택일 solid fill, 깔끔한 레이아웃.
Future<DateTime?> showDottieDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: DottieColors.background,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _DottieDatePickerSheet(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    ),
  );
}

class _DottieDatePickerSheet extends StatefulWidget {
  const _DottieDatePickerSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_DottieDatePickerSheet> createState() => _DottieDatePickerSheetState();
}

class _DottieDatePickerSheetState extends State<_DottieDatePickerSheet> {
  late DateTime _focused; // 현재 보고 있는 연/월
  late DateTime _selected;

  final _today = DateUtils.dateOnly(DateTime.now());

  @override
  void initState() {
    super.initState();
    _selected = DateUtils.dateOnly(widget.initialDate);
    _focused = DateTime(_selected.year, _selected.month);
  }

  void _prevMonth() {
    final prev = DateTime(_focused.year, _focused.month - 1);
    if (!prev.isBefore(DateTime(widget.firstDate.year, widget.firstDate.month))) {
      setState(() => _focused = prev);
    }
  }

  void _nextMonth() {
    final next = DateTime(_focused.year, _focused.month + 1);
    if (!next.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month))) {
      setState(() => _focused = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: DottieColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          _buildMonthHeader(),
          const SizedBox(height: 16),
          _buildWeekdayRow(),
          const SizedBox(height: 8),
          _buildDayGrid(),
          const SizedBox(height: 16),
          _buildActions(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMonthHeader() {
    final canPrev = !DateTime(_focused.year, _focused.month)
        .isBefore(DateTime(widget.firstDate.year, widget.firstDate.month + 1));
    final canNext = !DateTime(_focused.year, _focused.month)
        .isAfter(DateTime(widget.lastDate.year, widget.lastDate.month - 1));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.md),
      child: Row(
        children: [
          Text(
            '${_focused.year}년 ${_focused.month}월',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: DottieColors.textPrimary,
            ),
          ),
          const Spacer(),
          _NavButton(
            icon: Icons.chevron_left_rounded,
            onTap: canPrev ? _prevMonth : null,
          ),
          const SizedBox(width: 4),
          _NavButton(
            icon: Icons.chevron_right_rounded,
            onTap: canNext ? _nextMonth : null,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayRow() {
    const labels = ['일', '월', '화', '수', '목', '금', '토'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.md),
      child: Row(
        children: labels
            .map(
              (l) => Expanded(
                child: Center(
                  child: Text(
                    l,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: l == '일'
                          ? DottieColors.error.withValues(alpha: 0.7)
                          : l == '토'
                              ? DottieColors.primary.withValues(alpha: 0.7)
                              : DottieColors.textSecondary,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildDayGrid() {
    final firstOfMonth = DateTime(_focused.year, _focused.month, 1);
    final startWeekday = firstOfMonth.weekday % 7; // 일=0
    final daysInMonth =
        DateUtils.getDaysInMonth(_focused.year, _focused.month);

    final cells = <Widget>[];

    // 앞 빈칸
    for (var i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focused.year, _focused.month, day);
      final isSelected = DateUtils.isSameDay(date, _selected);
      final isToday = DateUtils.isSameDay(date, _today);
      final inRange = !date.isBefore(widget.firstDate) &&
          !date.isAfter(widget.lastDate);

      cells.add(_DayCell(
        day: day,
        isSelected: isSelected,
        isToday: isToday,
        enabled: inRange,
        weekday: date.weekday % 7,
        onTap: inRange ? () => setState(() => _selected = date) : null,
      ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.md),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 4,
        crossAxisSpacing: 0,
        childAspectRatio: 1,
        children: cells,
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.md),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: DottieColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: DottieColors.border),
                ),
              ),
              child: const Text(
                '취소',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: TextButton(
              onPressed: () => Navigator.pop(context, _selected),
              style: TextButton.styleFrom(
                backgroundColor: DottieColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '확인',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.enabled,
    required this.weekday,
    required this.onTap,
  });

  final int day;
  final bool isSelected;
  final bool isToday;
  final bool enabled;
  final int weekday; // 0=일, 6=토
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color textColor;
    if (!enabled) {
      textColor = DottieColors.textPrimary.withValues(alpha: 0.2);
    } else if (isSelected) {
      textColor = Colors.white;
    } else if (weekday == 0) {
      textColor = DottieColors.error.withValues(alpha: 0.75);
    } else if (weekday == 6) {
      textColor = DottieColors.primary.withValues(alpha: 0.75);
    } else {
      textColor = DottieColors.textPrimary;
    }

    // behavior: opaque — 셀 전체(원 바깥 여백 포함)를 터치 영역으로
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: isSelected
              ? const BoxDecoration(
                  color: DottieColors.primary,
                  shape: BoxShape.circle,
                )
              : isToday && enabled
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: DottieColors.primary, width: 1.5),
                    )
                  : null,
          child: Center(
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    isSelected || isToday ? FontWeight.w700 : FontWeight.w400,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: DottieColors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap != null
              ? DottieColors.textPrimary
              : DottieColors.textPrimary.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}

/// 여행 날짜 범위 선택 위젯 (출발일 · 도착일 인라인 필드).
class DateRangeField extends StatelessWidget {
  const DateRangeField({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartTap,
    required this.onEndTap,
  });

  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;

  @override
  Widget build(BuildContext context) {
    String fmt(DateTime d) =>
        '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
    final nights = endDate.difference(startDate).inDays;
    final durationLabel =
        nights == 0 ? '당일치기' : '$nights박 ${nights + 1}일';

    return Container(
      decoration: BoxDecoration(
        color: DottieColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onStartTap,
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(Dimensions.radiusMd)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: Dimensions.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '출발일',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color:
                            DottieColors.textPrimary.withValues(alpha: 0.45),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fmt(startDate),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: DottieColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(width: 1, height: 40, color: DottieColors.border),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              durationLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: DottieColors.primary,
              ),
            ),
          ),
          Container(width: 1, height: 40, color: DottieColors.border),
          Expanded(
            child: InkWell(
              onTap: onEndTap,
              borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(Dimensions.radiusMd)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: Dimensions.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '도착일',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color:
                            DottieColors.textPrimary.withValues(alpha: 0.45),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fmt(endDate),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: DottieColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
