// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'starred_place.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StarredPlace _$StarredPlaceFromJson(Map<String, dynamic> json) {
  return _StarredPlace.fromJson(json);
}

/// @nodoc
mixin _$StarredPlace {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'starred_at')
  DateTime get starredAt => throw _privateConstructorUsedError;

  /// 현재 유저와 다른 룸 멤버가 같은 장소를 함께 방문한 첫 번째 시점.
  @JsonKey(name: 'first_together')
  DateTime? get firstTogether => throw _privateConstructorUsedError;

  /// Serializes this StarredPlace to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StarredPlace
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StarredPlaceCopyWith<StarredPlace> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StarredPlaceCopyWith<$Res> {
  factory $StarredPlaceCopyWith(
    StarredPlace value,
    $Res Function(StarredPlace) then,
  ) = _$StarredPlaceCopyWithImpl<$Res, StarredPlace>;
  @useResult
  $Res call({
    String id,
    String name,
    double latitude,
    double longitude,
    @JsonKey(name: 'starred_at') DateTime starredAt,
    @JsonKey(name: 'first_together') DateTime? firstTogether,
  });
}

/// @nodoc
class _$StarredPlaceCopyWithImpl<$Res, $Val extends StarredPlace>
    implements $StarredPlaceCopyWith<$Res> {
  _$StarredPlaceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StarredPlace
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? starredAt = null,
    Object? firstTogether = freezed,
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
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            starredAt: null == starredAt
                ? _value.starredAt
                : starredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            firstTogether: freezed == firstTogether
                ? _value.firstTogether
                : firstTogether // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StarredPlaceImplCopyWith<$Res>
    implements $StarredPlaceCopyWith<$Res> {
  factory _$$StarredPlaceImplCopyWith(
    _$StarredPlaceImpl value,
    $Res Function(_$StarredPlaceImpl) then,
  ) = __$$StarredPlaceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    double latitude,
    double longitude,
    @JsonKey(name: 'starred_at') DateTime starredAt,
    @JsonKey(name: 'first_together') DateTime? firstTogether,
  });
}

/// @nodoc
class __$$StarredPlaceImplCopyWithImpl<$Res>
    extends _$StarredPlaceCopyWithImpl<$Res, _$StarredPlaceImpl>
    implements _$$StarredPlaceImplCopyWith<$Res> {
  __$$StarredPlaceImplCopyWithImpl(
    _$StarredPlaceImpl _value,
    $Res Function(_$StarredPlaceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StarredPlace
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? starredAt = null,
    Object? firstTogether = freezed,
  }) {
    return _then(
      _$StarredPlaceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        starredAt: null == starredAt
            ? _value.starredAt
            : starredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        firstTogether: freezed == firstTogether
            ? _value.firstTogether
            : firstTogether // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StarredPlaceImpl implements _StarredPlace {
  const _$StarredPlaceImpl({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    @JsonKey(name: 'starred_at') required this.starredAt,
    @JsonKey(name: 'first_together') this.firstTogether,
  });

  factory _$StarredPlaceImpl.fromJson(Map<String, dynamic> json) =>
      _$$StarredPlaceImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  @JsonKey(name: 'starred_at')
  final DateTime starredAt;

  /// 현재 유저와 다른 룸 멤버가 같은 장소를 함께 방문한 첫 번째 시점.
  @override
  @JsonKey(name: 'first_together')
  final DateTime? firstTogether;

  @override
  String toString() {
    return 'StarredPlace(id: $id, name: $name, latitude: $latitude, longitude: $longitude, starredAt: $starredAt, firstTogether: $firstTogether)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StarredPlaceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.starredAt, starredAt) ||
                other.starredAt == starredAt) &&
            (identical(other.firstTogether, firstTogether) ||
                other.firstTogether == firstTogether));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    latitude,
    longitude,
    starredAt,
    firstTogether,
  );

  /// Create a copy of StarredPlace
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StarredPlaceImplCopyWith<_$StarredPlaceImpl> get copyWith =>
      __$$StarredPlaceImplCopyWithImpl<_$StarredPlaceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StarredPlaceImplToJson(this);
  }
}

abstract class _StarredPlace implements StarredPlace {
  const factory _StarredPlace({
    required final String id,
    required final String name,
    required final double latitude,
    required final double longitude,
    @JsonKey(name: 'starred_at') required final DateTime starredAt,
    @JsonKey(name: 'first_together') final DateTime? firstTogether,
  }) = _$StarredPlaceImpl;

  factory _StarredPlace.fromJson(Map<String, dynamic> json) =
      _$StarredPlaceImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  @JsonKey(name: 'starred_at')
  DateTime get starredAt;

  /// 현재 유저와 다른 룸 멤버가 같은 장소를 함께 방문한 첫 번째 시점.
  @override
  @JsonKey(name: 'first_together')
  DateTime? get firstTogether;

  /// Create a copy of StarredPlace
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StarredPlaceImplCopyWith<_$StarredPlaceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
