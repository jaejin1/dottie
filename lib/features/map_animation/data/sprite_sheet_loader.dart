import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class SpriteSheetLoader {
  SpriteSheetLoader._();

  static const int targetSize = 344;

  /// 균등 분할 수평 스프라이트 시트를 [frameCount]개 PNG로 크롭해 반환.
  /// loading1.png / loading2.png 처럼 JSON 없이 n등분된 시트에 사용.
  static Future<List<Uint8List>> loadHorizontalFrames({
    required String imgAssetPath,
    required int frameCount,
  }) async {
    final imgBytes = await rootBundle.load(imgAssetPath);
    final codec =
        await ui.instantiateImageCodec(imgBytes.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final sheet = frame.image;

    final frameW = sheet.width ~/ frameCount;
    final frameH = sheet.height;

    final result = <Uint8List>[];
    for (int i = 0; i < frameCount; i++) {
      result.add(await _cropFrameExact(sheet, i * frameW, 0, frameW, frameH));
    }
    return result;
  }

  /// JSON + PNG 에셋에서 각 프레임을 targetSize×targetSize PNG로 크롭해 반환.
  /// 반환 맵 키: 'sprite-0' ~ 'sprite-N' (JSON sprites 배열 순서)
  static Future<Map<String, Uint8List>> loadFrames({
    required String jsonAssetPath,
    required String imgAssetPath,
  }) async {
    final jsonStr = await rootBundle.loadString(jsonAssetPath);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    final sprites = (json['sprites'] as List).cast<Map<String, dynamic>>();

    final imgBytes = await rootBundle.load(imgAssetPath);
    final codec =
        await ui.instantiateImageCodec(imgBytes.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    final sheet = frame.image;

    final result = <String, Uint8List>{};
    for (int i = 0; i < sprites.length; i++) {
      final s = sprites[i];
      result['sprite-$i'] = await _cropFrame(
        sheet,
        s['x'] as int,
        s['y'] as int,
        s['width'] as int,
        s['height'] as int,
      );
    }
    return result;
  }

  // JSON 기반 (targetSize 정규화)
  static Future<Uint8List> _cropFrame(
      ui.Image sheet, int x, int y, int w, int h) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final dst = ui.Rect.fromLTWH(
      (targetSize - w) / 2,
      (targetSize - h) / 2,
      w.toDouble(),
      h.toDouble(),
    );
    canvas.drawImageRect(
        sheet,
        ui.Rect.fromLTWH(x.toDouble(), y.toDouble(), w.toDouble(), h.toDouble()),
        dst,
        ui.Paint());
    final picture = recorder.endRecording();
    final img = await picture.toImage(targetSize, targetSize);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  // 수평 균등 분할 (원본 크기 유지)
  static Future<Uint8List> _cropFrameExact(
      ui.Image sheet, int x, int y, int w, int h) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawImageRect(
        sheet,
        ui.Rect.fromLTWH(x.toDouble(), y.toDouble(), w.toDouble(), h.toDouble()),
        ui.Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
        ui.Paint());
    final picture = recorder.endRecording();
    final img = await picture.toImage(w, h);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
