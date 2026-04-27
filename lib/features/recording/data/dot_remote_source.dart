import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/dot_model.dart';

part 'dot_remote_source.g.dart';

class DotRemoteSource {
  DotRemoteSource(this._dio);
  final Dio _dio;

  Future<String?> startRecording() async {
    try {
      final res = await _dio.post(ApiEndpoints.recordingsStart);
      return res.data['id'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> endRecording(String dayLogId) async {
    try {
      await _dio.post(
        ApiEndpoints.recordingsEnd,
        data: {'day_log_id': dayLogId},
      );
    } catch (_) {}
  }

  Future<bool> uploadDot(Dot dot) async {
    try {
      await _dio.post(ApiEndpoints.dots, data: {
        'id': dot.id,
        'latitude': dot.latitude,
        'longitude': dot.longitude,
        'timestamp': dot.timestamp.toIso8601String(),
        'place_name': dot.placeName,
        'place_category': dot.placeCategory,
        'photo_url': dot.photoUrl,
        'memo': dot.memo,
        'emotion': dot.emotion,
        'day_log_id': dot.dayLogId,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> batchSyncDots(List<Dot> dots) async {
    if (dots.isEmpty) return;
    try {
      await _dio.post(
        ApiEndpoints.dotsBatch,
        data: {
          'dots': dots
              .map((d) => {
                    'id': d.id,
                    'latitude': d.latitude,
                    'longitude': d.longitude,
                    'timestamp': d.timestamp.toIso8601String(),
                    'place_name': d.placeName,
                    'place_category': d.placeCategory,
                    'photo_url': d.photoUrl,
                    'memo': d.memo,
                    'emotion': d.emotion,
                    'day_log_id': d.dayLogId,
                  })
              .toList(),
        },
      );
    } catch (_) {}
  }
}

@riverpod
DotRemoteSource dotRemoteSource(Ref ref) =>
    DotRemoteSource(ApiClient.instance);
