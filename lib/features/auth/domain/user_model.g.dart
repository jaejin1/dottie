// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DottieUserImpl _$$DottieUserImplFromJson(Map<String, dynamic> json) =>
    _$DottieUserImpl(
      uid: json['uid'] as String,
      nickname: json['nickname'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      character: json['character'] == null
          ? const CharacterConfig()
          : CharacterConfig.fromJson(json['character'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$DottieUserImplToJson(_$DottieUserImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'nickname': instance.nickname,
      'email': instance.email,
      'photoUrl': instance.photoUrl,
      'character': instance.character,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$CharacterConfigImpl _$$CharacterConfigImplFromJson(
  Map<String, dynamic> json,
) => _$CharacterConfigImpl(
  colorKey: json['colorKey'] as String? ?? 'blue',
  accessoryKey: json['accessoryKey'] as String? ?? 'none',
  expressionKey: json['expressionKey'] as String? ?? 'default',
);

Map<String, dynamic> _$$CharacterConfigImplToJson(
  _$CharacterConfigImpl instance,
) => <String, dynamic>{
  'colorKey': instance.colorKey,
  'accessoryKey': instance.accessoryKey,
  'expressionKey': instance.expressionKey,
};
