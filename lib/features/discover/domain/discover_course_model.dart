import 'package:freezed_annotation/freezed_annotation.dart';

part 'discover_course_model.freezed.dart';
part 'discover_course_model.g.dart';

List<String> _tagsFromJson(dynamic v) {
  if (v is List) return v.whereType<String>().toList();
  return const <String>[];
}

List<String> _tagsToJson(List<String> v) => v;

/// 디스커버리 카드 read-model — `GET /discover/courses` 응답의 코스 1건.
///
/// 상세(items 포함)는 `GET /todo-lists/:id` 로 별도 조회. 여기엔 카드 렌더에
/// 필요한 필드만 담는다(`spot_count` 만, `items[]` 미포함).
@freezed
class DiscoverCourse with _$DiscoverCourse {
  const factory DiscoverCourse({
    required String id,
    required String name,
    @JsonKey(name: 'cover_emoji') String? coverEmoji,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    @JsonKey(name: 'course_type', defaultValue: 'trip')
    @Default('trip')
    String courseType,
    // Phase 3 에선 항상 null(표시 전용). region 필터는 미지원.
    @JsonKey(name: 'region') String? region,
    @JsonKey(fromJson: _tagsFromJson, toJson: _tagsToJson)
    @Default(<String>[])
    List<String> tags,
    @JsonKey(name: 'spot_count', defaultValue: 0) @Default(0) int spotCount,
    @JsonKey(name: 'like_count', defaultValue: 0) @Default(0) int likeCount,
    @JsonKey(name: 'liked_by_me', defaultValue: false)
    @Default(false)
    bool likedByMe,
    @JsonKey(name: 'owner_nickname', defaultValue: '')
    @Default('')
    String ownerNickname,
    @JsonKey(name: 'owner_color_hex') String? ownerColorHex,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _DiscoverCourse;

  factory DiscoverCourse.fromJson(Map<String, dynamic> json) =>
      _$DiscoverCourseFromJson(json);
}

extension DiscoverCourseX on DiscoverCourse {
  bool get isTrip => courseType == 'trip';
}
