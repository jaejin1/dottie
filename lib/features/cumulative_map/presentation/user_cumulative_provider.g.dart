// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_cumulative_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userCumulativeDotsHash() =>
    r'dcb12907573ada60ccfe16924aaca93b65a8c0e7';

/// 본인 누적 dot — `/v1/dots/cumulative` cursor pagination 자동 루프.
///
/// timestamp DESC 정렬. 안전장치 50 페이지 (5,000 dot 까지).
///
/// Copied from [userCumulativeDots].
@ProviderFor(userCumulativeDots)
final userCumulativeDotsProvider =
    AutoDisposeFutureProvider<List<Dot>>.internal(
      userCumulativeDots,
      name: r'userCumulativeDotsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$userCumulativeDotsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserCumulativeDotsRef = AutoDisposeFutureProviderRef<List<Dot>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
