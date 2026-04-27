// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recording_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$RecordingSession {
  String get dayLogId => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  List<Dot> get dots => throw _privateConstructorUsedError;
  bool get isCapturingLocation => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of RecordingSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RecordingSessionCopyWith<RecordingSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecordingSessionCopyWith<$Res> {
  factory $RecordingSessionCopyWith(
    RecordingSession value,
    $Res Function(RecordingSession) then,
  ) = _$RecordingSessionCopyWithImpl<$Res, RecordingSession>;
  @useResult
  $Res call({
    String dayLogId,
    DateTime startedAt,
    List<Dot> dots,
    bool isCapturingLocation,
    String? error,
  });
}

/// @nodoc
class _$RecordingSessionCopyWithImpl<$Res, $Val extends RecordingSession>
    implements $RecordingSessionCopyWith<$Res> {
  _$RecordingSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RecordingSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dayLogId = null,
    Object? startedAt = null,
    Object? dots = null,
    Object? isCapturingLocation = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            dayLogId: null == dayLogId
                ? _value.dayLogId
                : dayLogId // ignore: cast_nullable_to_non_nullable
                      as String,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            dots: null == dots
                ? _value.dots
                : dots // ignore: cast_nullable_to_non_nullable
                      as List<Dot>,
            isCapturingLocation: null == isCapturingLocation
                ? _value.isCapturingLocation
                : isCapturingLocation // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RecordingSessionImplCopyWith<$Res>
    implements $RecordingSessionCopyWith<$Res> {
  factory _$$RecordingSessionImplCopyWith(
    _$RecordingSessionImpl value,
    $Res Function(_$RecordingSessionImpl) then,
  ) = __$$RecordingSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String dayLogId,
    DateTime startedAt,
    List<Dot> dots,
    bool isCapturingLocation,
    String? error,
  });
}

/// @nodoc
class __$$RecordingSessionImplCopyWithImpl<$Res>
    extends _$RecordingSessionCopyWithImpl<$Res, _$RecordingSessionImpl>
    implements _$$RecordingSessionImplCopyWith<$Res> {
  __$$RecordingSessionImplCopyWithImpl(
    _$RecordingSessionImpl _value,
    $Res Function(_$RecordingSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RecordingSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dayLogId = null,
    Object? startedAt = null,
    Object? dots = null,
    Object? isCapturingLocation = null,
    Object? error = freezed,
  }) {
    return _then(
      _$RecordingSessionImpl(
        dayLogId: null == dayLogId
            ? _value.dayLogId
            : dayLogId // ignore: cast_nullable_to_non_nullable
                  as String,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        dots: null == dots
            ? _value._dots
            : dots // ignore: cast_nullable_to_non_nullable
                  as List<Dot>,
        isCapturingLocation: null == isCapturingLocation
            ? _value.isCapturingLocation
            : isCapturingLocation // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$RecordingSessionImpl implements _RecordingSession {
  const _$RecordingSessionImpl({
    required this.dayLogId,
    required this.startedAt,
    final List<Dot> dots = const [],
    this.isCapturingLocation = false,
    this.error,
  }) : _dots = dots;

  @override
  final String dayLogId;
  @override
  final DateTime startedAt;
  final List<Dot> _dots;
  @override
  @JsonKey()
  List<Dot> get dots {
    if (_dots is EqualUnmodifiableListView) return _dots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dots);
  }

  @override
  @JsonKey()
  final bool isCapturingLocation;
  @override
  final String? error;

  @override
  String toString() {
    return 'RecordingSession(dayLogId: $dayLogId, startedAt: $startedAt, dots: $dots, isCapturingLocation: $isCapturingLocation, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RecordingSessionImpl &&
            (identical(other.dayLogId, dayLogId) ||
                other.dayLogId == dayLogId) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            const DeepCollectionEquality().equals(other._dots, _dots) &&
            (identical(other.isCapturingLocation, isCapturingLocation) ||
                other.isCapturingLocation == isCapturingLocation) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    dayLogId,
    startedAt,
    const DeepCollectionEquality().hash(_dots),
    isCapturingLocation,
    error,
  );

  /// Create a copy of RecordingSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RecordingSessionImplCopyWith<_$RecordingSessionImpl> get copyWith =>
      __$$RecordingSessionImplCopyWithImpl<_$RecordingSessionImpl>(
        this,
        _$identity,
      );
}

abstract class _RecordingSession implements RecordingSession {
  const factory _RecordingSession({
    required final String dayLogId,
    required final DateTime startedAt,
    final List<Dot> dots,
    final bool isCapturingLocation,
    final String? error,
  }) = _$RecordingSessionImpl;

  @override
  String get dayLogId;
  @override
  DateTime get startedAt;
  @override
  List<Dot> get dots;
  @override
  bool get isCapturingLocation;
  @override
  String? get error;

  /// Create a copy of RecordingSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RecordingSessionImplCopyWith<_$RecordingSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
