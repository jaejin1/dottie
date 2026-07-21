// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_places_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$roomPlacesHash() => r'c1866da5d64c3bf29a12a6dc47b982cdede4b2de';

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

/// B15 — `/v1/rooms/:id/places` 단일 호출 + cursor pagination 자동 루프.
///
/// 응답 가정:
///   { data: { places: [...], next_cursor: ..., total: int } }
///
/// orphan dots (place_id 없는 옛 dot) 는 BE 응답에 없음 — cumulativeRoomDots
/// provider 가 별도로 다룬다.
///
/// TODO(B15-stage2): bbox + zoom 파라미터 활용 (viewport fetch)
/// TODO(B15-stage3): mode=clusters 응답 처리
/// TODO(B15-stage4): member_ids/category 필터
/// TODO(B15-cache): ETag/If-None-Match → 304 처리
///
/// Copied from [roomPlaces].
@ProviderFor(roomPlaces)
const roomPlacesProvider = RoomPlacesFamily();

/// B15 — `/v1/rooms/:id/places` 단일 호출 + cursor pagination 자동 루프.
///
/// 응답 가정:
///   { data: { places: [...], next_cursor: ..., total: int } }
///
/// orphan dots (place_id 없는 옛 dot) 는 BE 응답에 없음 — cumulativeRoomDots
/// provider 가 별도로 다룬다.
///
/// TODO(B15-stage2): bbox + zoom 파라미터 활용 (viewport fetch)
/// TODO(B15-stage3): mode=clusters 응답 처리
/// TODO(B15-stage4): member_ids/category 필터
/// TODO(B15-cache): ETag/If-None-Match → 304 처리
///
/// Copied from [roomPlaces].
class RoomPlacesFamily extends Family<AsyncValue<RoomPlacesData>> {
  /// B15 — `/v1/rooms/:id/places` 단일 호출 + cursor pagination 자동 루프.
  ///
  /// 응답 가정:
  ///   { data: { places: [...], next_cursor: ..., total: int } }
  ///
  /// orphan dots (place_id 없는 옛 dot) 는 BE 응답에 없음 — cumulativeRoomDots
  /// provider 가 별도로 다룬다.
  ///
  /// TODO(B15-stage2): bbox + zoom 파라미터 활용 (viewport fetch)
  /// TODO(B15-stage3): mode=clusters 응답 처리
  /// TODO(B15-stage4): member_ids/category 필터
  /// TODO(B15-cache): ETag/If-None-Match → 304 처리
  ///
  /// Copied from [roomPlaces].
  const RoomPlacesFamily();

  /// B15 — `/v1/rooms/:id/places` 단일 호출 + cursor pagination 자동 루프.
  ///
  /// 응답 가정:
  ///   { data: { places: [...], next_cursor: ..., total: int } }
  ///
  /// orphan dots (place_id 없는 옛 dot) 는 BE 응답에 없음 — cumulativeRoomDots
  /// provider 가 별도로 다룬다.
  ///
  /// TODO(B15-stage2): bbox + zoom 파라미터 활용 (viewport fetch)
  /// TODO(B15-stage3): mode=clusters 응답 처리
  /// TODO(B15-stage4): member_ids/category 필터
  /// TODO(B15-cache): ETag/If-None-Match → 304 처리
  ///
  /// Copied from [roomPlaces].
  RoomPlacesProvider call(String roomId) {
    return RoomPlacesProvider(roomId);
  }

  @override
  RoomPlacesProvider getProviderOverride(
    covariant RoomPlacesProvider provider,
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
  String? get name => r'roomPlacesProvider';
}

/// B15 — `/v1/rooms/:id/places` 단일 호출 + cursor pagination 자동 루프.
///
/// 응답 가정:
///   { data: { places: [...], next_cursor: ..., total: int } }
///
/// orphan dots (place_id 없는 옛 dot) 는 BE 응답에 없음 — cumulativeRoomDots
/// provider 가 별도로 다룬다.
///
/// TODO(B15-stage2): bbox + zoom 파라미터 활용 (viewport fetch)
/// TODO(B15-stage3): mode=clusters 응답 처리
/// TODO(B15-stage4): member_ids/category 필터
/// TODO(B15-cache): ETag/If-None-Match → 304 처리
///
/// Copied from [roomPlaces].
class RoomPlacesProvider extends AutoDisposeFutureProvider<RoomPlacesData> {
  /// B15 — `/v1/rooms/:id/places` 단일 호출 + cursor pagination 자동 루프.
  ///
  /// 응답 가정:
  ///   { data: { places: [...], next_cursor: ..., total: int } }
  ///
  /// orphan dots (place_id 없는 옛 dot) 는 BE 응답에 없음 — cumulativeRoomDots
  /// provider 가 별도로 다룬다.
  ///
  /// TODO(B15-stage2): bbox + zoom 파라미터 활용 (viewport fetch)
  /// TODO(B15-stage3): mode=clusters 응답 처리
  /// TODO(B15-stage4): member_ids/category 필터
  /// TODO(B15-cache): ETag/If-None-Match → 304 처리
  ///
  /// Copied from [roomPlaces].
  RoomPlacesProvider(String roomId)
    : this._internal(
        (ref) => roomPlaces(ref as RoomPlacesRef, roomId),
        from: roomPlacesProvider,
        name: r'roomPlacesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$roomPlacesHash,
        dependencies: RoomPlacesFamily._dependencies,
        allTransitiveDependencies: RoomPlacesFamily._allTransitiveDependencies,
        roomId: roomId,
      );

  RoomPlacesProvider._internal(
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
    FutureOr<RoomPlacesData> Function(RoomPlacesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoomPlacesProvider._internal(
        (ref) => create(ref as RoomPlacesRef),
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
  AutoDisposeFutureProviderElement<RoomPlacesData> createElement() {
    return _RoomPlacesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoomPlacesProvider && other.roomId == roomId;
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
mixin RoomPlacesRef on AutoDisposeFutureProviderRef<RoomPlacesData> {
  /// The parameter `roomId` of this provider.
  String get roomId;
}

class _RoomPlacesProviderElement
    extends AutoDisposeFutureProviderElement<RoomPlacesData>
    with RoomPlacesRef {
  _RoomPlacesProviderElement(super.provider);

  @override
  String get roomId => (origin as RoomPlacesProvider).roomId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
