// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'place_insights.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PlaceInsights _$PlaceInsightsFromJson(Map<String, dynamic> json) {
  return _PlaceInsights.fromJson(json);
}

/// @nodoc
mixin _$PlaceInsights {
  Place get place => throw _privateConstructorUsedError;
  List<PlaceVisitor> get visitors => throw _privateConstructorUsedError;

  /// Serializes this PlaceInsights to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlaceInsights
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaceInsightsCopyWith<PlaceInsights> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaceInsightsCopyWith<$Res> {
  factory $PlaceInsightsCopyWith(
    PlaceInsights value,
    $Res Function(PlaceInsights) then,
  ) = _$PlaceInsightsCopyWithImpl<$Res, PlaceInsights>;
  @useResult
  $Res call({Place place, List<PlaceVisitor> visitors});

  $PlaceCopyWith<$Res> get place;
}

/// @nodoc
class _$PlaceInsightsCopyWithImpl<$Res, $Val extends PlaceInsights>
    implements $PlaceInsightsCopyWith<$Res> {
  _$PlaceInsightsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlaceInsights
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? place = null, Object? visitors = null}) {
    return _then(
      _value.copyWith(
            place: null == place
                ? _value.place
                : place // ignore: cast_nullable_to_non_nullable
                      as Place,
            visitors: null == visitors
                ? _value.visitors
                : visitors // ignore: cast_nullable_to_non_nullable
                      as List<PlaceVisitor>,
          )
          as $Val,
    );
  }

  /// Create a copy of PlaceInsights
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PlaceCopyWith<$Res> get place {
    return $PlaceCopyWith<$Res>(_value.place, (value) {
      return _then(_value.copyWith(place: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PlaceInsightsImplCopyWith<$Res>
    implements $PlaceInsightsCopyWith<$Res> {
  factory _$$PlaceInsightsImplCopyWith(
    _$PlaceInsightsImpl value,
    $Res Function(_$PlaceInsightsImpl) then,
  ) = __$$PlaceInsightsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Place place, List<PlaceVisitor> visitors});

  @override
  $PlaceCopyWith<$Res> get place;
}

/// @nodoc
class __$$PlaceInsightsImplCopyWithImpl<$Res>
    extends _$PlaceInsightsCopyWithImpl<$Res, _$PlaceInsightsImpl>
    implements _$$PlaceInsightsImplCopyWith<$Res> {
  __$$PlaceInsightsImplCopyWithImpl(
    _$PlaceInsightsImpl _value,
    $Res Function(_$PlaceInsightsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlaceInsights
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? place = null, Object? visitors = null}) {
    return _then(
      _$PlaceInsightsImpl(
        place: null == place
            ? _value.place
            : place // ignore: cast_nullable_to_non_nullable
                  as Place,
        visitors: null == visitors
            ? _value._visitors
            : visitors // ignore: cast_nullable_to_non_nullable
                  as List<PlaceVisitor>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaceInsightsImpl implements _PlaceInsights {
  const _$PlaceInsightsImpl({
    required this.place,
    final List<PlaceVisitor> visitors = const [],
  }) : _visitors = visitors;

  factory _$PlaceInsightsImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaceInsightsImplFromJson(json);

  @override
  final Place place;
  final List<PlaceVisitor> _visitors;
  @override
  @JsonKey()
  List<PlaceVisitor> get visitors {
    if (_visitors is EqualUnmodifiableListView) return _visitors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_visitors);
  }

  @override
  String toString() {
    return 'PlaceInsights(place: $place, visitors: $visitors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaceInsightsImpl &&
            (identical(other.place, place) || other.place == place) &&
            const DeepCollectionEquality().equals(other._visitors, _visitors));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    place,
    const DeepCollectionEquality().hash(_visitors),
  );

  /// Create a copy of PlaceInsights
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaceInsightsImplCopyWith<_$PlaceInsightsImpl> get copyWith =>
      __$$PlaceInsightsImplCopyWithImpl<_$PlaceInsightsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaceInsightsImplToJson(this);
  }
}

abstract class _PlaceInsights implements PlaceInsights {
  const factory _PlaceInsights({
    required final Place place,
    final List<PlaceVisitor> visitors,
  }) = _$PlaceInsightsImpl;

  factory _PlaceInsights.fromJson(Map<String, dynamic> json) =
      _$PlaceInsightsImpl.fromJson;

  @override
  Place get place;
  @override
  List<PlaceVisitor> get visitors;

  /// Create a copy of PlaceInsights
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaceInsightsImplCopyWith<_$PlaceInsightsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PlaceVisitor _$PlaceVisitorFromJson(Map<String, dynamic> json) {
  return _PlaceVisitor.fromJson(json);
}

/// @nodoc
mixin _$PlaceVisitor {
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  @JsonKey(name: 'character_config')
  PaperdollConfig get characterConfig => throw _privateConstructorUsedError;
  @JsonKey(name: 'visit_count')
  int get visitCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_visited_at')
  DateTime get firstVisitedAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_visited_at')
  DateTime get lastVisitedAt => throw _privateConstructorUsedError;

  /// Serializes this PlaceVisitor to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PlaceVisitor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PlaceVisitorCopyWith<PlaceVisitor> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlaceVisitorCopyWith<$Res> {
  factory $PlaceVisitorCopyWith(
    PlaceVisitor value,
    $Res Function(PlaceVisitor) then,
  ) = _$PlaceVisitorCopyWithImpl<$Res, PlaceVisitor>;
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    String nickname,
    @JsonKey(name: 'character_config') PaperdollConfig characterConfig,
    @JsonKey(name: 'visit_count') int visitCount,
    @JsonKey(name: 'first_visited_at') DateTime firstVisitedAt,
    @JsonKey(name: 'last_visited_at') DateTime lastVisitedAt,
  });
}

/// @nodoc
class _$PlaceVisitorCopyWithImpl<$Res, $Val extends PlaceVisitor>
    implements $PlaceVisitorCopyWith<$Res> {
  _$PlaceVisitorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PlaceVisitor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? characterConfig = null,
    Object? visitCount = null,
    Object? firstVisitedAt = null,
    Object? lastVisitedAt = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            nickname: null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String,
            characterConfig: null == characterConfig
                ? _value.characterConfig
                : characterConfig // ignore: cast_nullable_to_non_nullable
                      as PaperdollConfig,
            visitCount: null == visitCount
                ? _value.visitCount
                : visitCount // ignore: cast_nullable_to_non_nullable
                      as int,
            firstVisitedAt: null == firstVisitedAt
                ? _value.firstVisitedAt
                : firstVisitedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastVisitedAt: null == lastVisitedAt
                ? _value.lastVisitedAt
                : lastVisitedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PlaceVisitorImplCopyWith<$Res>
    implements $PlaceVisitorCopyWith<$Res> {
  factory _$$PlaceVisitorImplCopyWith(
    _$PlaceVisitorImpl value,
    $Res Function(_$PlaceVisitorImpl) then,
  ) = __$$PlaceVisitorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    String nickname,
    @JsonKey(name: 'character_config') PaperdollConfig characterConfig,
    @JsonKey(name: 'visit_count') int visitCount,
    @JsonKey(name: 'first_visited_at') DateTime firstVisitedAt,
    @JsonKey(name: 'last_visited_at') DateTime lastVisitedAt,
  });
}

/// @nodoc
class __$$PlaceVisitorImplCopyWithImpl<$Res>
    extends _$PlaceVisitorCopyWithImpl<$Res, _$PlaceVisitorImpl>
    implements _$$PlaceVisitorImplCopyWith<$Res> {
  __$$PlaceVisitorImplCopyWithImpl(
    _$PlaceVisitorImpl _value,
    $Res Function(_$PlaceVisitorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PlaceVisitor
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? characterConfig = null,
    Object? visitCount = null,
    Object? firstVisitedAt = null,
    Object? lastVisitedAt = null,
  }) {
    return _then(
      _$PlaceVisitorImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        nickname: null == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String,
        characterConfig: null == characterConfig
            ? _value.characterConfig
            : characterConfig // ignore: cast_nullable_to_non_nullable
                  as PaperdollConfig,
        visitCount: null == visitCount
            ? _value.visitCount
            : visitCount // ignore: cast_nullable_to_non_nullable
                  as int,
        firstVisitedAt: null == firstVisitedAt
            ? _value.firstVisitedAt
            : firstVisitedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastVisitedAt: null == lastVisitedAt
            ? _value.lastVisitedAt
            : lastVisitedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PlaceVisitorImpl implements _PlaceVisitor {
  const _$PlaceVisitorImpl({
    @JsonKey(name: 'user_id') required this.userId,
    required this.nickname,
    @JsonKey(name: 'character_config')
    this.characterConfig = PaperdollConfig.defaults,
    @JsonKey(name: 'visit_count') required this.visitCount,
    @JsonKey(name: 'first_visited_at') required this.firstVisitedAt,
    @JsonKey(name: 'last_visited_at') required this.lastVisitedAt,
  });

  factory _$PlaceVisitorImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlaceVisitorImplFromJson(json);

  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String nickname;
  @override
  @JsonKey(name: 'character_config')
  final PaperdollConfig characterConfig;
  @override
  @JsonKey(name: 'visit_count')
  final int visitCount;
  @override
  @JsonKey(name: 'first_visited_at')
  final DateTime firstVisitedAt;
  @override
  @JsonKey(name: 'last_visited_at')
  final DateTime lastVisitedAt;

  @override
  String toString() {
    return 'PlaceVisitor(userId: $userId, nickname: $nickname, characterConfig: $characterConfig, visitCount: $visitCount, firstVisitedAt: $firstVisitedAt, lastVisitedAt: $lastVisitedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlaceVisitorImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.characterConfig, characterConfig) ||
                other.characterConfig == characterConfig) &&
            (identical(other.visitCount, visitCount) ||
                other.visitCount == visitCount) &&
            (identical(other.firstVisitedAt, firstVisitedAt) ||
                other.firstVisitedAt == firstVisitedAt) &&
            (identical(other.lastVisitedAt, lastVisitedAt) ||
                other.lastVisitedAt == lastVisitedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    nickname,
    characterConfig,
    visitCount,
    firstVisitedAt,
    lastVisitedAt,
  );

  /// Create a copy of PlaceVisitor
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PlaceVisitorImplCopyWith<_$PlaceVisitorImpl> get copyWith =>
      __$$PlaceVisitorImplCopyWithImpl<_$PlaceVisitorImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlaceVisitorImplToJson(this);
  }
}

abstract class _PlaceVisitor implements PlaceVisitor {
  const factory _PlaceVisitor({
    @JsonKey(name: 'user_id') required final String userId,
    required final String nickname,
    @JsonKey(name: 'character_config') final PaperdollConfig characterConfig,
    @JsonKey(name: 'visit_count') required final int visitCount,
    @JsonKey(name: 'first_visited_at') required final DateTime firstVisitedAt,
    @JsonKey(name: 'last_visited_at') required final DateTime lastVisitedAt,
  }) = _$PlaceVisitorImpl;

  factory _PlaceVisitor.fromJson(Map<String, dynamic> json) =
      _$PlaceVisitorImpl.fromJson;

  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get nickname;
  @override
  @JsonKey(name: 'character_config')
  PaperdollConfig get characterConfig;
  @override
  @JsonKey(name: 'visit_count')
  int get visitCount;
  @override
  @JsonKey(name: 'first_visited_at')
  DateTime get firstVisitedAt;
  @override
  @JsonKey(name: 'last_visited_at')
  DateTime get lastVisitedAt;

  /// Create a copy of PlaceVisitor
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PlaceVisitorImplCopyWith<_$PlaceVisitorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
