// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dot_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Dot _$DotFromJson(Map<String, dynamic> json) {
  return _Dot.fromJson(json);
}

/// @nodoc
mixin _$Dot {
  String get id => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get placeName => throw _privateConstructorUsedError;
  String? get placeCategory => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  String? get memo => throw _privateConstructorUsedError;
  String? get emotion => throw _privateConstructorUsedError;
  String get dayLogId => throw _privateConstructorUsedError;
  bool get synced => throw _privateConstructorUsedError;

  /// Serializes this Dot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Dot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DotCopyWith<Dot> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DotCopyWith<$Res> {
  factory $DotCopyWith(Dot value, $Res Function(Dot) then) =
      _$DotCopyWithImpl<$Res, Dot>;
  @useResult
  $Res call({
    String id,
    double latitude,
    double longitude,
    DateTime timestamp,
    String? placeName,
    String? placeCategory,
    String? photoUrl,
    String? memo,
    String? emotion,
    String dayLogId,
    bool synced,
  });
}

/// @nodoc
class _$DotCopyWithImpl<$Res, $Val extends Dot> implements $DotCopyWith<$Res> {
  _$DotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Dot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? timestamp = null,
    Object? placeName = freezed,
    Object? placeCategory = freezed,
    Object? photoUrl = freezed,
    Object? memo = freezed,
    Object? emotion = freezed,
    Object? dayLogId = null,
    Object? synced = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            placeName: freezed == placeName
                ? _value.placeName
                : placeName // ignore: cast_nullable_to_non_nullable
                      as String?,
            placeCategory: freezed == placeCategory
                ? _value.placeCategory
                : placeCategory // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            memo: freezed == memo
                ? _value.memo
                : memo // ignore: cast_nullable_to_non_nullable
                      as String?,
            emotion: freezed == emotion
                ? _value.emotion
                : emotion // ignore: cast_nullable_to_non_nullable
                      as String?,
            dayLogId: null == dayLogId
                ? _value.dayLogId
                : dayLogId // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$DotImplCopyWith<$Res> implements $DotCopyWith<$Res> {
  factory _$$DotImplCopyWith(_$DotImpl value, $Res Function(_$DotImpl) then) =
      __$$DotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    double latitude,
    double longitude,
    DateTime timestamp,
    String? placeName,
    String? placeCategory,
    String? photoUrl,
    String? memo,
    String? emotion,
    String dayLogId,
    bool synced,
  });
}

/// @nodoc
class __$$DotImplCopyWithImpl<$Res> extends _$DotCopyWithImpl<$Res, _$DotImpl>
    implements _$$DotImplCopyWith<$Res> {
  __$$DotImplCopyWithImpl(_$DotImpl _value, $Res Function(_$DotImpl) _then)
    : super(_value, _then);

  /// Create a copy of Dot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? timestamp = null,
    Object? placeName = freezed,
    Object? placeCategory = freezed,
    Object? photoUrl = freezed,
    Object? memo = freezed,
    Object? emotion = freezed,
    Object? dayLogId = null,
    Object? synced = null,
  }) {
    return _then(
      _$DotImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        placeName: freezed == placeName
            ? _value.placeName
            : placeName // ignore: cast_nullable_to_non_nullable
                  as String?,
        placeCategory: freezed == placeCategory
            ? _value.placeCategory
            : placeCategory // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        memo: freezed == memo
            ? _value.memo
            : memo // ignore: cast_nullable_to_non_nullable
                  as String?,
        emotion: freezed == emotion
            ? _value.emotion
            : emotion // ignore: cast_nullable_to_non_nullable
                  as String?,
        dayLogId: null == dayLogId
            ? _value.dayLogId
            : dayLogId // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$DotImpl implements _Dot {
  const _$DotImpl({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.placeName,
    this.placeCategory,
    this.photoUrl,
    this.memo,
    this.emotion,
    required this.dayLogId,
    this.synced = false,
  });

  factory _$DotImpl.fromJson(Map<String, dynamic> json) =>
      _$$DotImplFromJson(json);

  @override
  final String id;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final DateTime timestamp;
  @override
  final String? placeName;
  @override
  final String? placeCategory;
  @override
  final String? photoUrl;
  @override
  final String? memo;
  @override
  final String? emotion;
  @override
  final String dayLogId;
  @override
  @JsonKey()
  final bool synced;

  @override
  String toString() {
    return 'Dot(id: $id, latitude: $latitude, longitude: $longitude, timestamp: $timestamp, placeName: $placeName, placeCategory: $placeCategory, photoUrl: $photoUrl, memo: $memo, emotion: $emotion, dayLogId: $dayLogId, synced: $synced)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DotImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.placeName, placeName) ||
                other.placeName == placeName) &&
            (identical(other.placeCategory, placeCategory) ||
                other.placeCategory == placeCategory) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            (identical(other.emotion, emotion) || other.emotion == emotion) &&
            (identical(other.dayLogId, dayLogId) ||
                other.dayLogId == dayLogId) &&
            (identical(other.synced, synced) || other.synced == synced));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    latitude,
    longitude,
    timestamp,
    placeName,
    placeCategory,
    photoUrl,
    memo,
    emotion,
    dayLogId,
    synced,
  );

  /// Create a copy of Dot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DotImplCopyWith<_$DotImpl> get copyWith =>
      __$$DotImplCopyWithImpl<_$DotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DotImplToJson(this);
  }
}

abstract class _Dot implements Dot {
  const factory _Dot({
    required final String id,
    required final double latitude,
    required final double longitude,
    required final DateTime timestamp,
    final String? placeName,
    final String? placeCategory,
    final String? photoUrl,
    final String? memo,
    final String? emotion,
    required final String dayLogId,
    final bool synced,
  }) = _$DotImpl;

  factory _Dot.fromJson(Map<String, dynamic> json) = _$DotImpl.fromJson;

  @override
  String get id;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  DateTime get timestamp;
  @override
  String? get placeName;
  @override
  String? get placeCategory;
  @override
  String? get photoUrl;
  @override
  String? get memo;
  @override
  String? get emotion;
  @override
  String get dayLogId;
  @override
  bool get synced;

  /// Create a copy of Dot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DotImplCopyWith<_$DotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
