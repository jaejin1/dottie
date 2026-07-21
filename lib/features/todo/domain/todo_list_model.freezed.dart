// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo_list_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TodoList _$TodoListFromJson(Map<String, dynamic> json) {
  return _TodoList.fromJson(json);
}

/// @nodoc
mixin _$TodoList {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_id')
  String get ownerId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_emoji')
  String? get coverEmoji => throw _privateConstructorUsedError;
  @JsonKey(name: 'start_date')
  DateTime get startDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  DateTime get endDate => throw _privateConstructorUsedError;
  List<TodoItem> get items => throw _privateConstructorUsedError;
  @JsonKey(name: 'share_token')
  String? get shareToken => throw _privateConstructorUsedError;
  @JsonKey(name: 'share_token_expires_at')
  DateTime? get shareTokenExpiresAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt => throw _privateConstructorUsedError;
  bool get synced =>
      throw _privateConstructorUsedError; // 코스 유형 — BE 저장/반환 (course_type, 000021). 기본값 'trip'.
  @JsonKey(name: 'course_type', defaultValue: 'trip')
  String get courseType => throw _privateConstructorUsedError; // Phase 2 메타 (BE 동기화 예정)
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _tagsFromJson, toJson: _tagsToJson)
  List<String> get tags => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_image_url')
  String? get coverImageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'visibility', defaultValue: 'private')
  String get visibility => throw _privateConstructorUsedError; // 다른 사람의 공유 코스를 import 한 경우 true (BE: is_imported). 하위호환 유지.
  @JsonKey(name: 'is_imported')
  bool get isImported => throw _privateConstructorUsedError; // 협업 멤버 목록 — 소유자 포함. BE: members[].
  @JsonKey(name: 'members')
  List<CourseMember> get members => throw _privateConstructorUsedError; // 현재 유효 초대 코드 — owner 에게만 값 있음. BE: invite_code.
  @JsonKey(name: 'invite_code')
  String? get inviteCode => throw _privateConstructorUsedError; // 초대 코드 만료 시각. BE: invite_code_expires_at.
  @JsonKey(name: 'invite_code_expires_at')
  DateTime? get inviteCodeExpiresAt => throw _privateConstructorUsedError; // 연결된 룸 ID — null이면 독립 스팟 리스트. BE: room_id.
  @JsonKey(name: 'room_id')
  String? get roomId => throw _privateConstructorUsedError; // 스팟 탭 상단 고정. BE: is_pinned / pin_order.
  @JsonKey(name: 'is_pinned')
  bool get isPinned => throw _privateConstructorUsedError;
  @JsonKey(name: 'pin_order')
  int get pinOrder => throw _privateConstructorUsedError;

  /// Serializes this TodoList to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TodoList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TodoListCopyWith<TodoList> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodoListCopyWith<$Res> {
  factory $TodoListCopyWith(TodoList value, $Res Function(TodoList) then) =
      _$TodoListCopyWithImpl<$Res, TodoList>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'owner_id') String ownerId,
    String name,
    @JsonKey(name: 'cover_emoji') String? coverEmoji,
    @JsonKey(name: 'start_date') DateTime startDate,
    @JsonKey(name: 'end_date') DateTime endDate,
    List<TodoItem> items,
    @JsonKey(name: 'share_token') String? shareToken,
    @JsonKey(name: 'share_token_expires_at') DateTime? shareTokenExpiresAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    bool synced,
    @JsonKey(name: 'course_type', defaultValue: 'trip') String courseType,
    String? description,
    @JsonKey(fromJson: _tagsFromJson, toJson: _tagsToJson) List<String> tags,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    @JsonKey(name: 'visibility', defaultValue: 'private') String visibility,
    @JsonKey(name: 'is_imported') bool isImported,
    @JsonKey(name: 'members') List<CourseMember> members,
    @JsonKey(name: 'invite_code') String? inviteCode,
    @JsonKey(name: 'invite_code_expires_at') DateTime? inviteCodeExpiresAt,
    @JsonKey(name: 'room_id') String? roomId,
    @JsonKey(name: 'is_pinned') bool isPinned,
    @JsonKey(name: 'pin_order') int pinOrder,
  });
}

/// @nodoc
class _$TodoListCopyWithImpl<$Res, $Val extends TodoList>
    implements $TodoListCopyWith<$Res> {
  _$TodoListCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TodoList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? name = null,
    Object? coverEmoji = freezed,
    Object? startDate = null,
    Object? endDate = null,
    Object? items = null,
    Object? shareToken = freezed,
    Object? shareTokenExpiresAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? synced = null,
    Object? courseType = null,
    Object? description = freezed,
    Object? tags = null,
    Object? coverImageUrl = freezed,
    Object? visibility = null,
    Object? isImported = null,
    Object? members = null,
    Object? inviteCode = freezed,
    Object? inviteCodeExpiresAt = freezed,
    Object? roomId = freezed,
    Object? isPinned = null,
    Object? pinOrder = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            ownerId: null == ownerId
                ? _value.ownerId
                : ownerId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            coverEmoji: freezed == coverEmoji
                ? _value.coverEmoji
                : coverEmoji // ignore: cast_nullable_to_non_nullable
                      as String?,
            startDate: null == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endDate: null == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<TodoItem>,
            shareToken: freezed == shareToken
                ? _value.shareToken
                : shareToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            shareTokenExpiresAt: freezed == shareTokenExpiresAt
                ? _value.shareTokenExpiresAt
                : shareTokenExpiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            synced: null == synced
                ? _value.synced
                : synced // ignore: cast_nullable_to_non_nullable
                      as bool,
            courseType: null == courseType
                ? _value.courseType
                : courseType // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            coverImageUrl: freezed == coverImageUrl
                ? _value.coverImageUrl
                : coverImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            visibility: null == visibility
                ? _value.visibility
                : visibility // ignore: cast_nullable_to_non_nullable
                      as String,
            isImported: null == isImported
                ? _value.isImported
                : isImported // ignore: cast_nullable_to_non_nullable
                      as bool,
            members: null == members
                ? _value.members
                : members // ignore: cast_nullable_to_non_nullable
                      as List<CourseMember>,
            inviteCode: freezed == inviteCode
                ? _value.inviteCode
                : inviteCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            inviteCodeExpiresAt: freezed == inviteCodeExpiresAt
                ? _value.inviteCodeExpiresAt
                : inviteCodeExpiresAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            roomId: freezed == roomId
                ? _value.roomId
                : roomId // ignore: cast_nullable_to_non_nullable
                      as String?,
            isPinned: null == isPinned
                ? _value.isPinned
                : isPinned // ignore: cast_nullable_to_non_nullable
                      as bool,
            pinOrder: null == pinOrder
                ? _value.pinOrder
                : pinOrder // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TodoListImplCopyWith<$Res>
    implements $TodoListCopyWith<$Res> {
  factory _$$TodoListImplCopyWith(
    _$TodoListImpl value,
    $Res Function(_$TodoListImpl) then,
  ) = __$$TodoListImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'owner_id') String ownerId,
    String name,
    @JsonKey(name: 'cover_emoji') String? coverEmoji,
    @JsonKey(name: 'start_date') DateTime startDate,
    @JsonKey(name: 'end_date') DateTime endDate,
    List<TodoItem> items,
    @JsonKey(name: 'share_token') String? shareToken,
    @JsonKey(name: 'share_token_expires_at') DateTime? shareTokenExpiresAt,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime updatedAt,
    bool synced,
    @JsonKey(name: 'course_type', defaultValue: 'trip') String courseType,
    String? description,
    @JsonKey(fromJson: _tagsFromJson, toJson: _tagsToJson) List<String> tags,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    @JsonKey(name: 'visibility', defaultValue: 'private') String visibility,
    @JsonKey(name: 'is_imported') bool isImported,
    @JsonKey(name: 'members') List<CourseMember> members,
    @JsonKey(name: 'invite_code') String? inviteCode,
    @JsonKey(name: 'invite_code_expires_at') DateTime? inviteCodeExpiresAt,
    @JsonKey(name: 'room_id') String? roomId,
    @JsonKey(name: 'is_pinned') bool isPinned,
    @JsonKey(name: 'pin_order') int pinOrder,
  });
}

/// @nodoc
class __$$TodoListImplCopyWithImpl<$Res>
    extends _$TodoListCopyWithImpl<$Res, _$TodoListImpl>
    implements _$$TodoListImplCopyWith<$Res> {
  __$$TodoListImplCopyWithImpl(
    _$TodoListImpl _value,
    $Res Function(_$TodoListImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TodoList
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? name = null,
    Object? coverEmoji = freezed,
    Object? startDate = null,
    Object? endDate = null,
    Object? items = null,
    Object? shareToken = freezed,
    Object? shareTokenExpiresAt = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? synced = null,
    Object? courseType = null,
    Object? description = freezed,
    Object? tags = null,
    Object? coverImageUrl = freezed,
    Object? visibility = null,
    Object? isImported = null,
    Object? members = null,
    Object? inviteCode = freezed,
    Object? inviteCodeExpiresAt = freezed,
    Object? roomId = freezed,
    Object? isPinned = null,
    Object? pinOrder = null,
  }) {
    return _then(
      _$TodoListImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        ownerId: null == ownerId
            ? _value.ownerId
            : ownerId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        coverEmoji: freezed == coverEmoji
            ? _value.coverEmoji
            : coverEmoji // ignore: cast_nullable_to_non_nullable
                  as String?,
        startDate: null == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endDate: null == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<TodoItem>,
        shareToken: freezed == shareToken
            ? _value.shareToken
            : shareToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        shareTokenExpiresAt: freezed == shareTokenExpiresAt
            ? _value.shareTokenExpiresAt
            : shareTokenExpiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        synced: null == synced
            ? _value.synced
            : synced // ignore: cast_nullable_to_non_nullable
                  as bool,
        courseType: null == courseType
            ? _value.courseType
            : courseType // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        coverImageUrl: freezed == coverImageUrl
            ? _value.coverImageUrl
            : coverImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        visibility: null == visibility
            ? _value.visibility
            : visibility // ignore: cast_nullable_to_non_nullable
                  as String,
        isImported: null == isImported
            ? _value.isImported
            : isImported // ignore: cast_nullable_to_non_nullable
                  as bool,
        members: null == members
            ? _value._members
            : members // ignore: cast_nullable_to_non_nullable
                  as List<CourseMember>,
        inviteCode: freezed == inviteCode
            ? _value.inviteCode
            : inviteCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        inviteCodeExpiresAt: freezed == inviteCodeExpiresAt
            ? _value.inviteCodeExpiresAt
            : inviteCodeExpiresAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        roomId: freezed == roomId
            ? _value.roomId
            : roomId // ignore: cast_nullable_to_non_nullable
                  as String?,
        isPinned: null == isPinned
            ? _value.isPinned
            : isPinned // ignore: cast_nullable_to_non_nullable
                  as bool,
        pinOrder: null == pinOrder
            ? _value.pinOrder
            : pinOrder // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TodoListImpl implements _TodoList {
  const _$TodoListImpl({
    required this.id,
    @JsonKey(name: 'owner_id') required this.ownerId,
    required this.name,
    @JsonKey(name: 'cover_emoji') this.coverEmoji,
    @JsonKey(name: 'start_date') required this.startDate,
    @JsonKey(name: 'end_date') required this.endDate,
    final List<TodoItem> items = const <TodoItem>[],
    @JsonKey(name: 'share_token') this.shareToken,
    @JsonKey(name: 'share_token_expires_at') this.shareTokenExpiresAt,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
    this.synced = false,
    @JsonKey(name: 'course_type', defaultValue: 'trip')
    this.courseType = 'trip',
    this.description,
    @JsonKey(fromJson: _tagsFromJson, toJson: _tagsToJson)
    final List<String> tags = const <String>[],
    @JsonKey(name: 'cover_image_url') this.coverImageUrl,
    @JsonKey(name: 'visibility', defaultValue: 'private')
    this.visibility = 'private',
    @JsonKey(name: 'is_imported') this.isImported = false,
    @JsonKey(name: 'members')
    final List<CourseMember> members = const <CourseMember>[],
    @JsonKey(name: 'invite_code') this.inviteCode,
    @JsonKey(name: 'invite_code_expires_at') this.inviteCodeExpiresAt,
    @JsonKey(name: 'room_id') this.roomId,
    @JsonKey(name: 'is_pinned') this.isPinned = false,
    @JsonKey(name: 'pin_order') this.pinOrder = 0,
  }) : _items = items,
       _tags = tags,
       _members = members;

  factory _$TodoListImpl.fromJson(Map<String, dynamic> json) =>
      _$$TodoListImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'owner_id')
  final String ownerId;
  @override
  final String name;
  @override
  @JsonKey(name: 'cover_emoji')
  final String? coverEmoji;
  @override
  @JsonKey(name: 'start_date')
  final DateTime startDate;
  @override
  @JsonKey(name: 'end_date')
  final DateTime endDate;
  final List<TodoItem> _items;
  @override
  @JsonKey()
  List<TodoItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  @JsonKey(name: 'share_token')
  final String? shareToken;
  @override
  @JsonKey(name: 'share_token_expires_at')
  final DateTime? shareTokenExpiresAt;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;
  @override
  @JsonKey()
  final bool synced;
  // 코스 유형 — BE 저장/반환 (course_type, 000021). 기본값 'trip'.
  @override
  @JsonKey(name: 'course_type', defaultValue: 'trip')
  final String courseType;
  // Phase 2 메타 (BE 동기화 예정)
  @override
  final String? description;
  final List<String> _tags;
  @override
  @JsonKey(fromJson: _tagsFromJson, toJson: _tagsToJson)
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey(name: 'cover_image_url')
  final String? coverImageUrl;
  @override
  @JsonKey(name: 'visibility', defaultValue: 'private')
  final String visibility;
  // 다른 사람의 공유 코스를 import 한 경우 true (BE: is_imported). 하위호환 유지.
  @override
  @JsonKey(name: 'is_imported')
  final bool isImported;
  // 협업 멤버 목록 — 소유자 포함. BE: members[].
  final List<CourseMember> _members;
  // 협업 멤버 목록 — 소유자 포함. BE: members[].
  @override
  @JsonKey(name: 'members')
  List<CourseMember> get members {
    if (_members is EqualUnmodifiableListView) return _members;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_members);
  }

  // 현재 유효 초대 코드 — owner 에게만 값 있음. BE: invite_code.
  @override
  @JsonKey(name: 'invite_code')
  final String? inviteCode;
  // 초대 코드 만료 시각. BE: invite_code_expires_at.
  @override
  @JsonKey(name: 'invite_code_expires_at')
  final DateTime? inviteCodeExpiresAt;
  // 연결된 룸 ID — null이면 독립 스팟 리스트. BE: room_id.
  @override
  @JsonKey(name: 'room_id')
  final String? roomId;
  // 스팟 탭 상단 고정. BE: is_pinned / pin_order.
  @override
  @JsonKey(name: 'is_pinned')
  final bool isPinned;
  @override
  @JsonKey(name: 'pin_order')
  final int pinOrder;

  @override
  String toString() {
    return 'TodoList(id: $id, ownerId: $ownerId, name: $name, coverEmoji: $coverEmoji, startDate: $startDate, endDate: $endDate, items: $items, shareToken: $shareToken, shareTokenExpiresAt: $shareTokenExpiresAt, createdAt: $createdAt, updatedAt: $updatedAt, synced: $synced, courseType: $courseType, description: $description, tags: $tags, coverImageUrl: $coverImageUrl, visibility: $visibility, isImported: $isImported, members: $members, inviteCode: $inviteCode, inviteCodeExpiresAt: $inviteCodeExpiresAt, roomId: $roomId, isPinned: $isPinned, pinOrder: $pinOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TodoListImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.coverEmoji, coverEmoji) ||
                other.coverEmoji == coverEmoji) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.shareToken, shareToken) ||
                other.shareToken == shareToken) &&
            (identical(other.shareTokenExpiresAt, shareTokenExpiresAt) ||
                other.shareTokenExpiresAt == shareTokenExpiresAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.synced, synced) || other.synced == synced) &&
            (identical(other.courseType, courseType) ||
                other.courseType == courseType) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            (identical(other.visibility, visibility) ||
                other.visibility == visibility) &&
            (identical(other.isImported, isImported) ||
                other.isImported == isImported) &&
            const DeepCollectionEquality().equals(other._members, _members) &&
            (identical(other.inviteCode, inviteCode) ||
                other.inviteCode == inviteCode) &&
            (identical(other.inviteCodeExpiresAt, inviteCodeExpiresAt) ||
                other.inviteCodeExpiresAt == inviteCodeExpiresAt) &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.isPinned, isPinned) ||
                other.isPinned == isPinned) &&
            (identical(other.pinOrder, pinOrder) ||
                other.pinOrder == pinOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    ownerId,
    name,
    coverEmoji,
    startDate,
    endDate,
    const DeepCollectionEquality().hash(_items),
    shareToken,
    shareTokenExpiresAt,
    createdAt,
    updatedAt,
    synced,
    courseType,
    description,
    const DeepCollectionEquality().hash(_tags),
    coverImageUrl,
    visibility,
    isImported,
    const DeepCollectionEquality().hash(_members),
    inviteCode,
    inviteCodeExpiresAt,
    roomId,
    isPinned,
    pinOrder,
  ]);

  /// Create a copy of TodoList
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TodoListImplCopyWith<_$TodoListImpl> get copyWith =>
      __$$TodoListImplCopyWithImpl<_$TodoListImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TodoListImplToJson(this);
  }
}

abstract class _TodoList implements TodoList {
  const factory _TodoList({
    required final String id,
    @JsonKey(name: 'owner_id') required final String ownerId,
    required final String name,
    @JsonKey(name: 'cover_emoji') final String? coverEmoji,
    @JsonKey(name: 'start_date') required final DateTime startDate,
    @JsonKey(name: 'end_date') required final DateTime endDate,
    final List<TodoItem> items,
    @JsonKey(name: 'share_token') final String? shareToken,
    @JsonKey(name: 'share_token_expires_at')
    final DateTime? shareTokenExpiresAt,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'updated_at') required final DateTime updatedAt,
    final bool synced,
    @JsonKey(name: 'course_type', defaultValue: 'trip') final String courseType,
    final String? description,
    @JsonKey(fromJson: _tagsFromJson, toJson: _tagsToJson)
    final List<String> tags,
    @JsonKey(name: 'cover_image_url') final String? coverImageUrl,
    @JsonKey(name: 'visibility', defaultValue: 'private')
    final String visibility,
    @JsonKey(name: 'is_imported') final bool isImported,
    @JsonKey(name: 'members') final List<CourseMember> members,
    @JsonKey(name: 'invite_code') final String? inviteCode,
    @JsonKey(name: 'invite_code_expires_at')
    final DateTime? inviteCodeExpiresAt,
    @JsonKey(name: 'room_id') final String? roomId,
    @JsonKey(name: 'is_pinned') final bool isPinned,
    @JsonKey(name: 'pin_order') final int pinOrder,
  }) = _$TodoListImpl;

  factory _TodoList.fromJson(Map<String, dynamic> json) =
      _$TodoListImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'owner_id')
  String get ownerId;
  @override
  String get name;
  @override
  @JsonKey(name: 'cover_emoji')
  String? get coverEmoji;
  @override
  @JsonKey(name: 'start_date')
  DateTime get startDate;
  @override
  @JsonKey(name: 'end_date')
  DateTime get endDate;
  @override
  List<TodoItem> get items;
  @override
  @JsonKey(name: 'share_token')
  String? get shareToken;
  @override
  @JsonKey(name: 'share_token_expires_at')
  DateTime? get shareTokenExpiresAt;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  DateTime get updatedAt;
  @override
  bool get synced; // 코스 유형 — BE 저장/반환 (course_type, 000021). 기본값 'trip'.
  @override
  @JsonKey(name: 'course_type', defaultValue: 'trip')
  String get courseType; // Phase 2 메타 (BE 동기화 예정)
  @override
  String? get description;
  @override
  @JsonKey(fromJson: _tagsFromJson, toJson: _tagsToJson)
  List<String> get tags;
  @override
  @JsonKey(name: 'cover_image_url')
  String? get coverImageUrl;
  @override
  @JsonKey(name: 'visibility', defaultValue: 'private')
  String get visibility; // 다른 사람의 공유 코스를 import 한 경우 true (BE: is_imported). 하위호환 유지.
  @override
  @JsonKey(name: 'is_imported')
  bool get isImported; // 협업 멤버 목록 — 소유자 포함. BE: members[].
  @override
  @JsonKey(name: 'members')
  List<CourseMember> get members; // 현재 유효 초대 코드 — owner 에게만 값 있음. BE: invite_code.
  @override
  @JsonKey(name: 'invite_code')
  String? get inviteCode; // 초대 코드 만료 시각. BE: invite_code_expires_at.
  @override
  @JsonKey(name: 'invite_code_expires_at')
  DateTime? get inviteCodeExpiresAt; // 연결된 룸 ID — null이면 독립 스팟 리스트. BE: room_id.
  @override
  @JsonKey(name: 'room_id')
  String? get roomId; // 스팟 탭 상단 고정. BE: is_pinned / pin_order.
  @override
  @JsonKey(name: 'is_pinned')
  bool get isPinned;
  @override
  @JsonKey(name: 'pin_order')
  int get pinOrder;

  /// Create a copy of TodoList
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TodoListImplCopyWith<_$TodoListImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
