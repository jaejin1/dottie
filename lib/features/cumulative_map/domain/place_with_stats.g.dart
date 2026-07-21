// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_with_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaceWithStatsImpl _$$PlaceWithStatsImplFromJson(Map<String, dynamic> json) =>
    _$PlaceWithStatsImpl(
      id: json['place_id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      address: json['address'] as String?,
      roadAddress: json['road_address'] as String?,
      telephone: json['telephone'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      visitCount: (json['visit_count'] as num?)?.toInt() ?? 0,
      visitorCount: (json['visitor_count'] as num?)?.toInt() ?? 0,
      lastVisitedAt: json['last_visited_at'] == null
          ? null
          : DateTime.parse(json['last_visited_at'] as String),
      firstVisitedAt: json['first_visited_at'] == null
          ? null
          : DateTime.parse(json['first_visited_at'] as String),
      memberIds:
          (json['member_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isFirstTogether: json['is_first_together'] as bool? ?? false,
      isStarred: json['is_starred'] as bool? ?? false,
      starredByCount: (json['starred_by_count'] as num?)?.toInt() ?? 0,
      previewDot: json['preview_dot'] == null
          ? null
          : PreviewDot.fromJson(json['preview_dot'] as Map<String, dynamic>),
      commentCountTotal: (json['comment_count_total'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$PlaceWithStatsImplToJson(
  _$PlaceWithStatsImpl instance,
) => <String, dynamic>{
  'place_id': instance.id,
  'name': instance.name,
  'category': instance.category,
  'address': instance.address,
  'road_address': instance.roadAddress,
  'telephone': instance.telephone,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'visit_count': instance.visitCount,
  'visitor_count': instance.visitorCount,
  'last_visited_at': instance.lastVisitedAt?.toIso8601String(),
  'first_visited_at': instance.firstVisitedAt?.toIso8601String(),
  'member_ids': instance.memberIds,
  'is_first_together': instance.isFirstTogether,
  'is_starred': instance.isStarred,
  'starred_by_count': instance.starredByCount,
  'preview_dot': instance.previewDot,
  'comment_count_total': instance.commentCountTotal,
};

_$PreviewDotImpl _$$PreviewDotImplFromJson(Map<String, dynamic> json) =>
    _$PreviewDotImpl(
      dotId: json['dot_id'] as String,
      photoUrl: json['photo_url'] as String?,
      photoThumbUrl: json['photo_thumb_url'] as String?,
      photoPreviewUrl: json['photo_preview_url'] as String?,
      userId: json['user_id'] as String,
    );

Map<String, dynamic> _$$PreviewDotImplToJson(_$PreviewDotImpl instance) =>
    <String, dynamic>{
      'dot_id': instance.dotId,
      'photo_url': instance.photoUrl,
      'photo_thumb_url': instance.photoThumbUrl,
      'photo_preview_url': instance.photoPreviewUrl,
      'user_id': instance.userId,
    };

_$RoomPlacesDataImpl _$$RoomPlacesDataImplFromJson(Map<String, dynamic> json) =>
    _$RoomPlacesDataImpl(
      places:
          (json['places'] as List<dynamic>?)
              ?.map((e) => PlaceWithStats.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      nextCursor: json['next_cursor'] as String?,
      total: (json['total'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$RoomPlacesDataImplToJson(
  _$RoomPlacesDataImpl instance,
) => <String, dynamic>{
  'places': instance.places,
  'next_cursor': instance.nextCursor,
  'total': instance.total,
};
