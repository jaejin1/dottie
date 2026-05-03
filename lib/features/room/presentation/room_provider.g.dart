// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$roomListHash() => r'eb10e93a3b98fa10f795e50ed34e2d1a74b969a4';

/// See also [roomList].
@ProviderFor(roomList)
final roomListProvider = AutoDisposeFutureProvider<List<Room>>.internal(
  roomList,
  name: r'roomListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$roomListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RoomListRef = AutoDisposeFutureProviderRef<List<Room>>;
String _$roomDetailHash() => r'd20897d930694877f1083a83f1260ca7670612cb';

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

/// See also [roomDetail].
@ProviderFor(roomDetail)
const roomDetailProvider = RoomDetailFamily();

/// See also [roomDetail].
class RoomDetailFamily extends Family<AsyncValue<Room?>> {
  /// See also [roomDetail].
  const RoomDetailFamily();

  /// See also [roomDetail].
  RoomDetailProvider call(String roomId) {
    return RoomDetailProvider(roomId);
  }

  @override
  RoomDetailProvider getProviderOverride(
    covariant RoomDetailProvider provider,
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
  String? get name => r'roomDetailProvider';
}

/// See also [roomDetail].
class RoomDetailProvider extends AutoDisposeFutureProvider<Room?> {
  /// See also [roomDetail].
  RoomDetailProvider(String roomId)
    : this._internal(
        (ref) => roomDetail(ref as RoomDetailRef, roomId),
        from: roomDetailProvider,
        name: r'roomDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$roomDetailHash,
        dependencies: RoomDetailFamily._dependencies,
        allTransitiveDependencies: RoomDetailFamily._allTransitiveDependencies,
        roomId: roomId,
      );

  RoomDetailProvider._internal(
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
    FutureOr<Room?> Function(RoomDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoomDetailProvider._internal(
        (ref) => create(ref as RoomDetailRef),
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
  AutoDisposeFutureProviderElement<Room?> createElement() {
    return _RoomDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoomDetailProvider && other.roomId == roomId;
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
mixin RoomDetailRef on AutoDisposeFutureProviderRef<Room?> {
  /// The parameter `roomId` of this provider.
  String get roomId;
}

class _RoomDetailProviderElement extends AutoDisposeFutureProviderElement<Room?>
    with RoomDetailRef {
  _RoomDetailProviderElement(super.provider);

  @override
  String get roomId => (origin as RoomDetailProvider).roomId;
}

String _$roomNotifierHash() => r'b8a5fdd1144d7e1d92196b2008c70f80781fa5e4';

/// See also [RoomNotifier].
@ProviderFor(RoomNotifier)
final roomNotifierProvider =
    AutoDisposeNotifierProvider<RoomNotifier, AsyncValue<void>>.internal(
      RoomNotifier.new,
      name: r'roomNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$roomNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$RoomNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
