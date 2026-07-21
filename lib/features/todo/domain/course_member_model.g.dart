// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CourseMemberImpl _$$CourseMemberImplFromJson(Map<String, dynamic> json) =>
    _$CourseMemberImpl(
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      character: json['character_config'] == null
          ? const CharacterConfig()
          : CharacterConfig.fromJson(
              json['character_config'] as Map<String, dynamic>,
            ),
      profileImage: json['profile_image'] as String?,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      role: json['role'] as String? ?? 'member',
    );

Map<String, dynamic> _$$CourseMemberImplToJson(_$CourseMemberImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'nickname': instance.nickname,
      'character_config': instance.character,
      'profile_image': instance.profileImage,
      'joined_at': instance.joinedAt.toIso8601String(),
      'role': instance.role,
    };
