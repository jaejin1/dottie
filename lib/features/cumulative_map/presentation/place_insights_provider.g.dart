// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_insights_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$placeInsightsHash() => r'9c5ac20bf35da686be53700977cf22cf4fdc04df';

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

/// B10 — `/v1/rooms/:id/places/:place_id/insights` 응답.
/// place_id 가 BE 매칭된 ID 일 때만 호출 (placeId null 인 polkit-find 그룹은 호출 X).
///
/// Copied from [placeInsights].
@ProviderFor(placeInsights)
const placeInsightsProvider = PlaceInsightsFamily();

/// B10 — `/v1/rooms/:id/places/:place_id/insights` 응답.
/// place_id 가 BE 매칭된 ID 일 때만 호출 (placeId null 인 polkit-find 그룹은 호출 X).
///
/// Copied from [placeInsights].
class PlaceInsightsFamily extends Family<AsyncValue<PlaceInsights?>> {
  /// B10 — `/v1/rooms/:id/places/:place_id/insights` 응답.
  /// place_id 가 BE 매칭된 ID 일 때만 호출 (placeId null 인 polkit-find 그룹은 호출 X).
  ///
  /// Copied from [placeInsights].
  const PlaceInsightsFamily();

  /// B10 — `/v1/rooms/:id/places/:place_id/insights` 응답.
  /// place_id 가 BE 매칭된 ID 일 때만 호출 (placeId null 인 polkit-find 그룹은 호출 X).
  ///
  /// Copied from [placeInsights].
  PlaceInsightsProvider call(String roomId, String placeId) {
    return PlaceInsightsProvider(roomId, placeId);
  }

  @override
  PlaceInsightsProvider getProviderOverride(
    covariant PlaceInsightsProvider provider,
  ) {
    return call(provider.roomId, provider.placeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'placeInsightsProvider';
}

/// B10 — `/v1/rooms/:id/places/:place_id/insights` 응답.
/// place_id 가 BE 매칭된 ID 일 때만 호출 (placeId null 인 polkit-find 그룹은 호출 X).
///
/// Copied from [placeInsights].
class PlaceInsightsProvider extends AutoDisposeFutureProvider<PlaceInsights?> {
  /// B10 — `/v1/rooms/:id/places/:place_id/insights` 응답.
  /// place_id 가 BE 매칭된 ID 일 때만 호출 (placeId null 인 polkit-find 그룹은 호출 X).
  ///
  /// Copied from [placeInsights].
  PlaceInsightsProvider(String roomId, String placeId)
    : this._internal(
        (ref) => placeInsights(ref as PlaceInsightsRef, roomId, placeId),
        from: placeInsightsProvider,
        name: r'placeInsightsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$placeInsightsHash,
        dependencies: PlaceInsightsFamily._dependencies,
        allTransitiveDependencies:
            PlaceInsightsFamily._allTransitiveDependencies,
        roomId: roomId,
        placeId: placeId,
      );

  PlaceInsightsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roomId,
    required this.placeId,
  }) : super.internal();

  final String roomId;
  final String placeId;

  @override
  Override overrideWith(
    FutureOr<PlaceInsights?> Function(PlaceInsightsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PlaceInsightsProvider._internal(
        (ref) => create(ref as PlaceInsightsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roomId: roomId,
        placeId: placeId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<PlaceInsights?> createElement() {
    return _PlaceInsightsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PlaceInsightsProvider &&
        other.roomId == roomId &&
        other.placeId == placeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roomId.hashCode);
    hash = _SystemHash.combine(hash, placeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PlaceInsightsRef on AutoDisposeFutureProviderRef<PlaceInsights?> {
  /// The parameter `roomId` of this provider.
  String get roomId;

  /// The parameter `placeId` of this provider.
  String get placeId;
}

class _PlaceInsightsProviderElement
    extends AutoDisposeFutureProviderElement<PlaceInsights?>
    with PlaceInsightsRef {
  _PlaceInsightsProviderElement(super.provider);

  @override
  String get roomId => (origin as PlaceInsightsProvider).roomId;
  @override
  String get placeId => (origin as PlaceInsightsProvider).placeId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
