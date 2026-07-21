// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DottieUser _$DottieUserFromJson(Map<String, dynamic> json) {
  return _DottieUser.fromJson(json);
}

/// @nodoc
mixin _$DottieUser {
  @JsonKey(name: 'id')
  String get uid => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_image')
  String? get profileImage => throw _privateConstructorUsedError;
  @JsonKey(name: 'character_config')
  CharacterConfig get character => throw _privateConstructorUsedError;
  String? get provider => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// 필수 약관(이용약관/개인정보/위치기반/만14세) 동의가 필요한 상태.
  /// BE 미배포로 필드가 없으면 false → 동의 게이트 자동 비활성.
  @JsonKey(name: 'consent_required')
  bool get consentRequired => throw _privateConstructorUsedError;

  /// Serializes this DottieUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DottieUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DottieUserCopyWith<DottieUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DottieUserCopyWith<$Res> {
  factory $DottieUserCopyWith(
    DottieUser value,
    $Res Function(DottieUser) then,
  ) = _$DottieUserCopyWithImpl<$Res, DottieUser>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') String uid,
    String nickname,
    @JsonKey(name: 'profile_image') String? profileImage,
    @JsonKey(name: 'character_config') CharacterConfig character,
    String? provider,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'consent_required') bool consentRequired,
  });

  $CharacterConfigCopyWith<$Res> get character;
}

/// @nodoc
class _$DottieUserCopyWithImpl<$Res, $Val extends DottieUser>
    implements $DottieUserCopyWith<$Res> {
  _$DottieUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DottieUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? nickname = null,
    Object? profileImage = freezed,
    Object? character = null,
    Object? provider = freezed,
    Object? createdAt = null,
    Object? consentRequired = null,
  }) {
    return _then(
      _value.copyWith(
            uid: null == uid
                ? _value.uid
                : uid // ignore: cast_nullable_to_non_nullable
                      as String,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            profileImage: freezed == profileImage
                ? _value.profileImage
                : profileImage // ignore: cast_nullable_to_non_nullable
                      as String?,
            character: null == character
                ? _value.character
                : character // ignore: cast_nullable_to_non_nullable
                      as CharacterConfig,
            provider: freezed == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            consentRequired: null == consentRequired
                ? _value.consentRequired
                : consentRequired // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of DottieUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CharacterConfigCopyWith<$Res> get character {
    return $CharacterConfigCopyWith<$Res>(_value.character, (value) {
      return _then(_value.copyWith(character: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DottieUserImplCopyWith<$Res>
    implements $DottieUserCopyWith<$Res> {
  factory _$$DottieUserImplCopyWith(
    _$DottieUserImpl value,
    $Res Function(_$DottieUserImpl) then,
  ) = __$$DottieUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') String uid,
    String nickname,
    @JsonKey(name: 'profile_image') String? profileImage,
    @JsonKey(name: 'character_config') CharacterConfig character,
    String? provider,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'consent_required') bool consentRequired,
  });

  @override
  $CharacterConfigCopyWith<$Res> get character;
}

/// @nodoc
class __$$DottieUserImplCopyWithImpl<$Res>
    extends _$DottieUserCopyWithImpl<$Res, _$DottieUserImpl>
    implements _$$DottieUserImplCopyWith<$Res> {
  __$$DottieUserImplCopyWithImpl(
    _$DottieUserImpl _value,
    $Res Function(_$DottieUserImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DottieUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? nickname = null,
    Object? profileImage = freezed,
    Object? character = null,
    Object? provider = freezed,
    Object? createdAt = null,
    Object? consentRequired = null,
  }) {
    return _then(
      _$DottieUserImpl(
        uid: null == uid
            ? _value.uid
            : uid // ignore: cast_nullable_to_non_nullable
                  as String,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        profileImage: freezed == profileImage
            ? _value.profileImage
            : profileImage // ignore: cast_nullable_to_non_nullable
                  as String?,
        character: null == character
            ? _value.character
            : character // ignore: cast_nullable_to_non_nullable
                  as CharacterConfig,
        provider: freezed == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        consentRequired: null == consentRequired
            ? _value.consentRequired
            : consentRequired // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DottieUserImpl implements _DottieUser {
  const _$DottieUserImpl({
    @JsonKey(name: 'id') required this.uid,
    required this.nickname,
    @JsonKey(name: 'profile_image') this.profileImage,
    @JsonKey(name: 'character_config') this.character = const CharacterConfig(),
    this.provider,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'consent_required') this.consentRequired = false,
  });

  factory _$DottieUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$DottieUserImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String uid;
  @override
  final String nickname;
  @override
  @JsonKey(name: 'profile_image')
  final String? profileImage;
  @override
  @JsonKey(name: 'character_config')
  final CharacterConfig character;
  @override
  final String? provider;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  /// 필수 약관(이용약관/개인정보/위치기반/만14세) 동의가 필요한 상태.
  /// BE 미배포로 필드가 없으면 false → 동의 게이트 자동 비활성.
  @override
  @JsonKey(name: 'consent_required')
  final bool consentRequired;

  @override
  String toString() {
    return 'DottieUser(uid: $uid, nickname: $nickname, profileImage: $profileImage, character: $character, provider: $provider, createdAt: $createdAt, consentRequired: $consentRequired)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DottieUserImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.profileImage, profileImage) ||
                other.profileImage == profileImage) &&
            (identical(other.character, character) ||
                other.character == character) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.consentRequired, consentRequired) ||
                other.consentRequired == consentRequired));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    uid,
    nickname,
    profileImage,
    character,
    provider,
    createdAt,
    consentRequired,
  );

  /// Create a copy of DottieUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DottieUserImplCopyWith<_$DottieUserImpl> get copyWith =>
      __$$DottieUserImplCopyWithImpl<_$DottieUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DottieUserImplToJson(this);
  }
}

abstract class _DottieUser implements DottieUser {
  const factory _DottieUser({
    @JsonKey(name: 'id') required final String uid,
    required final String nickname,
    @JsonKey(name: 'profile_image') final String? profileImage,
    @JsonKey(name: 'character_config') final CharacterConfig character,
    final String? provider,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'consent_required') final bool consentRequired,
  }) = _$DottieUserImpl;

  factory _DottieUser.fromJson(Map<String, dynamic> json) =
      _$DottieUserImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String get uid;
  @override
  String get nickname;
  @override
  @JsonKey(name: 'profile_image')
  String? get profileImage;
  @override
  @JsonKey(name: 'character_config')
  CharacterConfig get character;
  @override
  String? get provider;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// 필수 약관(이용약관/개인정보/위치기반/만14세) 동의가 필요한 상태.
  /// BE 미배포로 필드가 없으면 false → 동의 게이트 자동 비활성.
  @override
  @JsonKey(name: 'consent_required')
  bool get consentRequired;

  /// Create a copy of DottieUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DottieUserImplCopyWith<_$DottieUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CharacterConfig _$CharacterConfigFromJson(Map<String, dynamic> json) {
  return _CharacterConfig.fromJson(json);
}

/// @nodoc
mixin _$CharacterConfig {
  @JsonKey(name: 'color_hex')
  String get colorHex => throw _privateConstructorUsedError;

  /// Serializes this CharacterConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CharacterConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CharacterConfigCopyWith<CharacterConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CharacterConfigCopyWith<$Res> {
  factory $CharacterConfigCopyWith(
    CharacterConfig value,
    $Res Function(CharacterConfig) then,
  ) = _$CharacterConfigCopyWithImpl<$Res, CharacterConfig>;
  @useResult
  $Res call({@JsonKey(name: 'color_hex') String colorHex});
}

/// @nodoc
class _$CharacterConfigCopyWithImpl<$Res, $Val extends CharacterConfig>
    implements $CharacterConfigCopyWith<$Res> {
  _$CharacterConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CharacterConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? colorHex = null}) {
    return _then(
      _value.copyWith(
            colorHex: null == colorHex
                ? _value.colorHex
                : colorHex // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CharacterConfigImplCopyWith<$Res>
    implements $CharacterConfigCopyWith<$Res> {
  factory _$$CharacterConfigImplCopyWith(
    _$CharacterConfigImpl value,
    $Res Function(_$CharacterConfigImpl) then,
  ) = __$$CharacterConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({@JsonKey(name: 'color_hex') String colorHex});
}

/// @nodoc
class __$$CharacterConfigImplCopyWithImpl<$Res>
    extends _$CharacterConfigCopyWithImpl<$Res, _$CharacterConfigImpl>
    implements _$$CharacterConfigImplCopyWith<$Res> {
  __$$CharacterConfigImplCopyWithImpl(
    _$CharacterConfigImpl _value,
    $Res Function(_$CharacterConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CharacterConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? colorHex = null}) {
    return _then(
      _$CharacterConfigImpl(
        colorHex: null == colorHex
            ? _value.colorHex
            : colorHex // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CharacterConfigImpl implements _CharacterConfig {
  const _$CharacterConfigImpl({
    @JsonKey(name: 'color_hex') this.colorHex = '#7EB8F7',
  });

  factory _$CharacterConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$CharacterConfigImplFromJson(json);

  @override
  @JsonKey(name: 'color_hex')
  final String colorHex;

  @override
  String toString() {
    return 'CharacterConfig(colorHex: $colorHex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CharacterConfigImpl &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, colorHex);

  /// Create a copy of CharacterConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CharacterConfigImplCopyWith<_$CharacterConfigImpl> get copyWith =>
      __$$CharacterConfigImplCopyWithImpl<_$CharacterConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CharacterConfigImplToJson(this);
  }
}

abstract class _CharacterConfig implements CharacterConfig {
  const factory _CharacterConfig({
    @JsonKey(name: 'color_hex') final String colorHex,
  }) = _$CharacterConfigImpl;

  factory _CharacterConfig.fromJson(Map<String, dynamic> json) =
      _$CharacterConfigImpl.fromJson;

  @override
  @JsonKey(name: 'color_hex')
  String get colorHex;

  /// Create a copy of CharacterConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CharacterConfigImplCopyWith<_$CharacterConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
