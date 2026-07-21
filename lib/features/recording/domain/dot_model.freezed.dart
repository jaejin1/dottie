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

  /// 업로드 직후 R2 원본 URL. **BE 응답에선 더 이상 안 옴** —
  /// (a) `POST /v1/dots` / `POST /v1/dots/batch` 요청 페이로드 (`photo_url`),
  /// (b) variant 생성 전 transient 로컬 캐시 ("처리 중" placeholder 트리거)
  /// 두 용도로만 쓰임. 표시는 [DotPhotoX.displayPhotoUrl] 사용.
  String? get photoUrl =>
      throw _privateConstructorUsedError; // BE 가 비동기로 생성하는 사진 variant.
  //   - photoThumbUrl: 160×160 center-crop JPEG (지도 핀, 리스트 미리보기)
  //   - photoPreviewUrl: 긴 변 720px JPEG (상세 / 본문)
  // 업로드 직후엔 둘 다 null — 수 초 내 BE 백그라운드 워커가 채움.
  @JsonKey(name: 'photo_thumb_url')
  String? get photoThumbUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_preview_url')
  String? get photoPreviewUrl => throw _privateConstructorUsedError;
  String? get memo => throw _privateConstructorUsedError;
  String? get emotion => throw _privateConstructorUsedError;
  String get dayLogId => throw _privateConstructorUsedError;
  bool get synced =>
      throw _privateConstructorUsedError; // BE 응답에서 매핑되는 댓글 메타. 로컬 dot(drift) 또는 다른 엔드포인트에서
  // 가져온 dot 은 default 0/null 로 안전.
  int get commentCount => throw _privateConstructorUsedError;
  DateTime? get lastCommentedAt =>
      throw _privateConstructorUsedError; // B8 — 사용자가 장소 선택 시 BE 가 매칭한 place_id + 응답 inline place.
  // 로컬 dot 이나 장소 미선택 dot 은 null.
  String? get placeId => throw _privateConstructorUsedError;
  Place? get place =>
      throw _privateConstructorUsedError; // 메모에서 추출된 해시태그 (정규화: lowercase, 30자, 최대 10개).
  // BE 가 권위 — FE 는 입력 시 prefilter 만 하고, 응답을 신뢰.
  List<String> get tags => throw _privateConstructorUsedError;

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
    @JsonKey(name: 'photo_thumb_url') String? photoThumbUrl,
    @JsonKey(name: 'photo_preview_url') String? photoPreviewUrl,
    String? memo,
    String? emotion,
    String dayLogId,
    bool synced,
    int commentCount,
    DateTime? lastCommentedAt,
    String? placeId,
    Place? place,
    List<String> tags,
  });

  $PlaceCopyWith<$Res>? get place;
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
    Object? photoThumbUrl = freezed,
    Object? photoPreviewUrl = freezed,
    Object? memo = freezed,
    Object? emotion = freezed,
    Object? dayLogId = null,
    Object? synced = null,
    Object? commentCount = null,
    Object? lastCommentedAt = freezed,
    Object? placeId = freezed,
    Object? place = freezed,
    Object? tags = null,
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
            photoThumbUrl: freezed == photoThumbUrl
                ? _value.photoThumbUrl
                : photoThumbUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoPreviewUrl: freezed == photoPreviewUrl
                ? _value.photoPreviewUrl
                : photoPreviewUrl // ignore: cast_nullable_to_non_nullable
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
            commentCount: null == commentCount
                ? _value.commentCount
                : commentCount // ignore: cast_nullable_to_non_nullable
                      as int,
            lastCommentedAt: freezed == lastCommentedAt
                ? _value.lastCommentedAt
                : lastCommentedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            placeId: freezed == placeId
                ? _value.placeId
                : placeId // ignore: cast_nullable_to_non_nullable
                      as String?,
            place: freezed == place
                ? _value.place
                : place // ignore: cast_nullable_to_non_nullable
                      as Place?,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }

  /// Create a copy of Dot
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
    @JsonKey(name: 'photo_thumb_url') String? photoThumbUrl,
    @JsonKey(name: 'photo_preview_url') String? photoPreviewUrl,
    String? memo,
    String? emotion,
    String dayLogId,
    bool synced,
    int commentCount,
    DateTime? lastCommentedAt,
    String? placeId,
    Place? place,
    List<String> tags,
  });

  @override
  $PlaceCopyWith<$Res>? get place;
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
    Object? photoThumbUrl = freezed,
    Object? photoPreviewUrl = freezed,
    Object? memo = freezed,
    Object? emotion = freezed,
    Object? dayLogId = null,
    Object? synced = null,
    Object? commentCount = null,
    Object? lastCommentedAt = freezed,
    Object? placeId = freezed,
    Object? place = freezed,
    Object? tags = null,
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
        photoThumbUrl: freezed == photoThumbUrl
            ? _value.photoThumbUrl
            : photoThumbUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoPreviewUrl: freezed == photoPreviewUrl
            ? _value.photoPreviewUrl
            : photoPreviewUrl // ignore: cast_nullable_to_non_nullable
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
        commentCount: null == commentCount
            ? _value.commentCount
            : commentCount // ignore: cast_nullable_to_non_nullable
                  as int,
        lastCommentedAt: freezed == lastCommentedAt
            ? _value.lastCommentedAt
            : lastCommentedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        placeId: freezed == placeId
            ? _value.placeId
            : placeId // ignore: cast_nullable_to_non_nullable
                  as String?,
        place: freezed == place
            ? _value.place
            : place // ignore: cast_nullable_to_non_nullable
                  as Place?,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
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
    @JsonKey(name: 'photo_thumb_url') this.photoThumbUrl,
    @JsonKey(name: 'photo_preview_url') this.photoPreviewUrl,
    this.memo,
    this.emotion,
    required this.dayLogId,
    this.synced = false,
    this.commentCount = 0,
    this.lastCommentedAt,
    this.placeId,
    this.place,
    final List<String> tags = const <String>[],
  }) : _tags = tags;

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

  /// 업로드 직후 R2 원본 URL. **BE 응답에선 더 이상 안 옴** —
  /// (a) `POST /v1/dots` / `POST /v1/dots/batch` 요청 페이로드 (`photo_url`),
  /// (b) variant 생성 전 transient 로컬 캐시 ("처리 중" placeholder 트리거)
  /// 두 용도로만 쓰임. 표시는 [DotPhotoX.displayPhotoUrl] 사용.
  @override
  final String? photoUrl;
  // BE 가 비동기로 생성하는 사진 variant.
  //   - photoThumbUrl: 160×160 center-crop JPEG (지도 핀, 리스트 미리보기)
  //   - photoPreviewUrl: 긴 변 720px JPEG (상세 / 본문)
  // 업로드 직후엔 둘 다 null — 수 초 내 BE 백그라운드 워커가 채움.
  @override
  @JsonKey(name: 'photo_thumb_url')
  final String? photoThumbUrl;
  @override
  @JsonKey(name: 'photo_preview_url')
  final String? photoPreviewUrl;
  @override
  final String? memo;
  @override
  final String? emotion;
  @override
  final String dayLogId;
  @override
  @JsonKey()
  final bool synced;
  // BE 응답에서 매핑되는 댓글 메타. 로컬 dot(drift) 또는 다른 엔드포인트에서
  // 가져온 dot 은 default 0/null 로 안전.
  @override
  @JsonKey()
  final int commentCount;
  @override
  final DateTime? lastCommentedAt;
  // B8 — 사용자가 장소 선택 시 BE 가 매칭한 place_id + 응답 inline place.
  // 로컬 dot 이나 장소 미선택 dot 은 null.
  @override
  final String? placeId;
  @override
  final Place? place;
  // 메모에서 추출된 해시태그 (정규화: lowercase, 30자, 최대 10개).
  // BE 가 권위 — FE 는 입력 시 prefilter 만 하고, 응답을 신뢰.
  final List<String> _tags;
  // 메모에서 추출된 해시태그 (정규화: lowercase, 30자, 최대 10개).
  // BE 가 권위 — FE 는 입력 시 prefilter 만 하고, 응답을 신뢰.
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  String toString() {
    return 'Dot(id: $id, latitude: $latitude, longitude: $longitude, timestamp: $timestamp, placeName: $placeName, placeCategory: $placeCategory, photoUrl: $photoUrl, photoThumbUrl: $photoThumbUrl, photoPreviewUrl: $photoPreviewUrl, memo: $memo, emotion: $emotion, dayLogId: $dayLogId, synced: $synced, commentCount: $commentCount, lastCommentedAt: $lastCommentedAt, placeId: $placeId, place: $place, tags: $tags)';
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
            (identical(other.photoThumbUrl, photoThumbUrl) ||
                other.photoThumbUrl == photoThumbUrl) &&
            (identical(other.photoPreviewUrl, photoPreviewUrl) ||
                other.photoPreviewUrl == photoPreviewUrl) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            (identical(other.emotion, emotion) || other.emotion == emotion) &&
            (identical(other.dayLogId, dayLogId) ||
                other.dayLogId == dayLogId) &&
            (identical(other.synced, synced) || other.synced == synced) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.lastCommentedAt, lastCommentedAt) ||
                other.lastCommentedAt == lastCommentedAt) &&
            (identical(other.placeId, placeId) || other.placeId == placeId) &&
            (identical(other.place, place) || other.place == place) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
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
    photoThumbUrl,
    photoPreviewUrl,
    memo,
    emotion,
    dayLogId,
    synced,
    commentCount,
    lastCommentedAt,
    placeId,
    place,
    const DeepCollectionEquality().hash(_tags),
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
    @JsonKey(name: 'photo_thumb_url') final String? photoThumbUrl,
    @JsonKey(name: 'photo_preview_url') final String? photoPreviewUrl,
    final String? memo,
    final String? emotion,
    required final String dayLogId,
    final bool synced,
    final int commentCount,
    final DateTime? lastCommentedAt,
    final String? placeId,
    final Place? place,
    final List<String> tags,
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

  /// 업로드 직후 R2 원본 URL. **BE 응답에선 더 이상 안 옴** —
  /// (a) `POST /v1/dots` / `POST /v1/dots/batch` 요청 페이로드 (`photo_url`),
  /// (b) variant 생성 전 transient 로컬 캐시 ("처리 중" placeholder 트리거)
  /// 두 용도로만 쓰임. 표시는 [DotPhotoX.displayPhotoUrl] 사용.
  @override
  String? get photoUrl; // BE 가 비동기로 생성하는 사진 variant.
  //   - photoThumbUrl: 160×160 center-crop JPEG (지도 핀, 리스트 미리보기)
  //   - photoPreviewUrl: 긴 변 720px JPEG (상세 / 본문)
  // 업로드 직후엔 둘 다 null — 수 초 내 BE 백그라운드 워커가 채움.
  @override
  @JsonKey(name: 'photo_thumb_url')
  String? get photoThumbUrl;
  @override
  @JsonKey(name: 'photo_preview_url')
  String? get photoPreviewUrl;
  @override
  String? get memo;
  @override
  String? get emotion;
  @override
  String get dayLogId;
  @override
  bool get synced; // BE 응답에서 매핑되는 댓글 메타. 로컬 dot(drift) 또는 다른 엔드포인트에서
  // 가져온 dot 은 default 0/null 로 안전.
  @override
  int get commentCount;
  @override
  DateTime? get lastCommentedAt; // B8 — 사용자가 장소 선택 시 BE 가 매칭한 place_id + 응답 inline place.
  // 로컬 dot 이나 장소 미선택 dot 은 null.
  @override
  String? get placeId;
  @override
  Place? get place; // 메모에서 추출된 해시태그 (정규화: lowercase, 30자, 최대 10개).
  // BE 가 권위 — FE 는 입력 시 prefilter 만 하고, 응답을 신뢰.
  @override
  List<String> get tags;

  /// Create a copy of Dot
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DotImplCopyWith<_$DotImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
