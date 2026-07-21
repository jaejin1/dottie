import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

abstract final class ImageCompress {
  /// 업로드 전 압축 — 최대 1080px, JPEG 82%.
  /// 실패하거나 이미 충분히 작으면 원본 경로 그대로 반환.
  static Future<String> forUpload(String sourcePath) async {
    try {
      final target = '${Directory.systemTemp.path}/'
          '${DateTime.now().millisecondsSinceEpoch}_c.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        target,
        minWidth: 1080,
        minHeight: 1080,
        quality: 82,
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
