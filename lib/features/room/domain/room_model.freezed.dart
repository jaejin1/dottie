// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Room _$RoomFromJson(Map<String, dynamic> json) {
  return _Room.fromJson(json);
}

/// @nodoc
mixin _$Room {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;
  List<RoomMember> get members => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get inviteCode => throw _privateConstructorUsedError;

  /// Serializes this Room to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoomCopyWith<Room> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomCopyWith<$Res> {
  factory $RoomCopyWith(Room value, $Res Function(Room) then) =
      _$RoomCopyWithImpl<$Res, Room>;
  @useResult
  $Res call({
    String id,
    String name,
    String ownerId,
    List<RoomMember> members,
    DateTime createdAt,
    String? inviteCode,
  });
}

/// @nodoc
class _$RoomCopyWithImpl<$Res, $Val extends Room>
    implements $RoomCopyWith<$Res> {
  _$RoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ownerId = null,
    Object? members = null,
    Object? createdAt = null,
    Object? inviteCode = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            ownerId: null == ownerId
                ? _value.ownerId
                : ownerId // ignore: cast_nullable_to_non_nullable
                      as String,
            members: null == members
                ? _value.members
                : members // ignore: cast_nullable_to_non_nullable
                      as List<RoomMember>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            inviteCode: freezed == inviteCode
                ? _value.inviteCode
                : inviteCode // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RoomImplCopyWith<$Res> implements $RoomCopyWith<$Res> {
  factory _$$RoomImplCopyWith(
    _$RoomImpl value,
    $Res Function(_$RoomImpl) then,
  ) = __$$RoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String ownerId,
    List<RoomMember> members,
    DateTime createdAt,
    String? inviteCode,
  });
}

/// @nodoc
class __$$RoomImplCopyWithImpl<$Res>
    extends _$RoomCopyWithImpl<$Res, _$RoomImpl>
    implements _$$RoomImplCopyWith<$Res> {
  __$$RoomImplCopyWithImpl(_$RoomImpl _value, $Res Function(_$RoomImpl) _then)
    : super(_value, _then);

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? ownerId = null,
    Object? members = null,
    Object? createdAt = null,
    Object? inviteCode = freezed,
  }) {
    return _then(
      _$RoomImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        ownerId: null == ownerId
            ? _value.ownerId
            : ownerId // ignore: cast_nullable_to_non_nullable
                  as String,
        members: null == members
            ? _value._members
            : members // ignore: cast_nullable_to_non_nullable
                  as List<RoomMember>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        inviteCode: freezed == inviteCode
            ? _value.inviteCode
            : inviteCode // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomImpl implements _Room {
  const _$RoomImpl({
    required this.id,
    required this.name,
    required this.ownerId,
    final List<RoomMember> members = const [],
    required this.createdAt,
    this.inviteCode,
  }) : _members = members;

  factory _$RoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String ownerId;
  final List<RoomMember> _members;
  @override
  @JsonKey()
  List<RoomMember> get members {
    if (_members is EqualUnmodifiableListView) return _members;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_members);
  }

  @override
  final DateTime createdAt;
  @override
  final String? inviteCode;

  @override
  String toString() {
    return 'Room(id: $id, name: $name, ownerId: $ownerId, members: $members, createdAt: $createdAt, inviteCode: $inviteCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            const DeepCollectionEquality().equals(other._members, _members) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    ownerId,
    const DeepCollectionEquality().hash(_members),
    createdAt,
    inviteCode,
  );

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomImplCopyWith<_$RoomImpl> get copyWith =>
      __$$RoomImplCopyWithImpl<_$RoomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomImplToJson(this);
  }
}

abstract class _Room implements Room {
  const factory _Room({
    required final String id,
    required final String name,
    required final String ownerId,
    final List<RoomMember> members,
    required final DateTime createdAt,
    final String? inviteCode,
  }) = _$RoomImpl;

  factory _Room.fromJson(Map<String, dynamic> json) = _$RoomImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get ownerId;
  @override
  List<RoomMember> get members;
  @override
  DateTime get createdAt;
  @override
  String? get inviteCode;

  /// Create a copy of Room
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoomImplCopyWith<_$RoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RoomMember _$RoomMemberFromJson(Map<String, dynamic> json) {
  return _RoomMember.fromJson(json);
}

/// @nodoc
mixin _$RoomMember {
  String get userId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  CharacterConfig get character => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;

  /// Serializes this RoomMember to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoomMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoomMemberCopyWith<RoomMember> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomMemberCopyWith<$Res> {
  factory $RoomMemberCopyWith(
    RoomMember value,
    $Res Function(RoomMember) then,
  ) = _$RoomMemberCopyWithImpl<$Res, RoomMember>;
  @useResult
  $Res call({
    String userId,
    String nickname,
    CharacterConfig character,
    DateTime joinedAt,
  });

  $CharacterConfigCopyWith<$Res> get character;
}

/// @nodoc
class _$RoomMemberCopyWithImpl<$Res, $Val extends RoomMember>
    implements $RoomMemberCopyWith<$Res> {
  _$RoomMemberCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoomMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? character = null,
    Object? joinedAt = null,
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
            joinedAt: null == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of RoomMember
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
abstract class _$$RoomMemberImplCopyWith<$Res>
    implements $RoomMemberCopyWith<$Res> {
  factory _$$RoomMemberImplCopyWith(
    _$RoomMemberImpl value,
    $Res Function(_$RoomMemberImpl) then,
  ) = __$$RoomMemberImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String nickname,
    CharacterConfig character,
    DateTime joinedAt,
  });

  @override
  $CharacterConfigCopyWith<$Res> get character;
}

/// @nodoc
class __$$RoomMemberImplCopyWithImpl<$Res>
    extends _$RoomMemberCopyWithImpl<$Res, _$RoomMemberImpl>
    implements _$$RoomMemberImplCopyWith<$Res> {
  __$$RoomMemberImplCopyWithImpl(
    _$RoomMemberImpl _value,
    $Res Function(_$RoomMemberImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RoomMember
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? character = null,
    Object? joinedAt = null,
  }) {
    return _then(
      _$RoomMemberImpl(
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
        joinedAt: null == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomMemberImpl implements _RoomMember {
  const _$RoomMemberImpl({
    required this.userId,
    required this.nickname,
    required this.character,
    required this.joinedAt,
  });

  factory _$RoomMemberImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomMemberImplFromJson(json);

  @override
  final String userId;
  @override
  final String nickname;
  @override
  final CharacterConfig character;
  @override
  final DateTime joinedAt;

  @override
  String toString() {
    return 'RoomMember(userId: $userId, nickname: $nickname, character: $character, joinedAt: $joinedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomMemberImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.character, character) ||
                other.character == character) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, nickname, character, joinedAt);

  /// Create a copy of RoomMember
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomMemberImplCopyWith<_$RoomMemberImpl> get copyWith =>
      __$$RoomMemberImplCopyWithImpl<_$RoomMemberImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomMemberImplToJson(this);
  }
}

abstract class _RoomMember implements RoomMember {
  const factory _RoomMember({
    required final String userId,
    required final String nickname,
    required final CharacterConfig character,
    required final DateTime joinedAt,
  }) = _$RoomMemberImpl;

  factory _RoomMember.fromJson(Map<String, dynamic> json) =
      _$RoomMemberImpl.fromJson;

  @override
  String get userId;
  @override
  String get nickname;
  @override
  CharacterConfig get character;
  @override
  DateTime get joinedAt;

  /// Create a copy of RoomMember
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoomMemberImplCopyWith<_$RoomMemberImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
