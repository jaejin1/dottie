import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/color_hex.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/text_validators.dart';
import '../../../../shared/utils/error_messages.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../cumulative_map/presentation/cumulative_map_provider.dart';
import '../../recording/data/dot_repository.dart';
import '../../recording/domain/dot_model.dart';
import '../../recording/presentation/recording_provider.dart';
import '../../shared_map/presentation/shared_map_provider.dart';
import 'hidden_dots_provider.dart';
import '../../timeline/domain/day_log_model.dart';
import '../domain/room_exceptions.dart';
import '../domain/room_model.dart';
import 'room_provider.dart';
import '../../todo/domain/todo_list_model.dart';
import '../../todo/presentation/todo_provider.dart';

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
        error: (e, _) => ErrorView(
          message: userMessageFor(e),
          onRetry: () =>
              ref.invalidate(roomDetailProvider(widget.roomId)),
        ),
        data: (room) => room == null
            ? const Center(child: Text('방을 찾을 수 없어요'))
            : _buildBody(context, room),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Room room) {
    final dottieUser = ref.watch(currentDottieUserProvider).valueOrNull;
    final isOwner = dottieUser != null && room.ownerId == dottieUser.uid;

    return CustomScrollView(
      slivers: [
        _buildAppBar(context, room),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MemberSection(room: room),
              const SizedBox(height: Dimensions.md),
              // D — 자동 공유 토글 (auto_share)
              _AutoShareCard(room: room),
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
              _LinkedSpotsSection(room: room, isOwner: isOwner),
              const SizedBox(height: Dimensions.md),
              _ShareTodayButton(roomId: room.id),
              const SizedBox(height: Dimensions.md),
              // 내가 그 룸에서 숨긴 dot 목록 진입점 (있을 때만 노출).
              _HiddenDotsSection(roomId: room.id),
              const SizedBox(height: Dimensions.xl),
              // owner 면 "방 삭제", 아니면 "방 나가기" — 하단 위험 액션 영역.
              _DangerZoneSection(
                room: room,
                isOwner: isOwner,
                onDelete: () => _confirmDelete(context, room),
                onLeave: () => _confirmLeave(context, room),
              ),
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
        // 순서: 지도 보기 → 이름 변경 (owner) → 초대 코드 공유 (owner)
        IconButton(
          tooltip: '지도 보기',
          icon: const Icon(Icons.map_outlined,
              color: DottieColors.textSecondary),
          onPressed: () => _goToMap(context, room),
        ),
        if (isOwner)
          IconButton(
            tooltip: '이름 변경',
            icon: const Icon(Icons.edit_outlined,
                color: DottieColors.textSecondary),
            onPressed: () => _showRenameDialog(context, room),
          ),
        if (isOwner)
          IconButton(
            tooltip: '멤버 초대',
            icon: const Icon(Icons.person_add_outlined,
                color: DottieColors.textSecondary),
            onPressed: () => _shareInviteCode(context, room),
          ),
        const SizedBox(width: 4),
        // 방 삭제 / 방 나가기는 본문 하단의 _DangerZoneSection 으로 옮김.
      ],
    );
  }

  /// 방 이름 변경 — RoomJoinDialog 와 동일한 비주얼 (● 헤더 + filled TextField).
  /// 액션은 커스텀: 우하단에 작은 [취소][저장] (Expanded 아닌 컴팩트 사이즈).
  Future<void> _showRenameDialog(BuildContext context, Room room) async {
    final controller = TextEditingController(text: room.name);
    final newName = await showDialog<String?>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: DottieColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusLg),
        ),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimensions.md + 4,
              Dimensions.md + 4,
              Dimensions.md + 4,
              Dimensions.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ● 방 이름 변경 — primary dot + 굵은 타이틀
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: DottieColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '방 이름 변경',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: DottieColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                '새 방 이름을 입력하세요',
                style: TextStyle(
                  fontSize: 12,
                  color: DottieColors.textSecondary,
                ),
              ),
              const SizedBox(height: Dimensions.md),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 50,
                cursorColor: DottieColors.primary,
                decoration: InputDecoration(
                  hintText: '방 이름',
                  hintStyle:
                      const TextStyle(color: DottieColors.textHint),
                  counterText: '',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  filled: true,
                  fillColor: DottieColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusMd),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusMd),
                    borderSide: const BorderSide(
                        color: DottieColors.primary, width: 2),
                  ),
                ),
                onSubmitted: (_) {
                  final v = controller.text.trim();
                  if (!TextValidators.isValidUserText(v)) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('글자를 완성해서 입력해주세요')),
                    );
                    return;
                  }
                  Navigator.pop(dialogContext, v);
                },
              ),
              const SizedBox(height: Dimensions.sm),
              // 우하단 컴팩트 액션 — Row + MainAxisAlignment.end (Expanded X).
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 4),
                  FilledButton(
                    onPressed: () {
                      final v = controller.text.trim();
                      if (!TextValidators.isValidUserText(v)) {
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(content: Text('글자를 완성해서 입력해주세요')),
                        );
                        return;
                      }
                      Navigator.pop(dialogContext, v);
                    },
                    style: FilledButton.styleFrom(
                        backgroundColor: DottieColors.primary),
                    child: const Text('저장'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();

    if (newName == null || newName == room.name || !context.mounted) return;
    if (newName.length > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방 이름은 50자 이하로 입력해 주세요.')),
      );
      return;
    }
    try {
      await ref
          .read(roomNotifierProvider.notifier)
          .renameRoom(room.id, newName);
      if (!context.mounted) return;
      // 삭제와 동일하게 룸 리스트로 이동 (info 화면에 머물지 않음).
      context.go('/rooms');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방 이름을 바꿨어요')),
      );
    } on RenameRoomException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userMessageFor(e)),
          backgroundColor: DottieColors.error,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('방 이름 변경에 실패했어요. 잠시 후 다시 시도해 주세요.'),
          backgroundColor: DottieColors.error,
        ),
      );
    }
  }

  /// 누적 지도로 돌아가기.
  /// /info 가 누적 지도에서 push 된 경우엔 pop, 직접 진입(딥링크 등) 시 go 로
  /// `/rooms/:id` 진입.
  void _goToMap(BuildContext context, Room room) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/rooms/${room.id}');
    }
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

    final inviteLink = '${AppConfig.webHost}/invite/room/${invite.code}';
    final diff = invite.expiresAt.difference(DateTime.now());
    final expiresText = diff.inHours >= 24
        ? '${diff.inDays}일 후 만료'
        : diff.inHours >= 1
            ? '${diff.inHours}시간 후 만료'
            : '${diff.inMinutes.clamp(1, 59)}분 후 만료';

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: DottieColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusLg),
        ),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimensions.md + 4,
              Dimensions.md + 4,
              Dimensions.md + 4,
              Dimensions.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: DottieColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '초대 링크',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: DottieColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '$expiresText 사용 가능',
                style: const TextStyle(
                  fontSize: 12,
                  color: DottieColors.textSecondary,
                ),
              ),
              const SizedBox(height: Dimensions.md),
              // 링크 박스 — 탭하면 클립보드 복사
              GestureDetector(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: inviteLink));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('링크가 복사됐어요!')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: DottieColors.surfaceVariant,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          inviteLink,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: DottieColors.primary.withValues(alpha: 0.85),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.copy_rounded,
                          size: 16,
                          color: DottieColors.textHint),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: FilledButton.styleFrom(
                        backgroundColor: DottieColors.primary),
                    child: const Text('확인'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLeave(BuildContext context, Room room) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          '방 나가기',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: DottieColors.textPrimary,
          ),
        ),
        content: Text.rich(
          TextSpan(
            style: const TextStyle(
              height: 1.6,
              color: DottieColors.textPrimary,
            ),
            children: [
              TextSpan(
                text: "'${room.name}'",
                style: const TextStyle(
                  color: DottieColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const TextSpan(text: '에서 나갈까요?\n\n'),
              const TextSpan(text: '이 방에 공유한 내 기록과 댓글이 사라져요. '),
              const TextSpan(text: '내 dot 자체와 다른 방의 공유는 그대로 남아요.'),
            ],
          ),
        ),
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
                if (!context.mounted) return;
                // 이미 멤버 아니라 부모 /rooms/:id 화면이 BE 403 / 빈 상태로
                // 떨어지므로, info 만 pop 하면 어색. 룸 리스트로 안전하게 이동.
                context.go('/rooms');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("'${room.name}'에서 나갔어요")),
                );
              } on LeaveRoomException catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(userMessageFor(e)),
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
        title: const Text(
          '방 삭제',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: DottieColors.textPrimary,
          ),
        ),
        content: Text.rich(
          TextSpan(
            style: const TextStyle(
              height: 1.6,
              color: DottieColors.textPrimary,
            ),
            children: [
              TextSpan(
                text: "'${room.name}'",
                style: const TextStyle(
                  color: DottieColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const TextSpan(text: '을 삭제할까요?\n\n'),
              const TextSpan(text: '이 방에 공유된 모든 멤버의 기록과 댓글이 사라져요. '),
              const TextSpan(text: '각자의 dot 자체와 다른 방의 공유는 그대로 남아요.'),
            ],
          ),
        ),
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
                if (!context.mounted) return;
                // 삭제된 방의 SharedMapScreen(/rooms/:id)으로 pop 되면 어색 →
                // 룸 리스트로 안전하게 이동.
                context.go('/rooms');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("'${room.name}'을 삭제했어요")),
                );
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

class _MemberSection extends ConsumerWidget {
  const _MemberSection({required this.room});
  final Room room;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentDottieUserProvider).valueOrNull;
    final isOwner = me != null && room.ownerId == me.uid;

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
          Row(
            children: [
              Text('멤버 ${room.members.length}명',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: DottieColors.textSecondary)),
              const Spacer(),
              if (isOwner)
                Text(
                  '꾹 눌러 내보내기',
                  style: TextStyle(
                    fontSize: 11,
                    color: DottieColors.textHint.withAlpha(220),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Dimensions.sm),
          Wrap(
            spacing: Dimensions.sm,
            runSpacing: Dimensions.sm,
            children: room.members
                .map((m) => _MemberChip(
                      member: m,
                      room: room,
                      meUid: me?.uid,
                      isOwnerView: isOwner,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MemberChip extends ConsumerWidget {
  const _MemberChip({
    required this.member,
    required this.room,
    required this.meUid,
    required this.isOwnerView,
  });

  final RoomMember member;
  final Room room;
  final String? meUid;

  /// 현재 보고 있는 사용자가 룸 owner 인지. true 일 때만 long-press 강퇴 활성.
  final bool isOwnerView;

  /// 이 멤버가 룸 owner 인지.
  bool get _memberIsOwner => member.userId == room.ownerId;

  /// 자기 자신인지.
  bool get _isSelf => meUid != null && member.userId == meUid;

  /// 강퇴 가능한 멤버: owner 가 보는 화면 + 본인 아니고 + owner 아닌 멤버.
  bool get _canKick => isOwnerView && !_isSelf && !_memberIsOwner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = colorFromHex(member.character.colorHex,
        fallback: DottieColors.primary);
    final chip = Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
      decoration: BoxDecoration(
        color: DottieColors.surfaceVariant,
        borderRadius: BorderRadius.circular(Dimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
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
          if (_memberIsOwner) ...[
            const SizedBox(width: 4),
            const Icon(Icons.shield_outlined,
                size: 12, color: DottieColors.textHint),
          ],
        ],
      ),
    );

    if (!_canKick) return chip;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => _confirmKick(context, ref),
      child: chip,
    );
  }

  Future<void> _confirmKick(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final memberColor = colorFromHex(member.character.colorHex,
        fallback: DottieColors.primary);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          '멤버 내보내기',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: DottieColors.textPrimary,
          ),
        ),
        content: Text.rich(
          TextSpan(
            style: const TextStyle(
              height: 1.6,
              color: DottieColors.textPrimary,
            ),
            children: [
              TextSpan(
                text: member.nickname,
                style: TextStyle(
                  color: memberColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const TextSpan(text: ' 님을 이 방에서 내보낼까요?\n\n'),
              const TextSpan(text: '이 방에 공유된 '),
              TextSpan(
                text: member.nickname,
                style: TextStyle(
                  color: memberColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const TextSpan(text: ' 님의 기록과 댓글이 사라져요. '),
              const TextSpan(text: 'dot 자체와 다른 방의 공유는 그대로 남아요.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: DottieColors.error),
            child: const Text('내보내기'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref
          .read(roomNotifierProvider.notifier)
          .kickMember(room.id, member.userId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${member.nickname} 님을 내보냈어요')),
      );
    } on KickMemberException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userMessageFor(e)),
          backgroundColor: DottieColors.error,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('멤버 내보내기에 실패했어요. 잠시 후 다시 시도해 주세요.'),
          backgroundColor: DottieColors.error,
        ),
      );
    }
  }
}

// ─── 날짜 캘린더 섹션 ─────────────────────────────────────────

class _CalendarSection extends ConsumerWidget {
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

  /// 실제로 그 날짜에 dot 을 공유한 멤버 ID 집합을 날짜별로 매핑.
  /// cumulativeRoomDots 의 dot 들을 (날짜 → memberIds) 로 그룹화.
  /// 이전엔 `members.take(2)` 같은 placeholder 였어서 강퇴/재가입 멤버가
  /// 과거 모든 공유 날짜에 점이 찍히던 버그를 해결.
  Map<String, Set<String>> _membersByDate(WidgetRef ref) {
    final dots =
        ref.watch(cumulativeRoomDotsProvider(room.id)).valueOrNull;
    if (dots == null) return const {};
    final result = <String, Set<String>>{};
    for (final rd in dots) {
      final local = rd.dot.timestamp.toLocal();
      final dateStr =
          '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
      result.putIfAbsent(dateStr, () => <String>{}).add(rd.memberId);
    }
    return result;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysInMonth = DateUtils.getDaysInMonth(
        selectedMonth.year, selectedMonth.month);
    final firstWeekday =
        DateTime(selectedMonth.year, selectedMonth.month, 1).weekday % 7;
    final membersByDate = _membersByDate(ref);

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
              final dateStr = DottieDateUtils.toDateString(date);
              return _DayCell(
                day: day,
                date: date,
                allMembers: room.members,
                sharedDates: _sharedDates,
                memberIdsForDate:
                    membersByDate[dateStr] ?? const <String>{},
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
    required this.allMembers,
    required this.sharedDates,
    required this.memberIdsForDate,
    required this.onTap,
  });

  final int day;
  final DateTime date;

  /// 룸의 모든 멤버 (현재 룸에 속한 멤버 풀 — 색/닉네임 lookup 용).
  final List<RoomMember> allMembers;

  /// `room.sharedDates` — 그 날짜에 어떤 멤버라도 공유한 적 있으면 포함.
  /// dot 데이터가 도착하기 전까지의 빠른 indicator 용 (점 색은 모름).
  final Set<String> sharedDates;

  /// 그 날짜에 실제로 dot 을 공유한 멤버 ID 집합 (cumulativeRoomDots 기반).
  /// 이 집합이 권위 있는 데이터 — 빈 집합이면 점 안 그림.
  final Set<String> memberIdsForDate;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = DottieDateUtils.isSameDay(date, DateTime.now());
    final dateStr = DottieDateUtils.toDateString(date);
    // hasRecord: cumulativeRoomDots 가 로드됐으면 그 데이터 우선,
    // 아직 로딩 중이면 sharedDates 폴백 (어떤 멤버가 했는지는 모름).
    final hasRecord =
        memberIdsForDate.isNotEmpty || sharedDates.contains(dateStr);
    // 점은 실제 공유한 멤버만 — 최대 2명까지 표시.
    final recordingMembers = memberIdsForDate.isEmpty
        ? const <RoomMember>[]
        : allMembers
            .where((m) => memberIdsForDate.contains(m.userId))
            .take(2)
            .toList();

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
                final c = colorFromHex(m.character.colorHex,
                    fallback: DottieColors.primary);
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
        label: const Text(
          '오늘 기록 이 방에 공유하기',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: DottieColors.primary,
          foregroundColor: Colors.white,
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
          content: Text(userMessageFor(e)),
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


// ── 자동 공유 토글 카드 (D) ──────────────────────────────────

class _AutoShareCard extends ConsumerStatefulWidget {
  const _AutoShareCard({required this.room});
  final Room room;

  @override
  ConsumerState<_AutoShareCard> createState() => _AutoShareCardState();
}

class _AutoShareCardState extends ConsumerState<_AutoShareCard> {
  bool? _optimisticValue;

  @override
  Widget build(BuildContext context) {
    final value = _optimisticValue ?? widget.room.autoShare;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.md),
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      decoration: BoxDecoration(
        color: DottieColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        border: Border.all(color: DottieColors.border, width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: DottieColors.primary.withAlpha(30),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.event_repeat_rounded,
                color: DottieColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '매일 자동으로 공유',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: DottieColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value
                      ? '오늘 기록이 매일 자동으로 이 방에 공유돼요'
                      : '"오늘 기록 이 방에 공유하기" 버튼으로 직접 공유',
                  style: const TextStyle(
                    fontSize: 11,
                    color: DottieColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (v) async {
              HapticFeedback.lightImpact();
              setState(() => _optimisticValue = v);
              try {
                await ref
                    .read(roomNotifierProvider.notifier)
                    .setAutoShare(widget.room.id, v);
              } catch (_) {
                if (mounted) setState(() => _optimisticValue = null);
              }
            },
          ),
        ],
      ),
    );
  }
}

// ─── 위험 액션 영역 (방 삭제 / 나가기) ───────────────────────

class _DangerZoneSection extends StatelessWidget {
  const _DangerZoneSection({
    required this.room,
    required this.isOwner,
    required this.onDelete,
    required this.onLeave,
  });

  final Room room;
  final bool isOwner;
  final VoidCallback onDelete;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final isDestructive = isOwner; // owner 면 "삭제", 아니면 "나가기"
    final label = isDestructive ? '방 삭제' : '방 나가기';
    final description = isDestructive
        ? '이 방의 모든 공유 기록과 댓글이 함께 사라져요.'
        : '내가 이 방에서 나가요. 내 dot은 그대로 유지되지만 이 방 내에선 더 이상 공유되지 않아요.';
    final action = isDestructive ? onDelete : onLeave;
    final icon = isDestructive
        ? Icons.delete_outline_rounded
        : Icons.exit_to_app_rounded;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.md),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: DottieColors.error.withAlpha(18),
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        border: Border.all(
            color: DottieColors.error.withAlpha(60), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: DottieColors.error, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: DottieColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: DottieColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: action,
              icon: Icon(icon, size: 18, color: DottieColors.error),
              label: Text(
                label,
                style: const TextStyle(
                  color: DottieColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: DottieColors.error.withAlpha(120)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 내가 숨긴 기록 섹션 ─────────────────────────────────────

/// 룸 설정 본문에 노출되는 작은 진입 카드.
/// 숨긴 dot 이 0개면 카드 자체를 안 그림 (빈 자리 차지 X).
/// 카드 탭 → bottom sheet 로 목록 + 항목별 "숨김 해제".
class _HiddenDotsSection extends ConsumerWidget {
  const _HiddenDotsSection({required this.roomId});
  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDots = ref.watch(hiddenDotsByMeProvider(roomId));
    final dots = asyncDots.valueOrNull ?? const <Dot>[];
    if (dots.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.md),
      child: Material(
        color: DottieColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        child: InkWell(
          borderRadius: BorderRadius.circular(Dimensions.radiusMd),
          onTap: () => _HiddenDotsSheet.show(context, roomId: roomId),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: DottieColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.visibility_off_outlined,
                      size: 18, color: DottieColors.textSecondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '내가 숨긴 기록',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: DottieColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '이 방에서만 안 보이는 내 dot ${dots.length}개',
                        style: const TextStyle(
                          fontSize: 12,
                          color: DottieColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: DottieColors.textHint, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 숨긴 dot 목록을 보여주는 bottom sheet. 각 항목 옆 "보이기" 버튼으로 unhide.
class _HiddenDotsSheet extends ConsumerWidget {
  const _HiddenDotsSheet({required this.roomId});
  final String roomId;

  static Future<void> show(BuildContext context,
      {required String roomId}) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _HiddenDotsSheet(roomId: roomId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDots = ref.watch(hiddenDotsByMeProvider(roomId));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      decoration: const BoxDecoration(
        color: DottieColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: DottieColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimensions.md, Dimensions.md, Dimensions.md, 0),
            child: Row(
              children: [
                const Icon(Icons.visibility_off_outlined,
                    size: 18, color: DottieColors.textSecondary),
                const SizedBox(width: 8),
                const Text(
                  '내가 숨긴 기록',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: DottieColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: DottieColors.textSecondary,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.md),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '"보이기" 를 누르면 다시 이 방의 지도에 나타나요.',
                style: TextStyle(
                  fontSize: 12,
                  color: DottieColors.textHint,
                ),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.sm),
          const Divider(height: 1, color: DottieColors.border),
          Flexible(
            child: asyncDots.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: DottieColors.primary,
                    ),
                  ),
                ),
              ),
              error: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 36),
                child: Center(child: Text('목록을 불러오지 못했어요')),
              ),
              data: (dots) {
                if (dots.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 36),
                    child: Center(
                      child: Text(
                        '숨긴 기록이 없어요',
                        style: TextStyle(
                          color: DottieColors.textHint,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom +
                        Dimensions.md,
                  ),
                  itemCount: dots.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: DottieColors.border),
                  itemBuilder: (_, i) =>
                      _HiddenDotRow(dot: dots[i], roomId: roomId),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HiddenDotRow extends ConsumerStatefulWidget {
  const _HiddenDotRow({required this.dot, required this.roomId});
  final Dot dot;
  final String roomId;

  @override
  ConsumerState<_HiddenDotRow> createState() => _HiddenDotRowState();
}

class _HiddenDotRowState extends ConsumerState<_HiddenDotRow> {
  bool _unhiding = false;

  Future<void> _unhide() async {
    if (_unhiding) return;
    setState(() => _unhiding = true);
    try {
      await ref
          .read(dotRepositoryProvider)
          .unhideDotInRoom(widget.dot.id, widget.roomId);
      if (!mounted) return;
      // 그 룸의 hidden 목록 + 지도/누적 캐시 모두 무효화 — 다음 진입에 즉시 반영.
      ref.invalidate(hiddenDotsByMeProvider(widget.roomId));
      ref.invalidate(cumulativeRoomDotsProvider(widget.roomId));
      ref.invalidate(placeGroupsProvider(widget.roomId));
      final localDate = widget.dot.timestamp.toLocal();
      final dateStr =
          '${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}';
      ref.invalidate(
          sharedMapNotifierProvider(widget.roomId, dateStr));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이 방에서 다시 보이게 했어요')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _unhiding = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('해제에 실패했어요. 잠시 후 다시 시도해 주세요.'),
          backgroundColor: DottieColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dot = widget.dot;
    final placeName = (dot.place?.name.isNotEmpty ?? false)
        ? dot.place!.name
        : dot.placeName;
    final memo = (dot.memo ?? '').trim();
    final dateLabel = DottieDateUtils.toKoreanDate(dot.timestamp.toLocal());

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.md, vertical: 12),
      child: Row(
        children: [
          // 작은 thumb 또는 dot indicator
          if (dot.photoThumbUrl != null && dot.photoThumbUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                dot.photoThumbUrl!,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderTile(),
              ),
            )
          else
            _placeholderTile(),
          const SizedBox(width: 12),
          // 본문
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (placeName?.isNotEmpty ?? false) ? placeName! : '장소 정보 없음',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: DottieColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  memo.isNotEmpty ? '$dateLabel · $memo' : dateLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: DottieColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 보이기 버튼
          TextButton(
            onPressed: _unhiding ? null : _unhide,
            style: TextButton.styleFrom(
              foregroundColor: DottieColors.primary,
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: _unhiding
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: DottieColors.primary,
                    ),
                  )
                : const Text(
                    '보이기',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderTile() => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: DottieColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.place_outlined,
            size: 18, color: DottieColors.textHint),
      );
}

// ── 룸 연결 스팟 리스트 섹션 ──────────────────────────────────────────

class _LinkedSpotsSection extends ConsumerWidget {
  const _LinkedSpotsSection({required this.room, required this.isOwner});
  final Room room;
  final bool isOwner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLists = ref.watch(roomTodoListsProvider(room.id));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '연결된 여행 계획',
                style: TextStyle(
                  color: DottieColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              if (isOwner)
                TextButton.icon(
                  onPressed: () => _showLinkSheet(context, ref),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('연결'),
                  style: TextButton.styleFrom(
                    foregroundColor: DottieColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          asyncLists.when(
            loading: () => const SizedBox(
              height: 40,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (lists) {
              if (lists.isEmpty) {
                return Text(
                  '연결된 여행 계획이 없어요',
                  style: TextStyle(
                    color: DottieColors.textHint,
                    fontSize: 13,
                  ),
                );
              }
              return Column(
                children: lists
                    .map((l) => _LinkedSpotCard(
                          list: l,
                          isOwner: isOwner,
                          roomId: room.id,
                          ref: ref,
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showLinkSheet(BuildContext context, WidgetRef ref) async {
    final myLists = await ref.read(myTodoListsProvider.future);
    // 이미 이 룸에 연결된 리스트 제외
    final linkedIds = (ref.read(roomTodoListsProvider(room.id)).valueOrNull ?? [])
        .map((l) => l.id)
        .toSet();
    final unlinked = myLists.where((l) => l.roomId == null || l.roomId == room.id).toList();

    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: DottieColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _LinkSpotSheet(
        lists: unlinked,
        linkedIds: linkedIds,
        roomId: room.id,
      ),
    );
  }
}

class _LinkedSpotCard extends StatelessWidget {
  const _LinkedSpotCard({
    required this.list,
    required this.isOwner,
    required this.roomId,
    required this.ref,
  });
  final TodoList list;
  final bool isOwner;
  final String roomId;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: DottieColors.surfaceVariant,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Text(list.coverEmoji ?? '📍', style: const TextStyle(fontSize: 24)),
        title: Text(
          list.name,
          style: const TextStyle(
            color: DottieColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          '${list.items.length}개 스팟',
          style: const TextStyle(color: DottieColors.textHint, fontSize: 12),
        ),
        trailing: isOwner
            ? IconButton(
                icon: const Icon(Icons.link_off, size: 18, color: DottieColors.textHint),
                tooltip: '연결 해제',
                onPressed: () => _unlink(context),
              )
            : null,
        onTap: () => context.push('/todo/${list.id}'),
      ),
    );
  }

  Future<void> _unlink(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('연결 해제'),
        content: const Text('이 여행 계획을 룸에서 연결 해제할까요?\n기존 멤버 권한은 유지됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('해제'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(todoNotifierProvider.notifier).setListRoom(list.id, null);
      ref.invalidate(roomTodoListsProvider(roomId));
    } catch (_) {}
  }
}

class _LinkSpotSheet extends ConsumerWidget {
  const _LinkSpotSheet({
    required this.lists,
    required this.linkedIds,
    required this.roomId,
  });
  final List<TodoList> lists;
  final Set<String> linkedIds;
  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (ctx, ctrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: DottieColors.textHint,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '연결할 여행 계획 선택',
              style: TextStyle(
                color: DottieColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: lists.isEmpty
                ? const Center(
                    child: Text(
                      '연결 가능한 여행 계획이 없어요',
                      style: TextStyle(color: DottieColors.textHint),
                    ),
                  )
                : ListView.builder(
                    controller: ctrl,
                    itemCount: lists.length,
                    itemBuilder: (_, i) {
                      final l = lists[i];
                      final isLinked = linkedIds.contains(l.id);
                      return ListTile(
                        leading: Text(l.coverEmoji ?? '📍',
                            style: const TextStyle(fontSize: 22)),
                        title: Text(l.name,
                            style: const TextStyle(
                                color: DottieColors.textPrimary, fontSize: 14)),
                        trailing: isLinked
                            ? const Icon(Icons.check_circle,
                                color: DottieColors.primary, size: 20)
                            : null,
                        onTap: isLinked
                            ? null
                            : () async {
                                Navigator.pop(ctx);
                                try {
                                  await ref
                                      .read(todoNotifierProvider.notifier)
                                      .setListRoom(l.id, roomId);
                                  ref.invalidate(roomTodoListsProvider(roomId));
                                } catch (_) {}
                              },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
