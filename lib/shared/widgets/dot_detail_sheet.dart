import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/date_utils.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/comment/presentation/comment_provider.dart';
import '../../features/cumulative_map/presentation/cumulative_map_provider.dart';
import '../../features/recording/data/dot_remote_source.dart';
import '../../features/recording/data/dot_repository.dart';
import '../../features/recording/domain/dot_model.dart';
import '../../features/recording/presentation/recording_provider.dart';
import '../../features/room/presentation/hidden_dots_provider.dart';
import '../../features/shared_map/presentation/shared_map_provider.dart';
import '../../features/timeline/presentation/timeline_provider.dart';
import 'dot_content_block.dart';

// 멘션 자동완성용 멤버 힌트 — 호출부에서 생성
class DotMemberHint {
  const DotMemberHint({
    required this.userId,
    required this.nickname,
    this.color,
  });
  final String userId;
  final String nickname;
  final Color? color;
}

// ── Dot 상세 시트 ──────────────────────────────────────────

class DotDetailSheet extends ConsumerStatefulWidget {
  const DotDetailSheet({
    super.key,
    required this.dot,
    this.memberName,
    this.memberColor,
    this.showBackButton = false,
    this.roomId,
    this.membersByRoomId = const {},
    this.ownerUserId,
    this.openInMapRoomIds,
    this.openInMapRoomNames,
    this.onOpenInMap,
    this.hideRoomIds,
    this.hideRoomNames,
    this.availableRoomIds,
    this.roomNameById,
  });

  final Dot dot;
  final String? memberName;
  final Color? memberColor;
  final bool showBackButton;
  final String? roomId;

  /// roomId → 멘션 후보 멤버 목록.
  final Map<String, List<DotMemberHint>> membersByRoomId;

  /// 이 dot 의 소유자 user id (BE UUID).
  /// null = caller 가 소유자를 모름 — 본인 dot 가정 (today_map / map_animation).
  /// 값이 있으면 현재 사용자(`currentDottieUser.uid`) 와 비교해 삭제 버튼 노출 결정.
  final String? ownerUserId;

  /// "지도에서 보기" 액션 노출 조건.
  /// null 또는 빈 set → 액션 숨김 (본인 비공개 dot / 지도 컨텍스트 등).
  /// 1개 이상이면 우상단에 아이콘 노출 — 누르면 단일이면 바로, 다수면 선택 시트.
  /// 콜백 [onOpenInMap] 도 같이 채워야 동작.
  final Set<String>? openInMapRoomIds;

  /// roomId → 사용자에게 표시할 방 이름. 여러 방 선택 시트 렌더링용.
  /// 누락된 id 는 "방" 으로 폴백.
  final Map<String, String>? openInMapRoomNames;

  /// 선택된 roomId 받아서 라우팅. DotDetailSheet 는 라우터 의존성을 안 가짐
  /// — caller 가 `/rooms/:id/map` 같은 navigation 을 처리.
  final void Function(String roomId)? onOpenInMap;

  /// "이 방에서 숨기기" 액션의 대상 방 set. 본인 dot 만 의미 있음.
  ///   - 피드 (cross-room): viewer 가 멤버이고 dot 이 공유된 방 모두 — 여러
  ///     방 가능. 사용자가 picker 로 어느 방에서 숨길지 선택.
  ///   - 룸 컨텍스트: 그 방 1개.
  /// null 이면 fallback 으로 [roomId] (단일) 사용. 둘 다 없으면 숨김 X.
  /// 빈 set 이면 숨김 X (본인 비공개 dot).
  final Set<String>? hideRoomIds;

  /// roomId → 방 이름. 다이얼로그 / picker 의 label 용. 누락된 id 는 "방"
  /// 으로 폴백 — chip 색만이라도 표시되어 어느 방인지 인지 가능.
  final Map<String, String>? hideRoomNames;

  /// 댓글 멀티룸 지원 — 피드에서 dot 이 여러 방에 공유된 경우.
  /// 제공 시 댓글 블록에서 룸별 선택 + 뱃지 표시.
  final Set<String>? availableRoomIds;
  final Map<String, String>? roomNameById;

  static Future<void> show(
    BuildContext context,
    Dot dot, {
    String? memberName,
    Color? memberColor,
    bool showBackButton = false,
    String? roomId,
    Map<String, List<DotMemberHint>> membersByRoomId = const {},
    String? ownerUserId,
    Set<String>? openInMapRoomIds,
    Map<String, String>? openInMapRoomNames,
    void Function(String roomId)? onOpenInMap,
    Set<String>? hideRoomIds,
    Map<String, String>? hideRoomNames,
    Set<String>? availableRoomIds,
    Map<String, String>? roomNameById,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DotDetailSheet(
        dot: dot,
        memberName: memberName,
        memberColor: memberColor,
        showBackButton: showBackButton,
        roomId: roomId,
        membersByRoomId: membersByRoomId,
        ownerUserId: ownerUserId,
        openInMapRoomIds: openInMapRoomIds,
        openInMapRoomNames: openInMapRoomNames,
        onOpenInMap: onOpenInMap,
        hideRoomIds: hideRoomIds,
        hideRoomNames: hideRoomNames,
        availableRoomIds: availableRoomIds,
        roomNameById: roomNameById,
      ),
    );
  }

  @override
  ConsumerState<DotDetailSheet> createState() => _DotDetailSheetState();
}

class _DotDetailSheetState extends ConsumerState<DotDetailSheet> {
  final _scrollController = ScrollController();
  bool _deleting = false;
  bool _hiding = false;

  /// 시트 안에서 보고 있는 dot — 사진 variant 가 비동기로 채워지는 동안
  /// BE 에서 단발 polling 으로 자체 갱신. caller 가 넘긴 [widget.dot] 은
  /// 시트 진입 시점의 snapshot 이라 stale 가능 (특히 today_map 의
  /// activeRecording dot — photo_url 만 있고 thumb/preview 둘 다 null).
  late Dot _currentDot;

  // ── photo variant polling 안전 장치 ───────────────────────
  Timer? _photoPollTimer;
  int _pollAttempt = 0;

  /// 이미 진행 중인 BE 호출 — 중복 실행 방지 (외부에서 _runPoll 직접
  /// 호출되어도 한 번에 하나만).
  bool _pollInFlight = false;

  /// 최대 시도 횟수 — 5초 × 6 = 30초 후 자동 종료. variant 워커가 그 안에
  /// 안 끝나면 사용자에게 "처리에 시간이 걸려요" 표시 후 종료.
  static const int _maxPollAttempts = 6;
  static const Duration _pollInterval = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _currentDot = widget.dot;
    if (_currentDot.isPhotoProcessing) {
      _scheduleNextPoll(_pollInterval);
    }
  }

  @override
  void dispose() {
    _photoPollTimer?.cancel();
    _photoPollTimer = null;
    _scrollController.dispose();
    super.dispose();
  }

  /// 다음 polling 단발 예약 — periodic 대신 chain 으로 stack 이 쌓이지 않도록.
  void _scheduleNextPoll(Duration delay) {
    if (!mounted) return;
    if (_pollAttempt >= _maxPollAttempts) return;
    _photoPollTimer?.cancel();
    _photoPollTimer = Timer(delay, _runPoll);
  }

  Future<void> _runPoll() async {
    if (!mounted || _pollInFlight) return;
    _pollInFlight = true;
    _pollAttempt += 1;
    try {
      final repo = ref.read(dotRepositoryProvider);
      // 사용자 dot 의 dayLog 전체를 다시 받아 같은 id 의 dot 으로 갱신.
      final dots = await repo.getDayLogDots(_currentDot.dayLogId);
      if (!mounted) return;
      if (dots != null) {
        Dot? fresh;
        for (final d in dots) {
          if (d.id == _currentDot.id) {
            fresh = d;
            break;
          }
        }
        if (fresh != null && fresh != _currentDot) {
          setState(() => _currentDot = fresh!);
          if (!fresh.isPhotoProcessing) {
            // variant 채워짐 — 종료. (사진 없는 dot 으로 BE 가 응답해도 종료)
            _photoPollTimer?.cancel();
            _photoPollTimer = null;
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('[DotDetail.poll] BE refresh error: $e');
      // 일시 오류 — 다음 시도까지 대기 (max attempts 도달 시 자연 종료)
    } finally {
      _pollInFlight = false;
    }
    // 아직 미완 + 시도 가능 → 다음 tick 예약. dispose 됐으면 mounted=false.
    if (mounted && _pollAttempt < _maxPollAttempts) {
      _scheduleNextPoll(_pollInterval);
    }
  }

  /// 삭제 버튼 노출 조건 — caller 가 owner 를 알려줬다면 본인과 비교,
  /// 안 알려줬으면 본인 dot 가정 (today_map / map_animation 등).
  bool _canDelete() {
    final me = ref.read(currentDottieUserProvider).valueOrNull;
    if (me == null) return false;
    final owner = widget.ownerUserId;
    if (owner == null) return true;
    return owner == me.uid;
  }

  Future<void> _confirmAndDelete() async {
    if (_deleting) return;
    HapticFeedback.lightImpact();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('이 기록을 삭제할까요?'),
        content: const Text(
            '이 dot 과 함께 작성된 댓글도 함께 삭제돼요. 되돌릴 수 없어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _performDelete();
  }

  Future<void> _performDelete() async {
    setState(() => _deleting = true);
    try {
      final repo = ref.read(dotRepositoryProvider);
      final success = await repo.deleteDot(widget.dot);
      if (!mounted) return;
      if (!success) {
        // 네트워크 오류 — 로컬 보존, 사용자에게 안내.
        _showSnack('네트워크 오류 — 잠시 후 다시 시도해주세요');
        setState(() => _deleting = false);
        return;
      }
      _invalidateAfterDelete();
      // DotDetailSheet 닫기. showBackButton=true 면 부모가 DotListSheet 인 경우라
      // 그 stale 한 정적 dot 리스트도 함께 닫아 사용자가 지도로 복귀하게 함
      // (지도는 invalidate 후 _refreshMemberSources 가 즉시 갱신).
      final nav = Navigator.of(context);
      nav.pop();
      if (widget.showBackButton) nav.pop();
    } on DotDeleteException catch (e) {
      if (!mounted) return;
      if (e.isForbidden) {
        _showSnack('본인 기록만 삭제할 수 있어요');
      } else {
        _showSnack('삭제하지 못했어요 (${e.code ?? e.statusCode ?? '알 수 없음'})');
      }
      setState(() => _deleting = false);
    } catch (_) {
      if (!mounted) return;
      _showSnack('삭제 중 오류가 발생했어요');
      setState(() => _deleting = false);
    }
  }

  /// dot 이 노출되던 캐시를 광범위하게 무효화.
  /// roomId 가 있으면 그 룸 화면들, 없어도 timeline / 오늘 세션은 갱신.
  void _invalidateAfterDelete() {
    ref.invalidate(activeRecordingProvider);
    ref.invalidate(timelineDayLogsProvider);
    final roomId = widget.roomId;
    if (roomId != null) {
      final roomKey = ([roomId]..sort()).join(',');
      ref.invalidate(
        mergedCommentListProvider((dotId: widget.dot.id, roomKey: roomKey)),
      );
      ref.invalidate(cumulativeRoomDotsProvider(roomId));
      ref.invalidate(placeGroupsProvider(roomId));
      // sharedMap 은 (roomId, date) 패밀리 — 정확한 date 키로 무효화.
      final localDate = widget.dot.timestamp.toLocal();
      final dateStr =
          '${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}';
      ref.invalidate(sharedMapNotifierProvider(roomId, dateStr));
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  /// 효과적 hide 대상 방 집합. caller 가 `hideRoomIds` 안 줬으면 `widget.roomId`
  /// 폴백 — 룸 컨텍스트 caller (shared_map 등) 호환.
  Set<String> _effectiveHideRoomIds() {
    final fromOpt = widget.hideRoomIds;
    if (fromOpt != null) return fromOpt;
    final rid = widget.roomId;
    if (rid != null) return {rid};
    return const {};
  }

  /// 룸별 숨김 — 본인 dot 만 가능 + 숨길 대상 방이 1개 이상.
  bool _canHide() => _effectiveHideRoomIds().isNotEmpty && _canDelete();

  /// "지도에서 보기" 액션 가능 여부 — caller 가 콜백 + 1개 이상 roomId 를
  /// 넘긴 경우만. 본인 비공개 dot (sharedRoomIds 비어있음) 은 자동 숨김.
  bool _canOpenInMap() {
    final ids = widget.openInMapRoomIds;
    return widget.onOpenInMap != null && ids != null && ids.isNotEmpty;
  }

  Future<void> _handleOpenInMap() async {
    final ids = widget.openInMapRoomIds!.toList();
    HapticFeedback.lightImpact();
    String? pickedId;
    if (ids.length == 1) {
      pickedId = ids.first;
    } else {
      pickedId = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: DottieColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _RoomPicker(
          title: '어느 방의 지도로 갈까요?',
          roomIds: ids,
          roomNames: widget.openInMapRoomNames ?? const {},
        ),
      );
    }
    if (pickedId == null || !mounted) return;
    Navigator.of(context).pop();
    widget.onOpenInMap!(pickedId);
  }

  Future<void> _confirmAndHide() async {
    if (_hiding || _deleting) return;
    HapticFeedback.lightImpact();
    final ids = _effectiveHideRoomIds().toList();
    if (ids.isEmpty) return;

    // 여러 방 공유 dot — 어느 방에서 숨길지 먼저 선택.
    // 1개면 picker 없이 바로 다이얼로그 (룸 컨텍스트 / 단일 방 공유 케이스).
    String? targetRoomId;
    if (ids.length == 1) {
      targetRoomId = ids.first;
    } else {
      targetRoomId = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: DottieColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _RoomPicker(
          title: '어느 방에서 숨길까요?',
          roomIds: ids,
          roomNames: widget.hideRoomNames ?? const {},
        ),
      );
    }
    if (targetRoomId == null || !mounted) return;

    final roomName =
        widget.hideRoomNames?[targetRoomId] ?? '이 방';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '$roomName 에서 숨기기',
          style: const TextStyle(
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
              TextSpan(text: '이 dot 을 '),
              TextSpan(
                text: roomName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const TextSpan(text: ' 에서만 보이지 않게 할까요?\n\n'),
              const TextSpan(
                  text: '다른 방의 공유와 내 기록 보관함에는 그대로 보여요. '),
              const TextSpan(
                text: '숨김 해제는 방 설정의 "내가 숨긴 기록" 에서 할 수 있어요.',
                style: TextStyle(color: DottieColors.textSecondary),
              ),
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
                backgroundColor: DottieColors.primary),
            child: const Text('숨기기'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _performHide(targetRoomId);
  }

  Future<void> _performHide(String roomId) async {
    setState(() => _hiding = true);
    try {
      await ref
          .read(dotRepositoryProvider)
          .hideDotInRoom(widget.dot.id, roomId);
      if (!mounted) return;
      // BE 가 다음 호출부터 자동 필터링 — 그 룸 캐시 무효화 후 시트 닫음.
      _invalidateAfterHideOrDelete(roomId);
      Navigator.of(context).pop();
      // 부모가 DotListSheet 였으면 같이 닫음 (stale 리스트 노출 방지).
      if (widget.showBackButton && mounted) {
        Navigator.of(context).pop();
      }
    } on HideDotException catch (e) {
      if (!mounted) return;
      _showSnack(e.toString());
      setState(() => _hiding = false);
    } catch (_) {
      if (!mounted) return;
      _showSnack('숨김 처리에 실패했어요. 잠시 후 다시 시도해 주세요.');
      setState(() => _hiding = false);
    }
  }

  /// hide 후 룸 캐시 무효화 — delete 와 같은 캐시 영역 + hidden 목록.
  void _invalidateAfterHideOrDelete(String roomId) {
    final roomKey = ([roomId]..sort()).join(',');
    ref.invalidate(
      mergedCommentListProvider((dotId: widget.dot.id, roomKey: roomKey)),
    );
    ref.invalidate(cumulativeRoomDotsProvider(roomId));
    ref.invalidate(placeGroupsProvider(roomId));
    ref.invalidate(hiddenDotsByMeProvider(roomId));
    final localDate = widget.dot.timestamp.toLocal();
    final dateStr =
        '${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}';
    ref.invalidate(sharedMapNotifierProvider(roomId, dateStr));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final canDelete = _canDelete();
    final canHide = _canHide();
    final canOpenInMap = _canOpenInMap();

    return ConstrainedBox(
      // iOS 상단 swipe-down(제어 센터/알림) 영역과 안전한 거리 — 78%.
      // 부족한 콘텐츠는 시트 내부 스크롤로 처리.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: DottieColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
                color: Color(0x28000000),
                blurRadius: 20,
                offset: Offset(0, -4)),
          ],
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

            // 상단 액션 행 — 좌: 목록으로 (옵션),
            // 우: 지도에서 보기 (피드) / 숨김 / 삭제 (본인 dot 한정).
            if (widget.showBackButton || canDelete || canHide || canOpenInMap)
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(4, 4, Dimensions.xs, 0),
                child: Row(
                  children: [
                    if (widget.showBackButton)
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 14,
                          color: DottieColors.primary,
                        ),
                        label: Text(
                          '목록으로',
                          style: GoogleFonts.notoSansKr(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: DottieColors.primary,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    const Spacer(),
                    // 지도에서 보기 — 피드 컨텍스트 (caller 가 콜백 + roomIds 제공).
                    if (canOpenInMap)
                      IconButton(
                        onPressed: _handleOpenInMap,
                        tooltip: '지도에서 보기',
                        icon: const Icon(
                          Icons.map_outlined,
                          size: 22,
                          color: DottieColors.textSecondary,
                        ),
                      ),
                    // 룸별 숨김 — 룸 컨텍스트 + 본인 dot 만.
                    if (canHide)
                      IconButton(
                        onPressed: (_hiding || _deleting)
                            ? null
                            : _confirmAndHide,
                        tooltip: '이 방에서 숨기기',
                        icon: _hiding
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: DottieColors.primary,
                                ),
                              )
                            : const Icon(
                                Icons.visibility_off_outlined,
                                size: 22,
                                color: DottieColors.textSecondary,
                              ),
                      ),
                    if (canDelete)
                      IconButton(
                        onPressed: (_deleting || _hiding)
                            ? null
                            : _confirmAndDelete,
                        tooltip: '기록 삭제',
                        icon: _deleting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.redAccent,
                                ),
                              )
                            : const Icon(
                                Icons.delete_outline_rounded,
                                size: 22,
                                color: Colors.redAccent,
                              ),
                      ),
                  ],
                ),
              ),

            // 스크롤 가능한 본문 + 댓글 목록 + 입력 (DotCommentBlock 안 입력란이
            // ListView 자식이므로 키보드가 올라올 때 padding 으로 입력란이
            // 가려지지 않도록 viewInsets.bottom 을 반영한다.)
            Flexible(
              child: ListView(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  Dimensions.md,
                  (widget.showBackButton || canDelete)
                      ? Dimensions.xs
                      : Dimensions.md,
                  Dimensions.md,
                  MediaQuery.of(context).padding.bottom +
                      bottomInset +
                      Dimensions.lg,
                ),
                shrinkWrap: true,
                children: [
                  DotContentBlock(
                    dot: _currentDot,
                    memberName: widget.memberName,
                    memberColor: widget.memberColor,
                    roomId: widget.roomId,
                    membersByRoomId: widget.membersByRoomId,
                    availableRoomIds: widget.availableRoomIds,
                    roomNameById: widget.roomNameById,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ── 여러 dot 목록 시트 ────────────────────────────────────

class DotListSheet extends StatelessWidget {
  const DotListSheet({
    super.key,
    required this.dots,
    this.memberName,
    this.memberColor,
    this.roomId,
    this.membersByRoomId = const {},
    this.ownerByDotId = const {},
  });

  final List<Dot> dots;
  final String? memberName;
  final Color? memberColor;
  final String? roomId;

  /// roomId → 멘션 후보 멤버 목록.
  final Map<String, List<DotMemberHint>> membersByRoomId;

  /// dot.id → owner user id 매핑. 자식 DotDetailSheet 의 삭제 버튼 노출 결정용.
  /// 비어 있으면 owner 모름 — DotDetailSheet 가 본인 dot 가정 (today_map / map_animation 경로).
  final Map<String, String> ownerByDotId;

  static Future<void> show(
    BuildContext context,
    List<Dot> dots, {
    String? memberName,
    Color? memberColor,
    String? roomId,
    Map<String, List<DotMemberHint>> membersByRoomId = const {},
    Map<String, String> ownerByDotId = const {},
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DotListSheet(
        dots: dots,
        memberName: memberName,
        memberColor: memberColor,
        roomId: roomId,
        membersByRoomId: membersByRoomId,
        ownerByDotId: ownerByDotId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sortedDots = [...dots]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: DottieColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
              color: Color(0x28000000),
              blurRadius: 20,
              offset: Offset(0, -4)),
        ],
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
                Dimensions.md, Dimensions.sm, Dimensions.md, 0),
            child: Row(
              children: [
                if (memberName != null) ...[
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: (memberColor ?? DottieColors.primary)
                          .withAlpha(30),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: (memberColor ?? DottieColors.primary)
                              .withAlpha(100),
                          width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      memberName!.isNotEmpty
                          ? memberName![0].toUpperCase()
                          : '?',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: memberColor ?? DottieColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  '이 위치에 dot ${sortedDots.length}개가 있어요',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: DottieColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.sm),
          const Divider(color: DottieColors.border, height: 1),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(context).padding.bottom + Dimensions.md,
              ),
              itemCount: sortedDots.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: DottieColors.border, height: 1),
              itemBuilder: (ctx, i) {
                final dot = sortedDots[i];
                final hasEmotion =
                    dot.emotion != null && dot.emotion!.isNotEmpty;
                final hasMemo =
                    dot.memo != null && dot.memo!.isNotEmpty;
                final hasPhoto = dot.hasPhotoData;
                return InkWell(
                  onTap: () {
                    DotDetailSheet.show(
                      context,
                      dot,
                      memberName: memberName,
                      memberColor: memberColor,
                      showBackButton: true,
                      roomId: roomId,
                      membersByRoomId: membersByRoomId,
                      ownerUserId: ownerByDotId[dot.id],
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.md, vertical: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          child: Text(
                            DottieDateUtils.toTimeString(dot.timestamp),
                            style: GoogleFonts.notoSansKr(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: DottieColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimensions.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (dot.placeName != null &&
                                  dot.placeName!.isNotEmpty)
                                Text(
                                  dot.placeName!,
                                  style: GoogleFonts.notoSansKr(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: DottieColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (hasEmotion)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    dot.emotion!,
                                    style: GoogleFonts.notoSansKr(
                                      fontSize: 11,
                                      color: DottieColors.primary,
                                    ),
                                  ),
                                ),
                              if (hasMemo)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    dot.memo!,
                                    style: GoogleFonts.notoSansKr(
                                      fontSize: 12,
                                      color: DottieColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (hasPhoto) ...[
                          const SizedBox(width: Dimensions.xs),
                          const Icon(Icons.photo_rounded,
                              size: 16, color: DottieColors.textHint),
                        ],
                        if (roomId != null)
                          Consumer(
                            builder: (context, ref, _) {
                              final roomKey = ([roomId!]..sort()).join(',');
                              final count = ref
                                      .watch(mergedCommentListProvider((
                                        dotId: dot.id,
                                        roomKey: roomKey,
                                      )))
                                      .valueOrNull
                                      ?.length ??
                                  0;
                              if (count == 0) return const SizedBox.shrink();
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(width: Dimensions.xs),
                                  const Icon(Icons.chat_bubble_rounded,
                                      size: 14,
                                      color: DottieColors.textHint),
                                  const SizedBox(width: 2),
                                  Text(
                                    '$count',
                                    style: GoogleFonts.notoSansKr(
                                      fontSize: 11,
                                      color: DottieColors.textHint,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded,
                            size: 18, color: DottieColors.textHint),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── 방 선택 시트 — 여러 방 공유 dot 에서 어느 방에 대한 액션인지 결정 ──────
//
// "지도에서 보기" / "이 방에서 숨기기" 등 여러 방 공유 케이스에서 공통 사용.
// 1개 방이면 caller 가 picker 없이 바로 처리. 여러 개일 때만 이 시트.
//
// 동작: tap 시 선택된 roomId 를 결과로 pop. caller 가 후속 처리.

class _RoomPicker extends StatelessWidget {
  const _RoomPicker({
    required this.title,
    required this.roomIds,
    required this.roomNames,
  });

  final String title;
  final List<String> roomIds;
  final Map<String, String> roomNames;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: DottieColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimensions.md, Dimensions.xs, Dimensions.md, Dimensions.sm),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: GoogleFonts.notoSansKr(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: DottieColors.textPrimary,
                ),
              ),
            ),
          ),
          for (final id in roomIds)
            ListTile(
              leading: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: DottieColors.accentFor(id),
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(
                roomNames[id] ?? '방',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: DottieColors.textPrimary,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: DottieColors.textHint,
                size: 20,
              ),
              onTap: () => Navigator.of(context).pop(id),
            ),
          const SizedBox(height: Dimensions.sm),
        ],
      ),
    );
  }
}
