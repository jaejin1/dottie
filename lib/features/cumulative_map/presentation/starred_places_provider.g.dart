// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'starred_places_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isPlaceStarredHash() => r'c9703c0b28c310dfb298ead4bd2f6860bf22f5a8';

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

/// 편의 — 특정 placeId 가 즐겨찾기인지 빠르게 확인.
///
/// Copied from [isPlaceStarred].
@ProviderFor(isPlaceStarred)
const isPlaceStarredProvider = IsPlaceStarredFamily();

/// 편의 — 특정 placeId 가 즐겨찾기인지 빠르게 확인.
///
/// Copied from [isPlaceStarred].
class IsPlaceStarredFamily extends Family<bool> {
  /// 편의 — 특정 placeId 가 즐겨찾기인지 빠르게 확인.
  ///
  /// Copied from [isPlaceStarred].
  const IsPlaceStarredFamily();

  /// 편의 — 특정 placeId 가 즐겨찾기인지 빠르게 확인.
  ///
  /// Copied from [isPlaceStarred].
  IsPlaceStarredProvider call(String roomId, String placeId) {
    return IsPlaceStarredProvider(roomId, placeId);
  }

  @override
  IsPlaceStarredProvider getProviderOverride(
    covariant IsPlaceStarredProvider provider,
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
  String? get name => r'isPlaceStarredProvider';
}

/// 편의 — 특정 placeId 가 즐겨찾기인지 빠르게 확인.
///
/// Copied from [isPlaceStarred].
class IsPlaceStarredProvider extends AutoDisposeProvider<bool> {
  /// 편의 — 특정 placeId 가 즐겨찾기인지 빠르게 확인.
  ///
  /// Copied from [isPlaceStarred].
  IsPlaceStarredProvider(String roomId, String placeId)
    : this._internal(
        (ref) => isPlaceStarred(ref as IsPlaceStarredRef, roomId, placeId),
        from: isPlaceStarredProvider,
        name: r'isPlaceStarredProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$isPlaceStarredHash,
        dependencies: IsPlaceStarredFamily._dependencies,
        allTransitiveDependencies:
            IsPlaceStarredFamily._allTransitiveDependencies,
        roomId: roomId,
        placeId: placeId,
      );

  IsPlaceStarredProvider._internal(
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
  Override overrideWith(bool Function(IsPlaceStarredRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: IsPlaceStarredProvider._internal(
        (ref) => create(ref as IsPlaceStarredRef),
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
  AutoDisposeProviderElement<bool> createElement() {
    return _IsPlaceStarredProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsPlaceStarredProvider &&
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
mixin IsPlaceStarredRef on AutoDisposeProviderRef<bool> {
  /// The parameter `roomId` of this provider.
  String get roomId;

  /// The parameter `placeId` of this provider.
  String get placeId;
}

class _IsPlaceStarredProviderElement extends AutoDisposeProviderElement<bool>
    with IsPlaceStarredRef {
  _IsPlaceStarredProviderElement(super.provider);

  @override
  String get roomId => (origin as IsPlaceStarredProvider).roomId;
  @override
  String get placeId => (origin as IsPlaceStarredProvider).placeId;
}

String _$starredPlacesHash() => r'88218f20ccea6227ce90f0e487dfc19b4b0c559c';

abstract class _$StarredPlaces
    extends BuildlessAutoDisposeAsyncNotifier<List<StarredPlace>> {
  late final String roomId;

  FutureOr<List<StarredPlace>> build(String roomId);
}

/// B9 — 룸 즐겨찾기 장소 list.
///
/// Copied from [StarredPlaces].
@ProviderFor(StarredPlaces)
const starredPlacesProvider = StarredPlacesFamily();

/// B9 — 룸 즐겨찾기 장소 list.
///
/// Copied from [StarredPlaces].
class StarredPlacesFamily extends Family<AsyncValue<List<StarredPlace>>> {
  /// B9 — 룸 즐겨찾기 장소 list.
  ///
  /// Copied from [StarredPlaces].
  const StarredPlacesFamily();

  /// B9 — 룸 즐겨찾기 장소 list.
  ///
  /// Copied from [StarredPlaces].
  StarredPlacesProvider call(String roomId) {
    return StarredPlacesProvider(roomId);
  }

  @override
  StarredPlacesProvider getProviderOverride(
    covariant StarredPlacesProvider provider,
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
  String? get name => r'starredPlacesProvider';
}

/// B9 — 룸 즐겨찾기 장소 list.
///
/// Copied from [StarredPlaces].
class StarredPlacesProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          StarredPlaces,
          List<StarredPlace>
        > {
  /// B9 — 룸 즐겨찾기 장소 list.
  ///
  /// Copied from [StarredPlaces].
  StarredPlacesProvider(String roomId)
    : this._internal(
        () => StarredPlaces()..roomId = roomId,
        from: starredPlacesProvider,
        name: r'starredPlacesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$starredPlacesHash,
        dependencies: StarredPlacesFamily._dependencies,
        allTransitiveDependencies:
            StarredPlacesFamily._allTransitiveDependencies,
        roomId: roomId,
      );

  StarredPlacesProvider._internal(
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
  FutureOr<List<StarredPlace>> runNotifierBuild(
    covariant StarredPlaces notifier,
  ) {
    return notifier.build(roomId);
  }

  @override
  Override overrideWith(StarredPlaces Function() create) {
    return ProviderOverride(
      origin: this,
      override: StarredPlacesProvider._internal(
        () => create()..roomId = roomId,
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
  AutoDisposeAsyncNotifierProviderElement<StarredPlaces, List<StarredPlace>>
  createElement() {
    return _StarredPlacesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StarredPlacesProvider && other.roomId == roomId;
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
mixin StarredPlacesRef
    on AutoDisposeAsyncNotifierProviderRef<List<StarredPlace>> {
  /// The parameter `roomId` of this provider.
  String get roomId;
}

class _StarredPlacesProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          StarredPlaces,
          List<StarredPlace>
        >
    with StarredPlacesRef {
  _StarredPlacesProviderElement(super.provider);

  @override
  String get roomId => (origin as StarredPlacesProvider).roomId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
