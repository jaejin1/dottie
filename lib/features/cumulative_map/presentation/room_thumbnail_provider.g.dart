// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_thumbnail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$roomThumbnailUrlHash() => r'3355dbd8e47d758f88a667310b31c0f13fe6d9a7';

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

/// B11 — `/v1/rooms/:id/thumbnail` URL 단건. dot 분포 기반 Mapbox static URL.
/// 응답 비어 있으면 null. UI 측에서 null 시 placeholder 표시.
///
/// Copied from [roomThumbnailUrl].
@ProviderFor(roomThumbnailUrl)
const roomThumbnailUrlProvider = RoomThumbnailUrlFamily();

/// B11 — `/v1/rooms/:id/thumbnail` URL 단건. dot 분포 기반 Mapbox static URL.
/// 응답 비어 있으면 null. UI 측에서 null 시 placeholder 표시.
///
/// Copied from [roomThumbnailUrl].
class RoomThumbnailUrlFamily extends Family<AsyncValue<String?>> {
  /// B11 — `/v1/rooms/:id/thumbnail` URL 단건. dot 분포 기반 Mapbox static URL.
  /// 응답 비어 있으면 null. UI 측에서 null 시 placeholder 표시.
  ///
  /// Copied from [roomThumbnailUrl].
  const RoomThumbnailUrlFamily();

  /// B11 — `/v1/rooms/:id/thumbnail` URL 단건. dot 분포 기반 Mapbox static URL.
  /// 응답 비어 있으면 null. UI 측에서 null 시 placeholder 표시.
  ///
  /// Copied from [roomThumbnailUrl].
  RoomThumbnailUrlProvider call(String roomId) {
    return RoomThumbnailUrlProvider(roomId);
  }

  @override
  RoomThumbnailUrlProvider getProviderOverride(
    covariant RoomThumbnailUrlProvider provider,
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
  String? get name => r'roomThumbnailUrlProvider';
}

/// B11 — `/v1/rooms/:id/thumbnail` URL 단건. dot 분포 기반 Mapbox static URL.
/// 응답 비어 있으면 null. UI 측에서 null 시 placeholder 표시.
///
/// Copied from [roomThumbnailUrl].
class RoomThumbnailUrlProvider extends AutoDisposeFutureProvider<String?> {
  /// B11 — `/v1/rooms/:id/thumbnail` URL 단건. dot 분포 기반 Mapbox static URL.
  /// 응답 비어 있으면 null. UI 측에서 null 시 placeholder 표시.
  ///
  /// Copied from [roomThumbnailUrl].
  RoomThumbnailUrlProvider(String roomId)
    : this._internal(
        (ref) => roomThumbnailUrl(ref as RoomThumbnailUrlRef, roomId),
        from: roomThumbnailUrlProvider,
        name: r'roomThumbnailUrlProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$roomThumbnailUrlHash,
        dependencies: RoomThumbnailUrlFamily._dependencies,
        allTransitiveDependencies:
            RoomThumbnailUrlFamily._allTransitiveDependencies,
        roomId: roomId,
      );

  RoomThumbnailUrlProvider._internal(
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
    FutureOr<String?> Function(RoomThumbnailUrlRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoomThumbnailUrlProvider._internal(
        (ref) => create(ref as RoomThumbnailUrlRef),
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
  AutoDisposeFutureProviderElement<String?> createElement() {
    return _RoomThumbnailUrlProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoomThumbnailUrlProvider && other.roomId == roomId;
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
mixin RoomThumbnailUrlRef on AutoDisposeFutureProviderRef<String?> {
  /// The parameter `roomId` of this provider.
  String get roomId;
}

class _RoomThumbnailUrlProviderElement
    extends AutoDisposeFutureProviderElement<String?>
    with RoomThumbnailUrlRef {
  _RoomThumbnailUrlProviderElement(super.provider);

  @override
  String get roomId => (origin as RoomThumbnailUrlProvider).roomId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
