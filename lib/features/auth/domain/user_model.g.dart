// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DottieUserImpl _$$DottieUserImplFromJson(Map<String, dynamic> json) =>
    _$DottieUserImpl(
      uid: json['id'] as String,
      nickname: json['nickname'] as String,
      profileImage: json['profile_image'] as String?,
      character: json['character_config'] == null
          ? const CharacterConfig()
          : CharacterConfig.fromJson(
              json['character_config'] as Map<String, dynamic>,
            ),
      provider: json['provider'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$DottieUserImplToJson(_$DottieUserImpl instance) =>
    <String, dynamic>{
      'id': instance.uid,
      'nickname': instance.nickname,
      'profile_image': instance.profileImage,
      'character_config': instance.character,
      'provider': instance.provider,
      'created_at': instance.createdAt.toIso8601String(),
    };

_$CharacterConfigImpl _$$CharacterConfigImplFromJson(
  Map<String, dynamic> json,
) => _$CharacterConfigImpl(
  colorKey: json['color_key'] as String? ?? 'blue',
  accessoryKey: json['accessory'] as String? ?? 'none',
  expressionKey: json['expression'] as String? ?? 'default',
);

Map<String, dynamic> _$$CharacterConfigImplToJson(
  _$CharacterConfigImpl instance,
) => <String, dynamic>{
  'color_key': instance.colorKey,
  'accessory': instance.accessoryKey,
  'expression': instance.expressionKey,
};
