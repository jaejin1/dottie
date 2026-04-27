import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class DottieUser with _$DottieUser {
  const factory DottieUser({
    required String uid,
    required String nickname,
    required String email,
    String? photoUrl,
    @Default(CharacterConfig()) CharacterConfig character,
    required DateTime createdAt,
  }) = _DottieUser;

  factory DottieUser.fromJson(Map<String, dynamic> json) =>
      _$DottieUserFromJson(json);
}

@freezed
class CharacterConfig with _$CharacterConfig {
  const factory CharacterConfig({
    @Default('blue') String colorKey,
    @Default('none') String accessoryKey,
    @Default('default') String expressionKey,
  }) = _CharacterConfig;

  factory CharacterConfig.fromJson(Map<String, dynamic> json) =>
      _$CharacterConfigFromJson(json);
}
