import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../network/api_client.dart';
import '../network/api_endpoints.dart';
import '../utils/image_compress.dart';

part 'media_upload_service.g.dart';

/// 공용 이미지 업로드 — 압축 → BE presigned 발급(`/media/upload`) → R2 직접 PUT →
/// public URL 반환. 실패/오프라인 시 null.
///
/// **R2 오브젝트 키(경로)는 BE 가 결정한다.** FE 는 아래 스코프 힌트만
/// 업로드 요청에 실어 보내고, BE 가 이를 이용해 키를 구성한다:
///   - [purpose]    업로드 용도 (예: `course_cover`, `course_item`, `dot`)
///   - [todoListId] 코스(스팟) id — 코스 기준으로 묶기 위한 base
///   - [itemId]     코스 내 항목 id — 항목 사진(추후)용
///
/// 예상 R2 레이아웃(BE 구현):
///   `todo-lists/{todoListId}/cover/{uuid}.jpg`         (코스 배경/커버)
///   `todo-lists/{todoListId}/items/{itemId}/{uuid}.jpg` (항목 사진, 추후)
///
/// 스코프를 안 보내면 BE 기본 위치(사용자 폴더 등)에 저장 — 하위호환.
class MediaUploadService {
  MediaUploadService(this._dio);
  final Dio _dio;

  Future<String?> upload(
    String filePath, {
    String? purpose,
    String? todoListId,
    String? itemId,
    int maxDimension = 1080,
    int quality = 82,
  }) async {
    try {
      // 업로드 전 압축. 커버 등 저용량 용도는 maxDimension/quality 를 낮춰 호출.
      final uploadPath = await ImageCompress.forUpload(
        filePath,
        maxDimension: maxDimension,
        quality: quality,
      );
      final file = File(uploadPath);
      final fileSize = await file.length();
      final contentType = _mimeType(uploadPath);

      // Step 1: presigned upload URL 요청 (+ R2 키 스코프 힌트).
      final res = await _dio.post(
        ApiEndpoints.mediaUpload,
        data: {
          'content_type': contentType,
          'file_size': fileSize,
          // BE 가 키 경로 구성에 사용 — 미구현이면 무시되고 기본 위치에 저장(하위호환).
          if (purpose != null) 'purpose': purpose,
          if (todoListId != null) 'todo_list_id': todoListId,
          if (itemId != null) 'item_id': itemId,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      final uploadUrl = res.data['data']['upload_url'] as String?;
      final publicUrl = res.data['data']['public_url'] as String?;
      if (uploadUrl == null || publicUrl == null) return null;

      // Step 2: presigned URL 에 파일 바이너리 직접 PUT.
      // - 별도 Dio 인스턴스 → 인증 인터셉터/기본 헤더 미포함.
      // - Uint8List 직접 전송 → Content-Length 보장.
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
        _deleteTempFile(uploadPath, filePath);
        return null;
      }
      _deleteTempFile(uploadPath, filePath);
      return publicUrl;
    } catch (e) {
      debugPrint('[Media] upload error: $e');
      return null;
    }
  }

  /// 압축 temp 파일만 삭제. 원본([originalPath])과 같은 경로면 건드리지 않음.
  static void _deleteTempFile(String uploadPath, String originalPath) {
    if (uploadPath == originalPath) return;
    try {
      File(uploadPath).deleteSync();
    } catch (_) {
      // 삭제 실패 무시 — OS가 temp 디렉토리를 자체 정리.
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
}

@riverpod
MediaUploadService mediaUploadService(Ref ref) =>
    MediaUploadService(ApiClient.instance);
