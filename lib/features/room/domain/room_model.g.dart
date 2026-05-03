// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomImpl _$$RoomImplFromJson(Map<String, dynamic> json) => _$RoomImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  ownerId: json['owner_id'] as String,
  members:
      (json['members'] as List<dynamic>?)
          ?.map((e) => RoomMember.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['created_at'] as String),
  inviteCode: json['invite_code'] as String?,
  sharedDates:
      (json['shared_dates'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$$RoomImplToJson(_$RoomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'owner_id': instance.ownerId,
      'members': instance.members,
      'created_at': instance.createdAt.toIso8601String(),
      'invite_code': instance.inviteCode,
      'shared_dates': instance.sharedDates,
    };

_$RoomMemberImpl _$$RoomMemberImplFromJson(Map<String, dynamic> json) =>
    _$RoomMemberImpl(
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      character: json['character_config'] == null
          ? const CharacterConfig()
          : CharacterConfig.fromJson(
              json['character_config'] as Map<String, dynamic>,
            ),
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );

Map<String, dynamic> _$$RoomMemberImplToJson(_$RoomMemberImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'nickname': instance.nickname,
      'character_config': instance.character,
      'joined_at': instance.joinedAt.toIso8601String(),
    };
