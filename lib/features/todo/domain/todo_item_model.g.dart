// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TodoItemImpl _$$TodoItemImplFromJson(Map<String, dynamic> json) =>
    _$TodoItemImpl(
      id: json['id'] as String,
      todoListId: json['todo_list_id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      placeName: json['place_name'] as String?,
      placeCategory: json['place_category'] as String?,
      placeId: json['place_id'] as String?,
      plannedAt: json['planned_at'] == null
          ? null
          : DateTime.parse(json['planned_at'] as String),
      dayIndex: (json['day_index'] as num?)?.toInt() ?? 0,
      orderInDay: (json['order_in_day'] as num?)?.toInt() ?? 0,
      notes: json['notes'] as String?,
      emotion: json['emotion'] as String?,
      checkInDotId: json['check_in_dot_id'] as String?,
      checkedInAt: json['checked_in_at'] == null
          ? null
          : DateTime.parse(json['checked_in_at'] as String),
      isPinned: json['is_pinned'] as bool? ?? false,
      pinOrder: (json['pin_order'] as num?)?.toInt() ?? 0,
      photoUrl: json['photo_url'] as String?,
      place: json['place'] == null
          ? null
          : Place.fromJson(json['place'] as Map<String, dynamic>),
      synced: json['synced'] as bool? ?? false,
    );

Map<String, dynamic> _$$TodoItemImplToJson(_$TodoItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'todo_list_id': instance.todoListId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'place_name': instance.placeName,
      'place_category': instance.placeCategory,
      'place_id': instance.placeId,
      'planned_at': instance.plannedAt?.toIso8601String(),
      'day_index': instance.dayIndex,
      'order_in_day': instance.orderInDay,
      'notes': instance.notes,
      'emotion': instance.emotion,
      'check_in_dot_id': instance.checkInDotId,
      'checked_in_at': instance.checkedInAt?.toIso8601String(),
      'is_pinned': instance.isPinned,
      'pin_order': instance.pinOrder,
      'photo_url': instance.photoUrl,
      'place': instance.place,
      'synced': instance.synced,
    };
