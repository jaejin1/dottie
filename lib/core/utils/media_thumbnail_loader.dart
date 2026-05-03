import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// URL 이미지를 다운로드해 원형 크롭 PNG bytes로 반환하는 유틸.
/// Mapbox addStyleImage용 (ui.ImageByteFormat.png 필수).
class MediaThumbnailLoader {
  MediaThumbnailLoader._();

  static const int pixelSize = 80;
  static const double _sz = 80.0;
  static const double _border = 3.0;

  static Future<Uint8List?> loadCircle(
    String url, {
    Color borderColor = Colors.white,
    int? orderNumber,
    Color badgeColor = const Color(0xFFC07B5A),
  }) async {
    try {
      final res = await Dio().get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      if (res.data == null) return null;

      final codec = await ui.instantiateImageCodec(
        Uint8List.fromList(res.data!),
        targetWidth: pixelSize,
        targetHeight: pixelSize,
      );
      final src = (await codec.getNextFrame()).image;

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);

      // 테두리 원
      canvas.drawCircle(
        const Offset(_sz / 2, _sz / 2),
        _sz / 2,
        Paint()..color = borderColor,
      );

      // 이미지는 클리핑 영역 안에서만 그리고, 순서 뱃지는 클립 밖에 그릴 수 있게 save/restore
      canvas.save();
      canvas.clipPath(
        Path()
          ..addOval(Rect.fromCircle(
            center: const Offset(_sz / 2, _sz / 2),
            radius: _sz / 2 - _border,
          )),
      );
      canvas.drawImageRect(
        src,
        Rect.fromLTWH(0, 0, src.width.toDouble(), src.height.toDouble()),
        Rect.fromLTWH(_border, _border, _sz - _border * 2, _sz - _border * 2),
        Paint()..isAntiAlias = true,
      );
      canvas.restore();

      // 우측 하단 순서 뱃지
      if (orderNumber != null) {
        const badgeRadius = _sz * 0.20;
        final badgeCenter = Offset(_sz - badgeRadius - 2, _sz - badgeRadius - 2);
        canvas.drawCircle(
          badgeCenter,
          badgeRadius,
          Paint()..color = badgeColor,
        );
        canvas.drawCircle(
          badgeCenter,
          badgeRadius,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        final tp = TextPainter(
          text: TextSpan(
            text: '$orderNumber',
            style: const TextStyle(
              color: Colors.white,
              fontSize: badgeRadius * 1.05,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          badgeCenter - Offset(tp.width / 2, tp.height / 2),
        );
      }

      final img = await recorder.endRecording().toImage(pixelSize, pixelSize);
      final bd = await img.toByteData(format: ui.ImageByteFormat.png);
      return bd?.buffer.asUint8List();
    } catch (e) {
      debugPrint('[MediaThumbnail] $e');
      return null;
    }
  }
}
