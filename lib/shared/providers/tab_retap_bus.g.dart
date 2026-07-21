// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_retap_bus.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tabReTapBusHash() => r'81220fa0dbd5fe2370440eed618a3566c76c6336';

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

abstract class _$TabReTapBus extends BuildlessNotifier<int> {
  late final String path;

  int build(String path);
}

/// 같은 탭을 이미 활성화된 상태에서 다시 누른 이벤트의 broadcast bus.
///
/// family arg: 탭 root path (`AppRoutes.home`, `AppRoutes.rooms` 등).
/// 탭별로 별도 카운터.
///
/// **사용 패턴**:
/// - [MainShell] 의 `_onTap` 가 retap 감지 시 `.notify()` 호출
/// - 그 탭의 root screen (e.g. `_FeedView`) 가 `ref.listen` 으로 듣고 동작:
///   - 리스트 맨 위로 스크롤
///   - 데이터 invalidate
///
/// instagram / twitter / x 류 SNS 의 표준 UX 패턴 — "탭 더블탭으로 새로고침".
///
/// keepAlive — 카운터 state. listener (root screen) 가 dispose 돼도 카운터는
/// 살아있어 다음 listener 가 마지막 값을 기준으로 distinct 비교. 단 listener
/// mount 시점의 첫 build 에선 `ref.listen` 이 발화 안 함 — 의도된 동작.
///
/// Copied from [TabReTapBus].
@ProviderFor(TabReTapBus)
const tabReTapBusProvider = TabReTapBusFamily();

/// 같은 탭을 이미 활성화된 상태에서 다시 누른 이벤트의 broadcast bus.
///
/// family arg: 탭 root path (`AppRoutes.home`, `AppRoutes.rooms` 등).
/// 탭별로 별도 카운터.
///
/// **사용 패턴**:
/// - [MainShell] 의 `_onTap` 가 retap 감지 시 `.notify()` 호출
/// - 그 탭의 root screen (e.g. `_FeedView`) 가 `ref.listen` 으로 듣고 동작:
///   - 리스트 맨 위로 스크롤
///   - 데이터 invalidate
///
/// instagram / twitter / x 류 SNS 의 표준 UX 패턴 — "탭 더블탭으로 새로고침".
///
/// keepAlive — 카운터 state. listener (root screen) 가 dispose 돼도 카운터는
/// 살아있어 다음 listener 가 마지막 값을 기준으로 distinct 비교. 단 listener
/// mount 시점의 첫 build 에선 `ref.listen` 이 발화 안 함 — 의도된 동작.
///
/// Copied from [TabReTapBus].
class TabReTapBusFamily extends Family<int> {
  /// 같은 탭을 이미 활성화된 상태에서 다시 누른 이벤트의 broadcast bus.
  ///
  /// family arg: 탭 root path (`AppRoutes.home`, `AppRoutes.rooms` 등).
  /// 탭별로 별도 카운터.
  ///
  /// **사용 패턴**:
  /// - [MainShell] 의 `_onTap` 가 retap 감지 시 `.notify()` 호출
  /// - 그 탭의 root screen (e.g. `_FeedView`) 가 `ref.listen` 으로 듣고 동작:
  ///   - 리스트 맨 위로 스크롤
  ///   - 데이터 invalidate
  ///
  /// instagram / twitter / x 류 SNS 의 표준 UX 패턴 — "탭 더블탭으로 새로고침".
  ///
  /// keepAlive — 카운터 state. listener (root screen) 가 dispose 돼도 카운터는
  /// 살아있어 다음 listener 가 마지막 값을 기준으로 distinct 비교. 단 listener
  /// mount 시점의 첫 build 에선 `ref.listen` 이 발화 안 함 — 의도된 동작.
  ///
  /// Copied from [TabReTapBus].
  const TabReTapBusFamily();

  /// 같은 탭을 이미 활성화된 상태에서 다시 누른 이벤트의 broadcast bus.
  ///
  /// family arg: 탭 root path (`AppRoutes.home`, `AppRoutes.rooms` 등).
  /// 탭별로 별도 카운터.
  ///
  /// **사용 패턴**:
  /// - [MainShell] 의 `_onTap` 가 retap 감지 시 `.notify()` 호출
  /// - 그 탭의 root screen (e.g. `_FeedView`) 가 `ref.listen` 으로 듣고 동작:
  ///   - 리스트 맨 위로 스크롤
  ///   - 데이터 invalidate
  ///
  /// instagram / twitter / x 류 SNS 의 표준 UX 패턴 — "탭 더블탭으로 새로고침".
  ///
  /// keepAlive — 카운터 state. listener (root screen) 가 dispose 돼도 카운터는
  /// 살아있어 다음 listener 가 마지막 값을 기준으로 distinct 비교. 단 listener
  /// mount 시점의 첫 build 에선 `ref.listen` 이 발화 안 함 — 의도된 동작.
  ///
  /// Copied from [TabReTapBus].
  TabReTapBusProvider call(String path) {
    return TabReTapBusProvider(path);
  }

  @override
  TabReTapBusProvider getProviderOverride(
    covariant TabReTapBusProvider provider,
  ) {
    return call(provider.path);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tabReTapBusProvider';
}

/// 같은 탭을 이미 활성화된 상태에서 다시 누른 이벤트의 broadcast bus.
///
/// family arg: 탭 root path (`AppRoutes.home`, `AppRoutes.rooms` 등).
/// 탭별로 별도 카운터.
///
/// **사용 패턴**:
/// - [MainShell] 의 `_onTap` 가 retap 감지 시 `.notify()` 호출
/// - 그 탭의 root screen (e.g. `_FeedView`) 가 `ref.listen` 으로 듣고 동작:
///   - 리스트 맨 위로 스크롤
///   - 데이터 invalidate
///
/// instagram / twitter / x 류 SNS 의 표준 UX 패턴 — "탭 더블탭으로 새로고침".
///
/// keepAlive — 카운터 state. listener (root screen) 가 dispose 돼도 카운터는
/// 살아있어 다음 listener 가 마지막 값을 기준으로 distinct 비교. 단 listener
/// mount 시점의 첫 build 에선 `ref.listen` 이 발화 안 함 — 의도된 동작.
///
/// Copied from [TabReTapBus].
class TabReTapBusProvider extends NotifierProviderImpl<TabReTapBus, int> {
  /// 같은 탭을 이미 활성화된 상태에서 다시 누른 이벤트의 broadcast bus.
  ///
  /// family arg: 탭 root path (`AppRoutes.home`, `AppRoutes.rooms` 등).
  /// 탭별로 별도 카운터.
  ///
  /// **사용 패턴**:
  /// - [MainShell] 의 `_onTap` 가 retap 감지 시 `.notify()` 호출
  /// - 그 탭의 root screen (e.g. `_FeedView`) 가 `ref.listen` 으로 듣고 동작:
  ///   - 리스트 맨 위로 스크롤
  ///   - 데이터 invalidate
  ///
  /// instagram / twitter / x 류 SNS 의 표준 UX 패턴 — "탭 더블탭으로 새로고침".
  ///
  /// keepAlive — 카운터 state. listener (root screen) 가 dispose 돼도 카운터는
  /// 살아있어 다음 listener 가 마지막 값을 기준으로 distinct 비교. 단 listener
  /// mount 시점의 첫 build 에선 `ref.listen` 이 발화 안 함 — 의도된 동작.
  ///
  /// Copied from [TabReTapBus].
  TabReTapBusProvider(String path)
    : this._internal(
        () => TabReTapBus()..path = path,
        from: tabReTapBusProvider,
        name: r'tabReTapBusProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$tabReTapBusHash,
        dependencies: TabReTapBusFamily._dependencies,
        allTransitiveDependencies: TabReTapBusFamily._allTransitiveDependencies,
        path: path,
      );

  TabReTapBusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.path,
  }) : super.internal();

  final String path;

  @override
  int runNotifierBuild(covariant TabReTapBus notifier) {
    return notifier.build(path);
  }

  @override
  Override overrideWith(TabReTapBus Function() create) {
    return ProviderOverride(
      origin: this,
      override: TabReTapBusProvider._internal(
        () => create()..path = path,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        path: path,
      ),
    );
  }

  @override
  NotifierProviderElement<TabReTapBus, int> createElement() {
    return _TabReTapBusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TabReTapBusProvider && other.path == path;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, path.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TabReTapBusRef on NotifierProviderRef<int> {
  /// The parameter `path` of this provider.
  String get path;
}

class _TabReTapBusProviderElement
    extends NotifierProviderElement<TabReTapBus, int>
    with TabReTapBusRef {
  _TabReTapBusProviderElement(super.provider);

  @override
  String get path => (origin as TabReTapBusProvider).path;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
