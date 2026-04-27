// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DayLogImpl _$$DayLogImplFromJson(Map<String, dynamic> json) => _$DayLogImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  date: DateTime.parse(json['date'] as String),
  dots:
      (json['dots'] as List<dynamic>?)
          ?.map((e) => Dot.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  startedAt: DateTime.parse(json['startedAt'] as String),
  endedAt: json['endedAt'] == null
      ? null
      : DateTime.parse(json['endedAt'] as String),
  totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble(),
  placeCount: (json['placeCount'] as num?)?.toInt(),
  isRecording: json['isRecording'] as bool? ?? false,
  synced: json['synced'] as bool? ?? false,
);

Map<String, dynamic> _$$DayLogImplToJson(_$DayLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'date': instance.date.toIso8601String(),
      'dots': instance.dots,
      'startedAt': instance.startedAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'totalDistanceKm': instance.totalDistanceKm,
      'placeCount': instance.placeCount,
      'isRecording': instance.isRecording,
      'synced': instance.synced,
    };
