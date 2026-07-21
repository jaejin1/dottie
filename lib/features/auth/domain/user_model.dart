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

    /// 필수 약관(이용약관/개인정보/위치기반/만14세) 동의가 필요한 상태.
    /// BE 미배포로 필드가 없으면 false → 동의 게이트 자동 비활성.
    @JsonKey(name: 'consent_required') @Default(false) bool consentRequired,
  }) = _DottieUser;

  factory DottieUser.fromJson(Map<String, dynamic> json) =>
      _$DottieUserFromJson(json);
}

/// 사용자 정체성 색만 담는 경량 모델 (DottieUser/RoomMember에 임베드).
/// 전체 캐릭터 외형은 별도 PaperdollConfig가 담당.
@freezed
class CharacterConfig with _$CharacterConfig {
  const factory CharacterConfig({
    @JsonKey(name: 'color_hex') @Default('#7EB8F7') String colorHex,
  }) = _CharacterConfig;

  factory CharacterConfig.fromJson(Map<String, dynamic> json) =>
      _$CharacterConfigFromJson(json);
}
