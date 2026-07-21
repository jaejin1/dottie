// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room_dot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RoomDot {
  Dot get dot => throw _privateConstructorUsedError;
  String get memberId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  String get colorHex => throw _privateConstructorUsedError;
  PaperdollConfig? get paperdoll => throw _privateConstructorUsedError;

  /// Create a copy of RoomDot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoomDotCopyWith<RoomDot> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomDotCopyWith<$Res> {
  factory $RoomDotCopyWith(RoomDot value, $Res Function(RoomDot) then) =
      _$RoomDotCopyWithImpl<$Res, RoomDot>;
  @useResult
  $Res call({
    Dot dot,
    String memberId,
    String nickname,
    String colorHex,
    PaperdollConfig? paperdoll,
  });

  $DotCopyWith<$Res> get dot;
}

/// @nodoc
class _$RoomDotCopyWithImpl<$Res, $Val extends RoomDot>
    implements $RoomDotCopyWith<$Res> {
  _$RoomDotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoomDot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dot = null,
    Object? memberId = null,
    Object? nickname = null,
    Object? colorHex = null,
    Object? paperdoll = freezed,
  }) {
    return _then(
      _value.copyWith(
            dot: null == dot
                ? _value.dot
                : dot // ignore: cast_nullable_to_non_nullable
                      as Dot,
            memberId: null == memberId
                ? _value.memberId
                : memberId // ignore: cast_nullable_to_non_nullable
                      as String,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            colorHex: null == colorHex
                ? _value.colorHex
                : colorHex // ignore: cast_nullable_to_non_nullable
                      as String,
            paperdoll: freezed == paperdoll
                ? _value.paperdoll
                : paperdoll // ignore: cast_nullable_to_non_nullable
                      as PaperdollConfig?,
          )
          as $Val,
    );
  }

  /// Create a copy of RoomDot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DotCopyWith<$Res> get dot {
    return $DotCopyWith<$Res>(_value.dot, (value) {
      return _then(_value.copyWith(dot: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RoomDotImplCopyWith<$Res> implements $RoomDotCopyWith<$Res> {
  factory _$$RoomDotImplCopyWith(
    _$RoomDotImpl value,
    $Res Function(_$RoomDotImpl) then,
  ) = __$$RoomDotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Dot dot,
    String memberId,
    String nickname,
    String colorHex,
    PaperdollConfig? paperdoll,
  });

  @override
  $DotCopyWith<$Res> get dot;
}

/// @nodoc
class __$$RoomDotImplCopyWithImpl<$Res>
    extends _$RoomDotCopyWithImpl<$Res, _$RoomDotImpl>
    implements _$$RoomDotImplCopyWith<$Res> {
  __$$RoomDotImplCopyWithImpl(
    _$RoomDotImpl _value,
    $Res Function(_$RoomDotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RoomDot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dot = null,
    Object? memberId = null,
    Object? nickname = null,
    Object? colorHex = null,
    Object? paperdoll = freezed,
  }) {
    return _then(
      _$RoomDotImpl(
        dot: null == dot
            ? _value.dot
            : dot // ignore: cast_nullable_to_non_nullable
                  as Dot,
        memberId: null == memberId
            ? _value.memberId
            : memberId // ignore: cast_nullable_to_non_nullable
                  as String,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        colorHex: null == colorHex
            ? _value.colorHex
            : colorHex // ignore: cast_nullable_to_non_nullable
                  as String,
        paperdoll: freezed == paperdoll
            ? _value.paperdoll
            : paperdoll // ignore: cast_nullable_to_non_nullable
                  as PaperdollConfig?,
      ),
    );
  }
}

/// @nodoc

class _$RoomDotImpl implements _RoomDot {
  const _$RoomDotImpl({
    required this.dot,
    required this.memberId,
    required this.nickname,
    required this.colorHex,
    this.paperdoll,
  });

  @override
  final Dot dot;
  @override
  final String memberId;
  @override
  final String nickname;
  @override
  final String colorHex;
  @override
  final PaperdollConfig? paperdoll;

  @override
  String toString() {
    return 'RoomDot(dot: $dot, memberId: $memberId, nickname: $nickname, colorHex: $colorHex, paperdoll: $paperdoll)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomDotImpl &&
            (identical(other.dot, dot) || other.dot == dot) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex) &&
            (identical(other.paperdoll, paperdoll) ||
                other.paperdoll == paperdoll));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, dot, memberId, nickname, colorHex, paperdoll);

  /// Create a copy of RoomDot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomDotImplCopyWith<_$RoomDotImpl> get copyWith =>
      __$$RoomDotImplCopyWithImpl<_$RoomDotImpl>(this, _$identity);
}

abstract class _RoomDot implements RoomDot {
  const factory _RoomDot({
    required final Dot dot,
    required final String memberId,
    required final String nickname,
    required final String colorHex,
    final PaperdollConfig? paperdoll,
  }) = _$RoomDotImpl;

  @override
  Dot get dot;
  @override
  String get memberId;
  @override
  String get nickname;
  @override
  String get colorHex;
  @override
  PaperdollConfig? get paperdoll;

  /// Create a copy of RoomDot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoomDotImplCopyWith<_$RoomDotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
