// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$discoverFeedHash() => r'8da07d56250435d3274bb244f5daf033572d90fc';

/// 공개 코스 디스커버리 피드. 초기 로드 + 필터 변경 시 재조회 + 커서 무한 스크롤.
///
/// Copied from [DiscoverFeed].
@ProviderFor(DiscoverFeed)
final discoverFeedProvider =
    AutoDisposeAsyncNotifierProvider<DiscoverFeed, DiscoverFeedState>.internal(
      DiscoverFeed.new,
      name: r'discoverFeedProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$discoverFeedHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$DiscoverFeed = AutoDisposeAsyncNotifier<DiscoverFeedState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
