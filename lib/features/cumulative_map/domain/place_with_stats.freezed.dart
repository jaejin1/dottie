// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place_with_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlaceWithStats _$PlaceWithStatsFromJson(Map<String, dynamic> json) {
  return _PlaceWithStats.fromJson(json);
}

/// @nodoc
mixin _$PlaceWithStats {
  @JsonKey(name: 'place_id')
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  @JsonKey(name: 'road_address')
  String? get roadAddress => throw _privateConstructorUsedError;
  String? get telephone => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude =>
      throw _privateConstructorUsedError; // ── 룸 통계 ──────────────────────────────
  @JsonKey(name: 'visit_count')
  int get visitCount => throw _privateConstructorUsedError;

  /// 이 장소를 방문한 룸 멤버 수.
  @JsonKey(name: 'visitor_count')
  int get visitorCount => throw _privateConstructorUsedError;

  /// 가장 최근 방문 (date string `YYYY-MM-DD` 또는 timestamp).
  @JsonKey(name: 'last_visited_at')
  DateTime? get lastVisitedAt => throw _privateConstructorUsedError;

  /// 가장 처음 방문 시각.
  @JsonKey(name: 'first_visited_at')
  DateTime? get firstVisitedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'member_ids')
  List<String> get memberIds => throw _privateConstructorUsedError;

  /// 요청자와 다른 멤버가 같은 날 함께 방문한 적이 있는지.
  @JsonKey(name: 'is_first_together')
  bool get isFirstTogether => throw _privateConstructorUsedError; // ── 즐겨찾기 (B9) ──────────────────────────
  @JsonKey(name: 'is_starred')
  bool get isStarred => throw _privateConstructorUsedError;

  /// 이 룸에서 이 장소를 별표한 멤버 수.
  @JsonKey(name: 'starred_by_count')
  int get starredByCount => throw _privateConstructorUsedError; // ── 미리보기 ───────────────────────────────
  @JsonKey(name: 'preview_dot')
  PreviewDot? get previewDot => throw _privateConstructorUsedError;

  /// 이 장소 dot 들의 댓글 수 합산.
  @JsonKey(name: 'comment_count_total')
  int get commentCountTotal => throw _privateConstructorUsedError;

  /// Serializes this PlaceWithStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlaceWithStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaceWithStatsCopyWith<PlaceWithStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaceWithStatsCopyWith<$Res> {
  factory $PlaceWithStatsCopyWith(
    PlaceWithStats value,
    $Res Function(PlaceWithStats) then,
  ) = _$PlaceWithStatsCopyWithImpl<$Res, PlaceWithStats>;
  @useResult
  $Res call({
    @JsonKey(name: 'place_id') String id,
    String name,
    String? category,
    String? address,
    @JsonKey(name: 'road_address') String? roadAddress,
    String? telephone,
    double latitude,
    double longitude,
    @JsonKey(name: 'visit_count') int visitCount,
    @JsonKey(name: 'visitor_count') int visitorCount,
    @JsonKey(name: 'last_visited_at') DateTime? lastVisitedAt,
    @JsonKey(name: 'first_visited_at') DateTime? firstVisitedAt,
    @JsonKey(name: 'member_ids') List<String> memberIds,
    @JsonKey(name: 'is_first_together') bool isFirstTogether,
    @JsonKey(name: 'is_starred') bool isStarred,
    @JsonKey(name: 'starred_by_count') int starredByCount,
    @JsonKey(name: 'preview_dot') PreviewDot? previewDot,
    @JsonKey(name: 'comment_count_total') int commentCountTotal,
  });

  $PreviewDotCopyWith<$Res>? get previewDot;
}

/// @nodoc
class _$PlaceWithStatsCopyWithImpl<$Res, $Val extends PlaceWithStats>
    implements $PlaceWithStatsCopyWith<$Res> {
  _$PlaceWithStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlaceWithStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = freezed,
    Object? address = freezed,
    Object? roadAddress = freezed,
    Object? telephone = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? visitCount = null,
    Object? visitorCount = null,
    Object? lastVisitedAt = freezed,
    Object? firstVisitedAt = freezed,
    Object? memberIds = null,
    Object? isFirstTogether = null,
    Object? isStarred = null,
    Object? starredByCount = null,
    Object? previewDot = freezed,
    Object? commentCountTotal = null,
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
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            visitCount: null == visitCount
                ? _value.visitCount
                : visitCount // ignore: cast_nullable_to_non_nullable
                      as int,
            visitorCount: null == visitorCount
                ? _value.visitorCount
                : visitorCount // ignore: cast_nullable_to_non_nullable
                      as int,
            lastVisitedAt: freezed == lastVisitedAt
                ? _value.lastVisitedAt
                : lastVisitedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            firstVisitedAt: freezed == firstVisitedAt
                ? _value.firstVisitedAt
                : firstVisitedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            memberIds: null == memberIds
                ? _value.memberIds
                : memberIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            isFirstTogether: null == isFirstTogether
                ? _value.isFirstTogether
                : isFirstTogether // ignore: cast_nullable_to_non_nullable
                      as bool,
            isStarred: null == isStarred
                ? _value.isStarred
                : isStarred // ignore: cast_nullable_to_non_nullable
                      as bool,
            starredByCount: null == starredByCount
                ? _value.starredByCount
                : starredByCount // ignore: cast_nullable_to_non_nullable
                      as int,
            previewDot: freezed == previewDot
                ? _value.previewDot
                : previewDot // ignore: cast_nullable_to_non_nullable
                      as PreviewDot?,
            commentCountTotal: null == commentCountTotal
                ? _value.commentCountTotal
                : commentCountTotal // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of PlaceWithStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PreviewDotCopyWith<$Res>? get previewDot {
    if (_value.previewDot == null) {
      return null;
    }

    return $PreviewDotCopyWith<$Res>(_value.previewDot!, (value) {
      return _then(_value.copyWith(previewDot: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlaceWithStatsImplCopyWith<$Res>
    implements $PlaceWithStatsCopyWith<$Res> {
  factory _$$PlaceWithStatsImplCopyWith(
    _$PlaceWithStatsImpl value,
    $Res Function(_$PlaceWithStatsImpl) then,
  ) = __$$PlaceWithStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'place_id') String id,
    String name,
    String? category,
    String? address,
    @JsonKey(name: 'road_address') String? roadAddress,
    String? telephone,
    double latitude,
    double longitude,
    @JsonKey(name: 'visit_count') int visitCount,
    @JsonKey(name: 'visitor_count') int visitorCount,
    @JsonKey(name: 'last_visited_at') DateTime? lastVisitedAt,
    @JsonKey(name: 'first_visited_at') DateTime? firstVisitedAt,
    @JsonKey(name: 'member_ids') List<String> memberIds,
    @JsonKey(name: 'is_first_together') bool isFirstTogether,
    @JsonKey(name: 'is_starred') bool isStarred,
    @JsonKey(name: 'starred_by_count') int starredByCount,
    @JsonKey(name: 'preview_dot') PreviewDot? previewDot,
    @JsonKey(name: 'comment_count_total') int commentCountTotal,
  });

  @override
  $PreviewDotCopyWith<$Res>? get previewDot;
}

/// @nodoc
class __$$PlaceWithStatsImplCopyWithImpl<$Res>
    extends _$PlaceWithStatsCopyWithImpl<$Res, _$PlaceWithStatsImpl>
    implements _$$PlaceWithStatsImplCopyWith<$Res> {
  __$$PlaceWithStatsImplCopyWithImpl(
    _$PlaceWithStatsImpl _value,
    $Res Function(_$PlaceWithStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlaceWithStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = freezed,
    Object? address = freezed,
    Object? roadAddress = freezed,
    Object? telephone = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? visitCount = null,
    Object? visitorCount = null,
    Object? lastVisitedAt = freezed,
    Object? firstVisitedAt = freezed,
    Object? memberIds = null,
    Object? isFirstTogether = null,
    Object? isStarred = null,
    Object? starredByCount = null,
    Object? previewDot = freezed,
    Object? commentCountTotal = null,
  }) {
    return _then(
      _$PlaceWithStatsImpl(
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
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        visitCount: null == visitCount
            ? _value.visitCount
            : visitCount // ignore: cast_nullable_to_non_nullable
                  as int,
        visitorCount: null == visitorCount
            ? _value.visitorCount
            : visitorCount // ignore: cast_nullable_to_non_nullable
                  as int,
        lastVisitedAt: freezed == lastVisitedAt
            ? _value.lastVisitedAt
            : lastVisitedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        firstVisitedAt: freezed == firstVisitedAt
            ? _value.firstVisitedAt
            : firstVisitedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        memberIds: null == memberIds
            ? _value._memberIds
            : memberIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        isFirstTogether: null == isFirstTogether
            ? _value.isFirstTogether
            : isFirstTogether // ignore: cast_nullable_to_non_nullable
                  as bool,
        isStarred: null == isStarred
            ? _value.isStarred
            : isStarred // ignore: cast_nullable_to_non_nullable
                  as bool,
        starredByCount: null == starredByCount
            ? _value.starredByCount
            : starredByCount // ignore: cast_nullable_to_non_nullable
                  as int,
        previewDot: freezed == previewDot
            ? _value.previewDot
            : previewDot // ignore: cast_nullable_to_non_nullable
                  as PreviewDot?,
        commentCountTotal: null == commentCountTotal
            ? _value.commentCountTotal
            : commentCountTotal // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaceWithStatsImpl extends _PlaceWithStats {
  const _$PlaceWithStatsImpl({
    @JsonKey(name: 'place_id') required this.id,
    required this.name,
    this.category,
    this.address,
    @JsonKey(name: 'road_address') this.roadAddress,
    this.telephone,
    required this.latitude,
    required this.longitude,
    @JsonKey(name: 'visit_count') this.visitCount = 0,
    @JsonKey(name: 'visitor_count') this.visitorCount = 0,
    @JsonKey(name: 'last_visited_at') this.lastVisitedAt,
    @JsonKey(name: 'first_visited_at') this.firstVisitedAt,
    @JsonKey(name: 'member_ids') final List<String> memberIds = const [],
    @JsonKey(name: 'is_first_together') this.isFirstTogether = false,
    @JsonKey(name: 'is_starred') this.isStarred = false,
    @JsonKey(name: 'starred_by_count') this.starredByCount = 0,
    @JsonKey(name: 'preview_dot') this.previewDot,
    @JsonKey(name: 'comment_count_total') this.commentCountTotal = 0,
  }) : _memberIds = memberIds,
       super._();

  factory _$PlaceWithStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaceWithStatsImplFromJson(json);

  @override
  @JsonKey(name: 'place_id')
  final String id;
  @override
  final String name;
  @override
  final String? category;
  @override
  final String? address;
  @override
  @JsonKey(name: 'road_address')
  final String? roadAddress;
  @override
  final String? telephone;
  @override
  final double latitude;
  @override
  final double longitude;
  // ── 룸 통계 ──────────────────────────────
  @override
  @JsonKey(name: 'visit_count')
  final int visitCount;

  /// 이 장소를 방문한 룸 멤버 수.
  @override
  @JsonKey(name: 'visitor_count')
  final int visitorCount;

  /// 가장 최근 방문 (date string `YYYY-MM-DD` 또는 timestamp).
  @override
  @JsonKey(name: 'last_visited_at')
  final DateTime? lastVisitedAt;

  /// 가장 처음 방문 시각.
  @override
  @JsonKey(name: 'first_visited_at')
  final DateTime? firstVisitedAt;
  final List<String> _memberIds;
  @override
  @JsonKey(name: 'member_ids')
  List<String> get memberIds {
    if (_memberIds is EqualUnmodifiableListView) return _memberIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_memberIds);
  }

  /// 요청자와 다른 멤버가 같은 날 함께 방문한 적이 있는지.
  @override
  @JsonKey(name: 'is_first_together')
  final bool isFirstTogether;
  // ── 즐겨찾기 (B9) ──────────────────────────
  @override
  @JsonKey(name: 'is_starred')
  final bool isStarred;

  /// 이 룸에서 이 장소를 별표한 멤버 수.
  @override
  @JsonKey(name: 'starred_by_count')
  final int starredByCount;
  // ── 미리보기 ───────────────────────────────
  @override
  @JsonKey(name: 'preview_dot')
  final PreviewDot? previewDot;

  /// 이 장소 dot 들의 댓글 수 합산.
  @override
  @JsonKey(name: 'comment_count_total')
  final int commentCountTotal;

  @override
  String toString() {
    return 'PlaceWithStats(id: $id, name: $name, category: $category, address: $address, roadAddress: $roadAddress, telephone: $telephone, latitude: $latitude, longitude: $longitude, visitCount: $visitCount, visitorCount: $visitorCount, lastVisitedAt: $lastVisitedAt, firstVisitedAt: $firstVisitedAt, memberIds: $memberIds, isFirstTogether: $isFirstTogether, isStarred: $isStarred, starredByCount: $starredByCount, previewDot: $previewDot, commentCountTotal: $commentCountTotal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaceWithStatsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.roadAddress, roadAddress) ||
                other.roadAddress == roadAddress) &&
            (identical(other.telephone, telephone) ||
                other.telephone == telephone) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.visitCount, visitCount) ||
                other.visitCount == visitCount) &&
            (identical(other.visitorCount, visitorCount) ||
                other.visitorCount == visitorCount) &&
            (identical(other.lastVisitedAt, lastVisitedAt) ||
                other.lastVisitedAt == lastVisitedAt) &&
            (identical(other.firstVisitedAt, firstVisitedAt) ||
                other.firstVisitedAt == firstVisitedAt) &&
            const DeepCollectionEquality().equals(
              other._memberIds,
              _memberIds,
            ) &&
            (identical(other.isFirstTogether, isFirstTogether) ||
                other.isFirstTogether == isFirstTogether) &&
            (identical(other.isStarred, isStarred) ||
                other.isStarred == isStarred) &&
            (identical(other.starredByCount, starredByCount) ||
                other.starredByCount == starredByCount) &&
            (identical(other.previewDot, previewDot) ||
                other.previewDot == previewDot) &&
            (identical(other.commentCountTotal, commentCountTotal) ||
                other.commentCountTotal == commentCountTotal));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    category,
    address,
    roadAddress,
    telephone,
    latitude,
    longitude,
    visitCount,
    visitorCount,
    lastVisitedAt,
    firstVisitedAt,
    const DeepCollectionEquality().hash(_memberIds),
    isFirstTogether,
    isStarred,
    starredByCount,
    previewDot,
    commentCountTotal,
  );

  /// Create a copy of PlaceWithStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaceWithStatsImplCopyWith<_$PlaceWithStatsImpl> get copyWith =>
      __$$PlaceWithStatsImplCopyWithImpl<_$PlaceWithStatsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaceWithStatsImplToJson(this);
  }
}

abstract class _PlaceWithStats extends PlaceWithStats {
  const factory _PlaceWithStats({
    @JsonKey(name: 'place_id') required final String id,
    required final String name,
    final String? category,
    final String? address,
    @JsonKey(name: 'road_address') final String? roadAddress,
    final String? telephone,
    required final double latitude,
    required final double longitude,
    @JsonKey(name: 'visit_count') final int visitCount,
    @JsonKey(name: 'visitor_count') final int visitorCount,
    @JsonKey(name: 'last_visited_at') final DateTime? lastVisitedAt,
    @JsonKey(name: 'first_visited_at') final DateTime? firstVisitedAt,
    @JsonKey(name: 'member_ids') final List<String> memberIds,
    @JsonKey(name: 'is_first_together') final bool isFirstTogether,
    @JsonKey(name: 'is_starred') final bool isStarred,
    @JsonKey(name: 'starred_by_count') final int starredByCount,
    @JsonKey(name: 'preview_dot') final PreviewDot? previewDot,
    @JsonKey(name: 'comment_count_total') final int commentCountTotal,
  }) = _$PlaceWithStatsImpl;
  const _PlaceWithStats._() : super._();

  factory _PlaceWithStats.fromJson(Map<String, dynamic> json) =
      _$PlaceWithStatsImpl.fromJson;

  @override
  @JsonKey(name: 'place_id')
  String get id;
  @override
  String get name;
  @override
  String? get category;
  @override
  String? get address;
  @override
  @JsonKey(name: 'road_address')
  String? get roadAddress;
  @override
  String? get telephone;
  @override
  double get latitude;
  @override
  double get longitude; // ── 룸 통계 ──────────────────────────────
  @override
  @JsonKey(name: 'visit_count')
  int get visitCount;

  /// 이 장소를 방문한 룸 멤버 수.
  @override
  @JsonKey(name: 'visitor_count')
  int get visitorCount;

  /// 가장 최근 방문 (date string `YYYY-MM-DD` 또는 timestamp).
  @override
  @JsonKey(name: 'last_visited_at')
  DateTime? get lastVisitedAt;

  /// 가장 처음 방문 시각.
  @override
  @JsonKey(name: 'first_visited_at')
  DateTime? get firstVisitedAt;
  @override
  @JsonKey(name: 'member_ids')
  List<String> get memberIds;

  /// 요청자와 다른 멤버가 같은 날 함께 방문한 적이 있는지.
  @override
  @JsonKey(name: 'is_first_together')
  bool get isFirstTogether; // ── 즐겨찾기 (B9) ──────────────────────────
  @override
  @JsonKey(name: 'is_starred')
  bool get isStarred;

  /// 이 룸에서 이 장소를 별표한 멤버 수.
  @override
  @JsonKey(name: 'starred_by_count')
  int get starredByCount; // ── 미리보기 ───────────────────────────────
  @override
  @JsonKey(name: 'preview_dot')
  PreviewDot? get previewDot;

  /// 이 장소 dot 들의 댓글 수 합산.
  @override
  @JsonKey(name: 'comment_count_total')
  int get commentCountTotal;

  /// Create a copy of PlaceWithStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaceWithStatsImplCopyWith<_$PlaceWithStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PreviewDot _$PreviewDotFromJson(Map<String, dynamic> json) {
  return _PreviewDot.fromJson(json);
}

/// @nodoc
mixin _$PreviewDot {
  @JsonKey(name: 'dot_id')
  String get dotId => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_url')
  String? get photoUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_thumb_url')
  String? get photoThumbUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_preview_url')
  String? get photoPreviewUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;

  /// Serializes this PreviewDot to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PreviewDot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PreviewDotCopyWith<PreviewDot> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PreviewDotCopyWith<$Res> {
  factory $PreviewDotCopyWith(
    PreviewDot value,
    $Res Function(PreviewDot) then,
  ) = _$PreviewDotCopyWithImpl<$Res, PreviewDot>;
  @useResult
  $Res call({
    @JsonKey(name: 'dot_id') String dotId,
    @JsonKey(name: 'photo_url') String? photoUrl,
    @JsonKey(name: 'photo_thumb_url') String? photoThumbUrl,
    @JsonKey(name: 'photo_preview_url') String? photoPreviewUrl,
    @JsonKey(name: 'user_id') String userId,
  });
}

/// @nodoc
class _$PreviewDotCopyWithImpl<$Res, $Val extends PreviewDot>
    implements $PreviewDotCopyWith<$Res> {
  _$PreviewDotCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PreviewDot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dotId = null,
    Object? photoUrl = freezed,
    Object? photoThumbUrl = freezed,
    Object? photoPreviewUrl = freezed,
    Object? userId = null,
  }) {
    return _then(
      _value.copyWith(
            dotId: null == dotId
                ? _value.dotId
                : dotId // ignore: cast_nullable_to_non_nullable
                      as String,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoThumbUrl: freezed == photoThumbUrl
                ? _value.photoThumbUrl
                : photoThumbUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoPreviewUrl: freezed == photoPreviewUrl
                ? _value.photoPreviewUrl
                : photoPreviewUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PreviewDotImplCopyWith<$Res>
    implements $PreviewDotCopyWith<$Res> {
  factory _$$PreviewDotImplCopyWith(
    _$PreviewDotImpl value,
    $Res Function(_$PreviewDotImpl) then,
  ) = __$$PreviewDotImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'dot_id') String dotId,
    @JsonKey(name: 'photo_url') String? photoUrl,
    @JsonKey(name: 'photo_thumb_url') String? photoThumbUrl,
    @JsonKey(name: 'photo_preview_url') String? photoPreviewUrl,
    @JsonKey(name: 'user_id') String userId,
  });
}

/// @nodoc
class __$$PreviewDotImplCopyWithImpl<$Res>
    extends _$PreviewDotCopyWithImpl<$Res, _$PreviewDotImpl>
    implements _$$PreviewDotImplCopyWith<$Res> {
  __$$PreviewDotImplCopyWithImpl(
    _$PreviewDotImpl _value,
    $Res Function(_$PreviewDotImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PreviewDot
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dotId = null,
    Object? photoUrl = freezed,
    Object? photoThumbUrl = freezed,
    Object? photoPreviewUrl = freezed,
    Object? userId = null,
  }) {
    return _then(
      _$PreviewDotImpl(
        dotId: null == dotId
            ? _value.dotId
            : dotId // ignore: cast_nullable_to_non_nullable
                  as String,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoThumbUrl: freezed == photoThumbUrl
            ? _value.photoThumbUrl
            : photoThumbUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoPreviewUrl: freezed == photoPreviewUrl
            ? _value.photoPreviewUrl
            : photoPreviewUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PreviewDotImpl implements _PreviewDot {
  const _$PreviewDotImpl({
    @JsonKey(name: 'dot_id') required this.dotId,
    @JsonKey(name: 'photo_url') this.photoUrl,
    @JsonKey(name: 'photo_thumb_url') this.photoThumbUrl,
    @JsonKey(name: 'photo_preview_url') this.photoPreviewUrl,
    @JsonKey(name: 'user_id') required this.userId,
  });

  factory _$PreviewDotImpl.fromJson(Map<String, dynamic> json) =>
      _$$PreviewDotImplFromJson(json);

  @override
  @JsonKey(name: 'dot_id')
  final String dotId;
  @override
  @JsonKey(name: 'photo_url')
  final String? photoUrl;
  @override
  @JsonKey(name: 'photo_thumb_url')
  final String? photoThumbUrl;
  @override
  @JsonKey(name: 'photo_preview_url')
  final String? photoPreviewUrl;
  @override
  @JsonKey(name: 'user_id')
  final String userId;

  @override
  String toString() {
    return 'PreviewDot(dotId: $dotId, photoUrl: $photoUrl, photoThumbUrl: $photoThumbUrl, photoPreviewUrl: $photoPreviewUrl, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreviewDotImpl &&
            (identical(other.dotId, dotId) || other.dotId == dotId) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.photoThumbUrl, photoThumbUrl) ||
                other.photoThumbUrl == photoThumbUrl) &&
            (identical(other.photoPreviewUrl, photoPreviewUrl) ||
                other.photoPreviewUrl == photoPreviewUrl) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    dotId,
    photoUrl,
    photoThumbUrl,
    photoPreviewUrl,
    userId,
  );

  /// Create a copy of PreviewDot
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PreviewDotImplCopyWith<_$PreviewDotImpl> get copyWith =>
      __$$PreviewDotImplCopyWithImpl<_$PreviewDotImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PreviewDotImplToJson(this);
  }
}

abstract class _PreviewDot implements PreviewDot {
  const factory _PreviewDot({
    @JsonKey(name: 'dot_id') required final String dotId,
    @JsonKey(name: 'photo_url') final String? photoUrl,
    @JsonKey(name: 'photo_thumb_url') final String? photoThumbUrl,
    @JsonKey(name: 'photo_preview_url') final String? photoPreviewUrl,
    @JsonKey(name: 'user_id') required final String userId,
  }) = _$PreviewDotImpl;

  factory _PreviewDot.fromJson(Map<String, dynamic> json) =
      _$PreviewDotImpl.fromJson;

  @override
  @JsonKey(name: 'dot_id')
  String get dotId;
  @override
  @JsonKey(name: 'photo_url')
  String? get photoUrl;
  @override
  @JsonKey(name: 'photo_thumb_url')
  String? get photoThumbUrl;
  @override
  @JsonKey(name: 'photo_preview_url')
  String? get photoPreviewUrl;
  @override
  @JsonKey(name: 'user_id')
  String get userId;

  /// Create a copy of PreviewDot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PreviewDotImplCopyWith<_$PreviewDotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RoomPlacesData _$RoomPlacesDataFromJson(Map<String, dynamic> json) {
  return _RoomPlacesData.fromJson(json);
}

/// @nodoc
mixin _$RoomPlacesData {
  List<PlaceWithStats> get places => throw _privateConstructorUsedError;
  @JsonKey(name: 'next_cursor')
  String? get nextCursor => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;

  /// Serializes this RoomPlacesData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoomPlacesData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoomPlacesDataCopyWith<RoomPlacesData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomPlacesDataCopyWith<$Res> {
  factory $RoomPlacesDataCopyWith(
    RoomPlacesData value,
    $Res Function(RoomPlacesData) then,
  ) = _$RoomPlacesDataCopyWithImpl<$Res, RoomPlacesData>;
  @useResult
  $Res call({
    List<PlaceWithStats> places,
    @JsonKey(name: 'next_cursor') String? nextCursor,
    int total,
  });
}

/// @nodoc
class _$RoomPlacesDataCopyWithImpl<$Res, $Val extends RoomPlacesData>
    implements $RoomPlacesDataCopyWith<$Res> {
  _$RoomPlacesDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoomPlacesData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? places = null,
    Object? nextCursor = freezed,
    Object? total = null,
  }) {
    return _then(
      _value.copyWith(
            places: null == places
                ? _value.places
                : places // ignore: cast_nullable_to_non_nullable
                      as List<PlaceWithStats>,
            nextCursor: freezed == nextCursor
                ? _value.nextCursor
                : nextCursor // ignore: cast_nullable_to_non_nullable
                      as String?,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RoomPlacesDataImplCopyWith<$Res>
    implements $RoomPlacesDataCopyWith<$Res> {
  factory _$$RoomPlacesDataImplCopyWith(
    _$RoomPlacesDataImpl value,
    $Res Function(_$RoomPlacesDataImpl) then,
  ) = __$$RoomPlacesDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<PlaceWithStats> places,
    @JsonKey(name: 'next_cursor') String? nextCursor,
    int total,
  });
}

/// @nodoc
class __$$RoomPlacesDataImplCopyWithImpl<$Res>
    extends _$RoomPlacesDataCopyWithImpl<$Res, _$RoomPlacesDataImpl>
    implements _$$RoomPlacesDataImplCopyWith<$Res> {
  __$$RoomPlacesDataImplCopyWithImpl(
    _$RoomPlacesDataImpl _value,
    $Res Function(_$RoomPlacesDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RoomPlacesData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? places = null,
    Object? nextCursor = freezed,
    Object? total = null,
  }) {
    return _then(
      _$RoomPlacesDataImpl(
        places: null == places
            ? _value._places
            : places // ignore: cast_nullable_to_non_nullable
                  as List<PlaceWithStats>,
        nextCursor: freezed == nextCursor
            ? _value.nextCursor
            : nextCursor // ignore: cast_nullable_to_non_nullable
                  as String?,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RoomPlacesDataImpl implements _RoomPlacesData {
  const _$RoomPlacesDataImpl({
    final List<PlaceWithStats> places = const [],
    @JsonKey(name: 'next_cursor') this.nextCursor,
    this.total = 0,
  }) : _places = places;

  factory _$RoomPlacesDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoomPlacesDataImplFromJson(json);

  final List<PlaceWithStats> _places;
  @override
  @JsonKey()
  List<PlaceWithStats> get places {
    if (_places is EqualUnmodifiableListView) return _places;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_places);
  }

  @override
  @JsonKey(name: 'next_cursor')
  final String? nextCursor;
  @override
  @JsonKey()
  final int total;

  @override
  String toString() {
    return 'RoomPlacesData(places: $places, nextCursor: $nextCursor, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomPlacesDataImpl &&
            const DeepCollectionEquality().equals(other._places, _places) &&
            (identical(other.nextCursor, nextCursor) ||
                other.nextCursor == nextCursor) &&
            (identical(other.total, total) || other.total == total));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_places),
    nextCursor,
    total,
  );

  /// Create a copy of RoomPlacesData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomPlacesDataImplCopyWith<_$RoomPlacesDataImpl> get copyWith =>
      __$$RoomPlacesDataImplCopyWithImpl<_$RoomPlacesDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RoomPlacesDataImplToJson(this);
  }
}

abstract class _RoomPlacesData implements RoomPlacesData {
  const factory _RoomPlacesData({
    final List<PlaceWithStats> places,
    @JsonKey(name: 'next_cursor') final String? nextCursor,
    final int total,
  }) = _$RoomPlacesDataImpl;

  factory _RoomPlacesData.fromJson(Map<String, dynamic> json) =
      _$RoomPlacesDataImpl.fromJson;

  @override
  List<PlaceWithStats> get places;
  @override
  @JsonKey(name: 'next_cursor')
  String? get nextCursor;
  @override
  int get total;

  /// Create a copy of RoomPlacesData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoomPlacesDataImplCopyWith<_$RoomPlacesDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
