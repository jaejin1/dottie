// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'day_log_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DayLog _$DayLogFromJson(Map<String, dynamic> json) {
  return _DayLog.fromJson(json);
}

/// @nodoc
mixin _$DayLog {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  List<Dot> get dots => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get endedAt => throw _privateConstructorUsedError;
  double? get totalDistanceKm => throw _privateConstructorUsedError;
  int? get placeCount => throw _privateConstructorUsedError;
  bool get isRecording => throw _privateConstructorUsedError;
  bool get synced => throw _privateConstructorUsedError;

  /// Serializes this DayLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DayLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DayLogCopyWith<DayLog> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DayLogCopyWith<$Res> {
  factory $DayLogCopyWith(DayLog value, $Res Function(DayLog) then) =
      _$DayLogCopyWithImpl<$Res, DayLog>;
  @useResult
  $Res call({
    String id,
    String userId,
    DateTime date,
    List<Dot> dots,
    DateTime startedAt,
    DateTime? endedAt,
    double? totalDistanceKm,
    int? placeCount,
    bool isRecording,
    bool synced,
  });
}

/// @nodoc
class _$DayLogCopyWithImpl<$Res, $Val extends DayLog>
    implements $DayLogCopyWith<$Res> {
  _$DayLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DayLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? dots = null,
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? totalDistanceKm = freezed,
    Object? placeCount = freezed,
    Object? isRecording = null,
    Object? synced = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            dots: null == dots
                ? _value.dots
                : dots // ignore: cast_nullable_to_non_nullable
                      as List<Dot>,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endedAt: freezed == endedAt
                ? _value.endedAt
                : endedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            totalDistanceKm: freezed == totalDistanceKm
                ? _value.totalDistanceKm
                : totalDistanceKm // ignore: cast_nullable_to_non_nullable
                      as double?,
            placeCount: freezed == placeCount
                ? _value.placeCount
                : placeCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            isRecording: null == isRecording
                ? _value.isRecording
                : isRecording // ignore: cast_nullable_to_non_nullable
                      as bool,
            synced: null == synced
                ? _value.synced
                : synced // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DayLogImplCopyWith<$Res> implements $DayLogCopyWith<$Res> {
  factory _$$DayLogImplCopyWith(
    _$DayLogImpl value,
    $Res Function(_$DayLogImpl) then,
  ) = __$$DayLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    DateTime date,
    List<Dot> dots,
    DateTime startedAt,
    DateTime? endedAt,
    double? totalDistanceKm,
    int? placeCount,
    bool isRecording,
    bool synced,
  });
}

/// @nodoc
class __$$DayLogImplCopyWithImpl<$Res>
    extends _$DayLogCopyWithImpl<$Res, _$DayLogImpl>
    implements _$$DayLogImplCopyWith<$Res> {
  __$$DayLogImplCopyWithImpl(
    _$DayLogImpl _value,
    $Res Function(_$DayLogImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DayLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? dots = null,
    Object? startedAt = null,
    Object? endedAt = freezed,
    Object? totalDistanceKm = freezed,
    Object? placeCount = freezed,
    Object? isRecording = null,
    Object? synced = null,
  }) {
    return _then(
      _$DayLogImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        dots: null == dots
            ? _value._dots
            : dots // ignore: cast_nullable_to_non_nullable
                  as List<Dot>,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endedAt: freezed == endedAt
            ? _value.endedAt
            : endedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        totalDistanceKm: freezed == totalDistanceKm
            ? _value.totalDistanceKm
            : totalDistanceKm // ignore: cast_nullable_to_non_nullable
                  as double?,
        placeCount: freezed == placeCount
            ? _value.placeCount
            : placeCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        isRecording: null == isRecording
            ? _value.isRecording
            : isRecording // ignore: cast_nullable_to_non_nullable
                  as bool,
        synced: null == synced
            ? _value.synced
            : synced // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DayLogImpl implements _DayLog {
  const _$DayLogImpl({
    required this.id,
    required this.userId,
    required this.date,
    final List<Dot> dots = const [],
    required this.startedAt,
    this.endedAt,
    this.totalDistanceKm,
    this.placeCount,
    this.isRecording = false,
    this.synced = false,
  }) : _dots = dots;

  factory _$DayLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$DayLogImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final DateTime date;
  final List<Dot> _dots;
  @override
  @JsonKey()
  List<Dot> get dots {
    if (_dots is EqualUnmodifiableListView) return _dots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dots);
  }

  @override
  final DateTime startedAt;
  @override
  final DateTime? endedAt;
  @override
  final double? totalDistanceKm;
  @override
  final int? placeCount;
  @override
  @JsonKey()
  final bool isRecording;
  @override
  @JsonKey()
  final bool synced;

  @override
  String toString() {
    return 'DayLog(id: $id, userId: $userId, date: $date, dots: $dots, startedAt: $startedAt, endedAt: $endedAt, totalDistanceKm: $totalDistanceKm, placeCount: $placeCount, isRecording: $isRecording, synced: $synced)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DayLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(other._dots, _dots) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.totalDistanceKm, totalDistanceKm) ||
                other.totalDistanceKm == totalDistanceKm) &&
            (identical(other.placeCount, placeCount) ||
                other.placeCount == placeCount) &&
            (identical(other.isRecording, isRecording) ||
                other.isRecording == isRecording) &&
            (identical(other.synced, synced) || other.synced == synced));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    date,
    const DeepCollectionEquality().hash(_dots),
    startedAt,
    endedAt,
    totalDistanceKm,
    placeCount,
    isRecording,
    synced,
  );

  /// Create a copy of DayLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DayLogImplCopyWith<_$DayLogImpl> get copyWith =>
      __$$DayLogImplCopyWithImpl<_$DayLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DayLogImplToJson(this);
  }
}

abstract class _DayLog implements DayLog {
  const factory _DayLog({
    required final String id,
    required final String userId,
    required final DateTime date,
    final List<Dot> dots,
    required final DateTime startedAt,
    final DateTime? endedAt,
    final double? totalDistanceKm,
    final int? placeCount,
    final bool isRecording,
    final bool synced,
  }) = _$DayLogImpl;

  factory _DayLog.fromJson(Map<String, dynamic> json) = _$DayLogImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  DateTime get date;
  @override
  List<Dot> get dots;
  @override
  DateTime get startedAt;
  @override
  DateTime? get endedAt;
  @override
  double? get totalDistanceKm;
  @override
  int? get placeCount;
  @override
  bool get isRecording;
  @override
  bool get synced;

  /// Create a copy of DayLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DayLogImplCopyWith<_$DayLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
