import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/color_hex.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/memo_with_inline_tags.dart';
import '../../../comment/presentation/comment_count_overrides_provider.dart';
import '../../../recording/domain/dot_model.dart';
import '../../../recording/presentation/dot_photo_overrides_provider.dart';
import '../../../room/domain/room_model.dart';
import '../../domain/feed_entry.dart';
import '../feed_local_photo_store.dart';

/// 피드 단일 카드 — 헤더(아바타+닉네임+시각+방 chip) + 본문(장소/감정/메모/사진) + 푸터(댓글).
///
/// 탭하면 [onTap] 호출 → 홈의 _FeedView 가 DotDetailSheet.show 로 진입.
///
/// 사진은 letterbox 없이 원본 비율로. BE variant 생성 전이면 [FeedLocalPhotoStore]
/// 의 로컬 파일을 임시 표시 → 사용자가 즉시 확인 가능. variant 도착 후 네트워크 이미지로 교체.
class FeedCard extends ConsumerWidget {
  const FeedCard({
    super.key,
    required this.entry,
    required this.roomNameById,
    required this.onTap,
  });

  final FeedEntry entry;

  /// roomId → 방 이름. chip 표시용. 누락된 roomId 는 chip 에서 생략.
  final Map<String, Room> roomNameById;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rawDot = entry.dot;

    // BE variant 생성 전 로컬 파일 경로. dot 저장 직후에만 존재.
    final localPath = ref.watch(
      feedLocalPhotoStoreProvider.select((m) => m[rawDot.id]),
    );

    // BE variant worker 가 늦게 발급한 thumb/preview URL 을 polling 결과로
    // override store 에서 적용. feed 가 새로 fetch 안 돼도 사진 표시.
    final photoOverride = ref.watch(
      dotPhotoOverridesProvider.select((m) => m[rawDot.id]),
    );
    final dot = photoOverride == null
        ? rawDot
        : rawDot.copyWith(
            photoThumbUrl: photoOverride.thumbUrl ?? rawDot.photoThumbUrl,
            photoPreviewUrl:
                photoOverride.previewUrl ?? rawDot.photoPreviewUrl,
          );

    // variant 가 도착하면 로컬 경로 제거 (post-frame 으로 렌더 중 state 변경 회피).
    if (localPath != null && !dot.isPhotoProcessing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(feedLocalPhotoStoreProvider.notifier).remove(dot.id);
      });
    }

    final color = colorFromHex(entry.authorColorHex);
    final hasEmotion = dot.emotion != null && dot.emotion!.isNotEmpty;
    final hasMemo = dot.memo != null && dot.memo!.isNotEmpty;
    // 로컬 경로가 있으면 variant 미도착이어도 사진 영역 표시.
    final hasPhoto = dot.hasPhotoData || localPath != null;

    return Material(
      color: DottieColors.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimensions.md, Dimensions.md, Dimensions.md, Dimensions.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(entry: entry, color: color, roomNameById: roomNameById),
              if (dot.placeName != null && dot.placeName!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  dot.placeName!,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 12.5,
                    color: DottieColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (dot.place != null) ...[
                const SizedBox(height: Dimensions.sm),
                _PlaceCard(dot: dot),
              ],
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
                _MemoWithFade(memo: dot.memo!),
              ],
              if (hasPhoto) ...[
                const SizedBox(height: Dimensions.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _PhotoArea(dot: dot, localPath: localPath),
                ),
              ],
              const SizedBox(height: Dimensions.sm),
              _CommentCount(dotId: dot.id, fallback: dot.commentCount),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.entry,
    required this.color,
    required this.roomNameById,
  });

  final FeedEntry entry;
  final Color color;
  final Map<String, Room> roomNameById;

  @override
  Widget build(BuildContext context) {
    // sharedRoomIds 중 roomNameById 에 있는 것만 chip 으로. 다른 룸 dot 인데 내가
    // 그 룸을 떠난 경우 등의 edge case 는 chip 누락 (제목 자체는 sortable).
    final chipRoomIds = entry.sharedRoomIds
        .where((id) => roomNameById.containsKey(id))
        .toList();

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            shape: BoxShape.circle,
            border: Border.all(color: color.withAlpha(110), width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            entry.authorNickname.isNotEmpty
                ? entry.authorNickname[0].toUpperCase()
                : '?',
            style: GoogleFonts.notoSansKr(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      entry.isMine ? '나' : entry.authorNickname,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: DottieColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DottieDateUtils.toTimeString(entry.dot.timestamp),
                    style: GoogleFonts.notoSansKr(
                      fontSize: 12,
                      color: DottieColors.textHint,
                    ),
                  ),
                ],
              ),
              if (chipRoomIds.isNotEmpty) ...[
                const SizedBox(height: 3),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final id in chipRoomIds)
                      _RoomChip(
                        name: roomNameById[id]!.name,
                        color: DottieColors.accentFor(id),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RoomChip extends StatelessWidget {
  const _RoomChip({required this.name, required this.color});
  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          name,
          style: GoogleFonts.notoSansKr(
            fontSize: 11,
            color: DottieColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.dot});
  final Dot dot;

  @override
  Widget build(BuildContext context) {
    final place = dot.place!;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.sm, vertical: Dimensions.sm),
      decoration: BoxDecoration(
        color: DottieColors.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: DottieColors.primary.withAlpha(80), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: DottieColors.primary.withAlpha(40),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.place_rounded,
                color: DottieColors.primary, size: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: DottieColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (place.category != null ||
                    place.roadAddress != null ||
                    place.address != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (place.category != null) place.category!,
                      if (place.roadAddress != null)
                        place.roadAddress!
                      else if (place.address != null)
                        place.address!,
                    ].join(' · '),
                    style: GoogleFonts.notoSansKr(
                      fontSize: 11,
                      color: DottieColors.textHint,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// BE variant 도착 전엔 로컬 파일, 이후엔 네트워크 이미지 표시.
class _PhotoArea extends StatelessWidget {
  const _PhotoArea({required this.dot, this.localPath});

  final Dot dot;
  final String? localPath;

  @override
  Widget build(BuildContext context) {
    // variant 미도착 + 로컬 경로 존재 → 로컬 파일 즉시 표시
    if (localPath != null && dot.isPhotoProcessing) {
      return Image.file(
        File(localPath!),
        width: double.infinity,
        fit: BoxFit.fitWidth,
        errorBuilder: (_, __, ___) => _Photo(
          url: dot.displayPhotoUrl,
          isProcessing: dot.isPhotoProcessing,
        ),
      );
    }
    return _Photo(url: dot.displayPhotoUrl, isProcessing: dot.isPhotoProcessing);
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.url, required this.isProcessing});
  final String? url;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return AspectRatio(
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
              if (isProcessing) ...[
                const SizedBox(height: 10),
                Text(
                  '사진을 처리하고 있어요',
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
    }
    return CachedNetworkImage(
      imageUrl: url!,
      imageBuilder: (_, provider) => Image(
        image: provider,
        width: double.infinity,
        fit: BoxFit.fitWidth,
      ),
      placeholder: (_, __) => AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          color: DottieColors.surfaceVariant,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(
              color: DottieColors.primary, strokeWidth: 2),
        ),
      ),
      errorWidget: (_, __, ___) => AspectRatio(
        aspectRatio: 4 / 3,
        child: Container(
          color: DottieColors.surfaceVariant,
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined,
              color: DottieColors.textHint, size: 28),
        ),
      ),
    );
  }
}

/// 피드 카드 메모 — 메모 본문 안 `#태그` 클릭 가능 (시트와 동일 패턴) +
/// 6줄 넘으면 fade 처리.
///
/// 6줄 여부는 layout 단에서 정확히 판정 어렵지만, 메모 길이로 휴리스틱
/// (한국어 평균 22~28자/줄, 6줄 ≈ 132자). 이상이면 fade 표시.
///
/// `MemoWithInlineTags` 가 `Text.rich` 렌더 — ShaderMask 는 paint 만 영향,
/// hit-test 는 자식의 recognizer 가 그대로 받아 #태그 탭 정상 작동.
/// 메모를 Text 가 자체 잘라낸 영역 (maxLines=6 너머) 의 #태그 는 화면에 없어
/// 클릭 가능성 자체 없음 (의도).
///
/// `onBeforeNavigate: null` — 카드는 닫지 않고 검색 화면 push.
class _MemoWithFade extends StatelessWidget {
  const _MemoWithFade({required this.memo});
  final String memo;

  static const _heuristicTruncateLen = 132;

  @override
  Widget build(BuildContext context) {
    final isTruncated = memo.length > _heuristicTruncateLen;
    final memoWidget = MemoWithInlineTags(
      memo: memo,
      style: GoogleFonts.notoSansKr(
        fontSize: 14.5,
        color: DottieColors.textPrimary,
        height: 1.55,
      ),
      maxLines: 6,
      overflow: TextOverflow.ellipsis,
    );
    if (!isTruncated) return memoWidget;
    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        // 위 80% 는 그대로, 아래 20% 만 fade — 자연스러운 끝남 신호.
        stops: [0.0, 0.8, 1.0],
        colors: [Colors.black, Colors.black, Colors.transparent],
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: memoWidget,
    );
  }
}

/// 댓글 카운트 표시 — [commentCountOverridesProvider] 우선, 없으면 BE 응답값.
///
/// BE `/v1/feed` 의 `comment_count` 가 stale 인 경우의 안전망. 사용자가 시트
/// 한 번 열면 `CommentListNotifier._load` 가 override 를 set → 카드 갱신.
/// 시트 안 열어도 BE 응답이 정상이면 fallback 으로 그대로 표시.
class _CommentCount extends ConsumerWidget {
  const _CommentCount({required this.dotId, required this.fallback});
  final String dotId;
  final int fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // dot.id 만 select — 다른 dot 의 override 변화에는 rebuild X.
    final override = ref.watch(
      commentCountOverridesProvider.select((m) => m[dotId]),
    );
    final count = override ?? fallback;
    return Row(
      children: [
        const Icon(Icons.mode_comment_outlined,
            size: 15, color: DottieColors.textHint),
        const SizedBox(width: 5),
        Text(
          '$count',
          style: GoogleFonts.notoSansKr(
            fontSize: 12.5,
            color: DottieColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
