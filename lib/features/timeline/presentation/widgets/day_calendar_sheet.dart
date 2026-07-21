import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/day_log_model.dart';
import '../timeline_provider.dart';

/// 기록된 날짜를 그리드로 보여주는 다크 캘린더 바텀시트.
/// `currentDayLogId`에 해당하는 날짜는 채운 원, 오늘은 테두리 원으로 표시.
/// 기록된 날짜만 탭 가능. 탭 시 시트가 닫히고 `onDateSelected`가 호출된다.
class DayCalendarSheet extends ConsumerStatefulWidget {
  const DayCalendarSheet({
    super.key,
    required this.currentDayLogId,
    required this.onDateSelected,
  });

  /// 현재 선택되어 있는 dayLog ID (없으면 null).
  final String? currentDayLogId;

  /// 날짜 선택 콜백. 시트가 닫힌 뒤 호출된다.
  final void Function(DayLog) onDateSelected;

  static Future<void> show(
    BuildContext context, {
    required String? currentDayLogId,
    required void Function(DayLog) onDateSelected,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DayCalendarSheet(
        currentDayLogId: currentDayLogId,
        onDateSelected: onDateSelected,
      ),
    );
  }

  @override
  ConsumerState<DayCalendarSheet> createState() => _DayCalendarSheetState();
}

class _DayCalendarSheetState extends ConsumerState<DayCalendarSheet> {
  late DateTime _viewMonth;
  bool _monthInitialized = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _viewMonth = DateTime(now.year, now.month);
  }

  void _changeMonth(int delta) {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(timelineDayLogsProvider);

    return logsAsync.when(
      loading: () => _buildSheet(context, const {}, null),
      error: (_, __) => _buildSheet(context, const {}, null),
      data: (logs) {
        // 처음 로드 시 현재 선택된 날짜의 월로 이동
        if (!_monthInitialized) {
          try {
            final cur =
                logs.firstWhere((l) => l.id == widget.currentDayLogId);
            final local = cur.date.toLocal();
            _viewMonth = DateTime(local.year, local.month);
          } catch (_) {}
          _monthInitialized = true;
        }

        final activeMap = <String, DayLog>{};
        for (final log in logs) {
          activeMap[DottieDateUtils.toDateString(log.date.toLocal())] = log;
        }

        DateTime? selectedDate;
        try {
          selectedDate = logs
              .firstWhere((l) => l.id == widget.currentDayLogId)
              .date
              .toLocal();
        } catch (_) {}

        return _buildSheet(context, activeMap, selectedDate);
      },
    );
  }

  Widget _buildSheet(
    BuildContext context,
    Map<String, DayLog> activeMap,
    DateTime? selectedDate,
  ) {
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
                      _CalNavButton(
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
                      _CalNavButton(
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
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: firstWeekday + daysInMonth,
                    itemBuilder: (_, idx) {
                      if (idx < firstWeekday) return const SizedBox.shrink();
                      final day = idx - firstWeekday + 1;
                      final date =
                          DateTime(_viewMonth.year, _viewMonth.month, day);
                      final dateStr = DottieDateUtils.toDateString(date);
                      final log = activeMap[dateStr];
                      final isSelected = selectedDate != null &&
                          DottieDateUtils.isSameDay(date, selectedDate);
                      final isToday = DottieDateUtils.isSameDay(date, today);
                      return _CalDayCell(
                        day: day,
                        hasRecord: log != null,
                        selected: isSelected,
                        today: isToday,
                        onTap: log != null
                            ? () {
                                Navigator.of(context).pop();
                                widget.onDateSelected(log);
                              }
                            : null,
                      );
                    },
                  ),
                  const SizedBox(height: Dimensions.sm),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalNavButton extends StatelessWidget {
  const _CalNavButton({required this.icon, required this.onTap});
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

class _CalDayCell extends StatelessWidget {
  const _CalDayCell({
    required this.day,
    required this.hasRecord,
    required this.selected,
    required this.today,
    required this.onTap,
  });
  final int day;
  final bool hasRecord;
  final bool selected;
  final bool today;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final BoxDecoration circleDecoration;
    final Color textColor;

    if (selected) {
      circleDecoration = const BoxDecoration(
        color: DottieColors.primary,
        shape: BoxShape.circle,
      );
      textColor = Colors.white;
    } else if (today) {
      circleDecoration = BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: DottieColors.primary, width: 1.5),
      );
      textColor = DottieColors.primary;
    } else {
      circleDecoration = const BoxDecoration(shape: BoxShape.circle);
      textColor = hasRecord ? Colors.white : Colors.white.withAlpha(50);
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: circleDecoration,
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: selected || today || hasRecord
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasRecord && !selected
                  ? DottieColors.primary
                  : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
