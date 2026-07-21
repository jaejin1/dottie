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
      consentRequired: json['consent_required'] as bool? ?? false,
    );

Map<String, dynamic> _$$DottieUserImplToJson(_$DottieUserImpl instance) =>
    <String, dynamic>{
      'id': instance.uid,
      'nickname': instance.nickname,
      'profile_image': instance.profileImage,
      'character_config': instance.character,
      'provider': instance.provider,
      'created_at': instance.createdAt.toIso8601String(),
      'consent_required': instance.consentRequired,
    };

_$CharacterConfigImpl _$$CharacterConfigImplFromJson(
  Map<String, dynamic> json,
) => _$CharacterConfigImpl(colorHex: json['color_hex'] as String? ?? '#7EB8F7');

Map<String, dynamic> _$$CharacterConfigImplToJson(
  _$CharacterConfigImpl instance,
) => <String, dynamic>{'color_hex': instance.colorHex};
