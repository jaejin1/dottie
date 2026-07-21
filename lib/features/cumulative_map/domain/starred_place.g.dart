// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'starred_place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StarredPlaceImpl _$$StarredPlaceImplFromJson(Map<String, dynamic> json) =>
    _$StarredPlaceImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      starredAt: DateTime.parse(json['starred_at'] as String),
      firstTogether: json['first_together'] == null
          ? null
          : DateTime.parse(json['first_together'] as String),
    );

Map<String, dynamic> _$$StarredPlaceImplToJson(_$StarredPlaceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'starred_at': instance.starredAt.toIso8601String(),
      'first_together': instance.firstTogether?.toIso8601String(),
    };
