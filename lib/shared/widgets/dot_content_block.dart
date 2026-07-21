import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/dimensions.dart';
import '../../core/utils/date_utils.dart';
import '../../features/comment/presentation/dot_comment_block.dart';
import '../../features/recording/domain/dot_model.dart';
import 'dot_detail_sheet.dart' show DotMemberHint;
import 'memo_with_inline_tags.dart';

/// dot 의 본문(시간/장소/감정/메모/사진) + 댓글 블록을 한 위젯으로 묶음.
/// `DotDetailSheet` 와 `_MeetingDetailSheet`(인카운터 chip 탭 시) 양쪽에서 재사용.
///
/// 부모가 ListView/SingleChildScrollView 안에 두어 자체 스크롤 책임은 없다.
/// 댓글 블록(`DotCommentBlock`)은 [roomId] 가 있을 때만 표시.
class DotContentBlock extends StatelessWidget {
  const DotContentBlock({
    super.key,
    required this.dot,
    this.memberName,
    this.memberColor,
    this.roomId,
    this.membersByRoomId = const {},
    this.showMemberHeader = true,
    this.availableRoomIds,
    this.roomNameById,
  });

  final Dot dot;
  final String? memberName;
  final Color? memberColor;

  /// null 이면 댓글 블록 비표시 (room 외부 컨텍스트).
  /// [availableRoomIds] 가 제공되면 해당 값이 우선 사용됨.
  final String? roomId;

  /// roomId → 멘션 후보 멤버 목록.
  final Map<String, List<DotMemberHint>> membersByRoomId;

  /// false 이면 멤버 헤더 생략 (예: 인카운터 시트 — chip 이 이미 멤버 정체성 노출).
  final bool showMemberHeader;

  /// 피드 다중 룸 지원 — 제공 시 [roomId] 대신 사용.
  final Set<String>? availableRoomIds;

  /// roomId → 표시 이름. [availableRoomIds] 와 함께 사용.
  final Map<String, String>? roomNameById;

  Set<String> get _effectiveRoomIds {
    if (availableRoomIds != null && availableRoomIds!.isNotEmpty) {
      return availableRoomIds!;
    }
    if (roomId != null) return {roomId!};
    return const {};
  }

  bool get _hasComments => _effectiveRoomIds.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = dot.hasPhotoData;
    final hasEmotion = dot.emotion != null && dot.emotion!.isNotEmpty;
    final hasMemo = dot.memo != null && dot.memo!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showMemberHeader && memberName != null) ...[
          _MemberHeader(
              name: memberName!,
              color: memberColor ?? DottieColors.primary),
          const SizedBox(height: Dimensions.sm),
          const Divider(color: DottieColors.border, height: 1),
          const SizedBox(height: Dimensions.sm),
        ],

        // 시간 + (역지오코딩) 주소 — 항상 표시
        Row(
          children: [
            const Icon(Icons.access_time_rounded,
                size: 14, color: DottieColors.textHint),
            const SizedBox(width: 5),
            Text(
              DottieDateUtils.toTimeString(dot.timestamp),
              style: GoogleFonts.notoSansKr(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: DottieColors.textSecondary,
              ),
            ),
            if (dot.placeName != null && dot.placeName!.isNotEmpty) ...[
              const SizedBox(width: 6),
              const Text('·',
                  style: TextStyle(
                      color: DottieColors.textHint, fontSize: 13)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  dot.placeName!,
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

        // 사용자가 검색해 선택한 장소 카드 (place inline) — 시간/주소 아래 강조 표시
        if (dot.place != null) ...[
          const SizedBox(height: Dimensions.sm),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.sm, vertical: Dimensions.sm),
            decoration: BoxDecoration(
              color: DottieColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: DottieColors.primary.withAlpha(80), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: DottieColors.primary.withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.place_rounded,
                          color: DottieColors.primary, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dot.place!.name,
                            style: GoogleFonts.notoSansKr(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: DottieColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (dot.place!.categoryGroupName != null ||
                              dot.place!.category != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              dot.place!.categoryGroupName ??
                                  dot.place!.category!,
                              style: GoogleFonts.notoSansKr(
                                fontSize: 11,
                                color: DottieColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // 카카오맵 상세 페이지 (place 조인 시).
                    if (dot.place!.placeUrl != null)
                      GestureDetector(
                        onTap: () => launchUrl(
                          Uri.parse(dot.place!.placeUrl!),
                          mode: LaunchMode.externalApplication,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: DottieColors.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.open_in_new_rounded,
                                  size: 12, color: DottieColors.primary),
                              const SizedBox(width: 3),
                              Text(
                                '카카오맵',
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: DottieColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                // 주소 — road_address 우선, 없으면 address. (전화는 표시 안 함)
                if (dot.place!.roadAddress != null ||
                    dot.place!.address != null) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 2, top: 1),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 13, color: DottieColors.textHint),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            dot.place!.roadAddress ?? dot.place!.address!,
                            style: GoogleFonts.notoSansKr(
                              fontSize: 12,
                              color: DottieColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],

        if (hasEmotion) ...[
          const SizedBox(height: Dimensions.sm),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: DottieColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              dot.emotion!,
              style: GoogleFonts.notoSansKr(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: DottieColors.primary,
              ),
            ),
          ),
        ],

        if (hasMemo) ...[
          const SizedBox(height: Dimensions.sm),
          // 메모 본문의 `#태그` 자체를 chip 으로 — 별도 chip row 없이 인라인 강조.
          // 본인 dot 의 chip 중복도 회피되고, BE 가 tags 응답을 안 보낸 dot
          // (예: 룸 멤버 dot — BE 변경 대기 중) 도 클릭 가능. SNS 표준 패턴.
          //
          // 시트 안 — 태그 탭 시 시트를 먼저 닫고 검색 화면으로 push.
          Builder(
            builder: (innerCtx) => MemoWithInlineTags(
              memo: dot.memo!,
              onBeforeNavigate: () => Navigator.of(innerCtx).pop(),
            ),
          ),
        ],

        if (hasPhoto) ...[
          const SizedBox(height: Dimensions.md),
          // 시트 가로 가득 + 사진 비율 그대로 (letterbox 없음).
          // 본문 한 부분처럼 자연스럽게 흐르고, 카드/배경 띠가 안 생긴다.
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _DotPhotoLarge(
              previewUrl: dot.photoPreviewUrl,
              thumbUrl: dot.photoThumbUrl,
              isProcessing: dot.isPhotoProcessing,
            ),
          ),
        ],

        if (_hasComments) ...[
          const SizedBox(height: Dimensions.md),
          const Divider(color: DottieColors.border, height: 1),
          const SizedBox(height: Dimensions.sm),
          DotCommentBlock(
            dotId: dot.id,
            availableRoomIds: _effectiveRoomIds,
            roomNameById: roomNameById ?? const {},
            membersByRoomId: membersByRoomId,
          ),
        ],
      ],
    );
  }
}

class _MemberHeader extends StatelessWidget {
  const _MemberHeader({required this.name, required this.color});
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
            border: Border.all(color: color.withAlpha(100), width: 1.5),
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

/// 본문 사진 — 가로 가득 + 사진 비율 그대로 (letterbox 없음).
/// preview 우선, 실패 시 원본 폴백.
/// `imageBuilder` 로 로드된 이미지를 BoxFit.fitWidth 로 그려 세로 길이가
/// 사진 비율 따라 자동 조정됨. placeholder / errorWidget 은 4:3 임시 비율.
///
/// 폴백 체인: previewUrl → thumbUrl. BE 가 비동기로 채워주므로 dot 응답 시점에
/// 둘 다 null 일 수 있음 ([isProcessing]=true). 그 경우 "사진 처리 중" 안내.
class _DotPhotoLarge extends StatefulWidget {
  const _DotPhotoLarge({
    required this.previewUrl,
    required this.thumbUrl,
    required this.isProcessing,
  });

  final String? previewUrl;
  final String? thumbUrl;

  /// variant 생성 진행 중 (display URL 둘 다 null) — placeholder 대신 안내 노출.
  final bool isProcessing;

  @override
  State<_DotPhotoLarge> createState() => _DotPhotoLargeState();
}

class _DotPhotoLargeState extends State<_DotPhotoLarge> {
  late List<String> _candidates;
  int _idx = 0;

  /// processing 안내 단계 — timer 로 5초마다 0→1→2→3 증가. 마지막은 고정.
  /// widget.isProcessing 이 false 가 되거나 dispose 되면 timer cancel.
  Timer? _msgTimer;
  int _msgStep = 0;
  static const _msgSteps = [
    '사진을 처리하고 있어요',
    '조금만 더 기다려 주세요',
    '거의 다 됐어요',
    '처리에 시간이 걸리고 있어요',
  ];

  @override
  void initState() {
    super.initState();
    _candidates = _buildCandidates();
    if (widget.isProcessing && _candidates.isEmpty) {
      _startMessageRotation();
    }
    debugPrint(
        '[DotPhoto] candidates=$_candidates (preview=${widget.previewUrl}, '
        'thumb=${widget.thumbUrl}, processing=${widget.isProcessing})');
  }

  @override
  void didUpdateWidget(covariant _DotPhotoLarge oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 부모가 새 dot 으로 갱신해 isProcessing 이 false 가 되면 메시지 rotation 종료.
    // 반대로 candidates 가 비어 있고 여전히 processing 이면 계속 진행.
    if (widget.previewUrl != oldWidget.previewUrl ||
        widget.thumbUrl != oldWidget.thumbUrl ||
        widget.isProcessing != oldWidget.isProcessing) {
      final newCandidates = _buildCandidates();
      setState(() {
        _candidates = newCandidates;
        _idx = 0;
      });
      if (newCandidates.isNotEmpty || !widget.isProcessing) {
        _stopMessageRotation();
      } else if (_msgTimer == null) {
        _startMessageRotation();
      }
    }
  }

  @override
  void dispose() {
    _stopMessageRotation();
    super.dispose();
  }

  void _startMessageRotation() {
    _msgTimer?.cancel();
    _msgTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      // 마지막 단계에 도달하면 더 이상 변화 없음 — timer 만 살아있어도 무해하지만
      // 명시적으로 cancel 해 자원 회수.
      if (_msgStep >= _msgSteps.length - 1) {
        _msgTimer?.cancel();
        _msgTimer = null;
        return;
      }
      setState(() => _msgStep += 1);
    });
  }

  void _stopMessageRotation() {
    _msgTimer?.cancel();
    _msgTimer = null;
    if (_msgStep != 0) _msgStep = 0;
  }

  List<String> _buildCandidates() {
    final list = <String>[];
    void add(String? u) {
      if (u != null && u.isNotEmpty && !list.contains(u)) list.add(u);
    }
    add(widget.previewUrl);
    add(widget.thumbUrl);
    return list;
  }

  String get _currentUrl => _candidates[_idx];

  bool get _hasNext => _idx + 1 < _candidates.length;

  void _advance() {
    if (!_hasNext) return;
    setState(() => _idx += 1);
  }

  // placeholder / error 시점엔 사진 자체 비율을 모르므로 임시로 4:3 박스.
  Widget _placeholderBox({String? message}) => AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          color: DottieColors.surfaceVariant,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: DottieColors.primary,
                strokeWidth: 2,
              ),
              if (message != null) ...[
                const SizedBox(height: 12),
                Text(
                  message,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 12,
                    color: DottieColors.textHint,
                  ),
                ),
              ],
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (_candidates.isEmpty) {
      // variant 미생성 transient — 5초마다 메시지 rotation 으로 진행 표시.
      // 부모(_DotDetailSheetState) 가 자체 polling 으로 갱신하므로 곧 photoLayer 로 전환.
      return _placeholderBox(
        message: widget.isProcessing ? _msgSteps[_msgStep] : null,
      );
    }
    return CachedNetworkImage(
      imageUrl: _currentUrl,
      // 로드되면 imageBuilder 로 받아 가로 가득 + 비율 그대로 그림.
      imageBuilder: (context, imageProvider) => Image(
        image: imageProvider,
        width: double.infinity,
        fit: BoxFit.fitWidth,
      ),
      placeholder: (_, __) => _placeholderBox(),
      errorWidget: (_, url, error) {
        debugPrint('[DotPhoto] load failed url=$url err=$error');
        if (_hasNext) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _advance();
          });
          return _placeholderBox();
        }
        return AspectRatio(
          aspectRatio: 4 / 3,
          child: Container(
            color: DottieColors.surfaceVariant,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image_outlined,
                    color: DottieColors.textHint, size: 32),
                SizedBox(height: 8),
                Text('사진을 불러올 수 없어요',
                    style: TextStyle(
                        color: DottieColors.textHint, fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }
}
