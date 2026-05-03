// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseAuthHash() => r'8f84097cccd00af817397c1715c5f537399ba780';

/// See also [firebaseAuth].
@ProviderFor(firebaseAuth)
final firebaseAuthProvider = AutoDisposeProvider<FirebaseAuth>.internal(
  firebaseAuth,
  name: r'firebaseAuthProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseAuthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirebaseAuthRef = AutoDisposeProviderRef<FirebaseAuth>;
String _$authStateChangesHash() => r'ed73bb63cae92e791c80e19c01a8eb421d09a663';

/// See also [authStateChanges].
@ProviderFor(authStateChanges)
final authStateChangesProvider = AutoDisposeStreamProvider<User?>.internal(
  authStateChanges,
  name: r'authStateChangesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authStateChangesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuthStateChangesRef = AutoDisposeStreamProviderRef<User?>;
String _$currentUserHash() => r'a5bcb438e190bbc8fe821cc39d43e5c28ad9997c';

/// See also [currentUser].
@ProviderFor(currentUser)
final currentUserProvider = AutoDisposeProvider<User?>.internal(
  currentUser,
  name: r'currentUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserRef = AutoDisposeProviderRef<User?>;
String _$isAuthenticatedHash() => r'6d67d64c22072310457fc0024272859f112c0be2';

/// See also [isAuthenticated].
@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = AutoDisposeProvider<bool>.internal(
  isAuthenticated,
  name: r'isAuthenticatedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAuthenticatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAuthenticatedRef = AutoDisposeProviderRef<bool>;
String _$currentDottieUserHash() => r'21dad60944579cdb6e68729b0d6ab15db2cbc499';

/// BE /users/me 로부터 현재 사용자 정보를 가져옴. uid는 BE UUID(room.ownerId와 비교 가능).
///
/// Copied from [currentDottieUser].
@ProviderFor(currentDottieUser)
final currentDottieUserProvider = FutureProvider<DottieUser?>.internal(
  currentDottieUser,
  name: r'currentDottieUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentDottieUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentDottieUserRef = FutureProviderRef<DottieUser?>;
String _$currentUserColorHash() => r'864ed14a40c69cde82ce9ea0cd7870f8b9781d27';

/// 현재 사용자의 정체성 색.
///
/// 우선순위: `paperdollProvider.colorKey` > `currentDottieUser.character.colorKey`
/// (paperdollProvider가 picker 즉시 반영을 위한 단일 source of truth — 저장 후
/// `currentDottieUser` 재요청 없이 색이 즉시 갱신됨).
///
/// 5색 프리셋(`blue/mint/coral/lavender/yellow`) 기준. 모두 미로드/잘못된 값이면
/// `DottieColors.primary` 폴백.
///
/// Copied from [currentUserColor].
@ProviderFor(currentUserColor)
final currentUserColorProvider = AutoDisposeProvider<Color>.internal(
  currentUserColor,
  name: r'currentUserColorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserColorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserColorRef = AutoDisposeProviderRef<Color>;
String _$authNotifierHash() => r'45243020bbe4c9aa6431c1e2c9f849cc8c64f3e8';

/// See also [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AutoDisposeNotifierProvider<AuthNotifier, AsyncValue<void>>.internal(
      AuthNotifier.new,
      name: r'authNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AuthNotifier = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
