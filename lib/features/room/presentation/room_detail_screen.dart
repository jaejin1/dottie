import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../recording/presentation/recording_provider.dart';
import '../../timeline/domain/day_log_model.dart';
import '../domain/room_exceptions.dart';
import '../domain/room_model.dart';
import 'room_provider.dart';

class RoomDetailScreen extends ConsumerStatefulWidget {
  const RoomDetailScreen({super.key, required this.roomId});
  final String roomId;

  @override
  ConsumerState<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends ConsumerState<RoomDetailScreen> {
  DateTime _selectedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  @override
  Widget build(BuildContext context) {
    final roomAsync = ref.watch(roomDetailProvider(widget.roomId));

    return Scaffold(
      backgroundColor: DottieColors.background,
      body: roomAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (room) => room == null
            ? const Center(child: Text('방을 찾을 수 없어요'))
            : _buildBody(context, room),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Room room) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context, room),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MemberSection(room: room),
              const SizedBox(height: Dimensions.md),
              _CalendarSection(
                room: room,
                selectedMonth: _selectedMonth,
                onMonthChanged: (m) => setState(() => _selectedMonth = m),
                onDateTap: (date) => context.push(
                  '/rooms/${room.id}/map',
                  extra: {'date': DottieDateUtils.toDateString(date)},
                ),
              ),
              const SizedBox(height: Dimensions.md),
              _ShareTodayButton(roomId: room.id),
              const SizedBox(height: Dimensions.xxl),
            ],
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, Room room) {
    final dottieUser = ref.watch(currentDottieUserProvider).valueOrNull;
    final isOwner = dottieUser != null && room.ownerId == dottieUser.uid;

    return SliverAppBar(
      backgroundColor: DottieColors.surface,
      elevation: 0,
      pinned: true,
      title: Text(room.name,
          style: const TextStyle(
              color: DottieColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: DottieColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (isOwner)
          IconButton(
            icon: const Icon(Icons.share_outlined,
                color: DottieColors.textSecondary),
            onPressed: () => _shareInviteCode(context, room),
          ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded,
              color: DottieColors.textSecondary),
          onSelected: (v) {
            if (v == 'leave') _confirmLeave(context, room);
            if (v == 'delete') _confirmDelete(context, room);
          },
          itemBuilder: (_) => [
            if (isOwner)
              const PopupMenuItem(
                  value: 'delete',
                  child: Text('방 삭제',
                      style: TextStyle(color: DottieColors.error))),
            if (!isOwner)
              const PopupMenuItem(
                  value: 'leave', child: Text('방 나가기')),
          ],
        ),
      ],
    );
  }

  Future<void> _shareInviteCode(BuildContext context, Room room) async {
    // 호출마다 새 코드 발급
    final ({String code, DateTime expiresAt}) invite;
    try {
      invite = await ref
          .read(roomNotifierProvider.notifier)
          .generateInviteCode(room.id);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('초대 코드 발급에 실패했어요. 잠시 후 다시 시도해 주세요.'),
          backgroundColor: DottieColors.error,
        ),
      );
      return;
    }
    if (!context.mounted) return;

    final expiresText =
        '${invite.expiresAt.toLocal().month}/${invite.expiresAt.toLocal().day} '
        '${invite.expiresAt.toLocal().hour.toString().padLeft(2, '0')}:'
        '${invite.expiresAt.toLocal().minute.toString().padLeft(2, '0')} 까지';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${room.name} 초대 코드'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.lg, vertical: Dimensions.md),
              decoration: BoxDecoration(
                color: DottieColors.surfaceVariant,
                borderRadius:
                    BorderRadius.circular(Dimensions.radiusMd),
              ),
              child: Text(invite.code,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 6,
                      color: DottieColors.primary)),
            ),
            const SizedBox(height: Dimensions.sm),
            Text(
              expiresText,
              style: const TextStyle(
                  fontSize: 12, color: DottieColors.textHint),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: invite.code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('코드가 복사됐어요!')),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('복사'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: FilledButton.styleFrom(
                backgroundColor: DottieColors.primary),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _confirmLeave(BuildContext context, Room room) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('방 나가기'),
        content: Text('\'${room.name}\'에서 나가시겠어요?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소')),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(roomNotifierProvider.notifier)
                    .leaveRoom(room.id);
                if (context.mounted) context.pop();
              } on LeaveRoomException catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: DottieColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('나가기',
                style: TextStyle(color: DottieColors.error)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Room room) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('방 삭제'),
        content: Text('\'${room.name}\'을 삭제하면 모든 공유 기록이 사라져요. 정말 삭제하시겠어요?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소')),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await ref
                    .read(roomNotifierProvider.notifier)
                    .deleteRoom(room.id);
                if (context.mounted) context.pop();
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('방 삭제에 실패했어요. 잠시 후 다시 시도해 주세요.'),
                      backgroundColor: DottieColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('삭제',
                style: TextStyle(color: DottieColors.error)),
          ),
        ],
      ),
    );
  }
}

// ─── 멤버 섹션 ───────────────────────────────────────────────

class _MemberSection extends StatelessWidget {
  const _MemberSection({required this.room});
  final Room room;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(Dimensions.md),
      padding: const EdgeInsets.all(Dimensions.md),
      decoration: BoxDecoration(
        color: DottieColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('멤버 ${room.members.length}명',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DottieColors.textSecondary)),
          const SizedBox(height: Dimensions.sm),
          Wrap(
            spacing: Dimensions.sm,
            runSpacing: Dimensions.sm,
            children: room.members
                .map((m) => _MemberChip(member: m))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  const _MemberChip({required this.member});
  final RoomMember member;

  @override
  Widget build(BuildContext context) {
    final color =
        characterColorMap[member.character.colorKey] ?? DottieColors.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
              color: color, shape: BoxShape.circle),
          child: Center(
            child: Text(
              member.nickname.characters.first,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(member.nickname,
            style: const TextStyle(
                fontSize: 13, color: DottieColors.textPrimary)),
      ],
    );
  }
}

// ─── 날짜 캘린더 섹션 ─────────────────────────────────────────

class _CalendarSection extends StatelessWidget {
  const _CalendarSection({
    required this.room,
    required this.selectedMonth,
    required this.onMonthChanged,
    required this.onDateTap,
  });

  final Room room;
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDateTap;

  Set<String> get _sharedDates => room.sharedDates.toSet();

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
        selectedMonth.year, selectedMonth.month);
    final firstWeekday =
        DateTime(selectedMonth.year, selectedMonth.month, 1).weekday % 7;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.md),
      padding: const EdgeInsets.all(Dimensions.md),
      decoration: BoxDecoration(
        color: DottieColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
      ),
      child: Column(
        children: [
          // 월 네비게이션
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => onMonthChanged(DateTime(
                    selectedMonth.year, selectedMonth.month - 1)),
              ),
              Text(
                '${selectedMonth.year}년 ${selectedMonth.month}월',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () => onMonthChanged(DateTime(
                    selectedMonth.year, selectedMonth.month + 1)),
              ),
            ],
          ),
          // 요일 헤더
          Row(
            children: ['일', '월', '화', '수', '목', '금', '토']
                .map((d) => Expanded(
                      child: Text(d,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 11,
                              color: DottieColors.textHint)),
                    ))
                .toList(),
          ),
          const SizedBox(height: Dimensions.xs),
          // 날짜 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7, mainAxisSpacing: 4),
            itemCount: firstWeekday + daysInMonth,
            itemBuilder: (_, idx) {
              if (idx < firstWeekday) return const SizedBox.shrink();
              final day = idx - firstWeekday + 1;
              final date = DateTime(
                  selectedMonth.year, selectedMonth.month, day);
              return _DayCell(
                day: day,
                date: date,
                members: room.members,
                sharedDates: _sharedDates,
                onTap: () => onDateTap(date),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.date,
    required this.members,
    required this.sharedDates,
    required this.onTap,
  });

  final int day;
  final DateTime date;
  final List<RoomMember> members;
  final Set<String> sharedDates;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = DottieDateUtils.isSameDay(date, DateTime.now());
    final dateStr = DottieDateUtils.toDateString(date);
    final hasRecord = sharedDates.contains(dateStr);
    final recordingMembers = hasRecord ? members.take(2).toList() : <RoomMember>[];

    return GestureDetector(
      onTap: hasRecord ? onTap : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: isToday
                ? BoxDecoration(
                    color: DottieColors.primary,
                    shape: BoxShape.circle)
                : null,
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: isToday
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: isToday
                        ? Colors.white
                        : DottieColors.textPrimary),
              ),
            ),
          ),
          if (recordingMembers.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: recordingMembers.map((m) {
                final c = characterColorMap[m.character.colorKey] ??
                    DottieColors.primary;
                return Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(right: 1),
                  decoration: BoxDecoration(
                      color: c, shape: BoxShape.circle),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

// ─── 오늘 기록 공유 버튼 ──────────────────────────────────────

class _ShareTodayButton extends ConsumerWidget {
  const _ShareTodayButton({required this.roomId});
  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.md),
      child: FilledButton.icon(
        onPressed: () => _shareToday(context, ref),
        icon: const Icon(Icons.share_location_rounded),
        label: const Text('오늘 기록 이 방에 공유하기'),
        style: FilledButton.styleFrom(
          backgroundColor: DottieColors.secondary,
          foregroundColor: DottieColors.textPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusMd),
          ),
        ),
      ),
    );
  }

  Future<void> _shareToday(BuildContext context, WidgetRef ref) async {
    final DayLog? todayLog = await ref.read(todayDayLogProvider.future);
    if (!context.mounted) return;
    if (todayLog == null || todayLog.dots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오늘 기록한 dot이 없어요')),
      );
      return;
    }
    try {
      await ref
          .read(roomNotifierProvider.notifier)
          .shareDayLog(roomId, todayLog.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오늘 기록을 방에 공유했어요!')),
      );
    } on ShareDayLogException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: e.code == 'ALREADY_SHARED'
              ? Colors.orange
              : DottieColors.error,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('공유에 실패했어요. 잠시 후 다시 시도해 주세요.'),
          backgroundColor: DottieColors.error,
        ),
      );
    }
  }
}
