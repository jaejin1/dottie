import 'package:freezed_annotation/freezed_annotation.dart';

part 'starred_place.freezed.dart';
part 'starred_place.g.dart';

/// B9 — 룸 즐겨찾기 장소 응답 객체.
@freezed
class StarredPlace with _$StarredPlace {
  const factory StarredPlace({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    @JsonKey(name: 'starred_at') required DateTime starredAt,

    /// 현재 유저와 다른 룸 멤버가 같은 장소를 함께 방문한 첫 번째 시점.
    @JsonKey(name: 'first_together') DateTime? firstTogether,
  }) = _StarredPlace;

  factory StarredPlace.fromJson(Map<String, dynamic> json) =>
      _$StarredPlaceFromJson(json);
}
