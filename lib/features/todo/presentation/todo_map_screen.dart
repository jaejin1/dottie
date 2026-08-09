import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/color_hex.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/typography.dart';
import '../../../shared/utils/error_messages.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../room/presentation/room_provider.dart';
import '../domain/course_member_model.dart';
import '../domain/todo_list_model.dart';
import 'todo_provider.dart';
import 'widgets/_day_palette.dart';
import 'widgets/todo_item_input_sheet.dart';
import 'widgets/todo_list_view.dart';
import 'widgets/todo_map_view.dart';

/// 코스 상세 화면 — 지도 + 리스트 토글.
///
/// AppBar:
///   - title: 이름 + 이모지
///   - 우상단: 공유 아이콘 (직접 노출) / 리스트↔지도 토글 / ⋯ 메뉴
/// 여행 코스: AppBar 아래 일자 chip strip
class TodoMapScreen extends ConsumerStatefulWidget {
  const TodoMapScreen({super.key, required this.todoListId});

  final String todoListId;

  @override
  ConsumerState<TodoMapScreen> createState() => _TodoMapScreenState();
}

class _TodoMapScreenState extends ConsumerState<TodoMapScreen> {
  bool _showList = true;
  // -1 = 전체 보기
  int _selectedDay = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(selectedTodoListIdProvider.notifier).select(widget.todoListId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 상세 시트 "지도" 버튼 → 리스트 뷰였다면 지도 뷰로 전환.
    // 카메라 이동은 TodoMapView 가 처리 후 clear().
    ref.listen(todoMapFocusProvider, (_, item) {
      if (item != null && _showList) {
        setState(() => _showList = false);
      }
    });

    final listAsync = ref.watch(todoListByIdProvider(widget.todoListId));
    final list = listAsync.valueOrNull;
    final uid = ref.watch(currentDottieUserProvider).valueOrNull?.uid;
    final canEdit = list?.canEdit(uid) ?? true;
    final isOwner = list != null && uid != null && list.ownerId == uid;
    final isMember = list != null &&
        uid != null &&
        list.members.any((m) => m.userId == uid);
    // 디스커버리로 연 남의 공개 코스 — 내가 owner/member 가 아닌 public 코스.
    final isPublicVisitor =
        list != null && list.isPublic && !isOwner && !isMember;

    // 코스 편집으로 기간이 단축된 경우 선택된 Day가 범위를 벗어날 수 있음.
    if (list != null && _selectedDay >= list.totalDays) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedDay = -1);
      });
    }

    return Scaffold(
      backgroundColor: DottieColors.background,
      appBar: AppBar(
        backgroundColor: DottieColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: list == null
            ? Container(
                width: 140,
                height: 18,
                decoration: BoxDecoration(
                  color: DottieColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(list.coverEmoji ?? '📍',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          list.name,
                          style: AppTypography.tabHeader(),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (list.description != null &&
                            list.description!.isNotEmpty)
                          Text(
                            list.description!,
                            style: GoogleFonts.notoSansKr(
                              fontSize: 11,
                              color: DottieColors.textPrimary
                                  .withValues(alpha: 0.45),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (list.isPublic) ...[
                    const SizedBox(width: 6),
                    Icon(Icons.public_rounded,
                        size: 15,
                        color: DottieColors.primary.withValues(alpha: 0.7)),
                  ],
                ],
              ),
        centerTitle: false,
        actions: [
          // 좋아요는 둘러보기 카드에서만 누른다(인스타 방식) — 관리 화면인
          // 상세엔 좋아요 버튼을 두지 않음. 공개 상태는 제목 옆 🌐 로만 표시.
          // 초대 버튼 — owner 만 노출
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_rounded,
                  color: DottieColors.textSecondary, size: 22),
              tooltip: '멤버 초대',
              onPressed: () => _showInviteSheet(list),
            ),
          IconButton(
            icon: Icon(
              _showList
                  ? Icons.map_outlined
                  : Icons.format_list_bulleted_rounded,
              color: DottieColors.textSecondary,
              size: 22,
            ),
            tooltip: _showList ? '지도 보기' : '리스트 보기',
            onPressed: () => setState(() => _showList = !_showList),
          ),
          // 설정 — owner=편집, member=나가기. 남의 공개 코스(비멤버)엔 미노출.
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.settings_outlined,
                  color: DottieColors.textSecondary, size: 22),
              tooltip: '코스 편집',
              onPressed: () => context.push('/todos/${list.id}/edit'),
            )
          else if (list != null && isMember)
            IconButton(
              icon: const Icon(Icons.settings_outlined,
                  color: DottieColors.textSecondary, size: 22),
              tooltip: '코스 나가기',
              onPressed: () => _confirmLeave(context, list),
            ),
          // 남의 공개 코스 — 가져오기 + 신고(⋯).
          if (isPublicVisitor) _PublicVisitorActions(list: list),
          const SizedBox(width: 4),
        ],
        bottom: list != null && list.isTrip
            ? PreferredSize(
                preferredSize: const Size.fromHeight(44),
                child: _DayChipStrip(
                  list: list,
                  selectedDay: _selectedDay,
                  onDaySelected: (d) => setState(() => _selectedDay = d),
                ),
              )
            : null,
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(error: e, onRetry: () {
          // ignore: unused_result
          ref.refresh(todoListByIdProvider(widget.todoListId));
        }),
        data: (list) {
          if (list == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(Dimensions.xl),
                child: Text(
                  '이 코스를 찾을 수 없어요',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: DottieColors.textSecondary),
                ),
              ),
            );
          }
          final dayFilter = list.isTrip ? _selectedDay : -1;
          if (!_showList) {
            return TodoMapView(
              todoListId: list.id,
              filterDayIndex: dayFilter,
            );
          }
          return Column(
            children: [
              if (list.isShared) _CourseMemberBar(list: list),
              if (list.roomId != null)
                _RoomBadgeBanner(
                    list: list, isOwner: isOwner),
              Expanded(
                child: TodoListView(
                    todoListId: list.id, filterDayIndex: dayFilter),
              ),
            ],
          );
        },
      ),
      floatingActionButton: list == null || !canEdit
          ? null
          : FloatingActionButton(
              heroTag: 'todo-add-fab',
              onPressed: () => _addItem(list),
              backgroundColor: DottieColors.primary,
              foregroundColor: Colors.white,
              tooltip: '스팟 추가',
              child: const Icon(Icons.add_location_alt_rounded),
            ),
    );
  }

  Future<void> _addItem(TodoList list) async {
    final initialDayIndex = _selectedDay >= 0 ? _selectedDay : 0;
    await TodoItemInputSheet.show(
      context,
      todoList: list,
      initialDayIndex: initialDayIndex,
    );
  }

  Future<void> _showInviteSheet(TodoList list) async {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InviteSheet(todoList: list),
    );
  }

  Future<void> _confirmLeave(BuildContext context, TodoList list) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dc) => AlertDialog(
        title: const Text('코스 나가기'),
        content: Text("'${list.name}'에서 나갈까요?\n나가면 이 코스가 목록에서 사라져요."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dc, false),
              child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(dc, true),
            child:
                const Text('나가기', style: TextStyle(color: DottieColors.error)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(todoNotifierProvider.notifier).leaveCourse(list.id);
      if (!context.mounted) return;
      context.go('/todos');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userMessageFor(e))),
        );
      }
    }
  }
}

/// 남의 공개 코스 방문자용 액션 — "가져오기"(clone) + ⋯ 신고.
class _PublicVisitorActions extends ConsumerStatefulWidget {
  const _PublicVisitorActions({required this.list});
  final TodoList list;

  @override
  ConsumerState<_PublicVisitorActions> createState() =>
      _PublicVisitorActionsState();
}

class _PublicVisitorActionsState
    extends ConsumerState<_PublicVisitorActions> {
  bool _cloning = false;

  Future<void> _clone() async {
    if (_cloning) return;
    setState(() => _cloning = true);
    try {
      final newId = await ref
          .read(todoNotifierProvider.notifier)
          .cloneCourse(widget.list.id);
      if (!mounted) return;
      setState(() => _cloning = false);
      if (newId == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('내 스팟으로 가져왔어요')),
      );
      context.push('/todos/$newId');
    } catch (e) {
      if (!mounted) return;
      setState(() => _cloning = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessageFor(e))),
      );
    }
  }

  Future<void> _report() async {
    // BE 는 reason 을 자유 텍스트(≤100자)로 저장 — 모더레이터가 읽을 한글 라벨을
    // 그대로 전송한다(enum 코드 아님).
    const reasons = <String>[
      '스팸/광고',
      '부적절한 콘텐츠',
      '저작권 침해',
      '기타',
    ];
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: DottieColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text('신고 사유', style: AppTypography.tabHeader()),
            const SizedBox(height: 8),
            for (final label in reasons)
              ListTile(
                title: Text(label,
                    style: GoogleFonts.notoSansKr(fontSize: 14)),
                onTap: () => Navigator.pop(sheetCtx, label),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked == null || !mounted) return;
    try {
      await ref
          .read(todoNotifierProvider.notifier)
          .reportCourse(widget.list.id, reason: picked);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('신고가 접수되었어요')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessageFor(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 가져오기
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Material(
            color: DottieColors.primary,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: _cloning ? null : _clone,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_cloning)
                      const SizedBox(
                        width: 13,
                        height: 13,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    else
                      const Icon(Icons.download_rounded,
                          size: 15, color: Colors.white),
                    const SizedBox(width: 4),
                    const Text(
                      '가져오기',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded,
              color: DottieColors.textSecondary, size: 20),
          tooltip: '더보기',
          onPressed: _report,
        ),
      ],
    );
  }
}

/// 초대 코드 생성 + 공유 시트.
class _InviteSheet extends ConsumerStatefulWidget {
  const _InviteSheet({required this.todoList});
  final TodoList todoList;

  @override
  ConsumerState<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends ConsumerState<_InviteSheet> {
  bool _busy = false;
  String? _inviteUrl;
  DateTime? _expiresAt;
  String _role = 'member'; // 'member' | 'viewer'

  Future<void> _generate() async {
    setState(() => _busy = true);
    try {
      final result = await ref
          .read(todoNotifierProvider.notifier)
          .generateCourseInviteCode(widget.todoList.id, role: _role);
      if (!mounted) return;
      if (result != null) {
        setState(() {
          _inviteUrl =
              '${AppConfig.webHost}/invite/course/${result.code}';
          _expiresAt = result.expiresAt;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('초대 링크 생성에 실패했어요')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessageFor(e))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = _inviteUrl;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: DottieColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusLg),
      ),
      padding: const EdgeInsets.fromLTRB(
          Dimensions.md, Dimensions.md, Dimensions.md, Dimensions.lg),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: DottieColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.md),
            Text(
              '초대 링크',
              style: GoogleFonts.notoSansKr(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: DottieColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '권한을 선택하고 링크를 복사하세요',
              style: TextStyle(
                fontSize: 12,
                color: DottieColors.textPrimary.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: Dimensions.md),
            // 권한 선택 카드
            Row(
              children: [
                Expanded(
                  child: _RoleCard(
                    label: '함께 편집',
                    desc: '스팟 추가·수정 가능',
                    selected: _role == 'member',
                    onTap: () {
                      if (_role != 'member') {
                        setState(() { _role = 'member'; _inviteUrl = null; });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _RoleCard(
                    label: '보기만',
                    desc: '스팟 조회만 가능',
                    selected: _role == 'viewer',
                    onTap: () {
                      if (_role != 'viewer') {
                        setState(() { _role = 'viewer'; _inviteUrl = null; });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.md),
            if (url != null) ...[
              if (_expiresAt != null) ...[
                Text(
                  '${_formatExpires(_expiresAt!)} 사용 가능',
                  style: TextStyle(
                    fontSize: 12,
                    color: DottieColors.textPrimary.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: Dimensions.sm),
              ],
              // 링크 박스 — 탭하면 클립보드 복사
              GestureDetector(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: url));
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
                          url,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color:
                                DottieColors.primary.withValues(alpha: 0.85),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.copy_rounded,
                          size: 16, color: DottieColors.textHint),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                        backgroundColor: DottieColors.primary),
                    child: const Text('확인'),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _busy ? null : _generate,
                  style: FilledButton.styleFrom(
                    backgroundColor: DottieColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusMd),
                    ),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.2,
                          ),
                        )
                      : const Text(
                          '초대 링크 만들기',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatExpires(DateTime dt) {
    final local = dt.toLocal();
    final now = DateTime.now();
    final diff = local.difference(now);
    if (diff.isNegative) return '만료됨';
    if (diff.inHours < 1) return '${diff.inMinutes}분 후';
    if (diff.inHours < 24) return '${diff.inHours}시간 후';
    return '${diff.inDays}일 후';
  }
}

/// 공유 코스 멤버 바 — 멤버 아바타 + 강퇴(owner).
class _CourseMemberBar extends ConsumerWidget {
  const _CourseMemberBar({required this.list});
  final TodoList list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentDottieUserProvider).valueOrNull;
    final isOwner = me != null && list.ownerId == me.uid;

    return Container(
      color: DottieColors.surface,
      padding: const EdgeInsets.fromLTRB(
          Dimensions.md, Dimensions.sm, Dimensions.md, Dimensions.sm),
      child: Row(
        children: [
          const Icon(Icons.group_outlined,
              size: 14, color: DottieColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            '멤버 ${list.members.length}명',
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: DottieColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: list.members
                    .map((m) => _MemberAvatar(
                          member: m,
                          list: list,
                          meUid: me?.uid,
                          isOwnerView: isOwner,
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberAvatar extends ConsumerWidget {
  const _MemberAvatar({
    required this.member,
    required this.list,
    required this.meUid,
    required this.isOwnerView,
  });

  final CourseMember member;
  final TodoList list;
  final String? meUid;
  final bool isOwnerView;

  bool get _memberIsOwner => member.userId == list.ownerId;
  bool get _isSelf => meUid != null && member.userId == meUid;
  bool get _canKick => isOwnerView && !_isSelf && !_memberIsOwner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = colorFromHex(member.character.colorHex,
        fallback: DottieColors.primary);
    final chip = Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: _memberIsOwner
                  ? Border.all(
                      color: DottieColors.primary.withValues(alpha: 0.5),
                      width: 2)
                  : null,
            ),
            alignment: Alignment.center,
            child: Text(
              member.nickname.isNotEmpty ? member.nickname.characters.first : '?',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            member.nickname,
            style: TextStyle(
              fontSize: 9,
              color: DottieColors.textPrimary.withValues(alpha: 0.6),
            ),
          ),
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (dc) => AlertDialog(
        title: const Text('멤버 내보내기',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text('${member.nickname} 님을 이 코스에서 내보낼까요?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dc, false),
              child: const Text('취소')),
          FilledButton(
            onPressed: () => Navigator.pop(dc, true),
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
          .read(todoNotifierProvider.notifier)
          .kickCourseMember(list.id, member.userId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${member.nickname} 님을 내보냈어요')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessageFor(e))),
      );
    }
  }
}

/// 일자 chip strip — 여행 코스 전용.
class _DayChipStrip extends StatelessWidget {
  const _DayChipStrip({
    required this.list,
    required this.selectedDay,
    required this.onDaySelected,
  });

  final TodoList list;
  final int selectedDay;
  final ValueChanged<int> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final days = list.totalDays;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: days + 1, // +1 for "전체"
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final isAll = i == 0;
          final dayIndex = i - 1;
          final selected = isAll ? selectedDay == -1 : selectedDay == dayIndex;
          final label = isAll ? '전체' : 'Day ${dayIndex + 1}';

          // 날짜가 있으면 날짜도 표시
          String? dateLabel;
          if (!isAll) {
            final date = list.dateForDayIndex(dayIndex);
            dateLabel = '${date.month}/${date.day}';
          }

          return GestureDetector(
            onTap: () => onDaySelected(isAll ? -1 : dayIndex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? DottieColors.primary
                    : DottieColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? DottieColors.primary
                      : DottieColors.border,
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // day 색 점 — 지도 라인/핀·리스트 헤더와 같은 팔레트.
                  if (!isAll) ...[
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white
                            : dayColorOf(dayIndex),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : DottieColors.textSecondary,
                    ),
                  ),
                  if (dateLabel != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: selected
                            ? Colors.white.withValues(alpha: 0.8)
                            : DottieColors.textHint,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined,
                size: 48,
                color: DottieColors.textPrimary.withValues(alpha: 0.4)),
            const SizedBox(height: Dimensions.md),
            const Text(
              '불러오지 못했어요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: DottieColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              // raw error 노출 금지 — DioException 등은 내부 URL 포함.
              userMessageFor(error),
              textAlign: TextAlign.center,
              maxLines: 3,
              style: TextStyle(
                fontSize: 12,
                height: 1.6,
                color: DottieColors.textPrimary.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: Dimensions.lg),
            FilledButton.icon(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: DottieColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.label,
    required this.desc,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String desc;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? DottieColors.primary.withValues(alpha: 0.08)
              : DottieColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? DottieColors.primary.withValues(alpha: 0.5)
                : DottieColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? DottieColors.primary : DottieColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: TextStyle(
                fontSize: 11,
                color: DottieColors.textPrimary.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 룸 연결 배지 배너 ─────────────────────────────────────────────────

class _RoomBadgeBanner extends ConsumerWidget {
  const _RoomBadgeBanner({required this.list, required this.isOwner});
  final TodoList list;
  final bool isOwner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomAsync = ref.watch(roomDetailProvider(list.roomId!));
    final roomName = roomAsync.valueOrNull?.name;

    return Container(
      width: double.infinity,
      color: DottieColors.primary.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.group_outlined,
              size: 14, color: DottieColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              roomName != null ? '룸 "$roomName"에 연결됨' : '룸에 연결됨',
              style: const TextStyle(
                color: DottieColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (isOwner)
            GestureDetector(
              onTap: () => _confirmUnlink(context, ref),
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.link_off, size: 14, color: DottieColors.primary),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmUnlink(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('룸 연결 해제'),
        content: const Text('이 여행 계획을 룸에서 연결 해제할까요?'),
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
      ref.invalidate(todoListByIdProvider(list.id));
    } catch (_) {}
  }
}

