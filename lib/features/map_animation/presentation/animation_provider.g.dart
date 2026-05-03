// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$animationSequenceHash() => r'c32772cb07aa628e89690ecf683f169a39e89f29';

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

/// See also [animationSequence].
@ProviderFor(animationSequence)
const animationSequenceProvider = AnimationSequenceFamily();

/// See also [animationSequence].
class AnimationSequenceFamily extends Family<AsyncValue<AnimationSequence>> {
  /// See also [animationSequence].
  const AnimationSequenceFamily();

  /// See also [animationSequence].
  AnimationSequenceProvider call(String dayLogId) {
    return AnimationSequenceProvider(dayLogId);
  }

  @override
  AnimationSequenceProvider getProviderOverride(
    covariant AnimationSequenceProvider provider,
  ) {
    return call(provider.dayLogId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'animationSequenceProvider';
}

/// See also [animationSequence].
class AnimationSequenceProvider
    extends AutoDisposeFutureProvider<AnimationSequence> {
  /// See also [animationSequence].
  AnimationSequenceProvider(String dayLogId)
    : this._internal(
        (ref) => animationSequence(ref as AnimationSequenceRef, dayLogId),
        from: animationSequenceProvider,
        name: r'animationSequenceProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$animationSequenceHash,
        dependencies: AnimationSequenceFamily._dependencies,
        allTransitiveDependencies:
            AnimationSequenceFamily._allTransitiveDependencies,
        dayLogId: dayLogId,
      );

  AnimationSequenceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.dayLogId,
  }) : super.internal();

  final String dayLogId;

  @override
  Override overrideWith(
    FutureOr<AnimationSequence> Function(AnimationSequenceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AnimationSequenceProvider._internal(
        (ref) => create(ref as AnimationSequenceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        dayLogId: dayLogId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<AnimationSequence> createElement() {
    return _AnimationSequenceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AnimationSequenceProvider && other.dayLogId == dayLogId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, dayLogId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AnimationSequenceRef on AutoDisposeFutureProviderRef<AnimationSequence> {
  /// The parameter `dayLogId` of this provider.
  String get dayLogId;
}

class _AnimationSequenceProviderElement
    extends AutoDisposeFutureProviderElement<AnimationSequence>
    with AnimationSequenceRef {
  _AnimationSequenceProviderElement(super.provider);

  @override
  String get dayLogId => (origin as AnimationSequenceProvider).dayLogId;
}

String _$animationControllerHash() =>
    r'ac75847d69ba3d9746a09521400f5485e5fefa40';

abstract class _$AnimationController
    extends BuildlessAutoDisposeNotifier<AnimationState?> {
  late final String dayLogId;

  AnimationState? build(String dayLogId);
}

/// See also [AnimationController].
@ProviderFor(AnimationController)
const animationControllerProvider = AnimationControllerFamily();

/// See also [AnimationController].
class AnimationControllerFamily extends Family<AnimationState?> {
  /// See also [AnimationController].
  const AnimationControllerFamily();

  /// See also [AnimationController].
  AnimationControllerProvider call(String dayLogId) {
    return AnimationControllerProvider(dayLogId);
  }

  @override
  AnimationControllerProvider getProviderOverride(
    covariant AnimationControllerProvider provider,
  ) {
    return call(provider.dayLogId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'animationControllerProvider';
}

/// See also [AnimationController].
class AnimationControllerProvider
    extends
        AutoDisposeNotifierProviderImpl<AnimationController, AnimationState?> {
  /// See also [AnimationController].
  AnimationControllerProvider(String dayLogId)
    : this._internal(
        () => AnimationController()..dayLogId = dayLogId,
        from: animationControllerProvider,
        name: r'animationControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$animationControllerHash,
        dependencies: AnimationControllerFamily._dependencies,
        allTransitiveDependencies:
            AnimationControllerFamily._allTransitiveDependencies,
        dayLogId: dayLogId,
      );

  AnimationControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.dayLogId,
  }) : super.internal();

  final String dayLogId;

  @override
  AnimationState? runNotifierBuild(covariant AnimationController notifier) {
    return notifier.build(dayLogId);
  }

  @override
  Override overrideWith(AnimationController Function() create) {
    return ProviderOverride(
      origin: this,
      override: AnimationControllerProvider._internal(
        () => create()..dayLogId = dayLogId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        dayLogId: dayLogId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<AnimationController, AnimationState?>
  createElement() {
    return _AnimationControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AnimationControllerProvider && other.dayLogId == dayLogId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, dayLogId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AnimationControllerRef
    on AutoDisposeNotifierProviderRef<AnimationState?> {
  /// The parameter `dayLogId` of this provider.
  String get dayLogId;
}

class _AnimationControllerProviderElement
    extends
        AutoDisposeNotifierProviderElement<AnimationController, AnimationState?>
    with AnimationControllerRef {
  _AnimationControllerProviderElement(super.provider);

  @override
  String get dayLogId => (origin as AnimationControllerProvider).dayLogId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
