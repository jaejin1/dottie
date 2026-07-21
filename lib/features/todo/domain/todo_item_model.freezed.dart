// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TodoItem _$TodoItemFromJson(Map<String, dynamic> json) {
  return _TodoItem.fromJson(json);
}

/// @nodoc
mixin _$TodoItem {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'todo_list_id')
  String get todoListId => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'place_name')
  String? get placeName => throw _privateConstructorUsedError;
  @JsonKey(name: 'place_category')
  String? get placeCategory => throw _privateConstructorUsedError;
  @JsonKey(name: 'place_id')
  String? get placeId => throw _privateConstructorUsedError;

  /// 참고용 시간 — 미설정 시 null. 정렬에 영향 없음.
  @JsonKey(name: 'planned_at')
  DateTime? get plannedAt => throw _privateConstructorUsedError;

  /// startDate 기준 0,1,2... 인덱스. plannedAt 으로 계산 가능하지만
  /// UI 그룹화 효율을 위해 비정규화 저장.
  @JsonKey(name: 'day_index')
  int get dayIndex => throw _privateConstructorUsedError;

  /// 같은 일 내 정렬 순서 (드래그 재정렬).
  @JsonKey(name: 'order_in_day')
  int get orderInDay => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get emotion => throw _privateConstructorUsedError;

  /// 체크인 성공 시 생성된 Dot.id (약한 참조).
  @JsonKey(name: 'check_in_dot_id')
  String? get checkInDotId => throw _privateConstructorUsedError;
  @JsonKey(name: 'checked_in_at')
  DateTime? get checkedInAt => throw _privateConstructorUsedError;

  /// 즐겨찾기 고정 여부.
  @JsonKey(name: 'is_pinned')
  bool get isPinned => throw _privateConstructorUsedError;

  /// 핀 고정 순서 (낮을수록 위에 표시).
  @JsonKey(name: 'pin_order')
  int get pinOrder => throw _privateConstructorUsedError;

  /// 계획 시점 첨부 이미지 (선택).
  @JsonKey(name: 'photo_url')
  String? get photoUrl => throw _privateConstructorUsedError;

  /// place_id 조인 장소 상세 (주소/전화/카카오맵 링크) — BE GetList 가 embed.
  Place? get place => throw _privateConstructorUsedError;
  bool get synced => throw _privateConstructorUsedError;

  /// Serializes this TodoItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TodoItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TodoItemCopyWith<TodoItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodoItemCopyWith<$Res> {
  factory $TodoItemCopyWith(TodoItem value, $Res Function(TodoItem) then) =
      _$TodoItemCopyWithImpl<$Res, TodoItem>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'todo_list_id') String todoListId,
    double latitude,
    double longitude,
    @JsonKey(name: 'place_name') String? placeName,
    @JsonKey(name: 'place_category') String? placeCategory,
    @JsonKey(name: 'place_id') String? placeId,
    @JsonKey(name: 'planned_at') DateTime? plannedAt,
    @JsonKey(name: 'day_index') int dayIndex,
    @JsonKey(name: 'order_in_day') int orderInDay,
    String? notes,
    String? emotion,
    @JsonKey(name: 'check_in_dot_id') String? checkInDotId,
    @JsonKey(name: 'checked_in_at') DateTime? checkedInAt,
    @JsonKey(name: 'is_pinned') bool isPinned,
    @JsonKey(name: 'pin_order') int pinOrder,
    @JsonKey(name: 'photo_url') String? photoUrl,
    Place? place,
    bool synced,
  });

  $PlaceCopyWith<$Res>? get place;
}

/// @nodoc
class _$TodoItemCopyWithImpl<$Res, $Val extends TodoItem>
    implements $TodoItemCopyWith<$Res> {
  _$TodoItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TodoItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? todoListId = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? placeName = freezed,
    Object? placeCategory = freezed,
    Object? placeId = freezed,
    Object? plannedAt = freezed,
    Object? dayIndex = null,
    Object? orderInDay = null,
    Object? notes = freezed,
    Object? emotion = freezed,
    Object? checkInDotId = freezed,
    Object? checkedInAt = freezed,
    Object? isPinned = null,
    Object? pinOrder = null,
    Object? photoUrl = freezed,
    Object? place = freezed,
    Object? synced = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            todoListId: null == todoListId
                ? _value.todoListId
                : todoListId // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            placeName: freezed == placeName
                ? _value.placeName
                : placeName // ignore: cast_nullable_to_non_nullable
                      as String?,
            placeCategory: freezed == placeCategory
                ? _value.placeCategory
                : placeCategory // ignore: cast_nullable_to_non_nullable
                      as String?,
            placeId: freezed == placeId
                ? _value.placeId
                : placeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            plannedAt: freezed == plannedAt
                ? _value.plannedAt
                : plannedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            dayIndex: null == dayIndex
                ? _value.dayIndex
                : dayIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            orderInDay: null == orderInDay
                ? _value.orderInDay
                : orderInDay // ignore: cast_nullable_to_non_nullable
                      as int,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            emotion: freezed == emotion
                ? _value.emotion
                : emotion // ignore: cast_nullable_to_non_nullable
                      as String?,
            checkInDotId: freezed == checkInDotId
                ? _value.checkInDotId
                : checkInDotId // ignore: cast_nullable_to_non_nullable
                      as String?,
            checkedInAt: freezed == checkedInAt
                ? _value.checkedInAt
                : checkedInAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isPinned: null == isPinned
                ? _value.isPinned
                : isPinned // ignore: cast_nullable_to_non_nullable
                      as bool,
            pinOrder: null == pinOrder
                ? _value.pinOrder
                : pinOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            place: freezed == place
                ? _value.place
                : place // ignore: cast_nullable_to_non_nullable
                      as Place?,
            synced: null == synced
                ? _value.synced
                : synced // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }

  /// Create a copy of TodoItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlaceCopyWith<$Res>? get place {
    if (_value.place == null) {
      return null;
    }

    return $PlaceCopyWith<$Res>(_value.place!, (value) {
      return _then(_value.copyWith(place: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TodoItemImplCopyWith<$Res>
    implements $TodoItemCopyWith<$Res> {
  factory _$$TodoItemImplCopyWith(
    _$TodoItemImpl value,
    $Res Function(_$TodoItemImpl) then,
  ) = __$$TodoItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'todo_list_id') String todoListId,
    double latitude,
    double longitude,
    @JsonKey(name: 'place_name') String? placeName,
    @JsonKey(name: 'place_category') String? placeCategory,
    @JsonKey(name: 'place_id') String? placeId,
    @JsonKey(name: 'planned_at') DateTime? plannedAt,
    @JsonKey(name: 'day_index') int dayIndex,
    @JsonKey(name: 'order_in_day') int orderInDay,
    String? notes,
    String? emotion,
    @JsonKey(name: 'check_in_dot_id') String? checkInDotId,
    @JsonKey(name: 'checked_in_at') DateTime? checkedInAt,
    @JsonKey(name: 'is_pinned') bool isPinned,
    @JsonKey(name: 'pin_order') int pinOrder,
    @JsonKey(name: 'photo_url') String? photoUrl,
    Place? place,
    bool synced,
  });

  @override
  $PlaceCopyWith<$Res>? get place;
}

/// @nodoc
class __$$TodoItemImplCopyWithImpl<$Res>
    extends _$TodoItemCopyWithImpl<$Res, _$TodoItemImpl>
    implements _$$TodoItemImplCopyWith<$Res> {
  __$$TodoItemImplCopyWithImpl(
    _$TodoItemImpl _value,
    $Res Function(_$TodoItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TodoItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? todoListId = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? placeName = freezed,
    Object? placeCategory = freezed,
    Object? placeId = freezed,
    Object? plannedAt = freezed,
    Object? dayIndex = null,
    Object? orderInDay = null,
    Object? notes = freezed,
    Object? emotion = freezed,
    Object? checkInDotId = freezed,
    Object? checkedInAt = freezed,
    Object? isPinned = null,
    Object? pinOrder = null,
    Object? photoUrl = freezed,
    Object? place = freezed,
    Object? synced = null,
  }) {
    return _then(
      _$TodoItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        todoListId: null == todoListId
            ? _value.todoListId
            : todoListId // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        placeName: freezed == placeName
            ? _value.placeName
            : placeName // ignore: cast_nullable_to_non_nullable
                  as String?,
        placeCategory: freezed == placeCategory
            ? _value.placeCategory
            : placeCategory // ignore: cast_nullable_to_non_nullable
                  as String?,
        placeId: freezed == placeId
            ? _value.placeId
            : placeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        plannedAt: freezed == plannedAt
            ? _value.plannedAt
            : plannedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dayIndex: null == dayIndex
            ? _value.dayIndex
            : dayIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        orderInDay: null == orderInDay
            ? _value.orderInDay
            : orderInDay // ignore: cast_nullable_to_non_nullable
                  as int,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        emotion: freezed == emotion
            ? _value.emotion
            : emotion // ignore: cast_nullable_to_non_nullable
                  as String?,
        checkInDotId: freezed == checkInDotId
            ? _value.checkInDotId
            : checkInDotId // ignore: cast_nullable_to_non_nullable
                  as String?,
        checkedInAt: freezed == checkedInAt
            ? _value.checkedInAt
            : checkedInAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isPinned: null == isPinned
            ? _value.isPinned
            : isPinned // ignore: cast_nullable_to_non_nullable
                  as bool,
        pinOrder: null == pinOrder
            ? _value.pinOrder
            : pinOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        place: freezed == place
            ? _value.place
            : place // ignore: cast_nullable_to_non_nullable
                  as Place?,
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
class _$TodoItemImpl implements _TodoItem {
  const _$TodoItemImpl({
    required this.id,
    @JsonKey(name: 'todo_list_id') required this.todoListId,
    required this.latitude,
    required this.longitude,
    @JsonKey(name: 'place_name') this.placeName,
    @JsonKey(name: 'place_category') this.placeCategory,
    @JsonKey(name: 'place_id') this.placeId,
    @JsonKey(name: 'planned_at') this.plannedAt,
    @JsonKey(name: 'day_index') this.dayIndex = 0,
    @JsonKey(name: 'order_in_day') this.orderInDay = 0,
    this.notes,
    this.emotion,
    @JsonKey(name: 'check_in_dot_id') this.checkInDotId,
    @JsonKey(name: 'checked_in_at') this.checkedInAt,
    @JsonKey(name: 'is_pinned') this.isPinned = false,
    @JsonKey(name: 'pin_order') this.pinOrder = 0,
    @JsonKey(name: 'photo_url') this.photoUrl,
    this.place,
    this.synced = false,
  });

  factory _$TodoItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$TodoItemImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'todo_list_id')
  final String todoListId;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  @JsonKey(name: 'place_name')
  final String? placeName;
  @override
  @JsonKey(name: 'place_category')
  final String? placeCategory;
  @override
  @JsonKey(name: 'place_id')
  final String? placeId;

  /// 참고용 시간 — 미설정 시 null. 정렬에 영향 없음.
  @override
  @JsonKey(name: 'planned_at')
  final DateTime? plannedAt;

  /// startDate 기준 0,1,2... 인덱스. plannedAt 으로 계산 가능하지만
  /// UI 그룹화 효율을 위해 비정규화 저장.
  @override
  @JsonKey(name: 'day_index')
  final int dayIndex;

  /// 같은 일 내 정렬 순서 (드래그 재정렬).
  @override
  @JsonKey(name: 'order_in_day')
  final int orderInDay;
  @override
  final String? notes;
  @override
  final String? emotion;

  /// 체크인 성공 시 생성된 Dot.id (약한 참조).
  @override
  @JsonKey(name: 'check_in_dot_id')
  final String? checkInDotId;
  @override
  @JsonKey(name: 'checked_in_at')
  final DateTime? checkedInAt;

  /// 즐겨찾기 고정 여부.
  @override
  @JsonKey(name: 'is_pinned')
  final bool isPinned;

  /// 핀 고정 순서 (낮을수록 위에 표시).
  @override
  @JsonKey(name: 'pin_order')
  final int pinOrder;

  /// 계획 시점 첨부 이미지 (선택).
  @override
  @JsonKey(name: 'photo_url')
  final String? photoUrl;

  /// place_id 조인 장소 상세 (주소/전화/카카오맵 링크) — BE GetList 가 embed.
  @override
  final Place? place;
  @override
  @JsonKey()
  final bool synced;

  @override
  String toString() {
    return 'TodoItem(id: $id, todoListId: $todoListId, latitude: $latitude, longitude: $longitude, placeName: $placeName, placeCategory: $placeCategory, placeId: $placeId, plannedAt: $plannedAt, dayIndex: $dayIndex, orderInDay: $orderInDay, notes: $notes, emotion: $emotion, checkInDotId: $checkInDotId, checkedInAt: $checkedInAt, isPinned: $isPinned, pinOrder: $pinOrder, photoUrl: $photoUrl, place: $place, synced: $synced)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TodoItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.todoListId, todoListId) ||
                other.todoListId == todoListId) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.placeName, placeName) ||
                other.placeName == placeName) &&
            (identical(other.placeCategory, placeCategory) ||
                other.placeCategory == placeCategory) &&
            (identical(other.placeId, placeId) || other.placeId == placeId) &&
            (identical(other.plannedAt, plannedAt) ||
                other.plannedAt == plannedAt) &&
            (identical(other.dayIndex, dayIndex) ||
                other.dayIndex == dayIndex) &&
            (identical(other.orderInDay, orderInDay) ||
                other.orderInDay == orderInDay) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.emotion, emotion) || other.emotion == emotion) &&
            (identical(other.checkInDotId, checkInDotId) ||
                other.checkInDotId == checkInDotId) &&
            (identical(other.checkedInAt, checkedInAt) ||
                other.checkedInAt == checkedInAt) &&
            (identical(other.isPinned, isPinned) ||
                other.isPinned == isPinned) &&
            (identical(other.pinOrder, pinOrder) ||
                other.pinOrder == pinOrder) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.place, place) || other.place == place) &&
            (identical(other.synced, synced) || other.synced == synced));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    todoListId,
    latitude,
    longitude,
    placeName,
    placeCategory,
    placeId,
    plannedAt,
    dayIndex,
    orderInDay,
    notes,
    emotion,
    checkInDotId,
    checkedInAt,
    isPinned,
    pinOrder,
    photoUrl,
    place,
    synced,
  ]);

  /// Create a copy of TodoItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TodoItemImplCopyWith<_$TodoItemImpl> get copyWith =>
      __$$TodoItemImplCopyWithImpl<_$TodoItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TodoItemImplToJson(this);
  }
}

abstract class _TodoItem implements TodoItem {
  const factory _TodoItem({
    required final String id,
    @JsonKey(name: 'todo_list_id') required final String todoListId,
    required final double latitude,
    required final double longitude,
    @JsonKey(name: 'place_name') final String? placeName,
    @JsonKey(name: 'place_category') final String? placeCategory,
    @JsonKey(name: 'place_id') final String? placeId,
    @JsonKey(name: 'planned_at') final DateTime? plannedAt,
    @JsonKey(name: 'day_index') final int dayIndex,
    @JsonKey(name: 'order_in_day') final int orderInDay,
    final String? notes,
    final String? emotion,
    @JsonKey(name: 'check_in_dot_id') final String? checkInDotId,
    @JsonKey(name: 'checked_in_at') final DateTime? checkedInAt,
    @JsonKey(name: 'is_pinned') final bool isPinned,
    @JsonKey(name: 'pin_order') final int pinOrder,
    @JsonKey(name: 'photo_url') final String? photoUrl,
    final Place? place,
    final bool synced,
  }) = _$TodoItemImpl;

  factory _TodoItem.fromJson(Map<String, dynamic> json) =
      _$TodoItemImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'todo_list_id')
  String get todoListId;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  @JsonKey(name: 'place_name')
  String? get placeName;
  @override
  @JsonKey(name: 'place_category')
  String? get placeCategory;
  @override
  @JsonKey(name: 'place_id')
  String? get placeId;

  /// 참고용 시간 — 미설정 시 null. 정렬에 영향 없음.
  @override
  @JsonKey(name: 'planned_at')
  DateTime? get plannedAt;

  /// startDate 기준 0,1,2... 인덱스. plannedAt 으로 계산 가능하지만
  /// UI 그룹화 효율을 위해 비정규화 저장.
  @override
  @JsonKey(name: 'day_index')
  int get dayIndex;

  /// 같은 일 내 정렬 순서 (드래그 재정렬).
  @override
  @JsonKey(name: 'order_in_day')
  int get orderInDay;
  @override
  String? get notes;
  @override
  String? get emotion;

  /// 체크인 성공 시 생성된 Dot.id (약한 참조).
  @override
  @JsonKey(name: 'check_in_dot_id')
  String? get checkInDotId;
  @override
  @JsonKey(name: 'checked_in_at')
  DateTime? get checkedInAt;

  /// 즐겨찾기 고정 여부.
  @override
  @JsonKey(name: 'is_pinned')
  bool get isPinned;

  /// 핀 고정 순서 (낮을수록 위에 표시).
  @override
  @JsonKey(name: 'pin_order')
  int get pinOrder;

  /// 계획 시점 첨부 이미지 (선택).
  @override
  @JsonKey(name: 'photo_url')
  String? get photoUrl;

  /// place_id 조인 장소 상세 (주소/전화/카카오맵 링크) — BE GetList 가 embed.
  @override
  Place? get place;
  @override
  bool get synced;

  /// Create a copy of TodoItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TodoItemImplCopyWith<_$TodoItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
