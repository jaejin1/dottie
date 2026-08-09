// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_course_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiscoverCourseImpl _$$DiscoverCourseImplFromJson(Map<String, dynamic> json) =>
    _$DiscoverCourseImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      coverEmoji: json['cover_emoji'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      courseType: json['course_type'] as String? ?? 'trip',
      region: json['region'] as String?,
      tags: json['tags'] == null
          ? const <String>[]
          : _tagsFromJson(json['tags']),
      spotCount: (json['spot_count'] as num?)?.toInt() ?? 0,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      likedByMe: json['liked_by_me'] as bool? ?? false,
      ownerNickname: json['owner_nickname'] as String? ?? '',
      ownerColorHex: json['owner_color_hex'] as String?,
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$$DiscoverCourseImplToJson(
  _$DiscoverCourseImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'cover_emoji': instance.coverEmoji,
  'cover_image_url': instance.coverImageUrl,
  'course_type': instance.courseType,
  'region': instance.region,
  'tags': _tagsToJson(instance.tags),
  'spot_count': instance.spotCount,
  'like_count': instance.likeCount,
  'liked_by_me': instance.likedByMe,
  'owner_nickname': instance.ownerNickname,
  'owner_color_hex': instance.ownerColorHex,
  'updated_at': instance.updatedAt?.toIso8601String(),
};
