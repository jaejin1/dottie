// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TodoListImpl _$$TodoListImplFromJson(Map<String, dynamic> json) =>
    _$TodoListImpl(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      coverEmoji: json['cover_emoji'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <TodoItem>[],
      shareToken: json['share_token'] as String?,
      shareTokenExpiresAt: json['share_token_expires_at'] == null
          ? null
          : DateTime.parse(json['share_token_expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      synced: json['synced'] as bool? ?? false,
      courseType: json['course_type'] as String? ?? 'trip',
      description: json['description'] as String?,
      tags: json['tags'] == null
          ? const <String>[]
          : _tagsFromJson(json['tags']),
      coverImageUrl: json['cover_image_url'] as String?,
      visibility: json['visibility'] as String? ?? 'private',
      isImported: json['is_imported'] as bool? ?? false,
      members:
          (json['members'] as List<dynamic>?)
              ?.map((e) => CourseMember.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <CourseMember>[],
      inviteCode: json['invite_code'] as String?,
      inviteCodeExpiresAt: json['invite_code_expires_at'] == null
          ? null
          : DateTime.parse(json['invite_code_expires_at'] as String),
      roomId: json['room_id'] as String?,
      isPinned: json['is_pinned'] as bool? ?? false,
      pinOrder: (json['pin_order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TodoListImplToJson(_$TodoListImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'owner_id': instance.ownerId,
      'name': instance.name,
      'cover_emoji': instance.coverEmoji,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'items': instance.items,
      'share_token': instance.shareToken,
      'share_token_expires_at': instance.shareTokenExpiresAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'synced': instance.synced,
      'course_type': instance.courseType,
      'description': instance.description,
      'tags': _tagsToJson(instance.tags),
      'cover_image_url': instance.coverImageUrl,
      'visibility': instance.visibility,
      'is_imported': instance.isImported,
      'members': instance.members,
      'invite_code': instance.inviteCode,
      'invite_code_expires_at': instance.inviteCodeExpiresAt?.toIso8601String(),
      'room_id': instance.roomId,
      'is_pinned': instance.isPinned,
      'pin_order': instance.pinOrder,
    };
