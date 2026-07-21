import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/color_hex.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/text_validators.dart';
import '../../../shared/widgets/dot_detail_sheet.dart' show DotMemberHint;
import '../../auth/presentation/auth_provider.dart';
import '../data/comment_remote_source.dart';
import '../domain/comment_model.dart';
import 'comment_count_overrides_provider.dart';
import 'comment_provider.dart';

/// dot 의 댓글 list + 입력 컴포저를 한 위젯으로 묶음.
///
/// [availableRoomIds] — 이 dot 이 공유된 룸 ID 집합. 여러 룸이면 댓글 작성 시
/// 룸 선택 chip 이 표시되며, 각 댓글에 출처 룸 뱃지가 노출된다.
///
/// [membersByRoomId] — roomId → 멘션 후보 멤버 목록. 선택된 룸 기준으로
/// 멘션 후보가 동적으로 좁혀진다.
class DotCommentBlock extends ConsumerStatefulWidget {
  const DotCommentBlock({
    super.key,
    required this.dotId,
    required this.availableRoomIds,
    required this.roomNameById,
    required this.membersByRoomId,
  });

  final String dotId;
  final Set<String> availableRoomIds;
  final Map<String, String> roomNameById;

  /// roomId → 해당 룸의 멘션 후보 멤버 목록.
  final Map<String, List<DotMemberHint>> membersByRoomId;

  @override
  ConsumerState<DotCommentBlock> createState() => _DotCommentBlockState();
}

class _DotCommentBlockState extends ConsumerState<DotCommentBlock> {
  late final _MentionAwareController _controller;
  bool _posting = false;
  String? _mentionQuery;
  late Set<String> _selectedPostRoomIds;
  String? _errorMessage;
  Timer? _errorTimer;

  bool get _multiRoom => widget.availableRoomIds.length > 1;

  String get _roomKey =>
      ([...widget.availableRoomIds]..sort()).join(',');

  /// 현재 선택된 전송 대상 룸들의 멤버 합집합 (userId 기준 중복 제거).
  List<DotMemberHint> get _effectiveMembers {
    final targets = _selectedPostRoomIds.isEmpty
        ? widget.availableRoomIds
        : _selectedPostRoomIds;
    final seen = <String>{};
    final result = <DotMemberHint>[];
    for (final roomId in targets) {
      for (final m in widget.membersByRoomId[roomId] ?? const []) {
        if (seen.add(m.userId)) result.add(m);
      }
    }
    return result;
  }

  /// 댓글 표시용 전체 멤버 합집합 (룸 선택과 무관, 작성자 색상 조회용).
  List<DotMemberHint> get _allMembers {
    final seen = <String>{};
    final result = <DotMemberHint>[];
    for (final list in widget.membersByRoomId.values) {
      for (final m in list) {
        if (seen.add(m.userId)) result.add(m);
      }
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    _controller =
        _MentionAwareController(membersBuilder: () => _effectiveMembers);
    _selectedPostRoomIds = Set.from(widget.availableRoomIds);
  }

  @override
  void dispose() {
    _errorTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    _errorTimer?.cancel();
    setState(() => _errorMessage = msg);
    _errorTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _errorMessage = null);
    });
  }

  void _onChanged(String text) {
    final cursor = _controller.selection.baseOffset;
    if (cursor < 0) return;
    final before = text.substring(0, cursor.clamp(0, text.length));
    final lastAt = before.lastIndexOf('@');
    if (lastAt == -1) {
      if (_mentionQuery != null) setState(() => _mentionQuery = null);
      return;
    }
    final query = before.substring(lastAt + 1);
    if (query.contains(' ') || query.contains('\n')) {
      if (_mentionQuery != null) setState(() => _mentionQuery = null);
      return;
    }
    if (_mentionQuery != query) setState(() => _mentionQuery = query);
  }

  void _insertMention(DotMemberHint member) {
    final text = _controller.text;
    final cursor = _controller.selection.baseOffset.clamp(0, text.length);
    final lastAt = text.lastIndexOf('@', cursor);
    if (lastAt == -1) return;
    final before = text.substring(0, lastAt);
    final after = text.substring(cursor);
    final inserted = '@${member.nickname}';
    final newText = '$before$inserted $after';
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(
      offset: lastAt + inserted.length + 1,
    );
    setState(() => _mentionQuery = null);
  }

  List<MentionSpan> _extractMentions(String text) {
    final result = <MentionSpan>[];
    for (final m in _effectiveMembers) {
      final pattern = '@${m.nickname}';
      var idx = 0;
      while (true) {
        final pos = text.indexOf(pattern, idx);
        if (pos == -1) break;
        result.add(MentionSpan(
          userId: m.userId,
          nickname: m.nickname,
          start: pos,
          end: pos + pattern.length,
        ));
        idx = pos + pattern.length;
      }
    }
    return result;
  }

  Future<void> _post() async {
    // 한글 IME 조합 중인 자모를 완성 음절로 강제 커밋.
    // GestureDetector.onTap 은 TextField focus 를 유지하므로 IME 커밋이 발생하지 않는다.
    _controller.value = _controller.value.copyWith(composing: TextRange.empty);

    final text = _controller.text.trim();
    if (text.isEmpty) {
      debugPrint('[comment.post] blocked: empty text');
      return;
    }
    if (text.length > 500 || _posting) return;
    if (!TextValidators.isValidUserText(text)) {
      debugPrint('[comment.post] blocked: invalid text (IME jamo?): "$text"');
      HapticFeedback.selectionClick();
      _showError('글자를 완성해 주세요');
      return;
    }
    final targets = _selectedPostRoomIds.isEmpty
        ? widget.availableRoomIds
        : _selectedPostRoomIds;
    if (targets.isEmpty) {
      debugPrint('[comment.post] blocked: no target rooms');
      HapticFeedback.selectionClick();
      _showError('댓글을 보낼 방을 하나 이상 선택해 주세요');
      return;
    }
    setState(() => _posting = true);
    try {
      final mentions = _extractMentions(text);
      final source = ref.read(commentRemoteSourceProvider);
      await source.postComment(
        widget.dotId,
        roomIds: targets.toList(),
        content: text,
        mentions: mentions,
      );
      if (!mounted) return;
      HapticFeedback.lightImpact();
      // Optimistic count — merged provider 재조회 전 카드 카운트 즉시 갱신.
      final current = ref
              .read(mergedCommentListProvider(
                  (dotId: widget.dotId, roomKey: _roomKey)))
              .valueOrNull
              ?.length ??
          0;
      ref
          .read(commentCountOverridesProvider.notifier)
          .set(widget.dotId, current + 1);
      ref.invalidate(
          mergedCommentListProvider((dotId: widget.dotId, roomKey: _roomKey)));
      _controller.clear();
      setState(() => _mentionQuery = null);
    } catch (e) {
      debugPrint('[comment.post] error: $e');
      HapticFeedback.selectionClick();
      if (mounted) _showError('댓글 전송에 실패했어요');
    } finally {
      _posting = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = ref.watch(currentDottieUserProvider).valueOrNull?.uid ??
        ref.watch(currentUserProvider)?.uid;
    final effective = _effectiveMembers;
    final mentionCandidates = _mentionQuery == null
        ? <DotMemberHint>[]
        : effective
            .where((m) => m.userId != myUid)
            .where((m) => m.nickname
                .toLowerCase()
                .startsWith(_mentionQuery!.toLowerCase()))
            .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MergedCommentList(
          dotId: widget.dotId,
          roomKey: _roomKey,
          multiRoom: _multiRoom,
          roomNameById: widget.roomNameById,
          allMembers: _allMembers,
        ),

        if (_multiRoom) ...[
          const SizedBox(height: 10),
          _RoomSelectorChips(
            availableRoomIds: widget.availableRoomIds,
            roomNameById: widget.roomNameById,
            selected: _selectedPostRoomIds,
            onToggle: (id) => setState(() {
              if (_selectedPostRoomIds.contains(id)) {
                _selectedPostRoomIds.remove(id);
              } else {
                _selectedPostRoomIds.add(id);
              }
            }),
          ),
        ],

        if (mentionCandidates.isNotEmpty) ...[
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: mentionCandidates.map((m) {
                final c = m.color ?? DottieColors.primary;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _insertMention(m),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: c.withAlpha(40),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: c.withAlpha(120), width: 1),
                      ),
                      child: Text(
                        '@${m.nickname}',
                        style: GoogleFonts.notoSansKr(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: c,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        const SizedBox(height: 8),

        if (_errorMessage != null)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.redAccent.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.redAccent.withAlpha(80), width: 0.8),
            ),
            child: Text(
              _errorMessage!,
              style: GoogleFonts.notoSansKr(
                fontSize: 12,
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                maxLines: 4,
                minLines: 1,
                maxLength: 500,
                buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                    null,
                textInputAction: TextInputAction.newline,
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
                  color: DottieColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '댓글을 입력해요...',
                  hintStyle: GoogleFonts.notoSansKr(
                    fontSize: 14,
                    color: DottieColors.textHint,
                  ),
                  filled: true,
                  fillColor: DottieColors.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _post,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _posting
                      ? DottieColors.primary.withAlpha(100)
                      : DottieColors.primary,
                  shape: BoxShape.circle,
                ),
                child: _posting
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── 통합 댓글 목록 ───────────────────────────────────────────

class _MergedCommentList extends ConsumerWidget {
  const _MergedCommentList({
    required this.dotId,
    required this.roomKey,
    required this.multiRoom,
    required this.roomNameById,
    required this.allMembers,
  });
  final String dotId;
  final String roomKey;
  final bool multiRoom;
  final Map<String, String> roomNameById;
  final List<DotMemberHint> allMembers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerKey = (dotId: dotId, roomKey: roomKey);
    // 데이터 도착마다 카드 카운트 override 갱신 — feedNotifierProvider 재조회 불필요.
    ref.listen(mergedCommentListProvider(providerKey), (_, next) {
      if (next.hasValue) {
        ref
            .read(commentCountOverridesProvider.notifier)
            .set(dotId, next.value!.length);
      }
    });

    // unwrapPrevious: refresh 중에는 이전 data 를 그대로 노출해 레이아웃 shift 방지.
    // 첫 로드에만 loading 상태가 노출된다.
    final state = ref
        .watch(mergedCommentListProvider(providerKey))
        .unwrapPrevious();
    final currentUid = ref.watch(currentUserProvider)?.uid;

    return state.when(
      skipLoadingOnRefresh: true,
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: DottieColors.primary,
              strokeWidth: 2,
            ),
          ),
        ),
      ),
      error: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          '댓글을 불러오지 못했어요',
          style: GoogleFonts.notoSansKr(
              fontSize: 13, color: DottieColors.textHint),
        ),
      ),
      data: (comments) {
        if (comments.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '첫 댓글을 남겨보세요 💬',
              style: GoogleFonts.notoSansKr(
                fontSize: 13,
                color: DottieColors.textHint,
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '댓글 ${comments.length}개',
              style: GoogleFonts.notoSansKr(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: DottieColors.textSecondary,
              ),
            ),
            const SizedBox(height: Dimensions.sm),
            ...comments.map((c) {
              final roomNames = multiRoom
                  ? c.roomIds.map((id) => roomNameById[id] ?? id).toList()
                  : null;
              return _CommentItem(
                comment: c,
                isOwn: c.authorId == currentUid,
                allMembers: allMembers,
                roomNames: roomNames,
                onDelete: () async {
                  await ref
                      .read(commentRemoteSourceProvider)
                      .deleteComment(c.id);
                  // Optimistic count decrement.
                  final current = ref
                          .read(mergedCommentListProvider(providerKey))
                          .valueOrNull
                          ?.length ??
                      0;
                  if (current > 0) {
                    ref
                        .read(commentCountOverridesProvider.notifier)
                        .set(dotId, current - 1);
                  }
                  ref.invalidate(mergedCommentListProvider(providerKey));
                },
              );
            }),
          ],
        );
      },
    );
  }
}

// ── 룸 선택 chip ─────────────────────────────────────────────

class _RoomSelectorChips extends StatelessWidget {
  const _RoomSelectorChips({
    required this.availableRoomIds,
    required this.roomNameById,
    required this.selected,
    required this.onToggle,
  });

  final Set<String> availableRoomIds;
  final Map<String, String> roomNameById;
  final Set<String> selected;
  final void Function(String roomId) onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '댓글 보낼 방',
          style: GoogleFonts.notoSansKr(
            fontSize: 11,
            color: DottieColors.textHint,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: availableRoomIds.map((id) {
            final isOn = selected.contains(id);
            final name = roomNameById[id] ?? id;
            return GestureDetector(
              onTap: () => onToggle(id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOn
                      ? DottieColors.primary.withAlpha(30)
                      : DottieColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isOn
                        ? DottieColors.primary.withAlpha(180)
                        : DottieColors.border,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isOn)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: DottieColors.primary,
                        ),
                      ),
                    Text(
                      name,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 12,
                        fontWeight:
                            isOn ? FontWeight.w700 : FontWeight.w400,
                        color: isOn
                            ? DottieColors.primary
                            : DottieColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── 댓글 아이템 ──────────────────────────────────────────────

class _CommentItem extends StatelessWidget {
  const _CommentItem({
    required this.comment,
    required this.isOwn,
    required this.allMembers,
    required this.onDelete,
    this.roomNames,
  });

  final DotComment comment;
  final bool isOwn;
  final List<DotMemberHint> allMembers;
  final VoidCallback onDelete;
  final List<String>? roomNames;

  Color _authorColor() {
    if (comment.authorColorHex.isNotEmpty) {
      return colorFromHex(comment.authorColorHex, fallback: DottieColors.primary);
    }
    for (final m in allMembers) {
      if (m.userId == comment.authorId) return m.color ?? DottieColors.primary;
    }
    return DottieColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final authorColor = _authorColor();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: authorColor.withAlpha(45),
              shape: BoxShape.circle,
              border: Border.all(color: authorColor.withAlpha(120), width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              comment.authorNickname.isNotEmpty
                  ? comment.authorNickname[0].toUpperCase()
                  : '?',
              style: GoogleFonts.notoSansKr(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: authorColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorNickname,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: authorColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DottieDateUtils.toTimeString(comment.createdAt),
                      style: GoogleFonts.notoSansKr(
                        fontSize: 11,
                        color: DottieColors.textHint,
                      ),
                    ),
                    if (roomNames != null && roomNames!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      ...roomNames!.map((name) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: DottieColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: DottieColors.border, width: 0.8),
                              ),
                              child: Text(
                                name,
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 10,
                                  color: DottieColors.textSecondary,
                                ),
                              ),
                            ),
                          )),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                _buildContent(context),
              ],
            ),
          ),
          if (isOwn)
            GestureDetector(
              onTap: () => _confirmDelete(context),
              child: const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(Icons.close_rounded,
                    size: 16, color: DottieColors.textHint),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final baseStyle = GoogleFonts.notoSansKr(
      fontSize: 14,
      color: DottieColors.textPrimary,
      height: 1.4,
    );
    if (comment.mentions.isEmpty) {
      return Text(comment.content, style: baseStyle);
    }
    final spans = <TextSpan>[];
    int cursor = 0;
    final sorted = [...comment.mentions]
      ..sort((a, b) => a.start.compareTo(b.start));
    for (final m in sorted) {
      final safeStart = m.start.clamp(0, comment.content.length);
      final safeEnd = m.end.clamp(safeStart, comment.content.length);
      if (safeStart > cursor) {
        spans.add(TextSpan(text: comment.content.substring(cursor, safeStart)));
      }
      final mentionColor =
          colorFromHex(m.colorHex, fallback: DottieColors.primary);
      spans.add(TextSpan(
        text: comment.content.substring(safeStart, safeEnd),
        style: TextStyle(color: mentionColor, fontWeight: FontWeight.w700),
      ));
      cursor = safeEnd;
    }
    if (cursor < comment.content.length) {
      spans.add(TextSpan(text: comment.content.substring(cursor)));
    }
    return RichText(text: TextSpan(style: baseStyle, children: spans));
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('댓글 삭제',
            style: GoogleFonts.notoSansKr(fontWeight: FontWeight.w700)),
        content: Text('이 댓글을 삭제할까요?', style: GoogleFonts.notoSansKr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('취소',
                style: GoogleFonts.notoSansKr(
                    color: DottieColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              onDelete();
            },
            child: Text('삭제',
                style: GoogleFonts.notoSansKr(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── 멘션 인라인 강조 컨트롤러 ────────────────────────────────

class _MentionAwareController extends TextEditingController {
  _MentionAwareController({required this.membersBuilder});

  final List<DotMemberHint> Function() membersBuilder;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final members = membersBuilder();
    final raw = text;
    if (raw.isEmpty || members.isEmpty) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }

    final sortedMembers = [...members]
      ..sort((a, b) => b.nickname.length.compareTo(a.nickname.length));
    final ranges = <_MentionRange>[];
    for (final m in sortedMembers) {
      final pattern = '@${m.nickname}';
      var idx = 0;
      while (true) {
        final pos = raw.indexOf(pattern, idx);
        if (pos == -1) break;
        final overlap = ranges.any(
            (r) => !(pos + pattern.length <= r.start || pos >= r.end));
        if (!overlap) {
          ranges.add(_MentionRange(
            start: pos,
            end: pos + pattern.length,
            color: m.color ?? DottieColors.primary,
          ));
        }
        idx = pos + pattern.length;
      }
    }
    if (ranges.isEmpty) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    ranges.sort((a, b) => a.start.compareTo(b.start));

    final children = <TextSpan>[];
    var cursor = 0;
    for (final r in ranges) {
      if (r.start > cursor) {
        children.add(TextSpan(text: raw.substring(cursor, r.start)));
      }
      children.add(TextSpan(
        text: raw.substring(r.start, r.end),
        style: TextStyle(color: r.color, fontWeight: FontWeight.w700),
      ));
      cursor = r.end;
    }
    if (cursor < raw.length) {
      children.add(TextSpan(text: raw.substring(cursor)));
    }
    return TextSpan(style: style, children: children);
  }
}

class _MentionRange {
  const _MentionRange({
    required this.start,
    required this.end,
    required this.color,
  });
  final int start;
  final int end;
  final Color color;
}
