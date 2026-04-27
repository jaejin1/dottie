import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/dottie_app_bar.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../recording/presentation/recording_provider.dart';
import '../../recording/presentation/dot_input_sheet.dart';
import '../../recording/presentation/widgets/recording_fab.dart';
import '../domain/day_log_model.dart';
import 'timeline_provider.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  bool _isCalendarView = true;
  DateTime _focusedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final dayLogsAsync = ref.watch(timelineDayLogsProvider);
    final sessionAsync = ref.watch(activeRecordingProvider);
    final isRecording = sessionAsync.valueOrNull != null;

    return Scaffold(
      backgroundColor: DottieColors.background,
      appBar: DottieAppBar(
        title: 'Dottie',
        actions: [
          IconButton(
            icon: Icon(
              _isCalendarView ? Icons.view_list_rounded : Icons.calendar_month_rounded,
            ),
            onPressed: () => setState(() => _isCalendarView = !_isCalendarView),
          ),
        ],
      ),
      body: dayLogsAsync.when(
        data: (dayLogs) => _isCalendarView
            ? _CalendarView(
                dayLogs: dayLogs,
                focusedMonth: _focusedMonth,
                onMonthChanged: (m) => setState(() => _focusedMonth = m),
              )
            : _ListView(dayLogs: dayLogs),
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('오류: $e')),
      ),
      // 기록 중 배너
      bottomSheet: isRecording
          ? _RecordingBanner(
              dotCount: sessionAsync.valueOrNull?.dots.length ?? 0)
          : null,
      floatingActionButton: RecordingFab(
        onDotTap: () => DotInputSheet.show(context),
      ),
    );
  }
}

// ── 캘린더 뷰 ──────────────────────────────────────────

class _CalendarView extends StatelessWidget {
  const _CalendarView({
    required this.dayLogs,
    required this.focusedMonth,
    required this.onMonthChanged,
  });
  final List<DayLog> dayLogs;
  final DateTime focusedMonth;
  final ValueChanged<DateTime> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final recordedDays = dayLogs.map((d) => DottieDateUtils.toDateString(d.date)).toSet();

    return Column(
      children: [
        // 월 네비게이터
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => onMonthChanged(DateTime(
                    focusedMonth.year, focusedMonth.month - 1)),
              ),
              Text(
                '${focusedMonth.year}년 ${focusedMonth.month}월',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => onMonthChanged(DateTime(
                    focusedMonth.year, focusedMonth.month + 1)),
              ),
            ],
          ),
        ),

        // 요일 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['일', '월', '화', '수', '목', '금', '토']
                .map((d) => SizedBox(
                      width: 40,
                      child: Text(d,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12,
                              color: DottieColors.textSecondary,
                              fontWeight: FontWeight.w600)),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 4),

        // 날짜 그리드
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.sm),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: _daysInView(focusedMonth),
            itemBuilder: (context, index) {
              final day = _dayAtIndex(focusedMonth, index);
              if (day == null) return const SizedBox.shrink();

              final dateStr = DottieDateUtils.toDateString(day);
              final hasRecord = recordedDays.contains(dateStr);
              final isToday = DottieDateUtils.isSameDay(day, DateTime.now());

              return GestureDetector(
                onTap: hasRecord
                    ? () {
                        final log = dayLogs.firstWhere(
                          (d) => DottieDateUtils.isSameDay(d.date, day),
                        );
                        context.push(AppRoutes.mapAnimation
                            .replaceFirst(':id', log.id));
                      }
                    : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isToday
                            ? DottieColors.primary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isToday
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isToday
                                ? Colors.white
                                : DottieColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    if (hasRecord)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: DottieColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  int _daysInView(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    return firstDay.weekday % 7 + lastDay.day;
  }

  DateTime? _dayAtIndex(DateTime month, int index) {
    final firstDay = DateTime(month.year, month.month, 1);
    final offset = firstDay.weekday % 7;
    final dayNum = index - offset + 1;
    if (dayNum < 1) return null;
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    if (dayNum > lastDay) return null;
    return DateTime(month.year, month.month, dayNum);
  }
}

// ── 리스트 뷰 ──────────────────────────────────────────

class _ListView extends StatelessWidget {
  const _ListView({required this.dayLogs});
  final List<DayLog> dayLogs;

  @override
  Widget build(BuildContext context) {
    if (dayLogs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🔵', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text('아직 기록이 없어요.\n첫 dot을 찍어봐요!',
                textAlign: TextAlign.center,
                style: TextStyle(color: DottieColors.textSecondary, height: 1.6)),
          ],
        ),
      );
    }

    final sorted = [...dayLogs]..sort((a, b) => b.date.compareTo(a.date));

    return ListView.separated(
      padding: const EdgeInsets.all(Dimensions.md),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: Dimensions.sm),
      itemBuilder: (context, i) => _DayLogCard(
        dayLog: sorted[i],
        onTap: () => context
            .push(AppRoutes.mapAnimation.replaceFirst(':id', sorted[i].id)),
      ),
    );
  }
}

class _DayLogCard extends StatelessWidget {
  const _DayLogCard({required this.dayLog, required this.onTap});
  final DayLog dayLog;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: DottieColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                ),
                child: const Center(
                  child: Text('🔵', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: Dimensions.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DottieDateUtils.toKoreanDate(dayLog.date),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'dot ${dayLog.dots.length}개',
                      style: const TextStyle(
                          color: DottieColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (dayLog.isRecording)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: DottieColors.error.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle,
                          size: 8, color: DottieColors.error),
                      SizedBox(width: 4),
                      Text('기록 중',
                          style: TextStyle(
                              fontSize: 11,
                              color: DottieColors.error,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                )
              else
                const Icon(Icons.chevron_right_rounded,
                    color: DottieColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 기록 중 배너 ──────────────────────────────────────

class _RecordingBanner extends StatelessWidget {
  const _RecordingBanner({required this.dotCount});
  final int dotCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.md, vertical: Dimensions.sm),
      color: DottieColors.primary,
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            '기록 중 · dot $dotCount개',
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13),
          ),
        ],
      ),
    );
  }
}
