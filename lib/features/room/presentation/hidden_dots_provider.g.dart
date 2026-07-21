// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hidden_dots_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hiddenDotsByMeHash() => r'ebf28ed7d96c9c72bcf267fd993b211596f02ee0';

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

/// 본인이 특정 룸에서 숨긴 dot 목록.
/// 룸 설정 화면의 "내가 숨긴 기록" 섹션에서 watch.
/// 숨김/해제 액션 후엔 invalidate 해서 갱신.
///
/// Copied from [hiddenDotsByMe].
@ProviderFor(hiddenDotsByMe)
const hiddenDotsByMeProvider = HiddenDotsByMeFamily();

/// 본인이 특정 룸에서 숨긴 dot 목록.
/// 룸 설정 화면의 "내가 숨긴 기록" 섹션에서 watch.
/// 숨김/해제 액션 후엔 invalidate 해서 갱신.
///
/// Copied from [hiddenDotsByMe].
class HiddenDotsByMeFamily extends Family<AsyncValue<List<Dot>>> {
  /// 본인이 특정 룸에서 숨긴 dot 목록.
  /// 룸 설정 화면의 "내가 숨긴 기록" 섹션에서 watch.
  /// 숨김/해제 액션 후엔 invalidate 해서 갱신.
  ///
  /// Copied from [hiddenDotsByMe].
  const HiddenDotsByMeFamily();

  /// 본인이 특정 룸에서 숨긴 dot 목록.
  /// 룸 설정 화면의 "내가 숨긴 기록" 섹션에서 watch.
  /// 숨김/해제 액션 후엔 invalidate 해서 갱신.
  ///
  /// Copied from [hiddenDotsByMe].
  HiddenDotsByMeProvider call(String roomId) {
    return HiddenDotsByMeProvider(roomId);
  }

  @override
  HiddenDotsByMeProvider getProviderOverride(
    covariant HiddenDotsByMeProvider provider,
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
  String? get name => r'hiddenDotsByMeProvider';
}

/// 본인이 특정 룸에서 숨긴 dot 목록.
/// 룸 설정 화면의 "내가 숨긴 기록" 섹션에서 watch.
/// 숨김/해제 액션 후엔 invalidate 해서 갱신.
///
/// Copied from [hiddenDotsByMe].
class HiddenDotsByMeProvider extends AutoDisposeFutureProvider<List<Dot>> {
  /// 본인이 특정 룸에서 숨긴 dot 목록.
  /// 룸 설정 화면의 "내가 숨긴 기록" 섹션에서 watch.
  /// 숨김/해제 액션 후엔 invalidate 해서 갱신.
  ///
  /// Copied from [hiddenDotsByMe].
  HiddenDotsByMeProvider(String roomId)
    : this._internal(
        (ref) => hiddenDotsByMe(ref as HiddenDotsByMeRef, roomId),
        from: hiddenDotsByMeProvider,
        name: r'hiddenDotsByMeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$hiddenDotsByMeHash,
        dependencies: HiddenDotsByMeFamily._dependencies,
        allTransitiveDependencies:
            HiddenDotsByMeFamily._allTransitiveDependencies,
        roomId: roomId,
      );

  HiddenDotsByMeProvider._internal(
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
    FutureOr<List<Dot>> Function(HiddenDotsByMeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HiddenDotsByMeProvider._internal(
        (ref) => create(ref as HiddenDotsByMeRef),
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
  AutoDisposeFutureProviderElement<List<Dot>> createElement() {
    return _HiddenDotsByMeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HiddenDotsByMeProvider && other.roomId == roomId;
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
mixin HiddenDotsByMeRef on AutoDisposeFutureProviderRef<List<Dot>> {
  /// The parameter `roomId` of this provider.
  String get roomId;
}

class _HiddenDotsByMeProviderElement
    extends AutoDisposeFutureProviderElement<List<Dot>>
    with HiddenDotsByMeRef {
  _HiddenDotsByMeProviderElement(super.provider);

  @override
  String get roomId => (origin as HiddenDotsByMeProvider).roomId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
