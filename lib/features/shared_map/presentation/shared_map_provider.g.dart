// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_map_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sharedMapNotifierHash() => r'7d3c76d6b319ff8277e01a5fde72f7da1baa6b73';

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

abstract class _$SharedMapNotifier
    extends BuildlessAutoDisposeNotifier<SharedMapState?> {
  late final String roomId;
  late final String date;

  SharedMapState? build(String roomId, String date);
}

/// See also [SharedMapNotifier].
@ProviderFor(SharedMapNotifier)
const sharedMapNotifierProvider = SharedMapNotifierFamily();

/// See also [SharedMapNotifier].
class SharedMapNotifierFamily extends Family<SharedMapState?> {
  /// See also [SharedMapNotifier].
  const SharedMapNotifierFamily();

  /// See also [SharedMapNotifier].
  SharedMapNotifierProvider call(String roomId, String date) {
    return SharedMapNotifierProvider(roomId, date);
  }

  @override
  SharedMapNotifierProvider getProviderOverride(
    covariant SharedMapNotifierProvider provider,
  ) {
    return call(provider.roomId, provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sharedMapNotifierProvider';
}

/// See also [SharedMapNotifier].
class SharedMapNotifierProvider
    extends
        AutoDisposeNotifierProviderImpl<SharedMapNotifier, SharedMapState?> {
  /// See also [SharedMapNotifier].
  SharedMapNotifierProvider(String roomId, String date)
    : this._internal(
        () => SharedMapNotifier()
          ..roomId = roomId
          ..date = date,
        from: sharedMapNotifierProvider,
        name: r'sharedMapNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sharedMapNotifierHash,
        dependencies: SharedMapNotifierFamily._dependencies,
        allTransitiveDependencies:
            SharedMapNotifierFamily._allTransitiveDependencies,
        roomId: roomId,
        date: date,
      );

  SharedMapNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roomId,
    required this.date,
  }) : super.internal();

  final String roomId;
  final String date;

  @override
  SharedMapState? runNotifierBuild(covariant SharedMapNotifier notifier) {
    return notifier.build(roomId, date);
  }

  @override
  Override overrideWith(SharedMapNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: SharedMapNotifierProvider._internal(
        () => create()
          ..roomId = roomId
          ..date = date,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roomId: roomId,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<SharedMapNotifier, SharedMapState?>
  createElement() {
    return _SharedMapNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SharedMapNotifierProvider &&
        other.roomId == roomId &&
        other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roomId.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SharedMapNotifierRef on AutoDisposeNotifierProviderRef<SharedMapState?> {
  /// The parameter `roomId` of this provider.
  String get roomId;

  /// The parameter `date` of this provider.
  String get date;
}

class _SharedMapNotifierProviderElement
    extends
        AutoDisposeNotifierProviderElement<SharedMapNotifier, SharedMapState?>
    with SharedMapNotifierRef {
  _SharedMapNotifierProviderElement(super.provider);

  @override
  String get roomId => (origin as SharedMapNotifierProvider).roomId;
  @override
  String get date => (origin as SharedMapNotifierProvider).date;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
