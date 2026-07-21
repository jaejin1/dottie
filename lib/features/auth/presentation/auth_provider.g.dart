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
String _$currentUserHash() => r'23a5b5ccb41bcb80e716aa39d3646d17c21efe54';

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
String _$currentDottieUserHash() => r'a87c9a52f36b090392fc2fc5915d118b15835dab';

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
String _$currentUserColorHash() => r'40e78a50ece8c2bf7c4fdc4ab632e6149b7a9fa7';

/// 현재 사용자의 정체성 색.
///
/// 우선순위: `paperdollProvider.colorHex` > `currentDottieUser.character.colorHex`
/// (paperdollProvider가 picker 즉시 반영을 위한 단일 source of truth — 저장 후
/// `currentDottieUser` 재요청 없이 색이 즉시 갱신됨).
///
/// 자유 hex 형식. 잘못된 값이면 default(`#7EB8F7`)로 폴백.
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
String _$authNotifierHash() => r'd600ed9f4cd17afa03abc6a0aa7a57553b841ef5';

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
