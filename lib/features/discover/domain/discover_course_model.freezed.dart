// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discover_course_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DiscoverCourse _$DiscoverCourseFromJson(Map<String, dynamic> json) {
  return _DiscoverCourse.fromJson(json);
}

/// @nodoc
mixin _$DiscoverCourse {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_emoji')
  String? get coverEmoji => throw _privateConstructorUsedError;
  @JsonKey(name: 'cover_image_url')
  String? get coverImageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'course_type', defaultValue: 'trip')
  String get courseType => throw _privateConstructorUsedError; // Phase 3 에선 항상 null(표시 전용). region 필터는 미지원.
  @JsonKey(name: 'region')
  String? get region => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _tagsFromJson, toJson: _tagsToJson)
  List<String> get tags => throw _privateConstructorUsedError;
  @JsonKey(name: 'spot_count', defaultValue: 0)
  int get spotCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'like_count', defaultValue: 0)
  int get likeCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'liked_by_me', defaultValue: false)
  bool get likedByMe => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_nickname', defaultValue: '')
  String get ownerNickname => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_color_hex')
  String? get ownerColorHex => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this DiscoverCourse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiscoverCourse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiscoverCourseCopyWith<DiscoverCourse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscoverCourseCopyWith<$Res> {
  factory $DiscoverCourseCopyWith(
    DiscoverCourse value,
    $Res Function(DiscoverCourse) then,
  ) = _$DiscoverCourseCopyWithImpl<$Res, DiscoverCourse>;
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'cover_emoji') String? coverEmoji,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    @JsonKey(name: 'course_type', defaultValue: 'trip') String courseType,
    @JsonKey(name: 'region') String? region,
    @JsonKey(fromJson: _tagsFromJson, toJson: _tagsToJson) List<String> tags,
    @JsonKey(name: 'spot_count', defaultValue: 0) int spotCount,
    @JsonKey(name: 'like_count', defaultValue: 0) int likeCount,
    @JsonKey(name: 'liked_by_me', defaultValue: false) bool likedByMe,
    @JsonKey(name: 'owner_nickname', defaultValue: '') String ownerNickname,
    @JsonKey(name: 'owner_color_hex') String? ownerColorHex,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class _$DiscoverCourseCopyWithImpl<$Res, $Val extends DiscoverCourse>
    implements $DiscoverCourseCopyWith<$Res> {
  _$DiscoverCourseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiscoverCourse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? coverEmoji = freezed,
    Object? coverImageUrl = freezed,
    Object? courseType = null,
    Object? region = freezed,
    Object? tags = null,
    Object? spotCount = null,
    Object? likeCount = null,
    Object? likedByMe = null,
    Object? ownerNickname = null,
    Object? ownerColorHex = freezed,
    Object? updatedAt = freezed,
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
            coverEmoji: freezed == coverEmoji
                ? _value.coverEmoji
                : coverEmoji // ignore: cast_nullable_to_non_nullable
                      as String?,
            coverImageUrl: freezed == coverImageUrl
                ? _value.coverImageUrl
                : coverImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            courseType: null == courseType
                ? _value.courseType
                : courseType // ignore: cast_nullable_to_non_nullable
                      as String,
            region: freezed == region
                ? _value.region
                : region // ignore: cast_nullable_to_non_nullable
                      as String?,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            spotCount: null == spotCount
                ? _value.spotCount
                : spotCount // ignore: cast_nullable_to_non_nullable
                      as int,
            likeCount: null == likeCount
                ? _value.likeCount
                : likeCount // ignore: cast_nullable_to_non_nullable
                      as int,
            likedByMe: null == likedByMe
                ? _value.likedByMe
                : likedByMe // ignore: cast_nullable_to_non_nullable
                      as bool,
            ownerNickname: null == ownerNickname
                ? _value.ownerNickname
                : ownerNickname // ignore: cast_nullable_to_non_nullable
                      as String,
            ownerColorHex: freezed == ownerColorHex
                ? _value.ownerColorHex
                : ownerColorHex // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DiscoverCourseImplCopyWith<$Res>
    implements $DiscoverCourseCopyWith<$Res> {
  factory _$$DiscoverCourseImplCopyWith(
    _$DiscoverCourseImpl value,
    $Res Function(_$DiscoverCourseImpl) then,
  ) = __$$DiscoverCourseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    @JsonKey(name: 'cover_emoji') String? coverEmoji,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    @JsonKey(name: 'course_type', defaultValue: 'trip') String courseType,
    @JsonKey(name: 'region') String? region,
    @JsonKey(fromJson: _tagsFromJson, toJson: _tagsToJson) List<String> tags,
    @JsonKey(name: 'spot_count', defaultValue: 0) int spotCount,
    @JsonKey(name: 'like_count', defaultValue: 0) int likeCount,
    @JsonKey(name: 'liked_by_me', defaultValue: false) bool likedByMe,
    @JsonKey(name: 'owner_nickname', defaultValue: '') String ownerNickname,
    @JsonKey(name: 'owner_color_hex') String? ownerColorHex,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  });
}

/// @nodoc
class __$$DiscoverCourseImplCopyWithImpl<$Res>
    extends _$DiscoverCourseCopyWithImpl<$Res, _$DiscoverCourseImpl>
    implements _$$DiscoverCourseImplCopyWith<$Res> {
  __$$DiscoverCourseImplCopyWithImpl(
    _$DiscoverCourseImpl _value,
    $Res Function(_$DiscoverCourseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiscoverCourse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? coverEmoji = freezed,
    Object? coverImageUrl = freezed,
    Object? courseType = null,
    Object? region = freezed,
    Object? tags = null,
    Object? spotCount = null,
    Object? likeCount = null,
    Object? likedByMe = null,
    Object? ownerNickname = null,
    Object? ownerColorHex = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$DiscoverCourseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        coverEmoji: freezed == coverEmoji
            ? _value.coverEmoji
            : coverEmoji // ignore: cast_nullable_to_non_nullable
                  as String?,
        coverImageUrl: freezed == coverImageUrl
            ? _value.coverImageUrl
            : coverImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        courseType: null == courseType
            ? _value.courseType
            : courseType // ignore: cast_nullable_to_non_nullable
                  as String,
        region: freezed == region
            ? _value.region
            : region // ignore: cast_nullable_to_non_nullable
                  as String?,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        spotCount: null == spotCount
            ? _value.spotCount
            : spotCount // ignore: cast_nullable_to_non_nullable
                  as int,
        likeCount: null == likeCount
            ? _value.likeCount
            : likeCount // ignore: cast_nullable_to_non_nullable
                  as int,
        likedByMe: null == likedByMe
            ? _value.likedByMe
            : likedByMe // ignore: cast_nullable_to_non_nullable
                  as bool,
        ownerNickname: null == ownerNickname
            ? _value.ownerNickname
            : ownerNickname // ignore: cast_nullable_to_non_nullable
                  as String,
        ownerColorHex: freezed == ownerColorHex
            ? _value.ownerColorHex
            : ownerColorHex // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DiscoverCourseImpl implements _DiscoverCourse {
  const _$DiscoverCourseImpl({
    required this.id,
    required this.name,
    @JsonKey(name: 'cover_emoji') this.coverEmoji,
    @JsonKey(name: 'cover_image_url') this.coverImageUrl,
    @JsonKey(name: 'course_type', defaultValue: 'trip')
    this.courseType = 'trip',
    @JsonKey(name: 'region') this.region,
    @JsonKey(fromJson: _tagsFromJson, toJson: _tagsToJson)
    final List<String> tags = const <String>[],
    @JsonKey(name: 'spot_count', defaultValue: 0) this.spotCount = 0,
    @JsonKey(name: 'like_count', defaultValue: 0) this.likeCount = 0,
    @JsonKey(name: 'liked_by_me', defaultValue: false) this.likedByMe = false,
    @JsonKey(name: 'owner_nickname', defaultValue: '') this.ownerNickname = '',
    @JsonKey(name: 'owner_color_hex') this.ownerColorHex,
    @JsonKey(name: 'updated_at') this.updatedAt,
  }) : _tags = tags;

  factory _$DiscoverCourseImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiscoverCourseImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey(name: 'cover_emoji')
  final String? coverEmoji;
  @override
  @JsonKey(name: 'cover_image_url')
  final String? coverImageUrl;
  @override
  @JsonKey(name: 'course_type', defaultValue: 'trip')
  final String courseType;
  // Phase 3 에선 항상 null(표시 전용). region 필터는 미지원.
  @override
  @JsonKey(name: 'region')
  final String? region;
  final List<String> _tags;
  @override
  @JsonKey(fromJson: _tagsFromJson, toJson: _tagsToJson)
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey(name: 'spot_count', defaultValue: 0)
  final int spotCount;
  @override
  @JsonKey(name: 'like_count', defaultValue: 0)
  final int likeCount;
  @override
  @JsonKey(name: 'liked_by_me', defaultValue: false)
  final bool likedByMe;
  @override
  @JsonKey(name: 'owner_nickname', defaultValue: '')
  final String ownerNickname;
  @override
  @JsonKey(name: 'owner_color_hex')
  final String? ownerColorHex;
  @override
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'DiscoverCourse(id: $id, name: $name, coverEmoji: $coverEmoji, coverImageUrl: $coverImageUrl, courseType: $courseType, region: $region, tags: $tags, spotCount: $spotCount, likeCount: $likeCount, likedByMe: $likedByMe, ownerNickname: $ownerNickname, ownerColorHex: $ownerColorHex, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscoverCourseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.coverEmoji, coverEmoji) ||
                other.coverEmoji == coverEmoji) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            (identical(other.courseType, courseType) ||
                other.courseType == courseType) &&
            (identical(other.region, region) || other.region == region) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.spotCount, spotCount) ||
                other.spotCount == spotCount) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.likedByMe, likedByMe) ||
                other.likedByMe == likedByMe) &&
            (identical(other.ownerNickname, ownerNickname) ||
                other.ownerNickname == ownerNickname) &&
            (identical(other.ownerColorHex, ownerColorHex) ||
                other.ownerColorHex == ownerColorHex) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    coverEmoji,
    coverImageUrl,
    courseType,
    region,
    const DeepCollectionEquality().hash(_tags),
    spotCount,
    likeCount,
    likedByMe,
    ownerNickname,
    ownerColorHex,
    updatedAt,
  );

  /// Create a copy of DiscoverCourse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscoverCourseImplCopyWith<_$DiscoverCourseImpl> get copyWith =>
      __$$DiscoverCourseImplCopyWithImpl<_$DiscoverCourseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DiscoverCourseImplToJson(this);
  }
}

abstract class _DiscoverCourse implements DiscoverCourse {
  const factory _DiscoverCourse({
    required final String id,
    required final String name,
    @JsonKey(name: 'cover_emoji') final String? coverEmoji,
    @JsonKey(name: 'cover_image_url') final String? coverImageUrl,
    @JsonKey(name: 'course_type', defaultValue: 'trip') final String courseType,
    @JsonKey(name: 'region') final String? region,
    @JsonKey(fromJson: _tagsFromJson, toJson: _tagsToJson)
    final List<String> tags,
    @JsonKey(name: 'spot_count', defaultValue: 0) final int spotCount,
    @JsonKey(name: 'like_count', defaultValue: 0) final int likeCount,
    @JsonKey(name: 'liked_by_me', defaultValue: false) final bool likedByMe,
    @JsonKey(name: 'owner_nickname', defaultValue: '')
    final String ownerNickname,
    @JsonKey(name: 'owner_color_hex') final String? ownerColorHex,
    @JsonKey(name: 'updated_at') final DateTime? updatedAt,
  }) = _$DiscoverCourseImpl;

  factory _DiscoverCourse.fromJson(Map<String, dynamic> json) =
      _$DiscoverCourseImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'cover_emoji')
  String? get coverEmoji;
  @override
  @JsonKey(name: 'cover_image_url')
  String? get coverImageUrl;
  @override
  @JsonKey(name: 'course_type', defaultValue: 'trip')
  String get courseType; // Phase 3 에선 항상 null(표시 전용). region 필터는 미지원.
  @override
  @JsonKey(name: 'region')
  String? get region;
  @override
  @JsonKey(fromJson: _tagsFromJson, toJson: _tagsToJson)
  List<String> get tags;
  @override
  @JsonKey(name: 'spot_count', defaultValue: 0)
  int get spotCount;
  @override
  @JsonKey(name: 'like_count', defaultValue: 0)
  int get likeCount;
  @override
  @JsonKey(name: 'liked_by_me', defaultValue: false)
  bool get likedByMe;
  @override
  @JsonKey(name: 'owner_nickname', defaultValue: '')
  String get ownerNickname;
  @override
  @JsonKey(name: 'owner_color_hex')
  String? get ownerColorHex;
  @override
  @JsonKey(name: 'updated_at')
  DateTime? get updatedAt;

  /// Create a copy of DiscoverCourse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscoverCourseImplCopyWith<_$DiscoverCourseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
