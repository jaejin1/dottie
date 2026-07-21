import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

part 'notification_preferences_remote_source.g.dart';

/// 푸시 알림 환경설정 — BE 응답 DTO.
///
/// BE spec: `{ data: { comment_on_my_dot, new_dot_in_my_room } }`.
/// 신규 사용자는 BE 가 자동 default (`{true, true}`) 응답 — FE 분기 불필요.
class NotificationPrefsDto {
  const NotificationPrefsDto({
    required this.commentOnMyDot,
    required this.newDotInMyRoom,
  });

  final bool commentOnMyDot;
  final bool newDotInMyRoom;

  factory NotificationPrefsDto.fromJson(Map<String, dynamic> json) {
    // BE 가 누락 시 default true (spec 의 fail-open 과 일관).
    return NotificationPrefsDto(
      commentOnMyDot: json['comment_on_my_dot'] as bool? ?? true,
      newDotInMyRoom: json['new_dot_in_my_room'] as bool? ?? true,
    );
  }
}

/// `/v1/users/me/notification-preferences` 호출.
///
/// **에러 처리 전략** — BE 미배포 (404/501) / 네트워크 오류는 호출자가
/// SharedPreferences 폴백을 쓰도록 `null` 반환. 401 같은 인증 오류는
/// re-throw (AuthInterceptor 처리). 400 BAD_REQUEST 는 클라이언트 버그 →
/// re-throw 후 상위에서 로깅.
class NotificationPreferencesRemoteSource {
  NotificationPreferencesRemoteSource(this._dio);
  final Dio _dio;

  /// 현재 사용자 알림 설정. BE 가 없으면 `null` (호출자 로컬 폴백).
  Future<NotificationPrefsDto?> fetch() async {
    try {
      final res = await _dio.get(ApiEndpoints.notificationPreferences);
      final data = _unwrap(res.data);
      return NotificationPrefsDto.fromJson(data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404 || status == 501) {
        debugPrint('[notif-prefs] BE not deployed (status=$status) — fallback');
        return null;
      }
      if (e.response == null) {
        // 네트워크 오류 — 폴백
        assert(() {
          debugPrint('[notif-prefs] network error — fallback: $e');
          return true;
        }());
        return null;
      }
      rethrow;
    }
  }

  /// 부분 업데이트. `null` 인 필드는 PATCH 본문에서 생략. 응답은 갱신 후 전체.
  /// BE 미배포 / 네트워크 오류 시 `null` (호출자 로컬-only 모드).
  Future<NotificationPrefsDto?> patch({
    bool? commentOnMyDot,
    bool? newDotInMyRoom,
  }) async {
    final body = <String, dynamic>{
      if (commentOnMyDot != null) 'comment_on_my_dot': commentOnMyDot,
      if (newDotInMyRoom != null) 'new_dot_in_my_room': newDotInMyRoom,
    };
    if (body.isEmpty) {
      // 빈 PATCH 는 BE 가 400. 호출하지 말 것.
      throw ArgumentError('patch() requires at least one field');
    }
    try {
      final res = await _dio.patch(
        ApiEndpoints.notificationPreferences,
        data: body,
      );
      final data = _unwrap(res.data);
      return NotificationPrefsDto.fromJson(data);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404 || status == 501) {
        debugPrint('[notif-prefs] PATCH BE not deployed (status=$status)');
        return null;
      }
      if (e.response == null) {
        assert(() {
          debugPrint('[notif-prefs] PATCH network error: $e');
          return true;
        }());
        return null;
      }
      rethrow;
    }
  }

  Map<String, dynamic> _unwrap(dynamic raw) {
    if (raw is Map && raw['data'] is Map) {
      return (raw['data'] as Map).cast<String, dynamic>();
    }
    return (raw as Map).cast<String, dynamic>();
  }
}

@riverpod
NotificationPreferencesRemoteSource notificationPreferencesRemoteSource(
        Ref ref) =>
    NotificationPreferencesRemoteSource(ApiClient.instance);
