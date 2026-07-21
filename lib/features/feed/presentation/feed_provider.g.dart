// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedNotifierHash() => r'c240f9cda3d5d36dd59fe7dd1b4646bae9836ed2';

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

abstract class _$FeedNotifier extends BuildlessAsyncNotifier<FeedState> {
  late final String? roomFilter;

  FutureOr<FeedState> build(String? roomFilter);
}

/// 피드 페이지네이션 — `/v1/feed` cursor 기반.
///
/// family arg: `roomFilter` — null 이면 전체, 값 있으면 그 방만.
/// chip 마다 별도 인스턴스로 캐시 — `keepAlive` 라 chip 전환 후 복귀 시 재페치 X.
/// 새 dot/삭제 등 갱신은 호출자가 `ref.invalidate(feedNotifierProvider)`
/// (family 전체) 로 명시적으로 invalidate.
///
/// **BE fallback**: `/v1/feed` 미구현 (404/501) 시 자동으로
/// [FeedFallbackBuilder] (Phase 1 클라이언트 합치기) 로 우회. fallback 모드는
/// 페이지네이션 없이 100 개 cap. BE 배포 확인 후 fallback + 관련 모듈 제거.
///
/// **INVALID_CURSOR (400)**: BE 가 cursor 포맷 바꾸면 발생 — 자동으로 첫
/// 페이지부터 재페치 (`ref.invalidateSelf`).
///
/// Copied from [FeedNotifier].
@ProviderFor(FeedNotifier)
const feedNotifierProvider = FeedNotifierFamily();

/// 피드 페이지네이션 — `/v1/feed` cursor 기반.
///
/// family arg: `roomFilter` — null 이면 전체, 값 있으면 그 방만.
/// chip 마다 별도 인스턴스로 캐시 — `keepAlive` 라 chip 전환 후 복귀 시 재페치 X.
/// 새 dot/삭제 등 갱신은 호출자가 `ref.invalidate(feedNotifierProvider)`
/// (family 전체) 로 명시적으로 invalidate.
///
/// **BE fallback**: `/v1/feed` 미구현 (404/501) 시 자동으로
/// [FeedFallbackBuilder] (Phase 1 클라이언트 합치기) 로 우회. fallback 모드는
/// 페이지네이션 없이 100 개 cap. BE 배포 확인 후 fallback + 관련 모듈 제거.
///
/// **INVALID_CURSOR (400)**: BE 가 cursor 포맷 바꾸면 발생 — 자동으로 첫
/// 페이지부터 재페치 (`ref.invalidateSelf`).
///
/// Copied from [FeedNotifier].
class FeedNotifierFamily extends Family<AsyncValue<FeedState>> {
  /// 피드 페이지네이션 — `/v1/feed` cursor 기반.
  ///
  /// family arg: `roomFilter` — null 이면 전체, 값 있으면 그 방만.
  /// chip 마다 별도 인스턴스로 캐시 — `keepAlive` 라 chip 전환 후 복귀 시 재페치 X.
  /// 새 dot/삭제 등 갱신은 호출자가 `ref.invalidate(feedNotifierProvider)`
  /// (family 전체) 로 명시적으로 invalidate.
  ///
  /// **BE fallback**: `/v1/feed` 미구현 (404/501) 시 자동으로
  /// [FeedFallbackBuilder] (Phase 1 클라이언트 합치기) 로 우회. fallback 모드는
  /// 페이지네이션 없이 100 개 cap. BE 배포 확인 후 fallback + 관련 모듈 제거.
  ///
  /// **INVALID_CURSOR (400)**: BE 가 cursor 포맷 바꾸면 발생 — 자동으로 첫
  /// 페이지부터 재페치 (`ref.invalidateSelf`).
  ///
  /// Copied from [FeedNotifier].
  const FeedNotifierFamily();

  /// 피드 페이지네이션 — `/v1/feed` cursor 기반.
  ///
  /// family arg: `roomFilter` — null 이면 전체, 값 있으면 그 방만.
  /// chip 마다 별도 인스턴스로 캐시 — `keepAlive` 라 chip 전환 후 복귀 시 재페치 X.
  /// 새 dot/삭제 등 갱신은 호출자가 `ref.invalidate(feedNotifierProvider)`
  /// (family 전체) 로 명시적으로 invalidate.
  ///
  /// **BE fallback**: `/v1/feed` 미구현 (404/501) 시 자동으로
  /// [FeedFallbackBuilder] (Phase 1 클라이언트 합치기) 로 우회. fallback 모드는
  /// 페이지네이션 없이 100 개 cap. BE 배포 확인 후 fallback + 관련 모듈 제거.
  ///
  /// **INVALID_CURSOR (400)**: BE 가 cursor 포맷 바꾸면 발생 — 자동으로 첫
  /// 페이지부터 재페치 (`ref.invalidateSelf`).
  ///
  /// Copied from [FeedNotifier].
  FeedNotifierProvider call(String? roomFilter) {
    return FeedNotifierProvider(roomFilter);
  }

  @override
  FeedNotifierProvider getProviderOverride(
    covariant FeedNotifierProvider provider,
  ) {
    return call(provider.roomFilter);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'feedNotifierProvider';
}

/// 피드 페이지네이션 — `/v1/feed` cursor 기반.
///
/// family arg: `roomFilter` — null 이면 전체, 값 있으면 그 방만.
/// chip 마다 별도 인스턴스로 캐시 — `keepAlive` 라 chip 전환 후 복귀 시 재페치 X.
/// 새 dot/삭제 등 갱신은 호출자가 `ref.invalidate(feedNotifierProvider)`
/// (family 전체) 로 명시적으로 invalidate.
///
/// **BE fallback**: `/v1/feed` 미구현 (404/501) 시 자동으로
/// [FeedFallbackBuilder] (Phase 1 클라이언트 합치기) 로 우회. fallback 모드는
/// 페이지네이션 없이 100 개 cap. BE 배포 확인 후 fallback + 관련 모듈 제거.
///
/// **INVALID_CURSOR (400)**: BE 가 cursor 포맷 바꾸면 발생 — 자동으로 첫
/// 페이지부터 재페치 (`ref.invalidateSelf`).
///
/// Copied from [FeedNotifier].
class FeedNotifierProvider
    extends AsyncNotifierProviderImpl<FeedNotifier, FeedState> {
  /// 피드 페이지네이션 — `/v1/feed` cursor 기반.
  ///
  /// family arg: `roomFilter` — null 이면 전체, 값 있으면 그 방만.
  /// chip 마다 별도 인스턴스로 캐시 — `keepAlive` 라 chip 전환 후 복귀 시 재페치 X.
  /// 새 dot/삭제 등 갱신은 호출자가 `ref.invalidate(feedNotifierProvider)`
  /// (family 전체) 로 명시적으로 invalidate.
  ///
  /// **BE fallback**: `/v1/feed` 미구현 (404/501) 시 자동으로
  /// [FeedFallbackBuilder] (Phase 1 클라이언트 합치기) 로 우회. fallback 모드는
  /// 페이지네이션 없이 100 개 cap. BE 배포 확인 후 fallback + 관련 모듈 제거.
  ///
  /// **INVALID_CURSOR (400)**: BE 가 cursor 포맷 바꾸면 발생 — 자동으로 첫
  /// 페이지부터 재페치 (`ref.invalidateSelf`).
  ///
  /// Copied from [FeedNotifier].
  FeedNotifierProvider(String? roomFilter)
    : this._internal(
        () => FeedNotifier()..roomFilter = roomFilter,
        from: feedNotifierProvider,
        name: r'feedNotifierProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$feedNotifierHash,
        dependencies: FeedNotifierFamily._dependencies,
        allTransitiveDependencies:
            FeedNotifierFamily._allTransitiveDependencies,
        roomFilter: roomFilter,
      );

  FeedNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roomFilter,
  }) : super.internal();

  final String? roomFilter;

  @override
  FutureOr<FeedState> runNotifierBuild(covariant FeedNotifier notifier) {
    return notifier.build(roomFilter);
  }

  @override
  Override overrideWith(FeedNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: FeedNotifierProvider._internal(
        () => create()..roomFilter = roomFilter,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roomFilter: roomFilter,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<FeedNotifier, FeedState> createElement() {
    return _FeedNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FeedNotifierProvider && other.roomFilter == roomFilter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roomFilter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FeedNotifierRef on AsyncNotifierProviderRef<FeedState> {
  /// The parameter `roomFilter` of this provider.
  String? get roomFilter;
}

class _FeedNotifierProviderElement
    extends AsyncNotifierProviderElement<FeedNotifier, FeedState>
    with FeedNotifierRef {
  _FeedNotifierProviderElement(super.provider);

  @override
  String? get roomFilter => (origin as FeedNotifierProvider).roomFilter;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
