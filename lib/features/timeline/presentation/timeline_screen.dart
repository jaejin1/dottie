import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/router/app_router.dart';
import '../../onboarding/domain/onboarding_step.dart';
import '../../onboarding/presentation/onboarding_tour_provider.dart';
import '../../onboarding/presentation/tour_content.dart';
import '../../../core/utils/color_hex.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/providers/tab_retap_bus.dart';
import '../../../shared/utils/error_messages.dart';
import '../../../shared/widgets/dot_detail_sheet.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../feed/domain/feed_entry.dart';
import '../../feed/feed_config.dart';
import '../../feed/presentation/feed_provider.dart';
import '../../feed/presentation/widgets/feed_card.dart';
import '../../feed/presentation/widgets/room_filter_chips.dart';
import '../../notification/presentation/notification_provider.dart';
import '../../recording/presentation/recording_provider.dart';
import '../../recording/presentation/widgets/recording_speed_dial.dart';
import '../../room/domain/room_model.dart';
import '../../room/presentation/room_provider.dart';
import '../../settings/domain/auto_record_settings.dart';
import '../../settings/presentation/auto_record_chip.dart';
import '../../settings/presentation/auto_record_provider.dart';
import '../domain/day_log_model.dart';
import 'timeline_provider.dart';

/// 홈 화면 — 캘린더(본인 회고) ↔ 피드(시간순 합본) 토글.
///
/// Phase 2 통합: 이전엔 캘린더 ↔ 본인 일별 카드 리스트 토글이었으나, 피드 탭을
/// 홈에 흡수하면서 리스트 자리를 피드로 교체. 캘린더 = 본인 회고, 피드 = 소셜.
class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  static const _prefsKey = 'home.is_calendar_view';
  bool _isCalendarView = false;
  DateTime _focusedMonth = DateTime.now();

  final _calendarToggleKey = GlobalKey();
  bool _calendarTourShown = false;
  TutorialCoachMark? _coachMark;
  ProviderSubscription<OnboardingStep>? _tourSub;

  @override
  void initState() {
    super.initState();
    _restoreLastViewMode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          ref.read(onboardingTourProvider) == OnboardingStep.mapHint &&
          !_calendarTourShown) {
        _calendarTourShown = true;
        _showCalendarCoachMark();
      }
    });
    _tourSub = ref.listenManual(onboardingTourProvider, (prev, next) {
      if (next == OnboardingStep.idle || next == OnboardingStep.dotFab) {
        _calendarTourShown = false;
      }
      if (next == OnboardingStep.mapHint && !_calendarTourShown) {
        _calendarTourShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showCalendarCoachMark();
        });
      }
    });
  }

  @override
  void dispose() {
    _tourSub?.close();
    _coachMark?.finish();
    super.dispose();
  }

  Future<void> _restoreLastViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_prefsKey);
    if (saved != null && saved != _isCalendarView && mounted) {
      setState(() => _isCalendarView = saved);
    }
  }

  Future<void> _setViewMode(bool isCalendar) async {
    setState(() => _isCalendarView = isCalendar);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, isCalendar);
  }

  void _showCalendarCoachMark() {
    _coachMark = TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: 'calendarToggle',
          keyTarget: _calendarToggleKey,
          shape: ShapeLightFocus.Circle,
          radius: 28,
          paddingFocus: 10,
          enableOverlayTab: false,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (_, controller) => TourContent(
                message: '달력에서 기록을\n날짜별로 볼 수 있어요',
                description: 'dot이 찍힌 날은 달력에 표시돼요',
                actionLabel: '달력 열기',
                onAction: () => controller.next(),
                stepCurrent: 3,
                stepTotal: 5,
                onSkip: controller.skip,
              ),
            ),
          ],
        ),
      ],
      colorShadow: const Color(0xFF0A0908),
      opacityShadow: 0.78,
      focusAnimationDuration: const Duration(milliseconds: 350),
      pulseAnimationDuration: const Duration(milliseconds: 900),
      unFocusAnimationDuration: const Duration(milliseconds: 200),
      skipWidget: tourSkipIcon,
      onFinish: () {
        if (!mounted) return;
        _setViewMode(true); // 달력 뷰로 전환해 사용자가 오늘 날짜를 바로 볼 수 있게
        ref.read(onboardingTourProvider.notifier).advance(); // mapHint → calendarDay
      },
      onSkip: () {
        ref.read(onboardingTourProvider.notifier).skip();
        return true;
      },
    );
    _coachMark!.show(context: context, rootOverlay: true);
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeRecordingProvider).valueOrNull;
    final isRecording = session != null;
    final autoInterval =
        ref.watch(autoRecordNotifierProvider).valueOrNull ?? AutoRecordInterval.manual;
    final isAutoRecording = autoInterval != AutoRecordInterval.manual;

    return Scaffold(
      backgroundColor: DottieColors.background,
      appBar: AppBar(
        title: Text('Dottie', style: AppTypography.tabHeader()),
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
            key: _calendarToggleKey,
            tooltip: _isCalendarView ? '피드' : '회고',
            icon: Icon(
              _isCalendarView
                  ? Icons.dynamic_feed_rounded
                  : Icons.calendar_month_rounded,
              color: DottieColors.textSecondary,
              size: 22,
            ),
            onPressed: () => _setViewMode(!_isCalendarView),
          ),
          const _NotificationsBellAction(),
        ],
      ),
      body: AnimatedSwitcher(
        duration: 250.ms,
        child: _isCalendarView
            ? _CalendarBranch(
                key: const ValueKey('calendar'),
                focusedMonth: _focusedMonth,
                onMonthChanged: (m) => setState(() => _focusedMonth = m),
              )
            : const _FeedView(key: ValueKey('feed')),
      ),
      floatingActionButton: const RecordingSpeedDial(),
    );
  }
}

// ── 캘린더 브랜치 (dayLogs fetch + 캘린더 그리드) ─────────────────────────
//
// 캘린더 뷰만 timelineDayLogsProvider 가 필요해 별도 위젯으로 분리. 피드
// 모드에선 dayLogs 호출 자체를 안 함.

class _CalendarBranch extends ConsumerWidget {
  const _CalendarBranch({
    super.key,
    required this.focusedMonth,
    required this.onMonthChanged,
  });

  final DateTime focusedMonth;
  final ValueChanged<DateTime> onMonthChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayLogsAsync = ref.watch(timelineDayLogsProvider);
    return dayLogsAsync.when(
      data: (dayLogs) => _CalendarView(
        dayLogs: dayLogs,
        focusedMonth: focusedMonth,
        onMonthChanged: onMonthChanged,
      ),
      loading: () => const LoadingIndicator(),
      error: (e, _) => ErrorView(
        message: userMessageFor(e),
        onRetry: () => ref.invalidate(timelineDayLogsProvider),
      ),
    );
  }
}

// ── 피드 뷰 (방 chip + 무한 스크롤 피드 카드) ──────────────────────────────
//
// 페이지네이션은 BE `/v1/feed` cursor 기반. ScrollController listener 가
// 끝 600px 전에서 loadMore 호출. 마지막 페이지 (`hasMore=false`) 면 멈춤.

class _FeedView extends ConsumerStatefulWidget {
  const _FeedView({super.key});

  @override
  ConsumerState<_FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends ConsumerState<_FeedView> {
  String? _selectedRoomId;
  final _scrollController = ScrollController();

  /// 직전에 loadMore 트리거를 시도한 maxScrollExtent. 같은 extent 면 다시 시도
  /// 안 해 매 픽셀 redundant 호출 방지 (스크롤 한 번에 수십~수백 번 발화).
  /// loadMore 가 새 페이지를 append 하면 maxScrollExtent 가 늘어나 다음
  /// 트리거 허용.
  double _lastTriggeredExtent = -1;

  // rooms list 가 identical 일 때 같은 Map 인스턴스 재사용 — FeedCard 의
  // const / 동등 비교가 안정. 매 build 마다 새 Map literal 생성 회피.
  List<Room>? _cachedRooms;
  Map<String, Room> _cachedRoomById = const {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_maybeLoadMore);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_maybeLoadMore);
    _scrollController.dispose();
    super.dispose();
  }

  void _maybeLoadMore() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final triggerAt = pos.maxScrollExtent - FeedConfig.infiniteScrollTriggerPx;
    if (pos.pixels < triggerAt) return;
    // 같은 maxScrollExtent 안에서 한 번만 트리거.
    if (pos.maxScrollExtent == _lastTriggeredExtent) return;
    _lastTriggeredExtent = pos.maxScrollExtent;
    ref.read(feedNotifierProvider(_selectedRoomId).notifier).loadMore();
  }

  @override
  Widget build(BuildContext context) {
    // 하단 nav 의 홈 탭 재탭 → 맨 위 + 새로고침. 캘린더 모드에선 _FeedView
    // 자체가 dispose 돼 listen 도 끝남 (no-op).
    ref.listen<int>(tabReTapBusProvider(AppRoutes.home), (_, __) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        );
      }
      ref.invalidate(feedNotifierProvider(_selectedRoomId));
      // _lastTriggeredExtent 리셋 — 새 페이지 로드 후 트리거 재허용.
      _lastTriggeredExtent = -1;
    });

    final feedAsync = ref.watch(feedNotifierProvider(_selectedRoomId));
    final rooms = ref.watch(roomListProvider).valueOrNull ?? const <Room>[];
    // identical 캐싱 — provider 가 같은 list 인스턴스 주면 Map 재계산 skip.
    if (!identical(rooms, _cachedRooms)) {
      _cachedRooms = rooms;
      _cachedRoomById = {for (final r in rooms) r.id: r};
    }
    final roomById = _cachedRoomById;

    return Column(
      children: [
        if (rooms.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: RoomFilterChips(
              rooms: rooms,
              selectedRoomId: _selectedRoomId,
              onSelect: (id) {
                setState(() => _selectedRoomId = id);
                // chip 전환 시 스크롤 맨 위로 부드럽게 — 다른 family 의 캐시 노출.
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  );
                }
              },
            ),
          ),
        Expanded(
          child: feedAsync.when(
            loading: () => const LoadingIndicator(),
            error: (e, _) => _FeedError(
              onRetry: () => ref.invalidate(
                feedNotifierProvider(_selectedRoomId),
              ),
            ),
            data: (state) => _FeedList(
              entries: state.entries,
              roomById: roomById,
              hasMore: state.hasMore,
              isLoadingMore: state.isLoadingMore,
              scrollController: _scrollController,
              onRefresh: () async {
                HapticFeedback.lightImpact();
                ref.invalidate(feedNotifierProvider(_selectedRoomId));
                await ref.read(feedNotifierProvider(_selectedRoomId).future);
              },
              onTapEntry: (e) => _openDetail(e, roomById),
            ),
          ),
        ),
      ],
    );
  }

  void _openDetail(FeedEntry entry, Map<String, Room> roomById) {
    // viewer 가 멤버인 룸만 — BE 버그/캐시 정합성 방어.
    final actionableRoomIds = entry.sharedRoomIds
        .where(roomById.containsKey)
        .toSet();
    final actionableRoomNames = <String, String>{
      for (final id in actionableRoomIds) id: roomById[id]!.name,
    };

    // 댓글 멘션 후보 — 룸별로 분리해서 전달 (룸 선택 시 해당 룸 멤버만 자동완성).
    final membersByRoomId = <String, List<DotMemberHint>>{
      for (final id in actionableRoomIds)
        id: (roomById[id]?.members ?? const [])
            .map((m) => DotMemberHint(
                  userId: m.userId,
                  nickname: m.nickname,
                  color: colorFromHex(m.character.colorHex),
                ))
            .toList(),
    };

    DotDetailSheet.show(
      context,
      entry.dot,
      memberName: entry.isMine ? null : entry.authorNickname,
      memberColor: colorFromHex(entry.authorColorHex),
      membersByRoomId: membersByRoomId,
      ownerUserId: entry.authorId,
      openInMapRoomIds: actionableRoomIds,
      openInMapRoomNames: actionableRoomNames,
      onOpenInMap: (pickedRoomId) {
        final date = DottieDateUtils.toDateString(entry.dot.timestamp);
        context.push(
          '/rooms/$pickedRoomId/map',
          extra: {'date': date, 'dotId': entry.dot.id},
        );
      },
      hideRoomIds: actionableRoomIds,
      hideRoomNames: actionableRoomNames,
      availableRoomIds: actionableRoomIds,
      roomNameById: actionableRoomNames,
    );
  }
}

class _FeedList extends StatelessWidget {
  const _FeedList({
    required this.entries,
    required this.roomById,
    required this.hasMore,
    required this.isLoadingMore,
    required this.scrollController,
    required this.onRefresh,
    required this.onTapEntry,
  });

  final List<FeedEntry> entries;
  final Map<String, Room> roomById;
  final bool hasMore;
  final bool isLoadingMore;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final void Function(FeedEntry) onTapEntry;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: DottieColors.primary,
        child: ListView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const Icon(Icons.dynamic_feed_outlined,
                        size: 56, color: DottieColors.textHint),
                    const SizedBox(height: 14),
                    Text(
                      '아직 활동이 없어요',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: DottieColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '첫 dot 을 찍거나 방에 들어가 보세요',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 13,
                        color: DottieColors.textHint,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // CTA — 신규 사용자 전환율 ↑. 방에 들어가면 다른 멤버 활동이
                    // 피드에 보이기 시작.
                    ElevatedButton.icon(
                      onPressed: () => context.go(AppRoutes.rooms),
                      icon: const Icon(Icons.people_rounded, size: 18),
                      label: const Text('방 둘러보기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DottieColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: const StadiumBorder(),
                        textStyle: GoogleFonts.notoSansKr(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 마지막에 footer 1칸 추가 — hasMore 면 로딩 인디케이터, 끝이면 안내.
    final itemCount = entries.length + 1;

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: DottieColors.primary,
      child: ListView.separated(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: Dimensions.sm),
        itemCount: itemCount,
        separatorBuilder: (_, i) {
          if (i == entries.length - 1) return const SizedBox.shrink();
          return const Divider(
            height: 1,
            thickness: 1,
            color: DottieColors.border,
          );
        },
        itemBuilder: (_, i) {
          if (i == entries.length) {
            return _FeedFooter(
              hasMore: hasMore,
              isLoadingMore: isLoadingMore,
            );
          }
          return FeedCard(
            entry: entries[i],
            roomNameById: roomById,
            onTap: () => onTapEntry(entries[i]),
          );
        },
      ),
    );
  }
}

class _FeedFooter extends StatelessWidget {
  const _FeedFooter({required this.hasMore, required this.isLoadingMore});
  final bool hasMore;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              color: DottieColors.primary,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }
    if (hasMore) {
      // 무한 스크롤이 트리거 안 됐을 때 (짧은 list 등) 의 placeholder.
      return const SizedBox(height: 32);
    }
    // 마지막 페이지 — 더 이상 없음 안내. 차가운 "— 끝 —" 대신 부드러운 톤.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          '오늘은 여기까지에요',
          style: GoogleFonts.notoSansKr(
            fontSize: 12,
            color: DottieColors.textHint,
          ),
        ),
      ),
    );
  }
}

// ── 피드 에러 ─────────────────────────────────────────────────────────────
// 일반 메시지 + 다시 시도 버튼. raw DioException toString 노출 X (BE URL /
// 응답 body / status 가 스크린샷으로 새는 것 차단). 자세한 정보는 debugPrint.

class _FeedError extends StatelessWidget {
  const _FeedError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 40, color: DottieColors.textHint),
            const SizedBox(height: 12),
            Text(
              '피드를 불러올 수 없어요',
              style: GoogleFonts.notoSansKr(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: DottieColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '잠시 후 다시 시도해 주세요',
              style: GoogleFonts.notoSansKr(
                fontSize: 12,
                color: DottieColors.textHint,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('다시 시도'),
              style: TextButton.styleFrom(
                foregroundColor: DottieColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 캘린더 뷰 ──────────────────────────────────────────────────────────────

class _CalendarView extends ConsumerStatefulWidget {
  const _CalendarView({
    required this.dayLogs,
    required this.focusedMonth,
    required this.onMonthChanged,
  });

  final List<DayLog> dayLogs;
  final DateTime focusedMonth;
  final ValueChanged<DateTime> onMonthChanged;

  @override
  ConsumerState<_CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<_CalendarView> {
  final _todayCellKey = GlobalKey();
  bool _calendarDayTourShown = false;
  TutorialCoachMark? _calendarDayCoachMark;
  ProviderSubscription<OnboardingStep>? _tourSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          ref.read(onboardingTourProvider) == OnboardingStep.calendarDay &&
          !_calendarDayTourShown) {
        _calendarDayTourShown = true;
        _showTodayCellCoachMark();
      }
    });
    _tourSub = ref.listenManual(onboardingTourProvider, (prev, next) {
      if (next == OnboardingStep.idle || next == OnboardingStep.dotFab) {
        _calendarDayTourShown = false;
      }
      if (next == OnboardingStep.calendarDay && !_calendarDayTourShown) {
        _calendarDayTourShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showTodayCellCoachMark();
        });
      }
    });
  }

  @override
  void dispose() {
    _tourSub?.close();
    _calendarDayCoachMark?.finish();
    super.dispose();
  }

  void _showTodayCellCoachMark() {
    if (_todayCellKey.currentContext == null) return;
    _calendarDayCoachMark = TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: 'todayCell',
          keyTarget: _todayCellKey,
          shape: ShapeLightFocus.Circle,
          radius: 26,
          paddingFocus: 10,
          enableOverlayTab: false,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (_, controller) => TourContent(
                message: '오늘 날짜를 탭하면\n지도에서 캐릭터를 만나요',
                description: '기록한 dot이 지도 위에서 움직여요',
                actionLabel: '지도 열기',
                onAction: () => controller.next(),
                stepCurrent: 3,
                stepTotal: 5,
                onSkip: controller.skip,
              ),
            ),
          ],
        ),
      ],
      colorShadow: const Color(0xFF0A0908),
      opacityShadow: 0.78,
      focusAnimationDuration: const Duration(milliseconds: 350),
      pulseAnimationDuration: const Duration(milliseconds: 900),
      unFocusAnimationDuration: const Duration(milliseconds: 200),
      skipWidget: tourSkipIcon,
      onFinish: () {
        // 스팟라이트 탭 시 coach mark가 자동으로 이걸 호출 — 프로그래매틱으로 지도 이동
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          await context.push(AppRoutes.today);
          // 지도에서 뒤로 돌아온 후 advance — 지도 위에서 방 이동 coach mark 방지
          if (mounted &&
              ref.read(onboardingTourProvider) == OnboardingStep.calendarDay) {
            ref.read(onboardingTourProvider.notifier).advance(); // calendarDay → bottomTabRoom
          }
        });
      },
      onSkip: () {
        ref.read(onboardingTourProvider.notifier).skip();
        return true;
      },
    );
    _calendarDayCoachMark!.show(context: context, rootOverlay: true);
  }

  Future<void> _onTodayTap() async {
    // 투어 중에는 coach mark의 onFinish가 이동을 처리함.
    // 투어 외 (skip 후, 일반 사용 등)는 여기서 직접 이동.
    if (ref.read(onboardingTourProvider) == OnboardingStep.calendarDay) return;
    await context.push(AppRoutes.today);
  }

  @override
  Widget build(BuildContext context) {
    final recordedDays =
        widget.dayLogs.map((d) => DottieDateUtils.toDateString(d.date)).toSet();
    final dayLogsMap = {
      for (final d in widget.dayLogs) DottieDateUtils.toDateString(d.date): d,
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
                      '${widget.focusedMonth.month}월',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        color: DottieColors.textPrimary,
                        letterSpacing: -1.5,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      '${widget.focusedMonth.year}',
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
                onPressed: () => widget.onMonthChanged(
                    DateTime(widget.focusedMonth.year, widget.focusedMonth.month - 1)),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 22),
                color: DottieColors.textSecondary,
                onPressed: () => widget.onMonthChanged(
                    DateTime(widget.focusedMonth.year, widget.focusedMonth.month + 1)),
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
            itemCount: _daysInView(widget.focusedMonth),
            itemBuilder: (context, index) {
              final day = _dayAtIndex(widget.focusedMonth, index);
              if (day == null) return const SizedBox.shrink();

              final dateStr = DottieDateUtils.toDateString(day);
              final hasRecord = recordedDays.contains(dateStr);
              final isToday = DottieDateUtils.isSameDay(day, DateTime.now());
              final isSunday = day.weekday == DateTime.sunday;
              final isSaturday = day.weekday == DateTime.saturday;

              return GestureDetector(
                key: isToday ? _todayCellKey : null,
                onTap: isToday
                    ? _onTodayTap
                    : hasRecord
                        ? () {
                            final log = dayLogsMap[dateStr]!;
                            context.push(AppRoutes.mapAnimation
                                .replaceFirst(':id', log.id));
                          }
                        : null,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: hasRecord
                              ? DottieColors.primary
                              : Colors.transparent,
                          shape: BoxShape.circle,
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
                                  : isSunday
                                      ? DottieColors.error.withAlpha(160)
                                      : isSaturday
                                          ? DottieColors.primary.withAlpha(180)
                                          : DottieColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isToday
                              ? DottieColors.primary
                              : Colors.transparent,
                        ),
                      ),
                    ],
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
                '이번 달 ${_recordedDaysInMonth(recordedDays, widget.focusedMonth)}일 기록',
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

// ── 알림 종 액션 ──────────────────────────────────────────────

class _NotificationsBellAction extends ConsumerWidget {
  const _NotificationsBellAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(
      notificationProvider.select(
        (s) => s.valueOrNull?.where((n) => !n.isRead).length ?? 0,
      ),
    );
    return IconButton(
      tooltip: '알림',
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text(
          unread > 99 ? '99+' : '$unread',
          style: const TextStyle(fontSize: 10),
        ),
        child: const Icon(
          Icons.notifications_none_rounded,
          color: DottieColors.textSecondary,
          size: 22,
        ),
      ),
      onPressed: () {
        // 진입 시 최신 알림 강제 fetch (StatefulShell 외부 풀스크린이라
        // build 시점이 매번 호출되지만 명시적으로 한 번 더 보장).
        ref.read(notificationProvider.notifier).refresh();
        context.push(AppRoutes.notifications);
      },
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
