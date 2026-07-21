// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Place _$PlaceFromJson(Map<String, dynamic> json) {
  return _Place.fromJson(json);
}

/// @nodoc
mixin _$Place {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_group_code')
  String? get categoryGroupCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'category_group_name')
  String? get categoryGroupName => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  @JsonKey(name: 'road_address')
  String? get roadAddress => throw _privateConstructorUsedError;
  String? get telephone => throw _privateConstructorUsedError;
  @JsonKey(name: 'place_url')
  String? get placeUrl => throw _privateConstructorUsedError;
  int? get distance => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;

  /// Serializes this Place to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaceCopyWith<Place> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaceCopyWith<$Res> {
  factory $PlaceCopyWith(Place value, $Res Function(Place) then) =
      _$PlaceCopyWithImpl<$Res, Place>;
  @useResult
  $Res call({
    String id,
    String name,
    String? category,
    @JsonKey(name: 'category_group_code') String? categoryGroupCode,
    @JsonKey(name: 'category_group_name') String? categoryGroupName,
    String? address,
    @JsonKey(name: 'road_address') String? roadAddress,
    String? telephone,
    @JsonKey(name: 'place_url') String? placeUrl,
    int? distance,
    double latitude,
    double longitude,
  });
}

/// @nodoc
class _$PlaceCopyWithImpl<$Res, $Val extends Place>
    implements $PlaceCopyWith<$Res> {
  _$PlaceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = freezed,
    Object? categoryGroupCode = freezed,
    Object? categoryGroupName = freezed,
    Object? address = freezed,
    Object? roadAddress = freezed,
    Object? telephone = freezed,
    Object? placeUrl = freezed,
    Object? distance = freezed,
    Object? latitude = null,
    Object? longitude = null,
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
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            categoryGroupCode: freezed == categoryGroupCode
                ? _value.categoryGroupCode
                : categoryGroupCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            categoryGroupName: freezed == categoryGroupName
                ? _value.categoryGroupName
                : categoryGroupName // ignore: cast_nullable_to_non_nullable
                      as String?,
            address: freezed == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String?,
            roadAddress: freezed == roadAddress
                ? _value.roadAddress
                : roadAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
            telephone: freezed == telephone
                ? _value.telephone
                : telephone // ignore: cast_nullable_to_non_nullable
                      as String?,
            placeUrl: freezed == placeUrl
                ? _value.placeUrl
                : placeUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            distance: freezed == distance
                ? _value.distance
                : distance // ignore: cast_nullable_to_non_nullable
                      as int?,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlaceImplCopyWith<$Res> implements $PlaceCopyWith<$Res> {
  factory _$$PlaceImplCopyWith(
    _$PlaceImpl value,
    $Res Function(_$PlaceImpl) then,
  ) = __$$PlaceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String? category,
    @JsonKey(name: 'category_group_code') String? categoryGroupCode,
    @JsonKey(name: 'category_group_name') String? categoryGroupName,
    String? address,
    @JsonKey(name: 'road_address') String? roadAddress,
    String? telephone,
    @JsonKey(name: 'place_url') String? placeUrl,
    int? distance,
    double latitude,
    double longitude,
  });
}

/// @nodoc
class __$$PlaceImplCopyWithImpl<$Res>
    extends _$PlaceCopyWithImpl<$Res, _$PlaceImpl>
    implements _$$PlaceImplCopyWith<$Res> {
  __$$PlaceImplCopyWithImpl(
    _$PlaceImpl _value,
    $Res Function(_$PlaceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = freezed,
    Object? categoryGroupCode = freezed,
    Object? categoryGroupName = freezed,
    Object? address = freezed,
    Object? roadAddress = freezed,
    Object? telephone = freezed,
    Object? placeUrl = freezed,
    Object? distance = freezed,
    Object? latitude = null,
    Object? longitude = null,
  }) {
    return _then(
      _$PlaceImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        categoryGroupCode: freezed == categoryGroupCode
            ? _value.categoryGroupCode
            : categoryGroupCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        categoryGroupName: freezed == categoryGroupName
            ? _value.categoryGroupName
            : categoryGroupName // ignore: cast_nullable_to_non_nullable
                  as String?,
        address: freezed == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String?,
        roadAddress: freezed == roadAddress
            ? _value.roadAddress
            : roadAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
        telephone: freezed == telephone
            ? _value.telephone
            : telephone // ignore: cast_nullable_to_non_nullable
                  as String?,
        placeUrl: freezed == placeUrl
            ? _value.placeUrl
            : placeUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        distance: freezed == distance
            ? _value.distance
            : distance // ignore: cast_nullable_to_non_nullable
                  as int?,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaceImpl implements _Place {
  const _$PlaceImpl({
    required this.id,
    required this.name,
    this.category,
    @JsonKey(name: 'category_group_code') this.categoryGroupCode,
    @JsonKey(name: 'category_group_name') this.categoryGroupName,
    this.address,
    @JsonKey(name: 'road_address') this.roadAddress,
    this.telephone,
    @JsonKey(name: 'place_url') this.placeUrl,
    this.distance,
    required this.latitude,
    required this.longitude,
  });

  factory _$PlaceImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaceImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? category;
  @override
  @JsonKey(name: 'category_group_code')
  final String? categoryGroupCode;
  @override
  @JsonKey(name: 'category_group_name')
  final String? categoryGroupName;
  @override
  final String? address;
  @override
  @JsonKey(name: 'road_address')
  final String? roadAddress;
  @override
  final String? telephone;
  @override
  @JsonKey(name: 'place_url')
  final String? placeUrl;
  @override
  final int? distance;
  @override
  final double latitude;
  @override
  final double longitude;

  @override
  String toString() {
    return 'Place(id: $id, name: $name, category: $category, categoryGroupCode: $categoryGroupCode, categoryGroupName: $categoryGroupName, address: $address, roadAddress: $roadAddress, telephone: $telephone, placeUrl: $placeUrl, distance: $distance, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaceImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.categoryGroupCode, categoryGroupCode) ||
                other.categoryGroupCode == categoryGroupCode) &&
            (identical(other.categoryGroupName, categoryGroupName) ||
                other.categoryGroupName == categoryGroupName) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.roadAddress, roadAddress) ||
                other.roadAddress == roadAddress) &&
            (identical(other.telephone, telephone) ||
                other.telephone == telephone) &&
            (identical(other.placeUrl, placeUrl) ||
                other.placeUrl == placeUrl) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    category,
    categoryGroupCode,
    categoryGroupName,
    address,
    roadAddress,
    telephone,
    placeUrl,
    distance,
    latitude,
    longitude,
  );

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaceImplCopyWith<_$PlaceImpl> get copyWith =>
      __$$PlaceImplCopyWithImpl<_$PlaceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaceImplToJson(this);
  }
}

abstract class _Place implements Place {
  const factory _Place({
    required final String id,
    required final String name,
    final String? category,
    @JsonKey(name: 'category_group_code') final String? categoryGroupCode,
    @JsonKey(name: 'category_group_name') final String? categoryGroupName,
    final String? address,
    @JsonKey(name: 'road_address') final String? roadAddress,
    final String? telephone,
    @JsonKey(name: 'place_url') final String? placeUrl,
    final int? distance,
    required final double latitude,
    required final double longitude,
  }) = _$PlaceImpl;

  factory _Place.fromJson(Map<String, dynamic> json) = _$PlaceImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get category;
  @override
  @JsonKey(name: 'category_group_code')
  String? get categoryGroupCode;
  @override
  @JsonKey(name: 'category_group_name')
  String? get categoryGroupName;
  @override
  String? get address;
  @override
  @JsonKey(name: 'road_address')
  String? get roadAddress;
  @override
  String? get telephone;
  @override
  @JsonKey(name: 'place_url')
  String? get placeUrl;
  @override
  int? get distance;
  @override
  double get latitude;
  @override
  double get longitude;

  /// Create a copy of Place
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaceImplCopyWith<_$PlaceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
