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
  String get uid => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  CharacterConfig get character => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

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
    String uid,
    String nickname,
    String email,
    String? photoUrl,
    CharacterConfig character,
    DateTime createdAt,
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
    Object? email = null,
    Object? photoUrl = freezed,
    Object? character = null,
    Object? createdAt = null,
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
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            character: null == character
                ? _value.character
                : character // ignore: cast_nullable_to_non_nullable
                      as CharacterConfig,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
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
    String uid,
    String nickname,
    String email,
    String? photoUrl,
    CharacterConfig character,
    DateTime createdAt,
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
    Object? email = null,
    Object? photoUrl = freezed,
    Object? character = null,
    Object? createdAt = null,
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
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        character: null == character
            ? _value.character
            : character // ignore: cast_nullable_to_non_nullable
                  as CharacterConfig,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DottieUserImpl implements _DottieUser {
  const _$DottieUserImpl({
    required this.uid,
    required this.nickname,
    required this.email,
    this.photoUrl,
    this.character = const CharacterConfig(),
    required this.createdAt,
  });

  factory _$DottieUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$DottieUserImplFromJson(json);

  @override
  final String uid;
  @override
  final String nickname;
  @override
  final String email;
  @override
  final String? photoUrl;
  @override
  @JsonKey()
  final CharacterConfig character;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'DottieUser(uid: $uid, nickname: $nickname, email: $email, photoUrl: $photoUrl, character: $character, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DottieUserImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.character, character) ||
                other.character == character) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    uid,
    nickname,
    email,
    photoUrl,
    character,
    createdAt,
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
    required final String uid,
    required final String nickname,
    required final String email,
    final String? photoUrl,
    final CharacterConfig character,
    required final DateTime createdAt,
  }) = _$DottieUserImpl;

  factory _DottieUser.fromJson(Map<String, dynamic> json) =
      _$DottieUserImpl.fromJson;

  @override
  String get uid;
  @override
  String get nickname;
  @override
  String get email;
  @override
  String? get photoUrl;
  @override
  CharacterConfig get character;
  @override
  DateTime get createdAt;

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
  String get colorKey => throw _privateConstructorUsedError;
  String get accessoryKey => throw _privateConstructorUsedError;
  String get expressionKey => throw _privateConstructorUsedError;

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
  $Res call({String colorKey, String accessoryKey, String expressionKey});
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
  $Res call({
    Object? colorKey = null,
    Object? accessoryKey = null,
    Object? expressionKey = null,
  }) {
    return _then(
      _value.copyWith(
            colorKey: null == colorKey
                ? _value.colorKey
                : colorKey // ignore: cast_nullable_to_non_nullable
                      as String,
            accessoryKey: null == accessoryKey
                ? _value.accessoryKey
                : accessoryKey // ignore: cast_nullable_to_non_nullable
                      as String,
            expressionKey: null == expressionKey
                ? _value.expressionKey
                : expressionKey // ignore: cast_nullable_to_non_nullable
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
  $Res call({String colorKey, String accessoryKey, String expressionKey});
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
  $Res call({
    Object? colorKey = null,
    Object? accessoryKey = null,
    Object? expressionKey = null,
  }) {
    return _then(
      _$CharacterConfigImpl(
        colorKey: null == colorKey
            ? _value.colorKey
            : colorKey // ignore: cast_nullable_to_non_nullable
                  as String,
        accessoryKey: null == accessoryKey
            ? _value.accessoryKey
            : accessoryKey // ignore: cast_nullable_to_non_nullable
                  as String,
        expressionKey: null == expressionKey
            ? _value.expressionKey
            : expressionKey // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CharacterConfigImpl implements _CharacterConfig {
  const _$CharacterConfigImpl({
    this.colorKey = 'blue',
    this.accessoryKey = 'none',
    this.expressionKey = 'default',
  });

  factory _$CharacterConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$CharacterConfigImplFromJson(json);

  @override
  @JsonKey()
  final String colorKey;
  @override
  @JsonKey()
  final String accessoryKey;
  @override
  @JsonKey()
  final String expressionKey;

  @override
  String toString() {
    return 'CharacterConfig(colorKey: $colorKey, accessoryKey: $accessoryKey, expressionKey: $expressionKey)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CharacterConfigImpl &&
            (identical(other.colorKey, colorKey) ||
                other.colorKey == colorKey) &&
            (identical(other.accessoryKey, accessoryKey) ||
                other.accessoryKey == accessoryKey) &&
            (identical(other.expressionKey, expressionKey) ||
                other.expressionKey == expressionKey));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, colorKey, accessoryKey, expressionKey);

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
    final String colorKey,
    final String accessoryKey,
    final String expressionKey,
  }) = _$CharacterConfigImpl;

  factory _CharacterConfig.fromJson(Map<String, dynamic> json) =
      _$CharacterConfigImpl.fromJson;

  @override
  String get colorKey;
  @override
  String get accessoryKey;
  @override
  String get expressionKey;

  /// Create a copy of CharacterConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CharacterConfigImplCopyWith<_$CharacterConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
