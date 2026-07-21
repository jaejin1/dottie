import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../room/data/room_repository.dart';
import '../domain/place.dart';
import '../domain/place_with_stats.dart';

part 'room_places_provider.g.dart';

/// B15 — `/v1/rooms/:id/places` 단일 호출 + cursor pagination 자동 루프.
///
/// 응답 가정:
///   { data: { places: [...], next_cursor: ..., total: int } }
///
/// orphan dots (place_id 없는 옛 dot) 는 BE 응답에 없음 — cumulativeRoomDots
/// provider 가 별도로 다룬다.
///
/// TODO(B15-stage2): bbox + zoom 파라미터 활용 (viewport fetch)
/// TODO(B15-stage3): mode=clusters 응답 처리
/// TODO(B15-stage4): member_ids/category 필터
/// TODO(B15-cache): ETag/If-None-Match → 304 처리
@riverpod
Future<RoomPlacesData> roomPlaces(Ref ref, String roomId) async {
  final repo = ref.watch(roomRepositoryProvider);

  final allPlaces = <PlaceWithStats>[];
  int total = 0;
  String? cursor;

  // cursor null 까지 페이징 (안전장치 50)
  for (var page = 0; page < 50; page++) {
    final raw = await repo.getRoomPlaces(roomId, cursor: cursor);
    if (kDebugMode) {
      debugPrint('[roomPlaces] page=$page raw=$raw');
    }
    if (raw == null) break;
    try {
      final data = RoomPlacesData.fromJson(raw);
      allPlaces.addAll(data.places);
      if (page == 0) total = data.total;
      cursor = data.nextCursor;
      if (cursor == null) break;
    } catch (e, st) {
      debugPrint('[roomPlaces] parse error: $e\n$st');
      break;
    }
  }

  if (kDebugMode) {
    debugPrint('[roomPlaces] room=$roomId places=${allPlaces.length} total=$total');
  }

  return RoomPlacesData(
    places: allPlaces,
    nextCursor: null,
    total: total,
  );
}

/// 편의 — Place id 로 PlaceWithStats 조회.
extension PlaceLookup on RoomPlacesData {
  PlaceWithStats? findById(String placeId) {
    for (final p in places) {
      if (p.id == placeId) return p;
    }
    return null;
  }

  /// dot.placeId 로 inline Place 객체 (Dot 모델 호환).
  Place? findPlaceById(String? placeId) {
    if (placeId == null) return null;
    return findById(placeId)?.toPlace();
  }
}
