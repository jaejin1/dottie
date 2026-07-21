// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dot_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DotImpl _$$DotImplFromJson(Map<String, dynamic> json) => _$DotImpl(
  id: json['id'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  placeName: json['placeName'] as String?,
  placeCategory: json['placeCategory'] as String?,
  photoUrl: json['photoUrl'] as String?,
  photoThumbUrl: json['photo_thumb_url'] as String?,
  photoPreviewUrl: json['photo_preview_url'] as String?,
  memo: json['memo'] as String?,
  emotion: json['emotion'] as String?,
  dayLogId: json['dayLogId'] as String,
  synced: json['synced'] as bool? ?? false,
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  lastCommentedAt: json['lastCommentedAt'] == null
      ? null
      : DateTime.parse(json['lastCommentedAt'] as String),
  placeId: json['placeId'] as String?,
  place: json['place'] == null
      ? null
      : Place.fromJson(json['place'] as Map<String, dynamic>),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
);

Map<String, dynamic> _$$DotImplToJson(_$DotImpl instance) => <String, dynamic>{
  'id': instance.id,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'timestamp': instance.timestamp.toIso8601String(),
  'placeName': instance.placeName,
  'placeCategory': instance.placeCategory,
  'photoUrl': instance.photoUrl,
  'photo_thumb_url': instance.photoThumbUrl,
  'photo_preview_url': instance.photoPreviewUrl,
  'memo': instance.memo,
  'emotion': instance.emotion,
  'dayLogId': instance.dayLogId,
  'synced': instance.synced,
  'commentCount': instance.commentCount,
  'lastCommentedAt': instance.lastCommentedAt?.toIso8601String(),
  'placeId': instance.placeId,
  'place': instance.place,
  'tags': instance.tags,
};
