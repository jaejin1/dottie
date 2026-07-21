import 'package:freezed_annotation/freezed_annotation.dart';

import 'room_dot.dart';

part 'place_group.freezed.dart';

/// place 단위 그룹.
/// - BE PlaceWithStats 변환: dots 는 빈 list, visitCount 는 BE 집계 그대로.
/// - 클라이언트 좌표 클러스터(orphan): dots 채워짐, visitCount = dots.length.
@freezed
class PlaceGroup with _$PlaceGroup {
  const factory PlaceGroup({
    required String id,
    required List<RoomDot> dots, // timestamp DESC
    required double centerLat,
    required double centerLng,
    required Set<String> memberIds,
    required String placeName,
    String? category,
    required DateTime firstVisitedAt,

    /// 방문 수 — BE 가 정확히 카운트한 값(BE places 그룹) 또는 dots.length (orphan).
    required int visitCount,

    /// 룸 모든 멤버가 이 장소를 함께 방문했는가.
    @Default(false) bool isFirstTogether,
  }) = _PlaceGroup;
}
