// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$characterNotifierHash() => r'427bd2c39bb28bbfaaf18766fe232569f31243ce';

/// 캐릭터 관련 사용자 액션. 현재는 닉네임 변경 전용.
///
/// 캐릭터 외형(피부/머리/옷 등)은 `paperdollProvider`가 담당한다.
/// 이 notifier는 외형과 무관한 사용자 정보 변경에만 쓰인다.
///
/// Copied from [CharacterNotifier].
@ProviderFor(CharacterNotifier)
final characterNotifierProvider =
    AutoDisposeNotifierProvider<CharacterNotifier, CharacterConfig>.internal(
      CharacterNotifier.new,
      name: r'characterNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$characterNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CharacterNotifier = AutoDisposeNotifier<CharacterConfig>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
