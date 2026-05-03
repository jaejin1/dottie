import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/notification_model.dart';

final notificationRemoteSourceProvider =
    Provider<NotificationRemoteSource>((ref) {
  return NotificationRemoteSource();
});

class NotificationRemoteSource {
  final _dio = ApiClient.instance;

  Future<List<AppNotification>> getNotifications({
    int limit = 20,
    int offset = 0,
  }) async {
    debugPrint(
        '[Notification] GET /notifications?limit=$limit&offset=$offset');
    try {
      final res = await _dio.get(
        ApiEndpoints.notifications,
        queryParameters: {'limit': limit, 'offset': offset},
      );
      final list = (res.data['data'] ?? res.data) as List;
      final result = list
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
      debugPrint('[Notification] got ${result.length} items');
      // 첫 항목의 키 존재 여부만 로깅 (PII 보호)
      if (result.isNotEmpty) {
        final first = result.first;
        debugPrint(
            '[Notification] sample: roomId=${first.roomId != null} '
            'dotId=${first.dotId != null}');
      }
      return result;
    } on DioException catch (e) {
      debugPrint('[Notification] GET failed: ${e.response?.statusCode}');
      if (e.response != null) rethrow;
      return []; // 오프라인 → 빈 목록
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _dio.post(ApiEndpoints.notificationRead(id));
    } on DioException catch (e) {
      if (e.response != null) rethrow;
    }
  }

  Future<void> markAllRead() async {
    try {
      await _dio.post(ApiEndpoints.notificationsReadAll);
    } on DioException catch (e) {
      if (e.response != null) rethrow;
    }
  }
}
