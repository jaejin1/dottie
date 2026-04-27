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
  memo: json['memo'] as String?,
  emotion: json['emotion'] as String?,
  dayLogId: json['dayLogId'] as String,
  synced: json['synced'] as bool? ?? false,
);

Map<String, dynamic> _$$DotImplToJson(_$DotImpl instance) => <String, dynamic>{
  'id': instance.id,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'timestamp': instance.timestamp.toIso8601String(),
  'placeName': instance.placeName,
  'placeCategory': instance.placeCategory,
  'photoUrl': instance.photoUrl,
  'memo': instance.memo,
  'emotion': instance.emotion,
  'dayLogId': instance.dayLogId,
  'synced': instance.synced,
};
