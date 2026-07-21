// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationPreferencesNotifierHash() =>
    r'1ce4733e39bfaabfd73fc6218945895323b43055';

/// 푸시 알림 환경설정 — BE 우선 + SharedPreferences 캐시 폴백.
///
/// **소스 우선순위**:
/// 1. 앱 시작 시 BE `/v1/users/me/notification-preferences` GET 시도
/// 2. 성공 → 응답값을 SharedPreferences 에 캐시 후 사용
/// 3. 실패 (BE 미배포 404/501, 네트워크 오류) → SharedPreferences 캐시값 사용
///
/// **토글 동작** ([setCommentOnMyDot] / [setNewDotInMyRoom]):
/// - BE PATCH → 응답 echo 로 state + 캐시 갱신
/// - BE 미배포 (404/501) / 네트워크 오류 → remote source 가 흡수해 `null` 반환
///   → 로컬만 갱신 (오프라인-friendly)
/// - 그 외 4xx (400/401 등) → throw — 호출자가 snackbar + UI 롤백
///
/// **2차 방어**: BE 가 차단 누락한 경우에도
/// [push_notification_service._handleForeground] 가 [shouldShowForType] 로
/// foreground in-app banner 만 차단 — race condition / 오프라인 안전망.
///
/// Copied from [NotificationPreferencesNotifier].
@ProviderFor(NotificationPreferencesNotifier)
final notificationPreferencesNotifierProvider =
    AsyncNotifierProvider<
      NotificationPreferencesNotifier,
      NotificationPreferences
    >.internal(
      NotificationPreferencesNotifier.new,
      name: r'notificationPreferencesNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationPreferencesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationPreferencesNotifier =
    AsyncNotifier<NotificationPreferences>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
