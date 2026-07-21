import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

part 'push_token_remote_source.g.dart';

/// FCM 디바이스 토큰을 BE 에 등록/삭제.
///
/// `POST /v1/users/me/push-token` — 등록 (upsert)
/// `DELETE /v1/users/me/push-token` — 삭제 (멱등)
///
/// 호출 실패는 silent — 권한 거부/네트워크 일시 장애 등은 다음 sync 주기에서
/// 자연 재시도되거나 로그아웃 시 정리된다.
class PushTokenRemoteSource {
  PushTokenRemoteSource(this._dio);
  final Dio _dio;

  /// 토큰 등록 — 신규 또는 갱신.
  /// BE 가 user_id 는 인증 토큰에서 추출. token + platform 만 보냄.
  Future<void> registerToken(String token) async {
    try {
      await _dio.post(
        ApiEndpoints.pushToken,
        data: {
          'token': token,
          'platform': _platform(),
        },
      );
      assert(() {
        debugPrint('[PushToken] register OK token=${_truncate(token)}');
        return true;
      }());
    } on DioException catch (e) {
      debugPrint(
          '[PushToken] register failed status=${e.response?.statusCode} '
          'msg=${e.message}');
    } catch (e) {
      debugPrint('[PushToken] register unexpected: $e');
    }
  }

  /// 토큰 삭제 — 로그아웃 시 호출.
  Future<void> unregisterToken(String token) async {
    try {
      await _dio.delete(
        ApiEndpoints.pushToken,
        data: {'token': token},
      );
      assert(() {
        debugPrint('[PushToken] unregister OK token=${_truncate(token)}');
        return true;
      }());
    } on DioException catch (e) {
      debugPrint(
          '[PushToken] unregister failed status=${e.response?.statusCode} '
          'msg=${e.message}');
    } catch (e) {
      debugPrint('[PushToken] unregister unexpected: $e');
    }
  }

  String _platform() {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'unknown';
  }

  static String _truncate(String token) =>
      token.length > 20 ? '${token.substring(0, 20)}...' : token;
}

@riverpod
PushTokenRemoteSource pushTokenRemoteSource(Ref ref) =>
    PushTokenRemoteSource(ApiClient.instance);
