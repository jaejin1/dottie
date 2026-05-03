// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animation_frame.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AnimationFrame {
  int get index => throw _privateConstructorUsedError; // 현재 dot 인덱스
  Dot get dot => throw _privateConstructorUsedError; // 현재 dot
  Dot? get nextDot => throw _privateConstructorUsedError; // 다음 dot (null이면 마지막)
  double get latitude => throw _privateConstructorUsedError; // 현재 보간된 위도
  double get longitude => throw _privateConstructorUsedError; // 현재 보간된 경도
  CharacterState get state => throw _privateConstructorUsedError;
  double get distanceKm => throw _privateConstructorUsedError; // 다음 dot까지 거리
  Duration get duration =>
      throw _privateConstructorUsedError; // 다음 dot까지 실제 경과 시간
  bool get isArrived => throw _privateConstructorUsedError;

  /// Create a copy of AnimationFrame
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnimationFrameCopyWith<AnimationFrame> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnimationFrameCopyWith<$Res> {
  factory $AnimationFrameCopyWith(
    AnimationFrame value,
    $Res Function(AnimationFrame) then,
  ) = _$AnimationFrameCopyWithImpl<$Res, AnimationFrame>;
  @useResult
  $Res call({
    int index,
    Dot dot,
    Dot? nextDot,
    double latitude,
    double longitude,
    CharacterState state,
    double distanceKm,
    Duration duration,
    bool isArrived,
  });

  $DotCopyWith<$Res> get dot;
  $DotCopyWith<$Res>? get nextDot;
}

/// @nodoc
class _$AnimationFrameCopyWithImpl<$Res, $Val extends AnimationFrame>
    implements $AnimationFrameCopyWith<$Res> {
  _$AnimationFrameCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnimationFrame
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? dot = null,
    Object? nextDot = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? state = null,
    Object? distanceKm = null,
    Object? duration = null,
    Object? isArrived = null,
  }) {
    return _then(
      _value.copyWith(
            index: null == index
                ? _value.index
                : index // ignore: cast_nullable_to_non_nullable
                      as int,
            dot: null == dot
                ? _value.dot
                : dot // ignore: cast_nullable_to_non_nullable
                      as Dot,
            nextDot: freezed == nextDot
                ? _value.nextDot
                : nextDot // ignore: cast_nullable_to_non_nullable
                      as Dot?,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            state: null == state
                ? _value.state
                : state // ignore: cast_nullable_to_non_nullable
                      as CharacterState,
            distanceKm: null == distanceKm
                ? _value.distanceKm
                : distanceKm // ignore: cast_nullable_to_non_nullable
                      as double,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as Duration,
            isArrived: null == isArrived
                ? _value.isArrived
                : isArrived // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of AnimationFrame
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DotCopyWith<$Res> get dot {
    return $DotCopyWith<$Res>(_value.dot, (value) {
      return _then(_value.copyWith(dot: value) as $Val);
    });
  }

  /// Create a copy of AnimationFrame
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DotCopyWith<$Res>? get nextDot {
    if (_value.nextDot == null) {
      return null;
    }

    return $DotCopyWith<$Res>(_value.nextDot!, (value) {
      return _then(_value.copyWith(nextDot: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AnimationFrameImplCopyWith<$Res>
    implements $AnimationFrameCopyWith<$Res> {
  factory _$$AnimationFrameImplCopyWith(
    _$AnimationFrameImpl value,
    $Res Function(_$AnimationFrameImpl) then,
  ) = __$$AnimationFrameImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int index,
    Dot dot,
    Dot? nextDot,
    double latitude,
    double longitude,
    CharacterState state,
    double distanceKm,
    Duration duration,
    bool isArrived,
  });

  @override
  $DotCopyWith<$Res> get dot;
  @override
  $DotCopyWith<$Res>? get nextDot;
}

/// @nodoc
class __$$AnimationFrameImplCopyWithImpl<$Res>
    extends _$AnimationFrameCopyWithImpl<$Res, _$AnimationFrameImpl>
    implements _$$AnimationFrameImplCopyWith<$Res> {
  __$$AnimationFrameImplCopyWithImpl(
    _$AnimationFrameImpl _value,
    $Res Function(_$AnimationFrameImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AnimationFrame
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
    Object? dot = null,
    Object? nextDot = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? state = null,
    Object? distanceKm = null,
    Object? duration = null,
    Object? isArrived = null,
  }) {
    return _then(
      _$AnimationFrameImpl(
        index: null == index
            ? _value.index
            : index // ignore: cast_nullable_to_non_nullable
                  as int,
        dot: null == dot
            ? _value.dot
            : dot // ignore: cast_nullable_to_non_nullable
                  as Dot,
        nextDot: freezed == nextDot
            ? _value.nextDot
            : nextDot // ignore: cast_nullable_to_non_nullable
                  as Dot?,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        state: null == state
            ? _value.state
            : state // ignore: cast_nullable_to_non_nullable
                  as CharacterState,
        distanceKm: null == distanceKm
            ? _value.distanceKm
            : distanceKm // ignore: cast_nullable_to_non_nullable
                  as double,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as Duration,
        isArrived: null == isArrived
            ? _value.isArrived
            : isArrived // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$AnimationFrameImpl implements _AnimationFrame {
  const _$AnimationFrameImpl({
    required this.index,
    required this.dot,
    this.nextDot,
    required this.latitude,
    required this.longitude,
    required this.state,
    required this.distanceKm,
    required this.duration,
    this.isArrived = false,
  });

  @override
  final int index;
  // 현재 dot 인덱스
  @override
  final Dot dot;
  // 현재 dot
  @override
  final Dot? nextDot;
  // 다음 dot (null이면 마지막)
  @override
  final double latitude;
  // 현재 보간된 위도
  @override
  final double longitude;
  // 현재 보간된 경도
  @override
  final CharacterState state;
  @override
  final double distanceKm;
  // 다음 dot까지 거리
  @override
  final Duration duration;
  // 다음 dot까지 실제 경과 시간
  @override
  @JsonKey()
  final bool isArrived;

  @override
  String toString() {
    return 'AnimationFrame(index: $index, dot: $dot, nextDot: $nextDot, latitude: $latitude, longitude: $longitude, state: $state, distanceKm: $distanceKm, duration: $duration, isArrived: $isArrived)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnimationFrameImpl &&
            (identical(other.index, index) || other.index == index) &&
            (identical(other.dot, dot) || other.dot == dot) &&
            (identical(other.nextDot, nextDot) || other.nextDot == nextDot) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.distanceKm, distanceKm) ||
                other.distanceKm == distanceKm) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.isArrived, isArrived) ||
                other.isArrived == isArrived));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    index,
    dot,
    nextDot,
    latitude,
    longitude,
    state,
    distanceKm,
    duration,
    isArrived,
  );

  /// Create a copy of AnimationFrame
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnimationFrameImplCopyWith<_$AnimationFrameImpl> get copyWith =>
      __$$AnimationFrameImplCopyWithImpl<_$AnimationFrameImpl>(
        this,
        _$identity,
      );
}

abstract class _AnimationFrame implements AnimationFrame {
  const factory _AnimationFrame({
    required final int index,
    required final Dot dot,
    final Dot? nextDot,
    required final double latitude,
    required final double longitude,
    required final CharacterState state,
    required final double distanceKm,
    required final Duration duration,
    final bool isArrived,
  }) = _$AnimationFrameImpl;

  @override
  int get index; // 현재 dot 인덱스
  @override
  Dot get dot; // 현재 dot
  @override
  Dot? get nextDot; // 다음 dot (null이면 마지막)
  @override
  double get latitude; // 현재 보간된 위도
  @override
  double get longitude; // 현재 보간된 경도
  @override
  CharacterState get state;
  @override
  double get distanceKm; // 다음 dot까지 거리
  @override
  Duration get duration; // 다음 dot까지 실제 경과 시간
  @override
  bool get isArrived;

  /// Create a copy of AnimationFrame
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnimationFrameImplCopyWith<_$AnimationFrameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AnimationSequence {
  List<AnimationFrame> get frames => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime get endTime => throw _privateConstructorUsedError;
  double get totalDurationMs => throw _privateConstructorUsedError;

  /// Create a copy of AnimationSequence
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnimationSequenceCopyWith<AnimationSequence> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnimationSequenceCopyWith<$Res> {
  factory $AnimationSequenceCopyWith(
    AnimationSequence value,
    $Res Function(AnimationSequence) then,
  ) = _$AnimationSequenceCopyWithImpl<$Res, AnimationSequence>;
  @useResult
  $Res call({
    List<AnimationFrame> frames,
    DateTime startTime,
    DateTime endTime,
    double totalDurationMs,
  });
}

/// @nodoc
class _$AnimationSequenceCopyWithImpl<$Res, $Val extends AnimationSequence>
    implements $AnimationSequenceCopyWith<$Res> {
  _$AnimationSequenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnimationSequence
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frames = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? totalDurationMs = null,
  }) {
    return _then(
      _value.copyWith(
            frames: null == frames
                ? _value.frames
                : frames // ignore: cast_nullable_to_non_nullable
                      as List<AnimationFrame>,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            totalDurationMs: null == totalDurationMs
                ? _value.totalDurationMs
                : totalDurationMs // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AnimationSequenceImplCopyWith<$Res>
    implements $AnimationSequenceCopyWith<$Res> {
  factory _$$AnimationSequenceImplCopyWith(
    _$AnimationSequenceImpl value,
    $Res Function(_$AnimationSequenceImpl) then,
  ) = __$$AnimationSequenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<AnimationFrame> frames,
    DateTime startTime,
    DateTime endTime,
    double totalDurationMs,
  });
}

/// @nodoc
class __$$AnimationSequenceImplCopyWithImpl<$Res>
    extends _$AnimationSequenceCopyWithImpl<$Res, _$AnimationSequenceImpl>
    implements _$$AnimationSequenceImplCopyWith<$Res> {
  __$$AnimationSequenceImplCopyWithImpl(
    _$AnimationSequenceImpl _value,
    $Res Function(_$AnimationSequenceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AnimationSequence
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? frames = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? totalDurationMs = null,
  }) {
    return _then(
      _$AnimationSequenceImpl(
        frames: null == frames
            ? _value._frames
            : frames // ignore: cast_nullable_to_non_nullable
                  as List<AnimationFrame>,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        totalDurationMs: null == totalDurationMs
            ? _value.totalDurationMs
            : totalDurationMs // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$AnimationSequenceImpl implements _AnimationSequence {
  const _$AnimationSequenceImpl({
    required final List<AnimationFrame> frames,
    required this.startTime,
    required this.endTime,
    required this.totalDurationMs,
  }) : _frames = frames;

  final List<AnimationFrame> _frames;
  @override
  List<AnimationFrame> get frames {
    if (_frames is EqualUnmodifiableListView) return _frames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_frames);
  }

  @override
  final DateTime startTime;
  @override
  final DateTime endTime;
  @override
  final double totalDurationMs;

  @override
  String toString() {
    return 'AnimationSequence(frames: $frames, startTime: $startTime, endTime: $endTime, totalDurationMs: $totalDurationMs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnimationSequenceImpl &&
            const DeepCollectionEquality().equals(other._frames, _frames) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.totalDurationMs, totalDurationMs) ||
                other.totalDurationMs == totalDurationMs));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_frames),
    startTime,
    endTime,
    totalDurationMs,
  );

  /// Create a copy of AnimationSequence
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnimationSequenceImplCopyWith<_$AnimationSequenceImpl> get copyWith =>
      __$$AnimationSequenceImplCopyWithImpl<_$AnimationSequenceImpl>(
        this,
        _$identity,
      );
}

abstract class _AnimationSequence implements AnimationSequence {
  const factory _AnimationSequence({
    required final List<AnimationFrame> frames,
    required final DateTime startTime,
    required final DateTime endTime,
    required final double totalDurationMs,
  }) = _$AnimationSequenceImpl;

  @override
  List<AnimationFrame> get frames;
  @override
  DateTime get startTime;
  @override
  DateTime get endTime;
  @override
  double get totalDurationMs;

  /// Create a copy of AnimationSequence
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnimationSequenceImplCopyWith<_$AnimationSequenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
