import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../recording/data/dot_repository.dart';
import '../../recording/presentation/recording_provider.dart';
import '../../recording/presentation/widgets/recording_speed_dial.dart';
import '../../settings/domain/auto_record_settings.dart';
import '../../settings/presentation/auto_record_chip.dart';
import '../../settings/presentation/auto_record_provider.dart';
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
    final session = ref.watch(activeRecordingProvider).valueOrNull;
    final isRecording = session != null;
    final autoInterval =
        ref.watch(autoRecordNotifierProvider).valueOrNull ?? AutoRecordInterval.manual;
    final isAutoRecording = autoInterval != AutoRecordInterval.manual;

    return Scaffold(
      backgroundColor: DottieColors.background,
      appBar: AppBar(
        title: Text(
          'Dottie',
          style: GoogleFonts.notoSansKr(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: DottieColors.textPrimary,
            letterSpacing: -1.2,
            height: 1,
          ),
        ),
        centerTitle: false,
        backgroundColor: DottieColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(
              child: isAutoRecording
                  ? _AutoRecordingBadge(interval: autoInterval)
                  : _DotHintBadge(hasDotToday: isRecording),
            ),
          ),
          IconButton(
            icon: Icon(
              _isCalendarView
                  ? Icons.view_list_rounded
                  : Icons.calendar_month_rounded,
              color: DottieColors.textSecondary,
              size: 22,
            ),
            onPressed: () =>
                setState(() => _isCalendarView = !_isCalendarView),
          ),
        ],
      ),
      body: dayLogsAsync.when(
        data: (dayLogs) => AnimatedSwitcher(
          duration: 250.ms,
          child: _isCalendarView
              ? _CalendarView(
                  key: const ValueKey('calendar'),
                  dayLogs: dayLogs,
                  focusedMonth: _focusedMonth,
                  onMonthChanged: (m) => setState(() => _focusedMonth = m),
                )
              : _ListView(
                  key: const ValueKey('list'),
                  dayLogs: dayLogs,
                ),
        ),
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('오류: $e')),
      ),
      floatingActionButton: const RecordingSpeedDial(),
    );
  }
}

// ── 캘린더 뷰 ──────────────────────────────────────────────────────────────

class _CalendarView extends StatelessWidget {
  const _CalendarView({
    super.key,
    required this.dayLogs,
    required this.focusedMonth,
    required this.onMonthChanged,
  });

  final List<DayLog> dayLogs;
  final DateTime focusedMonth;
  final ValueChanged<DateTime> onMonthChanged;

  @override
  Widget build(BuildContext context) {
    final recordedDays =
        dayLogs.map((d) => DottieDateUtils.toDateString(d.date)).toSet();
    final dayLogsMap = {
      for (final d in dayLogs) DottieDateUtils.toDateString(d.date): d,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 월 헤더
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${focusedMonth.month}월',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: DottieColors.textPrimary,
                        letterSpacing: -1.5,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      '${focusedMonth.year}',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: DottieColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 22),
                color: DottieColors.textSecondary,
                onPressed: () => onMonthChanged(
                    DateTime(focusedMonth.year, focusedMonth.month - 1)),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 22),
                color: DottieColors.textSecondary,
                onPressed: () => onMonthChanged(
                    DateTime(focusedMonth.year, focusedMonth.month + 1)),
              ),
            ],
          ),
        ),

        // 요일 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: ['일', '월', '화', '수', '목', '금', '토']
                .asMap()
                .entries
                .map(
                  (e) => Expanded(
                    child: Text(
                      e.value,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: e.key == 0
                            ? DottieColors.error.withAlpha(160)
                            : e.key == 6
                                ? DottieColors.primary.withAlpha(180)
                                : DottieColors.textHint,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 6),

        // 날짜 그리드
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.88,
            ),
            itemCount: _daysInView(focusedMonth),
            itemBuilder: (context, index) {
              final day = _dayAtIndex(focusedMonth, index);
              if (day == null) return const SizedBox.shrink();

              final dateStr = DottieDateUtils.toDateString(day);
              final hasRecord = recordedDays.contains(dateStr);
              final isToday = DottieDateUtils.isSameDay(day, DateTime.now());
              final isSunday = day.weekday == DateTime.sunday;
              final isSaturday = day.weekday == DateTime.saturday;

              return GestureDetector(
                onTap: isToday
                    ? () => context.push(AppRoutes.today)
                    : hasRecord
                        ? () {
                            final log = dayLogsMap[dateStr]!;
                            context.push(AppRoutes.mapAnimation
                                .replaceFirst(':id', log.id));
                          }
                        : null,
                child: Center(
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: hasRecord ? DottieColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday && !hasRecord
                          ? Border.all(color: DottieColors.primary, width: 1.5)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${day.day}',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 13,
                          fontWeight: hasRecord || isToday
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: hasRecord
                              ? Colors.white
                              : isToday
                                  ? DottieColors.primary
                                  : isSunday
                                      ? DottieColors.error.withAlpha(160)
                                      : isSaturday
                                          ? DottieColors.primary.withAlpha(180)
                                          : DottieColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // 이번 달 기록 요약
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: DottieColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '이번 달 ${_recordedDaysInMonth(recordedDays, focusedMonth)}일 기록',
                style: GoogleFonts.notoSansKr(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: DottieColors.textHint,
                ),
              ),
            ],
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

  int _recordedDaysInMonth(Set<String> recordedDays, DateTime month) {
    return recordedDays.where((d) {
      final date = DateTime.tryParse(d);
      return date != null &&
          date.year == month.year &&
          date.month == month.month;
    }).length;
  }
}

// ── 리스트 뷰 ──────────────────────────────────────────────────────────────

class _ListView extends ConsumerWidget {
  const _ListView({super.key, required this.dayLogs});
  final List<DayLog> dayLogs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (dayLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: DottieColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                size: 32,
                color: DottieColors.primary,
              ),
            ).animate().scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 400.ms,
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: 16),
            Text(
              '아직 기록이 없어요',
              style: GoogleFonts.notoSansKr(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: DottieColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '첫 dot을 찍어봐요!',
              style: GoogleFonts.notoSansKr(
                fontSize: 14,
                color: DottieColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    final sorted = [...dayLogs]..sort((a, b) => b.date.compareTo(a.date));

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final log = sorted[i];
        final isToday = DottieDateUtils.isSameDay(log.date, DateTime.now());
        return _DismissibleCard(
          key: ValueKey(log.id),
          dayLog: log,
          onTap: isToday
              ? () => context.push(AppRoutes.today)
              : () => context.push(
                  AppRoutes.mapAnimation.replaceFirst(':id', log.id)),
          onDelete: () => _deleteDayLog(context, ref, log),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: (i * 35).ms)
            .slideX(
              begin: 0.05,
              end: 0,
              duration: 300.ms,
              delay: (i * 35).ms,
              curve: Curves.easeOutCubic,
            );
      },
    );
  }

  Future<void> _deleteDayLog(
      BuildContext context, WidgetRef ref, DayLog log) async {
    try {
      await ref.read(dotRepositoryProvider).deleteDayLog(log.id);
      // 오늘 daylog 삭제 시 activeRecording 리셋
      if (DottieDateUtils.isSameDay(log.date, DateTime.now())) {
        ref.invalidate(activeRecordingProvider);
      }
      ref.invalidate(timelineDayLogsProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('삭제에 실패했어요. 잠시 후 다시 시도해 주세요.'),
            backgroundColor: DottieColors.error,
          ),
        );
      }
    }
  }
}

// ── 스와이프/꾹 눌러 삭제 지원 카드 래퍼 ──────────────────────────────────

class _DismissibleCard extends StatelessWidget {
  const _DismissibleCard({
    super.key,
    required this.dayLog,
    required this.onTap,
    required this.onDelete,
  });

  final DayLog dayLog;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(dayLog.id),
      direction: DismissDirection.horizontal,
      background: _DeleteBackground(alignment: Alignment.centerLeft),
      secondaryBackground: _DeleteBackground(alignment: Alignment.centerRight),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => onDelete(),
      child: _DayLogCard(
        dayLog: dayLog,
        onTap: onTap,
        onLongPress: () async {
          final confirmed = await _confirmDelete(context);
          if (confirmed == true) onDelete();
        },
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '기록 삭제',
          style: GoogleFonts.notoSansKr(fontWeight: FontWeight.w700),
        ),
        content: Text(
          '${DottieDateUtils.toKoreanDate(dayLog.date)}의 기록을\n삭제할까요? 되돌릴 수 없어요.',
          style: GoogleFonts.notoSansKr(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              '삭제',
              style: GoogleFonts.notoSansKr(
                color: DottieColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground({required this.alignment});
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: DottieColors.error.withAlpha(220),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
    );
  }
}

class _DayLogCard extends StatelessWidget {
  const _DayLogCard({
    required this.dayLog,
    required this.onTap,
    this.onLongPress,
  });
  final DayLog dayLog;
  final VoidCallback? onLongPress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = DottieDateUtils.isSameDay(dayLog.date, DateTime.now());
    final places = dayLog.dots
        .where((d) => d.placeName != null && d.placeName!.isNotEmpty)
        .map((d) => d.placeName!)
        .toSet()
        .take(2)
        .join(' · ');

    return Material(
      color: DottieColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DottieColors.border, width: 0.8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 왼쪽 컬러 바
                  Container(
                    width: 4,
                    color: isToday && dayLog.isRecording
                        ? DottieColors.error
                        : DottieColors.primary,
                  ),
                  // 콘텐츠
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      DottieDateUtils.toKoreanDate(dayLog.date),
                                      style: GoogleFonts.notoSansKr(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: DottieColors.textPrimary,
                                      ),
                                    ),
                                    if (isToday && dayLog.isRecording) ...[
                                      const SizedBox(width: 8),
                                      _StatusBadge(
                                        label: '기록 중',
                                        color: DottieColors.error,
                                        showDot: true,
                                      ),
                                    ] else if (isToday) ...[
                                      const SizedBox(width: 8),
                                      _StatusBadge(
                                        label: '오늘',
                                        color: DottieColors.primary,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    _DotCountBadge(count: dayLog.dots.length),
                                    if (places.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          places,
                                          style: GoogleFonts.notoSansKr(
                                            fontSize: 12,
                                            color: DottieColors.textHint,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: DottieColors.textHint,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    this.showDot = false,
  });

  final String label;
  final Color color;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Icon(Icons.circle, size: 5, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: GoogleFonts.notoSansKr(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DotCountBadge extends StatelessWidget {
  const _DotCountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: DottieColors.primaryLight,
        borderRadius: BorderRadius.circular(Dimensions.radiusFull),
      ),
      child: Text(
        'dot $count',
        style: GoogleFonts.notoSansKr(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: DottieColors.secondary,
        ),
      ),
    );
  }
}

// ── 자동 기록 중 배지 ─────────────────────────────────────────

class _AutoRecordingBadge extends ConsumerWidget {
  const _AutoRecordingBadge({required this.interval});
  final int interval;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _openSettings(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: DottieColors.primary.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on_rounded,
                size: 11, color: DottieColors.primary),
            const SizedBox(width: 4),
            Text(
              '${AutoRecordInterval.label(interval)} 간격으로 자동 기록 중',
              style: GoogleFonts.notoSansKr(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: DottieColors.primary,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fadeIn(duration: 900.ms, curve: Curves.easeInOut);
  }

  void _openSettings(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: DottieColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => IntervalPickerSheet(current: interval, ref: ref),
    );
  }
}

// ── dot 안내 배지 ─────────────────────────────────────────────

class _DotHintBadge extends ConsumerWidget {
  const _DotHintBadge({required this.hasDotToday});
  final bool hasDotToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        final interval = ref.read(autoRecordNotifierProvider).valueOrNull ??
            AutoRecordInterval.manual;
        showModalBottomSheet(
          context: context,
          backgroundColor: DottieColors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => IntervalPickerSheet(current: interval, ref: ref),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: DottieColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: DottieColors.border, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off_outlined,
                size: 11, color: DottieColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              '자동 기록 꺼짐',
              style: GoogleFonts.notoSansKr(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: DottieColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
