// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identities_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$linkedIdentitiesNotifierHash() =>
    r'ecf7a433bdf7ab584c95565b9e73d48ac2ffbacf';

/// 연결된 소셜 계정 목록 + 연결/해제 액션.
///
/// Copied from [LinkedIdentitiesNotifier].
@ProviderFor(LinkedIdentitiesNotifier)
final linkedIdentitiesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      LinkedIdentitiesNotifier,
      List<LinkedIdentity>
    >.internal(
      LinkedIdentitiesNotifier.new,
      name: r'linkedIdentitiesNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$linkedIdentitiesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LinkedIdentitiesNotifier =
    AutoDisposeAsyncNotifier<List<LinkedIdentity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
