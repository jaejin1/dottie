// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'course_member_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CourseMember _$CourseMemberFromJson(Map<String, dynamic> json) {
  return _CourseMember.fromJson(json);
}

/// @nodoc
mixin _$CourseMember {
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  @JsonKey(name: 'character_config')
  CharacterConfig get character => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_image')
  String? get profileImage => throw _privateConstructorUsedError;
  @JsonKey(name: 'joined_at')
  DateTime get joinedAt => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;

  /// Serializes this CourseMember to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CourseMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CourseMemberCopyWith<CourseMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CourseMemberCopyWith<$Res> {
  factory $CourseMemberCopyWith(
    CourseMember value,
    $Res Function(CourseMember) then,
  ) = _$CourseMemberCopyWithImpl<$Res, CourseMember>;
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    String nickname,
    @JsonKey(name: 'character_config') CharacterConfig character,
    @JsonKey(name: 'profile_image') String? profileImage,
    @JsonKey(name: 'joined_at') DateTime joinedAt,
    String role,
  });

  $CharacterConfigCopyWith<$Res> get character;
}

/// @nodoc
class _$CourseMemberCopyWithImpl<$Res, $Val extends CourseMember>
    implements $CourseMemberCopyWith<$Res> {
  _$CourseMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CourseMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? character = null,
    Object? profileImage = freezed,
    Object? joinedAt = null,
    Object? role = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            character: null == character
                ? _value.character
                : character // ignore: cast_nullable_to_non_nullable
                      as CharacterConfig,
            profileImage: freezed == profileImage
                ? _value.profileImage
                : profileImage // ignore: cast_nullable_to_non_nullable
                      as String?,
            joinedAt: null == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of CourseMember
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
abstract class _$$CourseMemberImplCopyWith<$Res>
    implements $CourseMemberCopyWith<$Res> {
  factory _$$CourseMemberImplCopyWith(
    _$CourseMemberImpl value,
    $Res Function(_$CourseMemberImpl) then,
  ) = __$$CourseMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    String nickname,
    @JsonKey(name: 'character_config') CharacterConfig character,
    @JsonKey(name: 'profile_image') String? profileImage,
    @JsonKey(name: 'joined_at') DateTime joinedAt,
    String role,
  });

  @override
  $CharacterConfigCopyWith<$Res> get character;
}

/// @nodoc
class __$$CourseMemberImplCopyWithImpl<$Res>
    extends _$CourseMemberCopyWithImpl<$Res, _$CourseMemberImpl>
    implements _$$CourseMemberImplCopyWith<$Res> {
  __$$CourseMemberImplCopyWithImpl(
    _$CourseMemberImpl _value,
    $Res Function(_$CourseMemberImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CourseMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? character = null,
    Object? profileImage = freezed,
    Object? joinedAt = null,
    Object? role = null,
  }) {
    return _then(
      _$CourseMemberImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        character: null == character
            ? _value.character
            : character // ignore: cast_nullable_to_non_nullable
                  as CharacterConfig,
        profileImage: freezed == profileImage
            ? _value.profileImage
            : profileImage // ignore: cast_nullable_to_non_nullable
                  as String?,
        joinedAt: null == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CourseMemberImpl implements _CourseMember {
  const _$CourseMemberImpl({
    @JsonKey(name: 'user_id') required this.userId,
    required this.nickname,
    @JsonKey(name: 'character_config') this.character = const CharacterConfig(),
    @JsonKey(name: 'profile_image') this.profileImage,
    @JsonKey(name: 'joined_at') required this.joinedAt,
    this.role = 'member',
  });

  factory _$CourseMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$CourseMemberImplFromJson(json);

  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String nickname;
  @override
  @JsonKey(name: 'character_config')
  final CharacterConfig character;
  @override
  @JsonKey(name: 'profile_image')
  final String? profileImage;
  @override
  @JsonKey(name: 'joined_at')
  final DateTime joinedAt;
  @override
  @JsonKey()
  final String role;

  @override
  String toString() {
    return 'CourseMember(userId: $userId, nickname: $nickname, character: $character, profileImage: $profileImage, joinedAt: $joinedAt, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CourseMemberImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.character, character) ||
                other.character == character) &&
            (identical(other.profileImage, profileImage) ||
                other.profileImage == profileImage) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    nickname,
    character,
    profileImage,
    joinedAt,
    role,
  );

  /// Create a copy of CourseMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CourseMemberImplCopyWith<_$CourseMemberImpl> get copyWith =>
      __$$CourseMemberImplCopyWithImpl<_$CourseMemberImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CourseMemberImplToJson(this);
  }
}

abstract class _CourseMember implements CourseMember {
  const factory _CourseMember({
    @JsonKey(name: 'user_id') required final String userId,
    required final String nickname,
    @JsonKey(name: 'character_config') final CharacterConfig character,
    @JsonKey(name: 'profile_image') final String? profileImage,
    @JsonKey(name: 'joined_at') required final DateTime joinedAt,
    final String role,
  }) = _$CourseMemberImpl;

  factory _CourseMember.fromJson(Map<String, dynamic> json) =
      _$CourseMemberImpl.fromJson;

  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get nickname;
  @override
  @JsonKey(name: 'character_config')
  CharacterConfig get character;
  @override
  @JsonKey(name: 'profile_image')
  String? get profileImage;
  @override
  @JsonKey(name: 'joined_at')
  DateTime get joinedAt;
  @override
  String get role;

  /// Create a copy of CourseMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CourseMemberImplCopyWith<_$CourseMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
