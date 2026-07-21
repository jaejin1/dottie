import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/color_hex.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/dot_detail_sheet.dart';
import '../../../recording/domain/dot_model.dart';
import '../../../room/presentation/room_provider.dart';
import '../../domain/place_group.dart';
import '../../domain/room_dot.dart';
import '../cumulative_map_provider.dart';
import '../place_insights_provider.dart';
import '../room_places_provider.dart';
import '../starred_places_provider.dart';

/// 누적 지도 핀 탭 → 장소 카드.
/// 헤더(장소 이름 + 방문 수 + 첫 방문) + mock 인사이트 + 시간 역순 dot list.
/// dot row 탭 → DotDetailSheet (기존).
class PlaceCardSheet extends ConsumerWidget {
  const PlaceCardSheet({
    super.key,
    required this.group,
    required this.roomId,
  });

  final PlaceGroup group;
  final String roomId;

  static Future<void> show(
    BuildContext context, {
    required PlaceGroup group,
    required String roomId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => PlaceCardSheet(group: group, roomId: roomId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final room = ref.watch(roomDetailProvider(roomId)).valueOrNull;
    final membersByRoomId = <String, List<DotMemberHint>>{
      roomId: (room?.members ?? [])
          .map((m) => DotMemberHint(
                userId: m.userId,
                nickname: m.nickname,
                color: colorFromHex(m.character.colorHex),
              ))
          .toList(),
    };

    // B15 — group.id 가 'place-{realId}' 형태면 BE place_id, 'coord-...' 면 클라이언트 fallback
    final realPlaceId = group.id.startsWith('place-')
        ? group.id.substring('place-'.length)
        : null;

    // BE 통계 우선 (visit_count/first_visited/comment_count_total/preview/thumbnail).
    // group.dots 가 비어있어도 (B15 후 BE가 dots 안 줌) BE 응답 활용 가능.
    final placesData = ref.watch(roomPlacesProvider(roomId)).valueOrNull;
    final stats = realPlaceId != null
        ? placesData?.findById(realPlaceId)
        : null;

    // dot list — BE 가 dots 안 주므로 cumulativeRoomDots 에서 placeId 필터링.
    // TODO(B15-stage5): BE `/places/:id/dots?room_id=` endpoint 활용으로 교체
    //   (큰 룸에서 효율적 — preview 만 lazy load)
    final allDots =
        ref.watch(cumulativeRoomDotsProvider(roomId)).valueOrNull ?? const [];
    final List<RoomDot> dotsForPlace;
    if (realPlaceId != null) {
      dotsForPlace = allDots
          .where((rd) => rd.dot.placeId == realPlaceId)
          .toList()
        ..sort((a, b) => b.dot.timestamp.compareTo(a.dot.timestamp));
    } else {
      // orphan group — group.dots 그대로 사용 (PlaceGrouper 가 좌표 기반 묶음)
      dotsForPlace = group.dots;
    }

    // 표시용 통계 — BE 응답 우선, 없으면 group/local 합성
    final visitCount = stats?.visitCount ?? group.visitCount;
    final firstVisitedAt =
        stats?.firstVisitedAt ?? group.firstVisitedAt;
    final daysSinceFirst =
        DateTime.now().difference(firstVisitedAt).inDays;
    final placeLabel = (stats?.name ?? group.placeName).isNotEmpty
        ? (stats?.name ?? group.placeName)
        : (dotsForPlace.firstOrNull?.dot.placeName?.isNotEmpty == true
            ? dotsForPlace.first.dot.placeName!
            : '이름 없는 장소');
    // BE PlaceWithStats.isFirstTogether 우선, 없으면 group fallback.
    final isFirstTogether = stats?.isFirstTogether ?? group.isFirstTogether;
    final bool isStarred = stats?.isStarred ??
        (realPlaceId != null
            ? ref.watch(isPlaceStarredProvider(roomId, realPlaceId))
            : false);
    final insightsAsync = realPlaceId != null
        ? ref.watch(placeInsightsProvider(roomId, realPlaceId))
        : const AsyncValue.data(null);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      child: ClipRRect(
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: Dimensions.sm),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(60),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: Dimensions.md),
                  // 헤더 — 별표 토글 버튼 추가
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isFirstTogether)
                              const Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Text('⭐',
                                    style: TextStyle(fontSize: 18)),
                              )
                            else if (visitCount >= 5)
                              const Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Text('🔥',
                                    style: TextStyle(fontSize: 18)),
                              ),
                            Expanded(
                              child: Text(
                                placeLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // B9 — 별표 토글 (BE place_id 가 있을 때만)
                            if (realPlaceId != null)
                              IconButton(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(starredPlacesProvider(roomId)
                                          .notifier)
                                      .toggle(
                                        placeId: realPlaceId,
                                        currentlyStarred: isStarred,
                                      );
                                },
                                icon: Icon(
                                  isStarred
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_outline_rounded,
                                  color: isStarred
                                      ? DottieColors.primary
                                      : Colors.white.withAlpha(180),
                                  size: 22,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$visitCount번 방문 · 첫 방문 ${DottieDateUtils.toKoreanDate(firstVisitedAt)}',
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 인사이트 chip — BE PlaceWithStats 통계 우선
                  Padding(
                    padding: const EdgeInsets.fromLTRB(Dimensions.lg,
                        Dimensions.md, Dimensions.lg, 0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _InsightChip(text: '$daysSinceFirst일 전 첫 방문'),
                        if (isFirstTogether)
                          const _InsightChip(text: '⭐ 첫 함께 간 곳'),
                        if (((stats?.memberIds.length ?? 0) >= 2) ||
                            group.memberIds.length >= 2)
                          const _InsightChip(text: '함께 다녀온 곳'),
                        if (visitCount >= 5)
                          const _InsightChip(text: '🔥 단골 장소'),
                        if ((stats?.commentCountTotal ?? 0) > 0)
                          _InsightChip(
                            text: '💬 댓글 ${stats!.commentCountTotal}개',
                          ),
                        if ((stats?.starredByCount ?? 0) >= 2)
                          const _InsightChip(text: '둘 다 별표'),
                        // BE B10 visitors — 멤버별 방문 수 (insights endpoint)
                        ...?insightsAsync.valueOrNull?.visitors.map(
                          (v) => _InsightChip(
                            text: '${v.nickname} ${v.visitCount}번',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.md),
                  Divider(color: Colors.white.withAlpha(40), height: 1),
                  // dot 리스트 — cumulativeRoomDots 에서 placeId 필터링한 결과
                  Flexible(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.lg, vertical: 8),
                      itemCount: dotsForPlace.length,
                      itemBuilder: (context, idx) {
                        final rd = dotsForPlace[idx];
                        return _DotRow(
                          roomDot: rd,
                          onTap: () async {
                            final color = colorFromHex(rd.colorHex);
                            await DotDetailSheet.show(
                              context,
                              rd.dot,
                              memberName: rd.nickname,
                              memberColor: color,
                              roomId: roomId,
                              membersByRoomId: membersByRoomId,
                              ownerUserId: rd.memberId,
                            );
                          },
                        );
                      },
                    ),
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

class _InsightChip extends StatelessWidget {
  const _InsightChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DottieColors.borderGlass, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withAlpha(220),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DotRow extends StatelessWidget {
  const _DotRow({required this.roomDot, required this.onTap});

  final RoomDot roomDot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dot = roomDot.dot;
    final color =
        colorFromHex(roomDot.colorHex, fallback: DottieColors.primary);
    final thumbUrl = dot.displayThumbUrl;
    final hasPhoto = thumbUrl != null;
    final hasMemo = dot.memo != null && dot.memo!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(20), width: 1),
        ),
        child: Row(
          children: [
            // 멤버 색 dot
            Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${DottieDateUtils.toKoreanMonthDay(dot.timestamp)} · ${roomDot.nickname}',
                        style: TextStyle(
                          color: Colors.white.withAlpha(220),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (hasMemo) ...[
                    const SizedBox(height: 2),
                    Text(
                      dot.memo!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withAlpha(180),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (hasPhoto)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _PhotoThumb(url: thumbUrl, size: 44),
              )
            else
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white54, size: 20),
            if (dot.commentCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded,
                        size: 10, color: Colors.white.withAlpha(200)),
                    const SizedBox(width: 3),
                    Text(
                      '${dot.commentCount}',
                      style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 10,
                          fontWeight: FontWeight.w700),
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

/// thumb 우선, 실패 시 원본으로 재시도하는 정사각형 사진 위젯.
/// `primaryUrl` (예: photo_thumb_url) 이 null/빈문자면 바로 fallback 시도.
/// 단순 thumb 표시 위젯 — 단일 URL fetch (BE variant 가 항상 thumb URL 권위).
class _PhotoThumb extends StatelessWidget {
  const _PhotoThumb({required this.url, required this.size});
  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        width: size,
        height: size,
        color: Colors.white.withAlpha(30),
      ),
      errorWidget: (_, __, ___) => Container(
        width: size,
        height: size,
        color: Colors.white.withAlpha(30),
        child: const Icon(Icons.image_not_supported,
            color: Colors.white54, size: 18),
      ),
    );
  }
}
