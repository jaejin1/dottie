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
  String get colorHex => throw _privateConstructorUsedError;
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
    String colorHex,
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
    Object? colorHex = null,
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
            colorHex: null == colorHex
                ? _value.colorHex
                : colorHex // ignore: cast_nullable_to_non_nullable
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
    String colorHex,
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
    Object? colorHex = null,
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
        colorHex: null == colorHex
            ? _value.colorHex
            : colorHex // ignore: cast_nullable_to_non_nullable
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
    required this.colorHex,
    required this.sequence,
  });

  @override
  final String memberId;
  @override
  final String nickname;
  @override
  final String colorHex;
  @override
  final AnimationSequence sequence;

  @override
  String toString() {
    return 'MemberTrack(memberId: $memberId, nickname: $nickname, colorHex: $colorHex, sequence: $sequence)';
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
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex) &&
            (identical(other.sequence, sequence) ||
                other.sequence == sequence));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, memberId, nickname, colorHex, sequence);

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
    required final String colorHex,
    required final AnimationSequence sequence,
  }) = _$MemberTrackImpl;

  @override
  String get memberId;
  @override
  String get nickname;
  @override
  String get colorHex;
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
  String get colorHex => throw _privateConstructorUsedError;
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
    String colorHex,
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
    Object? colorHex = null,
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
            colorHex: null == colorHex
                ? _value.colorHex
                : colorHex // ignore: cast_nullable_to_non_nullable
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
    String colorHex,
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
    Object? colorHex = null,
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
        colorHex: null == colorHex
            ? _value.colorHex
            : colorHex // ignore: cast_nullable_to_non_nullable
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
    required this.colorHex,
    required this.lat,
    required this.lng,
    required this.state,
  });

  @override
  final String memberId;
  @override
  final String colorHex;
  @override
  final double lat;
  @override
  final double lng;
  @override
  final CharacterState state;

  @override
  String toString() {
    return 'CharacterPosition(memberId: $memberId, colorHex: $colorHex, lat: $lat, lng: $lng, state: $state)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CharacterPositionImpl &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.state, state) || other.state == state));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, memberId, colorHex, lat, lng, state);

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
    required final String colorHex,
    required final double lat,
    required final double lng,
    required final CharacterState state,
  }) = _$CharacterPositionImpl;

  @override
  String get memberId;
  @override
  String get colorHex;
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
  List<String> get userIds => throw _privateConstructorUsedError;
  double get lat => throw _privateConstructorUsedError;
  double get lng =>
      throw _privateConstructorUsedError; // BE 보강 필드 (클라이언트 detect 는 null/빈 list)
  DateTime? get startedAt => throw _privateConstructorUsedError;
  int? get durationMinutes => throw _privateConstructorUsedError;
  String? get placeName => throw _privateConstructorUsedError;
  List<String> get dotIds => throw _privateConstructorUsedError;
  double? get maxDistanceM => throw _privateConstructorUsedError;

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
  $Res call({
    List<String> userIds,
    double lat,
    double lng,
    DateTime? startedAt,
    int? durationMinutes,
    String? placeName,
    List<String> dotIds,
    double? maxDistanceM,
  });
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
    Object? userIds = null,
    Object? lat = null,
    Object? lng = null,
    Object? startedAt = freezed,
    Object? durationMinutes = freezed,
    Object? placeName = freezed,
    Object? dotIds = null,
    Object? maxDistanceM = freezed,
  }) {
    return _then(
      _value.copyWith(
            userIds: null == userIds
                ? _value.userIds
                : userIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            lat: null == lat
                ? _value.lat
                : lat // ignore: cast_nullable_to_non_nullable
                      as double,
            lng: null == lng
                ? _value.lng
                : lng // ignore: cast_nullable_to_non_nullable
                      as double,
            startedAt: freezed == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            durationMinutes: freezed == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int?,
            placeName: freezed == placeName
                ? _value.placeName
                : placeName // ignore: cast_nullable_to_non_nullable
                      as String?,
            dotIds: null == dotIds
                ? _value.dotIds
                : dotIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            maxDistanceM: freezed == maxDistanceM
                ? _value.maxDistanceM
                : maxDistanceM // ignore: cast_nullable_to_non_nullable
                      as double?,
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
  $Res call({
    List<String> userIds,
    double lat,
    double lng,
    DateTime? startedAt,
    int? durationMinutes,
    String? placeName,
    List<String> dotIds,
    double? maxDistanceM,
  });
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
    Object? userIds = null,
    Object? lat = null,
    Object? lng = null,
    Object? startedAt = freezed,
    Object? durationMinutes = freezed,
    Object? placeName = freezed,
    Object? dotIds = null,
    Object? maxDistanceM = freezed,
  }) {
    return _then(
      _$MeetingEventImpl(
        userIds: null == userIds
            ? _value._userIds
            : userIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        lat: null == lat
            ? _value.lat
            : lat // ignore: cast_nullable_to_non_nullable
                  as double,
        lng: null == lng
            ? _value.lng
            : lng // ignore: cast_nullable_to_non_nullable
                  as double,
        startedAt: freezed == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        durationMinutes: freezed == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int?,
        placeName: freezed == placeName
            ? _value.placeName
            : placeName // ignore: cast_nullable_to_non_nullable
                  as String?,
        dotIds: null == dotIds
            ? _value._dotIds
            : dotIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        maxDistanceM: freezed == maxDistanceM
            ? _value.maxDistanceM
            : maxDistanceM // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc

class _$MeetingEventImpl implements _MeetingEvent {
  const _$MeetingEventImpl({
    required final List<String> userIds,
    required this.lat,
    required this.lng,
    this.startedAt,
    this.durationMinutes,
    this.placeName,
    final List<String> dotIds = const [],
    this.maxDistanceM,
  }) : _userIds = userIds,
       _dotIds = dotIds;

  final List<String> _userIds;
  @override
  List<String> get userIds {
    if (_userIds is EqualUnmodifiableListView) return _userIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_userIds);
  }

  @override
  final double lat;
  @override
  final double lng;
  // BE 보강 필드 (클라이언트 detect 는 null/빈 list)
  @override
  final DateTime? startedAt;
  @override
  final int? durationMinutes;
  @override
  final String? placeName;
  final List<String> _dotIds;
  @override
  @JsonKey()
  List<String> get dotIds {
    if (_dotIds is EqualUnmodifiableListView) return _dotIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dotIds);
  }

  @override
  final double? maxDistanceM;

  @override
  String toString() {
    return 'MeetingEvent(userIds: $userIds, lat: $lat, lng: $lng, startedAt: $startedAt, durationMinutes: $durationMinutes, placeName: $placeName, dotIds: $dotIds, maxDistanceM: $maxDistanceM)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MeetingEventImpl &&
            const DeepCollectionEquality().equals(other._userIds, _userIds) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.placeName, placeName) ||
                other.placeName == placeName) &&
            const DeepCollectionEquality().equals(other._dotIds, _dotIds) &&
            (identical(other.maxDistanceM, maxDistanceM) ||
                other.maxDistanceM == maxDistanceM));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_userIds),
    lat,
    lng,
    startedAt,
    durationMinutes,
    placeName,
    const DeepCollectionEquality().hash(_dotIds),
    maxDistanceM,
  );

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
    required final List<String> userIds,
    required final double lat,
    required final double lng,
    final DateTime? startedAt,
    final int? durationMinutes,
    final String? placeName,
    final List<String> dotIds,
    final double? maxDistanceM,
  }) = _$MeetingEventImpl;

  @override
  List<String> get userIds;
  @override
  double get lat;
  @override
  double get lng; // BE 보강 필드 (클라이언트 detect 는 null/빈 list)
  @override
  DateTime? get startedAt;
  @override
  int? get durationMinutes;
  @override
  String? get placeName;
  @override
  List<String> get dotIds;
  @override
  double? get maxDistanceM;

  /// Create a copy of MeetingEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MeetingEventImplCopyWith<_$MeetingEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
