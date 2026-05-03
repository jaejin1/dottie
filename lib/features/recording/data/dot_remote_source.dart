import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/dot_model.dart';
import '../../timeline/domain/day_log_model.dart';

part 'dot_remote_source.g.dart';

class DotRemoteSource {
  DotRemoteSource(this._dio);
  final Dio _dio;

  Future<String?> uploadPhoto(String filePath) async {
    try {
      final file = File(filePath);
      final fileSize = await file.length();
      final contentType = _mimeType(filePath);

      // Step 1: presigned upload URL 요청
      final res = await _dio.post(
        ApiEndpoints.mediaUpload,
        data: {'content_type': contentType, 'file_size': fileSize},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final uploadUrl = res.data['data']['upload_url'] as String?;
      final publicUrl = res.data['data']['public_url'] as String?;
      if (uploadUrl == null || publicUrl == null) return null;

      // Step 2: presigned URL에 파일 바이너리 직접 PUT
      // - 별도 Dio 인스턴스 사용 → 인증 인터셉터/기본 헤더 미포함
      // - Stream 대신 Uint8List 직접 전송 → Content-Length 보장
      final bytes = await file.readAsBytes();
      final putDio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ));
      final putRes = await putDio.put<void>(
        uploadUrl,
        data: bytes,
        options: Options(
          contentType: contentType,
          headers: {'Content-Length': bytes.length},
        ),
      );
      if (putRes.statusCode != 200 && putRes.statusCode != 204) {
        debugPrint('[Media] presigned PUT failed: ${putRes.statusCode}');
        return null;
      }
      debugPrint('[Media] PUT success → public_url=$publicUrl');

      return publicUrl;
    } catch (e) {
      debugPrint('[Media] uploadPhoto error: $e');
      return null;
    }
  }

  static String _mimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }

  /// dot 업로드 — date 기반으로 서버가 daylog 자동 생성/조회.
  /// 성공 시 (dayLogId, dotId) 반환, 실패 시 (null, null).
  Future<({String? dayLogId, String? dotId})> uploadDot(Dot dot) async {
    try {
      final local = dot.timestamp.toLocal();
      final date =
          '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
      final res = await _dio.post(ApiEndpoints.dots, data: {
        'date': date,
        'latitude': dot.latitude,
        'longitude': dot.longitude,
        'timestamp': dot.timestamp.toUtc().toIso8601String(),
        'place_name': dot.placeName,
        'place_category': dot.placeCategory,
        'memo': dot.memo,
        'emotion': dot.emotion,
      });
      final data = res.data['data'] as Map<String, dynamic>;
      return (
        dayLogId: data['day_log_id'] as String?,
        dotId: data['id'] as String?,
      );
    } catch (_) {
      return (dayLogId: null, dotId: null);
    }
  }

  /// PATCH /dots/{id}/photo — 업로드된 사진 URL을 dot에 저장
  Future<void> patchDotPhoto(String dotId, String photoUrl) async {
    try {
      await _dio.patch(
        ApiEndpoints.dotPhoto(dotId),
        data: {'photo_url': photoUrl},
      );
    } catch (e) {
      debugPrint('[Media] patchDotPhoto error: $e');
    }
  }

  /// DELETE /daylogs/:id — daylog + 연결 dots 서버에서 삭제
  /// 오프라인이면 false 반환, 서버 에러(4xx/5xx)면 rethrow
  Future<bool> deleteDayLog(String id) async {
    try {
      await _dio.delete(ApiEndpoints.daylogById(id));
      return true;
    } on DioException catch (e) {
      if (e.response != null) rethrow;
      return false;
    }
  }

  /// GET /daylogs/today?date=YYYY-MM-DD — 로컬 날짜 기준 오늘 세션 복원
  Future<DayLog?> getTodayDayLog(String localDate) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.daylogsToday,
        queryParameters: {'date': localDate},
      );
      final data = res.data['data'];
      if (data == null) return null;
      return _dayLogFromApi(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// GET /v1/daylogs — 사용자의 전체 daylog 목록 (dots 포함).
  /// 네트워크 실패 시 null 반환 (호출부에서 로컬 폴백).
  Future<List<DayLog>?> getAllDayLogs() async {
    try {
      final res = await _dio.get(ApiEndpoints.daylogs);
      final list = (res.data['data'] ?? res.data) as List;
      return list
          .map((e) => _dayLogFromApi(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      debugPrint('[DotRemote] getAllDayLogs failed: ${e.response?.statusCode}');
      return null;
    } catch (e) {
      debugPrint('[DotRemote] getAllDayLogs error: ${e.runtimeType}');
      return null;
    }
  }

  static DayLog _dayLogFromApi(Map<String, dynamic> d) {
    final rawDots = d['dots'] as List? ?? [];
    final dots =
        rawDots.map((e) => _dotFromApi(e as Map<String, dynamic>)).toList();
    return DayLog(
      id: d['id'] as String,
      userId: d['user_id'] as String,
      date: DateTime.parse(d['date'] as String),
      startedAt: DateTime.parse(d['started_at'] as String),
      endedAt: d['ended_at'] != null
          ? DateTime.parse(d['ended_at'] as String)
          : null,
      isRecording: d['is_recording'] as bool? ?? false,
      dots: dots,
      synced: true,
    );
  }

  /// GET /daylogs/:id — dots 포함한 DayLog 조회
  Future<List<Dot>?> getDayLogDots(String dayLogId) async {
    try {
      final res = await _dio.get(ApiEndpoints.daylogById(dayLogId));
      final data = res.data['data'] as Map<String, dynamic>;
      final rawDots = data['dots'] as List? ?? [];
      return rawDots
          .map((d) => _dotFromApi(d as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  static Dot _dotFromApi(Map<String, dynamic> d) => Dot(
        id: d['id'] as String,
        latitude: (d['latitude'] as num).toDouble(),
        longitude: (d['longitude'] as num).toDouble(),
        timestamp: DateTime.parse(d['timestamp'] as String),
        placeName: d['place_name'] as String?,
        placeCategory: d['place_category'] as String?,
        photoUrl: d['photo_url'] as String?,
        memo: d['memo'] as String?,
        emotion: d['emotion'] as String?,
        dayLogId: d['day_log_id'] as String,
        synced: true,
      );

  /// dot 배치 업로드 — 날짜별로 그룹화해서 전송
  Future<void> batchSyncDots(List<Dot> dots) async {
    if (dots.isEmpty) return;
    // timestamp 기준으로 날짜별 그룹화 (day_log_id 대신 date 사용)
    final grouped = <String, List<Dot>>{};
    for (final d in dots) {
      final local = d.timestamp.toLocal();
      final dateKey =
          '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
      (grouped[dateKey] ??= []).add(d);
    }
    for (final entry in grouped.entries) {
      try {
        await _dio.post(
          ApiEndpoints.dotsBatch,
          data: {
            'date': entry.key,
            'dots': entry.value
                .map((d) => {
                      'client_id': d.id,
                      'latitude': d.latitude,
                      'longitude': d.longitude,
                      'timestamp': d.timestamp.toUtc().toIso8601String(),
                      'place_name': d.placeName,
                      'place_category': d.placeCategory,
                      'memo': d.memo,
                      'emotion': d.emotion,
                      'photo_url': d.photoUrl,
                    })
                .toList(),
          },
        );
      } catch (_) {}
    }
  }
}

@riverpod
DotRemoteSource dotRemoteSource(Ref ref) =>
    DotRemoteSource(ApiClient.instance);
