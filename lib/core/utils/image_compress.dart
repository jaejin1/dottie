import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

abstract final class ImageCompress {
  /// 업로드 전 압축. 기본 최대 1080px / JPEG 82%(사진용).
  /// 커버 같은 저용량 용도는 [maxDimension]/[quality] 를 낮춰 호출한다
  /// (예: 720px / 68% — 카드 배경엔 충분하고 용량 대폭 절감).
  /// 실패하거나 이미 충분히 작으면 원본 경로 그대로 반환.
  static Future<String> forUpload(
    String sourcePath, {
    int maxDimension = 1080,
    int quality = 82,
  }) async {
    try {
      final target = '${Directory.systemTemp.path}/'
          '${DateTime.now().millisecondsSinceEpoch}_c.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        target,
        minWidth: maxDimension,
        minHeight: maxDimension,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      if (result == null) return sourcePath;
      if (kDebugMode) {
        final orig = await File(sourcePath).length();
        final comp = await File(result.path).length();
        debugPrint(
            '[ImageCompress] ${(orig / 1024).toStringAsFixed(0)}KB → '
            '${(comp / 1024).toStringAsFixed(0)}KB '
            '(${(100 - comp / orig * 100).toStringAsFixed(0)}% 절약)');
      }
      return result.path;
    } catch (e) {
      debugPrint('[ImageCompress] 압축 실패, 원본 사용: $e');
      return sourcePath;
    }
  }
}
