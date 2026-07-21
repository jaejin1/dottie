// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PlaceGroup {
  String get id => throw _privateConstructorUsedError;
  List<RoomDot> get dots =>
      throw _privateConstructorUsedError; // timestamp DESC
  double get centerLat => throw _privateConstructorUsedError;
  double get centerLng => throw _privateConstructorUsedError;
  Set<String> get memberIds => throw _privateConstructorUsedError;
  String get placeName => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  DateTime get firstVisitedAt => throw _privateConstructorUsedError;

  /// 방문 수 — BE 가 정확히 카운트한 값(BE places 그룹) 또는 dots.length (orphan).
  int get visitCount => throw _privateConstructorUsedError;

  /// 룸 모든 멤버가 이 장소를 함께 방문했는가.
  bool get isFirstTogether => throw _privateConstructorUsedError;

  /// Create a copy of PlaceGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaceGroupCopyWith<PlaceGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaceGroupCopyWith<$Res> {
  factory $PlaceGroupCopyWith(
    PlaceGroup value,
    $Res Function(PlaceGroup) then,
  ) = _$PlaceGroupCopyWithImpl<$Res, PlaceGroup>;
  @useResult
  $Res call({
    String id,
    List<RoomDot> dots,
    double centerLat,
    double centerLng,
    Set<String> memberIds,
    String placeName,
    String? category,
    DateTime firstVisitedAt,
    int visitCount,
    bool isFirstTogether,
  });
}

/// @nodoc
class _$PlaceGroupCopyWithImpl<$Res, $Val extends PlaceGroup>
    implements $PlaceGroupCopyWith<$Res> {
  _$PlaceGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlaceGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dots = null,
    Object? centerLat = null,
    Object? centerLng = null,
    Object? memberIds = null,
    Object? placeName = null,
    Object? category = freezed,
    Object? firstVisitedAt = null,
    Object? visitCount = null,
    Object? isFirstTogether = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            dots: null == dots
                ? _value.dots
                : dots // ignore: cast_nullable_to_non_nullable
                      as List<RoomDot>,
            centerLat: null == centerLat
                ? _value.centerLat
                : centerLat // ignore: cast_nullable_to_non_nullable
                      as double,
            centerLng: null == centerLng
                ? _value.centerLng
                : centerLng // ignore: cast_nullable_to_non_nullable
                      as double,
            memberIds: null == memberIds
                ? _value.memberIds
                : memberIds // ignore: cast_nullable_to_non_nullable
                      as Set<String>,
            placeName: null == placeName
                ? _value.placeName
                : placeName // ignore: cast_nullable_to_non_nullable
                      as String,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            firstVisitedAt: null == firstVisitedAt
                ? _value.firstVisitedAt
                : firstVisitedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            visitCount: null == visitCount
                ? _value.visitCount
                : visitCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isFirstTogether: null == isFirstTogether
                ? _value.isFirstTogether
                : isFirstTogether // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlaceGroupImplCopyWith<$Res>
    implements $PlaceGroupCopyWith<$Res> {
  factory _$$PlaceGroupImplCopyWith(
    _$PlaceGroupImpl value,
    $Res Function(_$PlaceGroupImpl) then,
  ) = __$$PlaceGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    List<RoomDot> dots,
    double centerLat,
    double centerLng,
    Set<String> memberIds,
    String placeName,
    String? category,
    DateTime firstVisitedAt,
    int visitCount,
    bool isFirstTogether,
  });
}

/// @nodoc
class __$$PlaceGroupImplCopyWithImpl<$Res>
    extends _$PlaceGroupCopyWithImpl<$Res, _$PlaceGroupImpl>
    implements _$$PlaceGroupImplCopyWith<$Res> {
  __$$PlaceGroupImplCopyWithImpl(
    _$PlaceGroupImpl _value,
    $Res Function(_$PlaceGroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlaceGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? dots = null,
    Object? centerLat = null,
    Object? centerLng = null,
    Object? memberIds = null,
    Object? placeName = null,
    Object? category = freezed,
    Object? firstVisitedAt = null,
    Object? visitCount = null,
    Object? isFirstTogether = null,
  }) {
    return _then(
      _$PlaceGroupImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        dots: null == dots
            ? _value._dots
            : dots // ignore: cast_nullable_to_non_nullable
                  as List<RoomDot>,
        centerLat: null == centerLat
            ? _value.centerLat
            : centerLat // ignore: cast_nullable_to_non_nullable
                  as double,
        centerLng: null == centerLng
            ? _value.centerLng
            : centerLng // ignore: cast_nullable_to_non_nullable
                  as double,
        memberIds: null == memberIds
            ? _value._memberIds
            : memberIds // ignore: cast_nullable_to_non_nullable
                  as Set<String>,
        placeName: null == placeName
            ? _value.placeName
            : placeName // ignore: cast_nullable_to_non_nullable
                  as String,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        firstVisitedAt: null == firstVisitedAt
            ? _value.firstVisitedAt
            : firstVisitedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        visitCount: null == visitCount
            ? _value.visitCount
            : visitCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isFirstTogether: null == isFirstTogether
            ? _value.isFirstTogether
            : isFirstTogether // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$PlaceGroupImpl implements _PlaceGroup {
  const _$PlaceGroupImpl({
    required this.id,
    required final List<RoomDot> dots,
    required this.centerLat,
    required this.centerLng,
    required final Set<String> memberIds,
    required this.placeName,
    this.category,
    required this.firstVisitedAt,
    required this.visitCount,
    this.isFirstTogether = false,
  }) : _dots = dots,
       _memberIds = memberIds;

  @override
  final String id;
  final List<RoomDot> _dots;
  @override
  List<RoomDot> get dots {
    if (_dots is EqualUnmodifiableListView) return _dots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dots);
  }

  // timestamp DESC
  @override
  final double centerLat;
  @override
  final double centerLng;
  final Set<String> _memberIds;
  @override
  Set<String> get memberIds {
    if (_memberIds is EqualUnmodifiableSetView) return _memberIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_memberIds);
  }

  @override
  final String placeName;
  @override
  final String? category;
  @override
  final DateTime firstVisitedAt;

  /// 방문 수 — BE 가 정확히 카운트한 값(BE places 그룹) 또는 dots.length (orphan).
  @override
  final int visitCount;

  /// 룸 모든 멤버가 이 장소를 함께 방문했는가.
  @override
  @JsonKey()
  final bool isFirstTogether;

  @override
  String toString() {
    return 'PlaceGroup(id: $id, dots: $dots, centerLat: $centerLat, centerLng: $centerLng, memberIds: $memberIds, placeName: $placeName, category: $category, firstVisitedAt: $firstVisitedAt, visitCount: $visitCount, isFirstTogether: $isFirstTogether)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaceGroupImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._dots, _dots) &&
            (identical(other.centerLat, centerLat) ||
                other.centerLat == centerLat) &&
            (identical(other.centerLng, centerLng) ||
                other.centerLng == centerLng) &&
            const DeepCollectionEquality().equals(
              other._memberIds,
              _memberIds,
            ) &&
            (identical(other.placeName, placeName) ||
                other.placeName == placeName) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.firstVisitedAt, firstVisitedAt) ||
                other.firstVisitedAt == firstVisitedAt) &&
            (identical(other.visitCount, visitCount) ||
                other.visitCount == visitCount) &&
            (identical(other.isFirstTogether, isFirstTogether) ||
                other.isFirstTogether == isFirstTogether));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    const DeepCollectionEquality().hash(_dots),
    centerLat,
    centerLng,
    const DeepCollectionEquality().hash(_memberIds),
    placeName,
    category,
    firstVisitedAt,
    visitCount,
    isFirstTogether,
  );

  /// Create a copy of PlaceGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaceGroupImplCopyWith<_$PlaceGroupImpl> get copyWith =>
      __$$PlaceGroupImplCopyWithImpl<_$PlaceGroupImpl>(this, _$identity);
}

abstract class _PlaceGroup implements PlaceGroup {
  const factory _PlaceGroup({
    required final String id,
    required final List<RoomDot> dots,
    required final double centerLat,
    required final double centerLng,
    required final Set<String> memberIds,
    required final String placeName,
    final String? category,
    required final DateTime firstVisitedAt,
    required final int visitCount,
    final bool isFirstTogether,
  }) = _$PlaceGroupImpl;

  @override
  String get id;
  @override
  List<RoomDot> get dots; // timestamp DESC
  @override
  double get centerLat;
  @override
  double get centerLng;
  @override
  Set<String> get memberIds;
  @override
  String get placeName;
  @override
  String? get category;
  @override
  DateTime get firstVisitedAt;

  /// 방문 수 — BE 가 정확히 카운트한 값(BE places 그룹) 또는 dots.length (orphan).
  @override
  int get visitCount;

  /// 룸 모든 멤버가 이 장소를 함께 방문했는가.
  @override
  bool get isFirstTogether;

  /// Create a copy of PlaceGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaceGroupImplCopyWith<_$PlaceGroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
