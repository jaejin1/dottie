// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cumulative_map_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cumulativeRoomDotsHash() =>
    r'013f80cdd37d6aeebbd1684cab3574f343469040';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// B7 — 룸 누적 dot 단일 endpoint 호출 (`/v1/rooms/:id/cumulative-dots`).
/// cursor pagination 자동 루프.
///
/// 응답 가정:
///   { data: { members: [...], dots: [...], next_cursor: ... } }
///   - dots[].user_id 로 members 참조 (평면 구조)
///   - dots[] 에 B3(comment_count/last_commented_at), B8(place_id/place) 포함
///
/// 응답 형태가 다르면 _dotFromCumulative 만 수정.
///
/// Copied from [cumulativeRoomDots].
@ProviderFor(cumulativeRoomDots)
const cumulativeRoomDotsProvider = CumulativeRoomDotsFamily();

/// B7 — 룸 누적 dot 단일 endpoint 호출 (`/v1/rooms/:id/cumulative-dots`).
/// cursor pagination 자동 루프.
///
/// 응답 가정:
///   { data: { members: [...], dots: [...], next_cursor: ... } }
///   - dots[].user_id 로 members 참조 (평면 구조)
///   - dots[] 에 B3(comment_count/last_commented_at), B8(place_id/place) 포함
///
/// 응답 형태가 다르면 _dotFromCumulative 만 수정.
///
/// Copied from [cumulativeRoomDots].
class CumulativeRoomDotsFamily extends Family<AsyncValue<List<RoomDot>>> {
  /// B7 — 룸 누적 dot 단일 endpoint 호출 (`/v1/rooms/:id/cumulative-dots`).
  /// cursor pagination 자동 루프.
  ///
  /// 응답 가정:
  ///   { data: { members: [...], dots: [...], next_cursor: ... } }
  ///   - dots[].user_id 로 members 참조 (평면 구조)
  ///   - dots[] 에 B3(comment_count/last_commented_at), B8(place_id/place) 포함
  ///
  /// 응답 형태가 다르면 _dotFromCumulative 만 수정.
  ///
  /// Copied from [cumulativeRoomDots].
  const CumulativeRoomDotsFamily();

  /// B7 — 룸 누적 dot 단일 endpoint 호출 (`/v1/rooms/:id/cumulative-dots`).
  /// cursor pagination 자동 루프.
  ///
  /// 응답 가정:
  ///   { data: { members: [...], dots: [...], next_cursor: ... } }
  ///   - dots[].user_id 로 members 참조 (평면 구조)
  ///   - dots[] 에 B3(comment_count/last_commented_at), B8(place_id/place) 포함
  ///
  /// 응답 형태가 다르면 _dotFromCumulative 만 수정.
  ///
  /// Copied from [cumulativeRoomDots].
  CumulativeRoomDotsProvider call(String roomId) {
    return CumulativeRoomDotsProvider(roomId);
  }

  @override
  CumulativeRoomDotsProvider getProviderOverride(
    covariant CumulativeRoomDotsProvider provider,
  ) {
    return call(provider.roomId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cumulativeRoomDotsProvider';
}

/// B7 — 룸 누적 dot 단일 endpoint 호출 (`/v1/rooms/:id/cumulative-dots`).
/// cursor pagination 자동 루프.
///
/// 응답 가정:
///   { data: { members: [...], dots: [...], next_cursor: ... } }
///   - dots[].user_id 로 members 참조 (평면 구조)
///   - dots[] 에 B3(comment_count/last_commented_at), B8(place_id/place) 포함
///
/// 응답 형태가 다르면 _dotFromCumulative 만 수정.
///
/// Copied from [cumulativeRoomDots].
class CumulativeRoomDotsProvider
    extends AutoDisposeFutureProvider<List<RoomDot>> {
  /// B7 — 룸 누적 dot 단일 endpoint 호출 (`/v1/rooms/:id/cumulative-dots`).
  /// cursor pagination 자동 루프.
  ///
  /// 응답 가정:
  ///   { data: { members: [...], dots: [...], next_cursor: ... } }
  ///   - dots[].user_id 로 members 참조 (평면 구조)
  ///   - dots[] 에 B3(comment_count/last_commented_at), B8(place_id/place) 포함
  ///
  /// 응답 형태가 다르면 _dotFromCumulative 만 수정.
  ///
  /// Copied from [cumulativeRoomDots].
  CumulativeRoomDotsProvider(String roomId)
    : this._internal(
        (ref) => cumulativeRoomDots(ref as CumulativeRoomDotsRef, roomId),
        from: cumulativeRoomDotsProvider,
        name: r'cumulativeRoomDotsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$cumulativeRoomDotsHash,
        dependencies: CumulativeRoomDotsFamily._dependencies,
        allTransitiveDependencies:
            CumulativeRoomDotsFamily._allTransitiveDependencies,
        roomId: roomId,
      );

  CumulativeRoomDotsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roomId,
  }) : super.internal();

  final String roomId;

  @override
  Override overrideWith(
    FutureOr<List<RoomDot>> Function(CumulativeRoomDotsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CumulativeRoomDotsProvider._internal(
        (ref) => create(ref as CumulativeRoomDotsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roomId: roomId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RoomDot>> createElement() {
    return _CumulativeRoomDotsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CumulativeRoomDotsProvider && other.roomId == roomId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roomId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CumulativeRoomDotsRef on AutoDisposeFutureProviderRef<List<RoomDot>> {
  /// The parameter `roomId` of this provider.
  String get roomId;
}

class _CumulativeRoomDotsProviderElement
    extends AutoDisposeFutureProviderElement<List<RoomDot>>
    with CumulativeRoomDotsRef {
  _CumulativeRoomDotsProviderElement(super.provider);

  @override
  String get roomId => (origin as CumulativeRoomDotsProvider).roomId;
}

String _$placeGroupsHash() => r'33b483b282e941e60756c72ae48ccd12b6bd6e58';

/// 누적 지도 표시용 PlaceGroup list.
///
/// 흐름:
///   1. roomPlacesProvider 로 BE places fetch
///   2. BE places 가 있으면 → PlaceWithStats → PlaceGroup 매핑
///      + cumulativeRoomDots 에서 placeId 없는 orphan 만 좌표 클러스터링
///   3. BE places 가 비어있으면 (BE 미구현 / 빈 응답) → cumulativeRoomDots 전체로
///      클라이언트 측 그룹화 (PlaceGrouper) 폴백
///
/// 모든 멤버 동행 isFirstTogether 는 클라이언트 계산.
///
/// Copied from [placeGroups].
@ProviderFor(placeGroups)
const placeGroupsProvider = PlaceGroupsFamily();

/// 누적 지도 표시용 PlaceGroup list.
///
/// 흐름:
///   1. roomPlacesProvider 로 BE places fetch
///   2. BE places 가 있으면 → PlaceWithStats → PlaceGroup 매핑
///      + cumulativeRoomDots 에서 placeId 없는 orphan 만 좌표 클러스터링
///   3. BE places 가 비어있으면 (BE 미구현 / 빈 응답) → cumulativeRoomDots 전체로
///      클라이언트 측 그룹화 (PlaceGrouper) 폴백
///
/// 모든 멤버 동행 isFirstTogether 는 클라이언트 계산.
///
/// Copied from [placeGroups].
class PlaceGroupsFamily extends Family<AsyncValue<List<PlaceGroup>>> {
  /// 누적 지도 표시용 PlaceGroup list.
  ///
  /// 흐름:
  ///   1. roomPlacesProvider 로 BE places fetch
  ///   2. BE places 가 있으면 → PlaceWithStats → PlaceGroup 매핑
  ///      + cumulativeRoomDots 에서 placeId 없는 orphan 만 좌표 클러스터링
  ///   3. BE places 가 비어있으면 (BE 미구현 / 빈 응답) → cumulativeRoomDots 전체로
  ///      클라이언트 측 그룹화 (PlaceGrouper) 폴백
  ///
  /// 모든 멤버 동행 isFirstTogether 는 클라이언트 계산.
  ///
  /// Copied from [placeGroups].
  const PlaceGroupsFamily();

  /// 누적 지도 표시용 PlaceGroup list.
  ///
  /// 흐름:
  ///   1. roomPlacesProvider 로 BE places fetch
  ///   2. BE places 가 있으면 → PlaceWithStats → PlaceGroup 매핑
  ///      + cumulativeRoomDots 에서 placeId 없는 orphan 만 좌표 클러스터링
  ///   3. BE places 가 비어있으면 (BE 미구현 / 빈 응답) → cumulativeRoomDots 전체로
  ///      클라이언트 측 그룹화 (PlaceGrouper) 폴백
  ///
  /// 모든 멤버 동행 isFirstTogether 는 클라이언트 계산.
  ///
  /// Copied from [placeGroups].
  PlaceGroupsProvider call(String roomId) {
    return PlaceGroupsProvider(roomId);
  }

  @override
  PlaceGroupsProvider getProviderOverride(
    covariant PlaceGroupsProvider provider,
  ) {
    return call(provider.roomId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'placeGroupsProvider';
}

/// 누적 지도 표시용 PlaceGroup list.
///
/// 흐름:
///   1. roomPlacesProvider 로 BE places fetch
///   2. BE places 가 있으면 → PlaceWithStats → PlaceGroup 매핑
///      + cumulativeRoomDots 에서 placeId 없는 orphan 만 좌표 클러스터링
///   3. BE places 가 비어있으면 (BE 미구현 / 빈 응답) → cumulativeRoomDots 전체로
///      클라이언트 측 그룹화 (PlaceGrouper) 폴백
///
/// 모든 멤버 동행 isFirstTogether 는 클라이언트 계산.
///
/// Copied from [placeGroups].
class PlaceGroupsProvider extends AutoDisposeFutureProvider<List<PlaceGroup>> {
  /// 누적 지도 표시용 PlaceGroup list.
  ///
  /// 흐름:
  ///   1. roomPlacesProvider 로 BE places fetch
  ///   2. BE places 가 있으면 → PlaceWithStats → PlaceGroup 매핑
  ///      + cumulativeRoomDots 에서 placeId 없는 orphan 만 좌표 클러스터링
  ///   3. BE places 가 비어있으면 (BE 미구현 / 빈 응답) → cumulativeRoomDots 전체로
  ///      클라이언트 측 그룹화 (PlaceGrouper) 폴백
  ///
  /// 모든 멤버 동행 isFirstTogether 는 클라이언트 계산.
  ///
  /// Copied from [placeGroups].
  PlaceGroupsProvider(String roomId)
    : this._internal(
        (ref) => placeGroups(ref as PlaceGroupsRef, roomId),
        from: placeGroupsProvider,
        name: r'placeGroupsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$placeGroupsHash,
        dependencies: PlaceGroupsFamily._dependencies,
        allTransitiveDependencies: PlaceGroupsFamily._allTransitiveDependencies,
        roomId: roomId,
      );

  PlaceGroupsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roomId,
  }) : super.internal();

  final String roomId;

  @override
  Override overrideWith(
    FutureOr<List<PlaceGroup>> Function(PlaceGroupsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PlaceGroupsProvider._internal(
        (ref) => create(ref as PlaceGroupsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roomId: roomId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<PlaceGroup>> createElement() {
    return _PlaceGroupsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlaceGroupsProvider && other.roomId == roomId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roomId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PlaceGroupsRef on AutoDisposeFutureProviderRef<List<PlaceGroup>> {
  /// The parameter `roomId` of this provider.
  String get roomId;
}

class _PlaceGroupsProviderElement
    extends AutoDisposeFutureProviderElement<List<PlaceGroup>>
    with PlaceGroupsRef {
  _PlaceGroupsProviderElement(super.provider);

  @override
  String get roomId => (origin as PlaceGroupsProvider).roomId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
