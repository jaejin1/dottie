// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoomImpl _$$RoomImplFromJson(Map<String, dynamic> json) => _$RoomImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  ownerId: json['ownerId'] as String,
  members:
      (json['members'] as List<dynamic>?)
          ?.map((e) => RoomMember.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  createdAt: DateTime.parse(json['createdAt'] as String),
  inviteCode: json['inviteCode'] as String?,
);

Map<String, dynamic> _$$RoomImplToJson(_$RoomImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'ownerId': instance.ownerId,
      'members': instance.members,
      'createdAt': instance.createdAt.toIso8601String(),
      'inviteCode': instance.inviteCode,
    };

_$RoomMemberImpl _$$RoomMemberImplFromJson(Map<String, dynamic> json) =>
    _$RoomMemberImpl(
      userId: json['userId'] as String,
      nickname: json['nickname'] as String,
      character: CharacterConfig.fromJson(
        json['character'] as Map<String, dynamic>,
      ),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$$RoomMemberImplToJson(_$RoomMemberImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'nickname': instance.nickname,
      'character': instance.character,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };
