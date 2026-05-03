// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animation_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AnimationState {
  AnimationSequence get sequence => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError; // 0.0 ~ 1.0
  bool get isPlaying => throw _privateConstructorUsedError;
  PlaySpeed get speed => throw _privateConstructorUsedError;
  int get currentFrameIndex => throw _privateConstructorUsedError;
  bool get showPopup => throw _privateConstructorUsedError;
  Dot? get popupDot => throw _privateConstructorUsedError;

  /// Create a copy of AnimationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnimationStateCopyWith<AnimationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnimationStateCopyWith<$Res> {
  factory $AnimationStateCopyWith(
    AnimationState value,
    $Res Function(AnimationState) then,
  ) = _$AnimationStateCopyWithImpl<$Res, AnimationState>;
  @useResult
  $Res call({
    AnimationSequence sequence,
    double progress,
    bool isPlaying,
    PlaySpeed speed,
    int currentFrameIndex,
    bool showPopup,
    Dot? popupDot,
  });

  $AnimationSequenceCopyWith<$Res> get sequence;
  $DotCopyWith<$Res>? get popupDot;
}

/// @nodoc
class _$AnimationStateCopyWithImpl<$Res, $Val extends AnimationState>
    implements $AnimationStateCopyWith<$Res> {
  _$AnimationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnimationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sequence = null,
    Object? progress = null,
    Object? isPlaying = null,
    Object? speed = null,
    Object? currentFrameIndex = null,
    Object? showPopup = null,
    Object? popupDot = freezed,
  }) {
    return _then(
      _value.copyWith(
            sequence: null == sequence
                ? _value.sequence
                : sequence // ignore: cast_nullable_to_non_nullable
                      as AnimationSequence,
            progress: null == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as double,
            isPlaying: null == isPlaying
                ? _value.isPlaying
                : isPlaying // ignore: cast_nullable_to_non_nullable
                      as bool,
            speed: null == speed
                ? _value.speed
                : speed // ignore: cast_nullable_to_non_nullable
                      as PlaySpeed,
            currentFrameIndex: null == currentFrameIndex
                ? _value.currentFrameIndex
                : currentFrameIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            showPopup: null == showPopup
                ? _value.showPopup
                : showPopup // ignore: cast_nullable_to_non_nullable
                      as bool,
            popupDot: freezed == popupDot
                ? _value.popupDot
                : popupDot // ignore: cast_nullable_to_non_nullable
                      as Dot?,
          )
          as $Val,
    );
  }

  /// Create a copy of AnimationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AnimationSequenceCopyWith<$Res> get sequence {
    return $AnimationSequenceCopyWith<$Res>(_value.sequence, (value) {
      return _then(_value.copyWith(sequence: value) as $Val);
    });
  }

  /// Create a copy of AnimationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DotCopyWith<$Res>? get popupDot {
    if (_value.popupDot == null) {
      return null;
    }

    return $DotCopyWith<$Res>(_value.popupDot!, (value) {
      return _then(_value.copyWith(popupDot: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AnimationStateImplCopyWith<$Res>
    implements $AnimationStateCopyWith<$Res> {
  factory _$$AnimationStateImplCopyWith(
    _$AnimationStateImpl value,
    $Res Function(_$AnimationStateImpl) then,
  ) = __$$AnimationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    AnimationSequence sequence,
    double progress,
    bool isPlaying,
    PlaySpeed speed,
    int currentFrameIndex,
    bool showPopup,
    Dot? popupDot,
  });

  @override
  $AnimationSequenceCopyWith<$Res> get sequence;
  @override
  $DotCopyWith<$Res>? get popupDot;
}

/// @nodoc
class __$$AnimationStateImplCopyWithImpl<$Res>
    extends _$AnimationStateCopyWithImpl<$Res, _$AnimationStateImpl>
    implements _$$AnimationStateImplCopyWith<$Res> {
  __$$AnimationStateImplCopyWithImpl(
    _$AnimationStateImpl _value,
    $Res Function(_$AnimationStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AnimationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sequence = null,
    Object? progress = null,
    Object? isPlaying = null,
    Object? speed = null,
    Object? currentFrameIndex = null,
    Object? showPopup = null,
    Object? popupDot = freezed,
  }) {
    return _then(
      _$AnimationStateImpl(
        sequence: null == sequence
            ? _value.sequence
            : sequence // ignore: cast_nullable_to_non_nullable
                  as AnimationSequence,
        progress: null == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as double,
        isPlaying: null == isPlaying
            ? _value.isPlaying
            : isPlaying // ignore: cast_nullable_to_non_nullable
                  as bool,
        speed: null == speed
            ? _value.speed
            : speed // ignore: cast_nullable_to_non_nullable
                  as PlaySpeed,
        currentFrameIndex: null == currentFrameIndex
            ? _value.currentFrameIndex
            : currentFrameIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        showPopup: null == showPopup
            ? _value.showPopup
            : showPopup // ignore: cast_nullable_to_non_nullable
                  as bool,
        popupDot: freezed == popupDot
            ? _value.popupDot
            : popupDot // ignore: cast_nullable_to_non_nullable
                  as Dot?,
      ),
    );
  }
}

/// @nodoc

class _$AnimationStateImpl implements _AnimationState {
  const _$AnimationStateImpl({
    required this.sequence,
    this.progress = 0.0,
    this.isPlaying = false,
    this.speed = PlaySpeed.x1,
    this.currentFrameIndex = 0,
    this.showPopup = false,
    this.popupDot,
  });

  @override
  final AnimationSequence sequence;
  @override
  @JsonKey()
  final double progress;
  // 0.0 ~ 1.0
  @override
  @JsonKey()
  final bool isPlaying;
  @override
  @JsonKey()
  final PlaySpeed speed;
  @override
  @JsonKey()
  final int currentFrameIndex;
  @override
  @JsonKey()
  final bool showPopup;
  @override
  final Dot? popupDot;

  @override
  String toString() {
    return 'AnimationState(sequence: $sequence, progress: $progress, isPlaying: $isPlaying, speed: $speed, currentFrameIndex: $currentFrameIndex, showPopup: $showPopup, popupDot: $popupDot)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnimationStateImpl &&
            (identical(other.sequence, sequence) ||
                other.sequence == sequence) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.isPlaying, isPlaying) ||
                other.isPlaying == isPlaying) &&
            (identical(other.speed, speed) || other.speed == speed) &&
            (identical(other.currentFrameIndex, currentFrameIndex) ||
                other.currentFrameIndex == currentFrameIndex) &&
            (identical(other.showPopup, showPopup) ||
                other.showPopup == showPopup) &&
            (identical(other.popupDot, popupDot) ||
                other.popupDot == popupDot));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    sequence,
    progress,
    isPlaying,
    speed,
    currentFrameIndex,
    showPopup,
    popupDot,
  );

  /// Create a copy of AnimationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnimationStateImplCopyWith<_$AnimationStateImpl> get copyWith =>
      __$$AnimationStateImplCopyWithImpl<_$AnimationStateImpl>(
        this,
        _$identity,
      );
}

abstract class _AnimationState implements AnimationState {
  const factory _AnimationState({
    required final AnimationSequence sequence,
    final double progress,
    final bool isPlaying,
    final PlaySpeed speed,
    final int currentFrameIndex,
    final bool showPopup,
    final Dot? popupDot,
  }) = _$AnimationStateImpl;

  @override
  AnimationSequence get sequence;
  @override
  double get progress; // 0.0 ~ 1.0
  @override
  bool get isPlaying;
  @override
  PlaySpeed get speed;
  @override
  int get currentFrameIndex;
  @override
  bool get showPopup;
  @override
  Dot? get popupDot;

  /// Create a copy of AnimationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnimationStateImplCopyWith<_$AnimationStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
