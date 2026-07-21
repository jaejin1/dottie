// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_notification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pushNotificationServiceHash() =>
    r'72f4ff928512ad644a3488a42c967eea31276a33';

/// 앱 평생 유지되는 singleton — keepAlive.
///
/// prefs 는 watch 가 아닌 listen — 토글 변경 시 service 에 push 만 하고
/// 새 인스턴스 생성은 안 함 (Firebase listener 가 끊겨버리는 것 방지).
///
/// Copied from [pushNotificationService].
@ProviderFor(pushNotificationService)
final pushNotificationServiceProvider =
    Provider<PushNotificationService>.internal(
      pushNotificationService,
      name: r'pushNotificationServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pushNotificationServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PushNotificationServiceRef = ProviderRef<PushNotificationService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
