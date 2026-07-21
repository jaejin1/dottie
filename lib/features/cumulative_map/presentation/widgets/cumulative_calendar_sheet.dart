import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../room/presentation/room_provider.dart';

/// 누적 지도 → 캘린더 시트. shared_map 의 _DateCalendarSheet 와 같은 디자인.
/// 별도 public 위젯으로 두 화면에서 호출 가능.
class CumulativeCalendarSheet extends ConsumerStatefulWidget {
  const CumulativeCalendarSheet({super.key, required this.roomId});
  final String roomId;

  static Future<DateTime?> show(
    BuildContext context, {
    required String roomId,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CumulativeCalendarSheet(roomId: roomId),
    );
  }

  @override
  ConsumerState<CumulativeCalendarSheet> createState() =>
      _CumulativeCalendarSheetState();
}

class _CumulativeCalendarSheetState
    extends ConsumerState<CumulativeCalendarSheet> {
  late DateTime _viewMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _viewMonth = DateTime(now.year, now.month);
  }

  /// 날짜 long-press → 공유/비공개 토글 시트.
  Future<void> _showShareToggle(
      BuildContext context, DateTime date, bool currentlyShared) async {
    final label = DottieDateUtils.toKoreanMonthDay(date);
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1A1B1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(60),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: Dimensions.md),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: Dimensions.lg),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: Dimensions.sm),
            ListTile(
              leading: Icon(
                currentlyShared
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.white,
              ),
              title: Text(
                currentlyShared ? '이 날 공유 끄기' : '이 날 공유하기',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                currentlyShared
                    ? '룸 멤버에게 더 이상 안 보여요'
                    : '룸 멤버에게 이 날 dot 이 보여요',
                style: TextStyle(
                  color: Colors.white.withAlpha(160),
                  fontSize: 11,
                ),
              ),
              onTap: () => Navigator.of(ctx)
                  .pop(currentlyShared ? 'unshare' : 'share'),
            ),
            const SizedBox(height: Dimensions.sm),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;
    final notifier = ref.read(roomNotifierProvider.notifier);
    if (action == 'share') {
      await notifier.shareDate(widget.roomId, date);
    } else {
      await notifier.unshareDate(widget.roomId, date);
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            action == 'share' ? '$label 공유했어요' : '$label 공유를 껐어요'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateUtils.getDaysInMonth(_viewMonth.year, _viewMonth.month);
    final firstWeekday =
        DateTime(_viewMonth.year, _viewMonth.month, 1).weekday % 7;
    final today = DottieDateUtils.todayStart();
    final activeDates = ref
            .watch(roomDetailProvider(widget.roomId))
            .valueOrNull
            ?.sharedDates
            .toSet() ??
        const <String>{};

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
                      _NavBtn(
                        icon: Icons.chevron_left_rounded,
                        onTap: () => setState(() => _viewMonth =
                            DateTime(_viewMonth.year, _viewMonth.month - 1)),
                      ),
                      Text(
                        DottieDateUtils.toKoreanYearMonth(_viewMonth),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _NavBtn(
                        icon: Icons.chevron_right_rounded,
                        onTap: () => setState(() => _viewMonth =
                            DateTime(_viewMonth.year, _viewMonth.month + 1)),
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
                            crossAxisSpacing: 4),
                    itemCount: firstWeekday + daysInMonth,
                    itemBuilder: (_, idx) {
                      if (idx < firstWeekday) return const SizedBox.shrink();
                      final day = idx - firstWeekday + 1;
                      final date =
                          DateTime(_viewMonth.year, _viewMonth.month, day);
                      final dateStr = DottieDateUtils.toDateString(date);
                      final hasRecord = activeDates.contains(dateStr);
                      final isToday = DottieDateUtils.isSameDay(date, today);

                      // 미래 날짜는 비활성 — share 토글/탐색 의미 없음
                      final isFuture = date.isAfter(today);

                      final BoxDecoration? deco;
                      final Color textColor;
                      if (isToday) {
                        deco = BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: DottieColors.primary.withAlpha(180),
                              width: 1.5),
                        );
                        textColor = Colors.white;
                      } else if (isFuture) {
                        deco = null;
                        textColor = Colors.white.withAlpha(50);
                      } else {
                        // 과거 — share 데이터 유무에 따라 강조
                        deco = null;
                        textColor = hasRecord
                            ? Colors.white
                            : Colors.white.withAlpha(140);
                      }

                      // 탭 가능 조건: 과거 또는 오늘 (데이터 유무 무관 — 빈 날도
                      // 하루 지도로 진입해 dot 을 찍거나 share 토글 가능).
                      // 미래 날짜만 비활성.
                      return GestureDetector(
                        onTap: isFuture
                            ? null
                            : () {
                                HapticFeedback.lightImpact();
                                Navigator.of(context).pop(date);
                              },
                        onLongPress: isFuture
                            ? null
                            : () {
                                HapticFeedback.mediumImpact();
                                _showShareToggle(
                                    context, date, hasRecord);
                              },
                        behavior: HitTestBehavior.opaque,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: deco,
                              alignment: Alignment.center,
                              child: Text(
                                '$day',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                  fontWeight: isToday
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (hasRecord)
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

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.onTap});
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
