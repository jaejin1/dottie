import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/date_utils.dart';

/// 다크 글래스 캘린더 시트.
///
/// `activeDates` 에 들어있는 `YYYY-MM-DD` 만 탭 가능 (활동 점 표시).
/// 선택 시 `Navigator.pop(DateTime)`. 취소 시 null.
///
/// 룸 / 홈 / 누적 공통. 호출 측이 activeDates 를 직접 watch.
class DateCalendarSheet extends StatefulWidget {
  const DateCalendarSheet({
    super.key,
    required this.selectedDate,
    required this.activeDates,
  });

  final DateTime selectedDate;
  final Set<String> activeDates;

  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime selectedDate,
    required Set<String> activeDates,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DateCalendarSheet(
        selectedDate: selectedDate,
        activeDates: activeDates,
      ),
    );
  }

  @override
  State<DateCalendarSheet> createState() => _DateCalendarSheetState();
}

class _DateCalendarSheetState extends State<DateCalendarSheet> {
  late DateTime _viewMonth;

  @override
  void initState() {
    super.initState();
    _viewMonth =
        DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  void _changeMonth(int delta) {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateUtils.getDaysInMonth(_viewMonth.year, _viewMonth.month);
    final firstWeekday =
        DateTime(_viewMonth.year, _viewMonth.month, 1).weekday % 7;
    final today = DottieDateUtils.todayStart();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1B1E).withAlpha(240),
            border: Border(
              top: BorderSide(color: Colors.white.withAlpha(28), width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  Dimensions.md, Dimensions.sm, Dimensions.md, Dimensions.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(60),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: Dimensions.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CalendarNavButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: () => _changeMonth(-1),
                      ),
                      Text(
                        DottieDateUtils.toKoreanYearMonth(_viewMonth),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _CalendarNavButton(
                        icon: Icons.chevron_right_rounded,
                        onTap: () => _changeMonth(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.md),
                  Row(
                    children: ['일', '월', '화', '수', '목', '금', '토']
                        .map((d) => Expanded(
                              child: Text(
                                d,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withAlpha(120),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: Dimensions.sm),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: firstWeekday + daysInMonth,
                    itemBuilder: (_, idx) {
                      if (idx < firstWeekday) return const SizedBox.shrink();
                      final day = idx - firstWeekday + 1;
                      final date =
                          DateTime(_viewMonth.year, _viewMonth.month, day);
                      final dateStr = DottieDateUtils.toDateString(date);
                      final hasRecord = widget.activeDates.contains(dateStr);
                      final isSelected = DottieDateUtils.isSameDay(
                          date, widget.selectedDate);
                      final isToday = DottieDateUtils.isSameDay(date, today);
                      return _CalendarDayCell(
                        day: day,
                        active: hasRecord,
                        selected: isSelected,
                        today: isToday,
                        onTap: hasRecord
                            ? () {
                                HapticFeedback.lightImpact();
                                Navigator.of(context).pop(date);
                              }
                            : null,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarNavButton extends StatelessWidget {
  const _CalendarNavButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          shape: BoxShape.circle,
          border: Border.all(color: DottieColors.borderGlass, width: 1),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.active,
    required this.selected,
    required this.today,
    required this.onTap,
  });

  final int day;
  final bool active;
  final bool selected;
  final bool today;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final BoxDecoration? decoration;
    final Color textColor;
    if (selected) {
      decoration = const BoxDecoration(
        color: DottieColors.primary,
        shape: BoxShape.circle,
      );
      textColor = Colors.white;
    } else if (today) {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: DottieColors.primary.withAlpha(180), width: 1.5),
      );
      textColor = Colors.white;
    } else {
      decoration = null;
      textColor = active
          ? Colors.white
          : Colors.white.withAlpha(60);
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: decoration,
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: selected || today
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ),
          if (active && !selected)
            Positioned(
              bottom: 2,
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: DottieColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
