// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaceImpl _$$PlaceImplFromJson(Map<String, dynamic> json) => _$PlaceImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  category: json['category'] as String?,
  categoryGroupCode: json['category_group_code'] as String?,
  categoryGroupName: json['category_group_name'] as String?,
  address: json['address'] as String?,
  roadAddress: json['road_address'] as String?,
  telephone: json['telephone'] as String?,
  placeUrl: json['place_url'] as String?,
  distance: (json['distance'] as num?)?.toInt(),
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
);

Map<String, dynamic> _$$PlaceImplToJson(_$PlaceImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'category_group_code': instance.categoryGroupCode,
      'category_group_name': instance.categoryGroupName,
      'address': instance.address,
      'road_address': instance.roadAddress,
      'telephone': instance.telephone,
      'place_url': instance.placeUrl,
      'distance': instance.distance,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
