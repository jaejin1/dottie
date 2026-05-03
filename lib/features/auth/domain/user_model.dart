import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class DottieUser with _$DottieUser {
  const factory DottieUser({
    @JsonKey(name: 'id') required String uid,
    required String nickname,
    @JsonKey(name: 'profile_image') String? profileImage,
    @JsonKey(name: 'character_config') @Default(CharacterConfig()) CharacterConfig character,
    String? provider,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _DottieUser;

  factory DottieUser.fromJson(Map<String, dynamic> json) =>
      _$DottieUserFromJson(json);
}

@freezed
class CharacterConfig with _$CharacterConfig {
  const factory CharacterConfig({
    @JsonKey(name: 'color_key') @Default('blue') String colorKey,
    @JsonKey(name: 'accessory') @Default('none') String accessoryKey,
    @JsonKey(name: 'expression') @Default('default') String expressionKey,
  }) = _CharacterConfig;

  factory CharacterConfig.fromJson(Map<String, dynamic> json) =>
      _$CharacterConfigFromJson(json);
}
