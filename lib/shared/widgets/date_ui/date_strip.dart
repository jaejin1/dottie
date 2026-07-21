import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/date_utils.dart';

/// 상단 헤더 아래의 가로 스크롤 날짜 chip row. 오늘 ~ 과거 30일.
///
/// `activeDates` 에 포함된 날짜만 탭 가능 (활동 점 표시).
/// 선택된 날짜 = 채워진 원, 오늘 = 테두리 원.
///
/// 룸 / 홈 공통. 룸은 sharedDates, 홈은 user 자신의 daylog dates 를 주입.
class DateStrip extends StatefulWidget {
  const DateStrip({
    super.key,
    required this.selectedDate,
    required this.activeDates,
    required this.onDateSelected,
    required this.isDaytime,
    this.daysBack = 30,
  });

  final DateTime selectedDate;
  final Set<String> activeDates;
  final ValueChanged<DateTime> onDateSelected;
  final bool isDaytime;
  final int daysBack;

  @override
  State<DateStrip> createState() => _DateStripState();
}

class _DateStripState extends State<DateStrip> {
  late final ScrollController _scrollController;
  static const double _cellWidth = 40.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
  }

  @override
  void didUpdateWidget(covariant DateStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!DottieDateUtils.isSameDay(oldWidget.selectedDate, widget.selectedDate)) {
      _scrollToSelected();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelected() {
    if (!_scrollController.hasClients) return;
    final today = DottieDateUtils.todayStart();
    final selected = DateTime(
        widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day);
    final daysAgo = today.difference(selected).inDays;
    if (daysAgo < 0 || daysAgo >= widget.daysBack) return;
    final indexFromStart = widget.daysBack - 1 - daysAgo;
    final viewportWidth = _scrollController.position.viewportDimension;
    final targetOffset = (indexFromStart * _cellWidth) -
        (viewportWidth / 2) +
        (_cellWidth / 2);
    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _onDateTap(DateTime date) {
    if (DottieDateUtils.isSameDay(date, widget.selectedDate)) return;
    HapticFeedback.lightImpact();
    widget.onDateSelected(date);
  }

  @override
  Widget build(BuildContext context) {
    final today = DottieDateUtils.todayStart();

    final bg = widget.isDaytime
        ? const Color(0xCC1C1C1E)
        : Colors.white.withAlpha(22);
    final border = widget.isDaytime
        ? Colors.white.withAlpha(20)
        : Colors.white.withAlpha(45);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimensions.md, Dimensions.sm, Dimensions.md, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: border, width: 1),
            ),
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: widget.daysBack,
              itemBuilder: (_, idx) {
                final daysAgo = widget.daysBack - 1 - idx;
                final date = today.subtract(Duration(days: daysAgo));
                final dateStr = DottieDateUtils.toDateString(date);
                final isActive = widget.activeDates.contains(dateStr);
                final isSelected =
                    DottieDateUtils.isSameDay(date, widget.selectedDate);
                final isToday = daysAgo == 0;
                return _DateStripCell(
                  date: date,
                  isActive: isActive,
                  isSelected: isSelected,
                  isToday: isToday,
                  onTap: isActive ? () => _onDateTap(date) : null,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _DateStripCell extends StatelessWidget {
  const _DateStripCell({
    required this.date,
    required this.isActive,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final bool isActive;
  final bool isSelected;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final BoxDecoration? deco;
    final Color textColor;
    if (isSelected) {
      deco = const BoxDecoration(
        color: DottieColors.primary,
        shape: BoxShape.circle,
      );
      textColor = Colors.white;
    } else if (isToday) {
      deco = BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: DottieColors.primary.withAlpha(180), width: 1.5),
      );
      textColor = Colors.white;
    } else {
      deco = null;
      textColor = isActive ? Colors.white : Colors.white.withAlpha(70);
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: _DateStripState._cellWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ['일', '월', '화', '수', '목', '금', '토'][date.weekday % 7],
              style: TextStyle(
                color: isActive
                    ? Colors.white.withAlpha(160)
                    : Colors.white.withAlpha(60),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 30,
              height: 30,
              decoration: deco,
              alignment: Alignment.center,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: isSelected || isToday
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 2),
            if (isActive && !isSelected)
              Container(
                width: 3,
                height: 3,
                decoration: const BoxDecoration(
                  color: DottieColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
