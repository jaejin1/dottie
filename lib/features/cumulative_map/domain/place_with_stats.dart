import 'package:freezed_annotation/freezed_annotation.dart';

import 'place.dart';

part 'place_with_stats.freezed.dart';
part 'place_with_stats.g.dart';

/// B15 — `/v1/rooms/:id/places` 응답의 단일 place 객체.
/// BE 가 룸 안에서 집계한 통계 포함.
@freezed
class PlaceWithStats with _$PlaceWithStats {
  const factory PlaceWithStats({
    @JsonKey(name: 'place_id') required String id,
    required String name,
    String? category,
    String? address,
    @JsonKey(name: 'road_address') String? roadAddress,
    String? telephone,
    required double latitude,
    required double longitude,

    // ── 룸 통계 ──────────────────────────────
    @JsonKey(name: 'visit_count') @Default(0) int visitCount,

    /// 이 장소를 방문한 룸 멤버 수.
    @JsonKey(name: 'visitor_count') @Default(0) int visitorCount,

    /// 가장 최근 방문 (date string `YYYY-MM-DD` 또는 timestamp).
    @JsonKey(name: 'last_visited_at') DateTime? lastVisitedAt,

    /// 가장 처음 방문 시각.
    @JsonKey(name: 'first_visited_at') DateTime? firstVisitedAt,

    @JsonKey(name: 'member_ids') @Default([]) List<String> memberIds,

    /// 요청자와 다른 멤버가 같은 날 함께 방문한 적이 있는지.
    @JsonKey(name: 'is_first_together') @Default(false) bool isFirstTogether,

    // ── 즐겨찾기 (B9) ──────────────────────────
    @JsonKey(name: 'is_starred') @Default(false) bool isStarred,

    /// 이 룸에서 이 장소를 별표한 멤버 수.
    @JsonKey(name: 'starred_by_count') @Default(0) int starredByCount,

    // ── 미리보기 ───────────────────────────────
    @JsonKey(name: 'preview_dot') PreviewDot? previewDot,

    /// 이 장소 dot 들의 댓글 수 합산.
    @JsonKey(name: 'comment_count_total') @Default(0) int commentCountTotal,
  }) = _PlaceWithStats;

  factory PlaceWithStats.fromJson(Map<String, dynamic> json) =>
      _$PlaceWithStatsFromJson(json);

  const PlaceWithStats._();

  /// 기본 Place 정보만 추출 (Dot.place 호환).
  Place toPlace() => Place(
        id: id,
        name: name,
        category: category,
        address: address,
        roadAddress: roadAddress,
        telephone: telephone,
        latitude: latitude,
        longitude: longitude,
      );

  /// 미리보기 사진 URL — preview_dot 안 thumb 우선, 없으면 preview, 없으면
  /// 원본(`photo_url`). BE 가 응답에서 `photo_url` 을 빼는 정책이 끝까지 적용된
  /// 시점엔 thumb 만 채워진다.
  String? get thumbnailUrl {
    final p = previewDot;
    if (p == null) return null;
    final thumb = p.photoThumbUrl;
    if (thumb != null && thumb.isNotEmpty) return thumb;
    final preview = p.photoPreviewUrl;
    if (preview != null && preview.isNotEmpty) return preview;
    final orig = p.photoUrl;
    if (orig != null && orig.isNotEmpty) return orig;
    return null;
  }
}

/// BE preview_dot 객체.
/// BE 가 응답에서 `photo_url` 을 점진 제거 중 — `photo_thumb_url` /
/// `photo_preview_url` 이 권위. 셋 다 nullable 로 받아 호환 유지.
@freezed
class PreviewDot with _$PreviewDot {
  const factory PreviewDot({
    @JsonKey(name: 'dot_id') required String dotId,
    @JsonKey(name: 'photo_url') String? photoUrl,
    @JsonKey(name: 'photo_thumb_url') String? photoThumbUrl,
    @JsonKey(name: 'photo_preview_url') String? photoPreviewUrl,
    @JsonKey(name: 'user_id') required String userId,
  }) = _PreviewDot;

  factory PreviewDot.fromJson(Map<String, dynamic> json) =>
      _$PreviewDotFromJson(json);
}

/// B15 응답 전체.
@freezed
class RoomPlacesData with _$RoomPlacesData {
  const factory RoomPlacesData({
    @Default([]) List<PlaceWithStats> places,
    @JsonKey(name: 'next_cursor') String? nextCursor,
    @Default(0) int total,
  }) = _RoomPlacesData;

  factory RoomPlacesData.fromJson(Map<String, dynamic> json) =>
      _$RoomPlacesDataFromJson(json);
}
