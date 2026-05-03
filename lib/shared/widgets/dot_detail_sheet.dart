import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/date_utils.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/comment/domain/comment_model.dart';
import '../../features/comment/presentation/comment_provider.dart';
import '../../features/recording/domain/dot_model.dart';

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
    this.members = const [],
  });

  final Dot dot;
  final String? memberName;
  final Color? memberColor;
  final bool showBackButton;
  final String? roomId;
  final List<DotMemberHint> members;

  static Future<void> show(
    BuildContext context,
    Dot dot, {
    String? memberName,
    Color? memberColor,
    bool showBackButton = false,
    String? roomId,
    List<DotMemberHint> members = const [],
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
        members: members,
      ),
    );
  }

  @override
  ConsumerState<DotDetailSheet> createState() => _DotDetailSheetState();
}

class _DotDetailSheetState extends ConsumerState<DotDetailSheet> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  bool _posting = false;
  String? _mentionQuery; // @ 이후 현재 입력 중인 쿼리

  bool get _hasComments => widget.roomId != null;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onCommentChanged(String text) {
    final cursor = _commentController.selection.baseOffset;
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
    final text = _commentController.text;
    final cursor =
        _commentController.selection.baseOffset.clamp(0, text.length);
    final lastAt = text.lastIndexOf('@', cursor);
    if (lastAt == -1) return;
    final before = text.substring(0, lastAt);
    final after = text.substring(cursor);
    final inserted = '@${member.nickname}';
    final newText = '$before$inserted $after';
    _commentController.text = newText;
    _commentController.selection = TextSelection.collapsed(
      offset: lastAt + inserted.length + 1,
    );
    setState(() => _mentionQuery = null);
  }

  List<MentionSpan> _extractMentions(String text) {
    final result = <MentionSpan>[];
    for (final m in widget.members) {
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

  Future<void> _postComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || text.length > 500 || _posting) return;
    setState(() => _posting = true);
    try {
      final mentions = _extractMentions(text);
      await ref
          .read(commentListProvider(widget.dot.id).notifier)
          .post(text, mentions);
      _commentController.clear();
      setState(() => _mentionQuery = null);
      // 스크롤 맨 아래로
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('댓글 전송에 실패했어요')),
        );
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = widget.dot.photoUrl != null && widget.dot.photoUrl!.isNotEmpty;
    final hasEmotion = widget.dot.emotion != null && widget.dot.emotion!.isNotEmpty;
    final hasMemo = widget.dot.memo != null && widget.dot.memo!.isNotEmpty;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    // 멘션 자동완성 대상 필터
    final mentionCandidates = _mentionQuery == null
        ? <DotMemberHint>[]
        : widget.members
            .where((m) => m.nickname.toLowerCase()
                .startsWith(_mentionQuery!.toLowerCase()))
            .toList();

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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

            // 뒤로가기 버튼
            if (widget.showBackButton)
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(4, 4, Dimensions.md, 0),
                child: Row(
                  children: [
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
                  ],
                ),
              ),

            // 스크롤 가능한 본문 + 댓글 목록
            Flexible(
              child: ListView(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(
                  Dimensions.md,
                  widget.showBackButton ? Dimensions.xs : Dimensions.md,
                  Dimensions.md,
                  _hasComments ? Dimensions.sm : Dimensions.lg,
                ),
                shrinkWrap: true,
                children: [
                  // 멤버 행
                  if (widget.memberName != null) ...[
                    _MemberRow(
                      name: widget.memberName!,
                      color: widget.memberColor ?? DottieColors.primary,
                    ),
                    const SizedBox(height: Dimensions.sm),
                    const Divider(color: DottieColors.border, height: 1),
                    const SizedBox(height: Dimensions.sm),
                  ],

                  // 시간 + 장소
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 14, color: DottieColors.textHint),
                      const SizedBox(width: 5),
                      Text(
                        DottieDateUtils.toTimeString(widget.dot.timestamp),
                        style: GoogleFonts.notoSansKr(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: DottieColors.textSecondary,
                        ),
                      ),
                      if (widget.dot.placeName != null &&
                          widget.dot.placeName!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        const Text('·',
                            style: TextStyle(
                                color: DottieColors.textHint,
                                fontSize: 13)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.dot.placeName!,
                            style: GoogleFonts.notoSansKr(
                              fontSize: 13,
                              color: DottieColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // 감정 배지
                  if (hasEmotion) ...[
                    const SizedBox(height: Dimensions.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: DottieColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.dot.emotion!,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DottieColors.primary,
                        ),
                      ),
                    ),
                  ],

                  // 메모
                  if (hasMemo) ...[
                    const SizedBox(height: Dimensions.sm),
                    Text(
                      widget.dot.memo!,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 15,
                        color: DottieColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ],

                  // 사진
                  if (hasPhoto) ...[
                    const SizedBox(height: Dimensions.md),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedNetworkImage(
                        imageUrl: widget.dot.photoUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          height: 220,
                          color: DottieColors.surfaceVariant,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: DottieColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          height: 220,
                          color: DottieColors.surfaceVariant,
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.broken_image_outlined,
                                  color: DottieColors.textHint, size: 32),
                              SizedBox(height: 8),
                              Text('사진을 불러올 수 없어요',
                                  style: TextStyle(
                                      color: DottieColors.textHint,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  // 댓글 섹션 (room에서만)
                  if (_hasComments) ...[
                    const SizedBox(height: Dimensions.md),
                    const Divider(color: DottieColors.border, height: 1),
                    const SizedBox(height: Dimensions.sm),
                    _CommentSection(
                      dotId: widget.dot.id,
                      members: widget.members,
                    ),
                  ],
                ],
              ),
            ),

            // 댓글 입력 영역 (room에서만)
            if (_hasComments) ...[
              const Divider(color: DottieColors.border, height: 1),

              // @멘션 자동완성 칩
              if (mentionCandidates.isNotEmpty)
                Container(
                  color: DottieColors.surface,
                  padding: const EdgeInsets.fromLTRB(
                      Dimensions.md, 8, Dimensions.md, 4),
                  child: SingleChildScrollView(
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
                                border: Border.all(
                                    color: c.withAlpha(120), width: 1),
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
                ),

              // 입력창
              Padding(
                padding: EdgeInsets.fromLTRB(
                  Dimensions.md,
                  8,
                  Dimensions.md,
                  MediaQuery.of(context).padding.bottom +
                      bottomInset +
                      8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        onChanged: _onCommentChanged,
                        maxLines: 4,
                        minLines: 1,
                        maxLength: 500,
                        buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                            null, // 카운터 UI 숨김
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
                      onTap: _postComment,
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
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── 댓글 목록 섹션 ────────────────────────────────────────

class _CommentSection extends ConsumerWidget {
  const _CommentSection({
    required this.dotId,
    required this.members,
  });
  final String dotId;
  final List<DotMemberHint> members;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commentListProvider(dotId));
    final currentUid = ref.watch(currentUserProvider)?.uid;

    return state.when(
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
            ...comments.map((c) => _CommentItem(
                  comment: c,
                  isOwn: c.authorId == currentUid,
                  members: members,
                  onDelete: () => ref
                      .read(commentListProvider(dotId).notifier)
                      .delete(c.id),
                )),
          ],
        );
      },
    );
  }
}

// ── 댓글 아이템 ───────────────────────────────────────────

class _CommentItem extends StatelessWidget {
  const _CommentItem({
    required this.comment,
    required this.isOwn,
    required this.members,
    required this.onDelete,
  });

  final DotComment comment;
  final bool isOwn;
  final List<DotMemberHint> members;
  final VoidCallback onDelete;

  /// 작성자의 정체성 색.
  /// 1순위 — BE 응답의 `author_color` (룸 떠난 사용자도 정확).
  /// 2순위 — room members 룩업 (혹시 BE 응답이 없을 경우).
  /// 3순위 — primary 폴백.
  Color _authorColor() {
    final beColor = characterColorMap[comment.authorColorKey];
    if (beColor != null) return beColor;
    for (final m in members) {
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
          // 아바타 — 닉네임 첫 글자, 색깔만 사용자 색
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
                  ],
                ),
                const SizedBox(height: 2),
                _buildContent(context),
              ],
            ),
          ),
          // 본인 댓글 삭제 버튼
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
        spans.add(TextSpan(
            text: comment.content.substring(cursor, safeStart)));
      }
      // 멘션 대상자의 정체성 색으로 강조
      final mentionColor =
          characterColorMap[m.colorKey] ?? DottieColors.primary;
      spans.add(TextSpan(
        text: comment.content.substring(safeStart, safeEnd),
        style: TextStyle(
          color: mentionColor,
          fontWeight: FontWeight.w700,
        ),
      ));
      cursor = safeEnd;
    }
    if (cursor < comment.content.length) {
      spans.add(TextSpan(text: comment.content.substring(cursor)));
    }
    return RichText(
      text: TextSpan(style: baseStyle, children: spans),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('댓글 삭제',
            style: GoogleFonts.notoSansKr(fontWeight: FontWeight.w700)),
        content: Text('이 댓글을 삭제할까요?',
            style: GoogleFonts.notoSansKr()),
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

// ── 여러 dot 목록 시트 ────────────────────────────────────

class DotListSheet extends StatelessWidget {
  const DotListSheet({
    super.key,
    required this.dots,
    this.memberName,
    this.memberColor,
    this.roomId,
    this.members = const [],
  });

  final List<Dot> dots;
  final String? memberName;
  final Color? memberColor;
  final String? roomId;
  final List<DotMemberHint> members;

  static Future<void> show(
    BuildContext context,
    List<Dot> dots, {
    String? memberName,
    Color? memberColor,
    String? roomId,
    List<DotMemberHint> members = const [],
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
        members: members,
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
                final hasPhoto =
                    dot.photoUrl != null && dot.photoUrl!.isNotEmpty;
                return InkWell(
                  onTap: () {
                    DotDetailSheet.show(
                      context,
                      dot,
                      memberName: memberName,
                      memberColor: memberColor,
                      showBackButton: true,
                      roomId: roomId,
                      members: members,
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
                              final count = ref
                                      .watch(commentListProvider(dot.id))
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

// ── 멤버 행 ───────────────────────────────────────────────

class _MemberRow extends StatelessWidget {
  const _MemberRow({required this.name, required this.color});
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            shape: BoxShape.circle,
            border:
                Border.all(color: color.withAlpha(100), width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          name,
          style: GoogleFonts.notoSansKr(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: DottieColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
