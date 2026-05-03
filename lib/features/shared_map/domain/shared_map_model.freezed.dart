// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shared_map_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MemberTrack {
  String get memberId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  String get colorKey => throw _privateConstructorUsedError;
  AnimationSequence get sequence => throw _privateConstructorUsedError;

  /// Create a copy of MemberTrack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MemberTrackCopyWith<MemberTrack> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberTrackCopyWith<$Res> {
  factory $MemberTrackCopyWith(
    MemberTrack value,
    $Res Function(MemberTrack) then,
  ) = _$MemberTrackCopyWithImpl<$Res, MemberTrack>;
  @useResult
  $Res call({
    String memberId,
    String nickname,
    String colorKey,
    AnimationSequence sequence,
  });

  $AnimationSequenceCopyWith<$Res> get sequence;
}

/// @nodoc
class _$MemberTrackCopyWithImpl<$Res, $Val extends MemberTrack>
    implements $MemberTrackCopyWith<$Res> {
  _$MemberTrackCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MemberTrack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberId = null,
    Object? nickname = null,
    Object? colorKey = null,
    Object? sequence = null,
  }) {
    return _then(
      _value.copyWith(
            memberId: null == memberId
                ? _value.memberId
                : memberId // ignore: cast_nullable_to_non_nullable
                      as String,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            colorKey: null == colorKey
                ? _value.colorKey
                : colorKey // ignore: cast_nullable_to_non_nullable
                      as String,
            sequence: null == sequence
                ? _value.sequence
                : sequence // ignore: cast_nullable_to_non_nullable
                      as AnimationSequence,
          )
          as $Val,
    );
  }

  /// Create a copy of MemberTrack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AnimationSequenceCopyWith<$Res> get sequence {
    return $AnimationSequenceCopyWith<$Res>(_value.sequence, (value) {
      return _then(_value.copyWith(sequence: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MemberTrackImplCopyWith<$Res>
    implements $MemberTrackCopyWith<$Res> {
  factory _$$MemberTrackImplCopyWith(
    _$MemberTrackImpl value,
    $Res Function(_$MemberTrackImpl) then,
  ) = __$$MemberTrackImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String memberId,
    String nickname,
    String colorKey,
    AnimationSequence sequence,
  });

  @override
  $AnimationSequenceCopyWith<$Res> get sequence;
}

/// @nodoc
class __$$MemberTrackImplCopyWithImpl<$Res>
    extends _$MemberTrackCopyWithImpl<$Res, _$MemberTrackImpl>
    implements _$$MemberTrackImplCopyWith<$Res> {
  __$$MemberTrackImplCopyWithImpl(
    _$MemberTrackImpl _value,
    $Res Function(_$MemberTrackImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MemberTrack
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberId = null,
    Object? nickname = null,
    Object? colorKey = null,
    Object? sequence = null,
  }) {
    return _then(
      _$MemberTrackImpl(
        memberId: null == memberId
            ? _value.memberId
            : memberId // ignore: cast_nullable_to_non_nullable
                  as String,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        colorKey: null == colorKey
            ? _value.colorKey
            : colorKey // ignore: cast_nullable_to_non_nullable
                  as String,
        sequence: null == sequence
            ? _value.sequence
            : sequence // ignore: cast_nullable_to_non_nullable
                  as AnimationSequence,
      ),
    );
  }
}

/// @nodoc

class _$MemberTrackImpl implements _MemberTrack {
  const _$MemberTrackImpl({
    required this.memberId,
    required this.nickname,
    required this.colorKey,
    required this.sequence,
  });

  @override
  final String memberId;
  @override
  final String nickname;
  @override
  final String colorKey;
  @override
  final AnimationSequence sequence;

  @override
  String toString() {
    return 'MemberTrack(memberId: $memberId, nickname: $nickname, colorKey: $colorKey, sequence: $sequence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemberTrackImpl &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.colorKey, colorKey) ||
                other.colorKey == colorKey) &&
            (identical(other.sequence, sequence) ||
                other.sequence == sequence));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, memberId, nickname, colorKey, sequence);

  /// Create a copy of MemberTrack
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MemberTrackImplCopyWith<_$MemberTrackImpl> get copyWith =>
      __$$MemberTrackImplCopyWithImpl<_$MemberTrackImpl>(this, _$identity);
}

abstract class _MemberTrack implements MemberTrack {
  const factory _MemberTrack({
    required final String memberId,
    required final String nickname,
    required final String colorKey,
    required final AnimationSequence sequence,
  }) = _$MemberTrackImpl;

  @override
  String get memberId;
  @override
  String get nickname;
  @override
  String get colorKey;
  @override
  AnimationSequence get sequence;

  /// Create a copy of MemberTrack
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MemberTrackImplCopyWith<_$MemberTrackImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CharacterPosition {
  String get memberId => throw _privateConstructorUsedError;
  String get colorKey => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  CharacterState get state => throw _privateConstructorUsedError;

  /// Create a copy of CharacterPosition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CharacterPositionCopyWith<CharacterPosition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CharacterPositionCopyWith<$Res> {
  factory $CharacterPositionCopyWith(
    CharacterPosition value,
    $Res Function(CharacterPosition) then,
  ) = _$CharacterPositionCopyWithImpl<$Res, CharacterPosition>;
  @useResult
  $Res call({
    String memberId,
    String colorKey,
    double lat,
    double lng,
    CharacterState state,
  });
}

/// @nodoc
class _$CharacterPositionCopyWithImpl<$Res, $Val extends CharacterPosition>
    implements $CharacterPositionCopyWith<$Res> {
  _$CharacterPositionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CharacterPosition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberId = null,
    Object? colorKey = null,
    Object? lat = null,
    Object? lng = null,
    Object? state = null,
  }) {
    return _then(
      _value.copyWith(
            memberId: null == memberId
                ? _value.memberId
                : memberId // ignore: cast_nullable_to_non_nullable
                      as String,
            colorKey: null == colorKey
                ? _value.colorKey
                : colorKey // ignore: cast_nullable_to_non_nullable
                      as String,
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lng: null == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double,
            state: null == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as CharacterState,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CharacterPositionImplCopyWith<$Res>
    implements $CharacterPositionCopyWith<$Res> {
  factory _$$CharacterPositionImplCopyWith(
    _$CharacterPositionImpl value,
    $Res Function(_$CharacterPositionImpl) then,
  ) = __$$CharacterPositionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String memberId,
    String colorKey,
    double lat,
    double lng,
    CharacterState state,
  });
}

/// @nodoc
class __$$CharacterPositionImplCopyWithImpl<$Res>
    extends _$CharacterPositionCopyWithImpl<$Res, _$CharacterPositionImpl>
    implements _$$CharacterPositionImplCopyWith<$Res> {
  __$$CharacterPositionImplCopyWithImpl(
    _$CharacterPositionImpl _value,
    $Res Function(_$CharacterPositionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CharacterPosition
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberId = null,
    Object? colorKey = null,
    Object? lat = null,
    Object? lng = null,
    Object? state = null,
  }) {
    return _then(
      _$CharacterPositionImpl(
        memberId: null == memberId
            ? _value.memberId
            : memberId // ignore: cast_nullable_to_non_nullable
                  as String,
        colorKey: null == colorKey
            ? _value.colorKey
            : colorKey // ignore: cast_nullable_to_non_nullable
                  as String,
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lng: null == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double,
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as CharacterState,
      ),
    );
  }
}

/// @nodoc

class _$CharacterPositionImpl implements _CharacterPosition {
  const _$CharacterPositionImpl({
    required this.memberId,
    required this.colorKey,
    required this.lat,
    required this.lng,
    required this.state,
  });

  @override
  final String memberId;
  @override
  final String colorKey;
  @override
  final double lat;
  @override
  final double lng;
  @override
  final CharacterState state;

  @override
  String toString() {
    return 'CharacterPosition(memberId: $memberId, colorKey: $colorKey, lat: $lat, lng: $lng, state: $state)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CharacterPositionImpl &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.colorKey, colorKey) ||
                other.colorKey == colorKey) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.state, state) || other.state == state));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, memberId, colorKey, lat, lng, state);

  /// Create a copy of CharacterPosition
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CharacterPositionImplCopyWith<_$CharacterPositionImpl> get copyWith =>
      __$$CharacterPositionImplCopyWithImpl<_$CharacterPositionImpl>(
        this,
        _$identity,
      );
}

abstract class _CharacterPosition implements CharacterPosition {
  const factory _CharacterPosition({
    required final String memberId,
    required final String colorKey,
    required final double lat,
    required final double lng,
    required final CharacterState state,
  }) = _$CharacterPositionImpl;

  @override
  String get memberId;
  @override
  String get colorKey;
  @override
  double get lat;
  @override
  double get lng;
  @override
  CharacterState get state;

  /// Create a copy of CharacterPosition
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CharacterPositionImplCopyWith<_$CharacterPositionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MeetingEvent {
  String get memberIdA => throw _privateConstructorUsedError;
  String get memberIdB => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;

  /// Create a copy of MeetingEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MeetingEventCopyWith<MeetingEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MeetingEventCopyWith<$Res> {
  factory $MeetingEventCopyWith(
    MeetingEvent value,
    $Res Function(MeetingEvent) then,
  ) = _$MeetingEventCopyWithImpl<$Res, MeetingEvent>;
  @useResult
  $Res call({String memberIdA, String memberIdB, double lat, double lng});
}

/// @nodoc
class _$MeetingEventCopyWithImpl<$Res, $Val extends MeetingEvent>
    implements $MeetingEventCopyWith<$Res> {
  _$MeetingEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MeetingEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberIdA = null,
    Object? memberIdB = null,
    Object? lat = null,
    Object? lng = null,
  }) {
    return _then(
      _value.copyWith(
            memberIdA: null == memberIdA
                ? _value.memberIdA
                : memberIdA // ignore: cast_nullable_to_non_nullable
                      as String,
            memberIdB: null == memberIdB
                ? _value.memberIdB
                : memberIdB // ignore: cast_nullable_to_non_nullable
                      as String,
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lng: null == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MeetingEventImplCopyWith<$Res>
    implements $MeetingEventCopyWith<$Res> {
  factory _$$MeetingEventImplCopyWith(
    _$MeetingEventImpl value,
    $Res Function(_$MeetingEventImpl) then,
  ) = __$$MeetingEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String memberIdA, String memberIdB, double lat, double lng});
}

/// @nodoc
class __$$MeetingEventImplCopyWithImpl<$Res>
    extends _$MeetingEventCopyWithImpl<$Res, _$MeetingEventImpl>
    implements _$$MeetingEventImplCopyWith<$Res> {
  __$$MeetingEventImplCopyWithImpl(
    _$MeetingEventImpl _value,
    $Res Function(_$MeetingEventImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MeetingEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? memberIdA = null,
    Object? memberIdB = null,
    Object? lat = null,
    Object? lng = null,
  }) {
    return _then(
      _$MeetingEventImpl(
        memberIdA: null == memberIdA
            ? _value.memberIdA
            : memberIdA // ignore: cast_nullable_to_non_nullable
                  as String,
        memberIdB: null == memberIdB
            ? _value.memberIdB
            : memberIdB // ignore: cast_nullable_to_non_nullable
                  as String,
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lng: null == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$MeetingEventImpl implements _MeetingEvent {
  const _$MeetingEventImpl({
    required this.memberIdA,
    required this.memberIdB,
    required this.lat,
    required this.lng,
  });

  @override
  final String memberIdA;
  @override
  final String memberIdB;
  @override
  final double lat;
  @override
  final double lng;

  @override
  String toString() {
    return 'MeetingEvent(memberIdA: $memberIdA, memberIdB: $memberIdB, lat: $lat, lng: $lng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeetingEventImpl &&
            (identical(other.memberIdA, memberIdA) ||
                other.memberIdA == memberIdA) &&
            (identical(other.memberIdB, memberIdB) ||
                other.memberIdB == memberIdB) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng));
  }

  @override
  int get hashCode => Object.hash(runtimeType, memberIdA, memberIdB, lat, lng);

  /// Create a copy of MeetingEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MeetingEventImplCopyWith<_$MeetingEventImpl> get copyWith =>
      __$$MeetingEventImplCopyWithImpl<_$MeetingEventImpl>(this, _$identity);
}

abstract class _MeetingEvent implements MeetingEvent {
  const factory _MeetingEvent({
    required final String memberIdA,
    required final String memberIdB,
    required final double lat,
    required final double lng,
  }) = _$MeetingEventImpl;

  @override
  String get memberIdA;
  @override
  String get memberIdB;
  @override
  double get lat;
  @override
  double get lng;

  /// Create a copy of MeetingEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeetingEventImplCopyWith<_$MeetingEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
