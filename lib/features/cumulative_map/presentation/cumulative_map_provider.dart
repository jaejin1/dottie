import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../character/paperdoll/data/paperdoll_legacy_adapter.dart';
import '../../recording/domain/dot_model.dart';
import '../../room/data/room_repository.dart';
import '../../room/presentation/room_provider.dart';
import '../data/place_grouper.dart';
import '../domain/place.dart';
import '../domain/place_group.dart';
import '../domain/room_dot.dart';
import 'room_places_provider.dart';

part 'cumulative_map_provider.g.dart';

/// B7 — 룸 누적 dot 단일 endpoint 호출 (`/v1/rooms/:id/cumulative-dots`).
/// cursor pagination 자동 루프.
///
/// 응답 가정:
///   { data: { members: [...], dots: [...], next_cursor: ... } }
///   - dots[].user_id 로 members 참조 (평면 구조)
///   - dots[] 에 B3(comment_count/last_commented_at), B8(place_id/place) 포함
///
/// 응답 형태가 다르면 _dotFromCumulative 만 수정.
@riverpod
Future<List<RoomDot>> cumulativeRoomDots(Ref ref, String roomId) async {
  final repo = ref.watch(roomRepositoryProvider);

  String? cursor;
  final allDots = <Map<String, dynamic>>[];
  Map<String, Map<String, dynamic>>? membersById;

  // cursor 가 null 일 때까지 페이징 (안전장치 50 페이지)
  for (var page = 0; page < 50; page++) {
    final data = await repo.getCumulativeDots(roomId, cursor: cursor);
    if (data == null) break;
    final dots = (data['dots'] as List?) ?? const [];
    allDots.addAll(dots.cast<Map<String, dynamic>>());

    // 멤버 메타 — 첫 응답에서만 추출
    if (membersById == null) {
      final members = (data['members'] as List?) ?? const [];
      membersById = {
        for (final m in members.cast<Map<String, dynamic>>())
          m['user_id'] as String: m,
      };
    }

    cursor = data['next_cursor'] as String?;
    if (cursor == null) break;
  }

  // 응답에 members 누락이면 room.members 폴백
  if (membersById == null || membersById.isEmpty) {
    final room = await ref.watch(roomDetailProvider(roomId).future);
    membersById = {
      for (final m in (room?.members ?? const []))
        m.userId: <String, dynamic>{
          'user_id': m.userId,
          'nickname': m.nickname,
          'character_config': {'color_hex': m.character.colorHex},
        },
    };
  }

  // dot → RoomDot
  final out = <RoomDot>[];
  for (final d in allDots) {
    final userId = d['user_id'] as String? ?? '';
    final memberRaw = membersById[userId];
    final config = memberRaw?['character_config'] as Map<String, dynamic>?;
    out.add(RoomDot(
      dot: _dotFromCumulative(d, fallbackDayLogId: roomId),
      memberId: userId,
      nickname: memberRaw?['nickname'] as String? ?? '',
      colorHex: config?['color_hex'] as String? ?? '#7EB8F7',
      paperdoll: paperdollFromMixedJson(config),
    ));
  }

  // dot.id 중복 제거 (안전망)
  final seen = <String>{};
  final result = out.where((rd) => seen.add(rd.dot.id)).toList();

  // 디버그 — user 별 dot 카운트 (룸 멤버 외 dot 진단용)
  if (kDebugMode) {
    final byUser = <String, int>{};
    for (final rd in result) {
      byUser.update(rd.memberId, (v) => v + 1, ifAbsent: () => 1);
    }
    final memberIds = membersById.keys.toSet();
    final outsiders = byUser.keys.where((u) => !memberIds.contains(u));
    debugPrint(
        '[cumulative] room=$roomId dots=${result.length} byUser=$byUser '
        'memberIds=${memberIds.toList()} '
        'outsiders=${outsiders.toList()}');
  }

  return result;
}

/// 누적 지도 표시용 PlaceGroup list.
///
/// 흐름:
///   1. roomPlacesProvider 로 BE places fetch
///   2. BE places 가 있으면 → PlaceWithStats → PlaceGroup 매핑
///      + cumulativeRoomDots 에서 placeId 없는 orphan 만 좌표 클러스터링
///   3. BE places 가 비어있으면 (BE 미구현 / 빈 응답) → cumulativeRoomDots 전체로
///      클라이언트 측 그룹화 (PlaceGrouper) 폴백
///
/// 모든 멤버 동행 isFirstTogether 는 클라이언트 계산.
@riverpod
Future<List<PlaceGroup>> placeGroups(Ref ref, String roomId) async {
  final placesData =
      await ref.watch(roomPlacesProvider(roomId).future);
  final allDots =
      await ref.watch(cumulativeRoomDotsProvider(roomId).future);

  // ★ Fallback — BE places 가 비어있으면 클라이언트 측 그룹화로 폴백.
  //   원인: BE 미배포 / 응답 버그 / 진짜 데이터 없음.
  //   이 경로로도 placeId 있는 dot 은 placeId 별 그룹, 없는 건 좌표 union-find.
  if (placesData.places.isEmpty) {
    if (kDebugMode) {
      debugPrint(
          '[placeGroups] BE places empty (allDots=${allDots.length}) — fallback to client grouping');
    }
    return PlaceGrouper.group(allDots);
  }

  final groups = <PlaceGroup>[];

  // 1. BE PlaceWithStats → PlaceGroup
  // BE 가 is_first_together / first_visited_at 직접 제공 — 그대로 사용.
  for (final p in placesData.places) {
    groups.add(PlaceGroup(
      id: 'place-${p.id}',
      // BE 가 dot list 미반환 — PlaceCardSheet 에서 cumulativeRoomDots 필터로 합성.
      // TODO(B15-stage5): /v1/places/:id/dots?room_id= lazy fetch 검토
      dots: const [],
      centerLat: p.latitude,
      centerLng: p.longitude,
      memberIds: p.memberIds.toSet(),
      placeName: p.name,
      category: p.category,
      firstVisitedAt:
          p.firstVisitedAt ?? p.lastVisitedAt ?? DateTime.now(),
      visitCount: p.visitCount, // BE 집계 그대로 (dots 비어있어도 정확)
      isFirstTogether: p.isFirstTogether,
    ));
  }

  // 2. orphan dots — placeId 없는 dot 만 추려 좌표 클러스터링
  final orphanDots = allDots.where((rd) {
    final pid = rd.dot.placeId;
    return pid == null || pid.isEmpty;
  }).toList();
  if (orphanDots.isNotEmpty) {
    groups.addAll(PlaceGrouper.group(orphanDots));
  }

  if (kDebugMode) {
    debugPrint(
        '[placeGroups] BE places=${placesData.places.length} orphans=${orphanDots.length} → groups=${groups.length}');
  }

  return groups;
}

Dot _dotFromCumulative(
  Map<String, dynamic> d, {
  required String fallbackDayLogId,
}) {
  final lastCommentedRaw = d['last_commented_at'] as String?;
  final placeRaw = d['place'] as Map<String, dynamic>?;
  final rawTags = d['tags'];
  final tags = (rawTags is List)
      ? rawTags.whereType<String>().toList(growable: false)
      : const <String>[];
  return Dot(
    id: d['id'] as String,
    latitude: (d['latitude'] as num).toDouble(),
    longitude: (d['longitude'] as num).toDouble(),
    timestamp: DateTime.parse(d['timestamp'] as String),
    placeName: d['place_name'] as String?,
    placeCategory: d['place_category'] as String?,
    // photo_url 은 BE 응답에서 제거됨 — variant URL 만 받음.
    photoThumbUrl: d['photo_thumb_url'] as String?,
    photoPreviewUrl: d['photo_preview_url'] as String?,
    memo: d['memo'] as String?,
    emotion: d['emotion'] as String?,
    dayLogId: d['day_log_id'] as String? ?? fallbackDayLogId,
    synced: true,
    commentCount: (d['comment_count'] as num?)?.toInt() ?? 0,
    lastCommentedAt:
        lastCommentedRaw != null ? DateTime.parse(lastCommentedRaw) : null,
    placeId: d['place_id'] as String?,
    place: placeRaw != null ? Place.fromJson(placeRaw) : null,
    tags: tags,
  );
}
