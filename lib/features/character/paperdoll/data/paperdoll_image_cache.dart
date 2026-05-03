import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart' show rootBundle;

/// 부위 PNG 및 합성 결과 캐시.
///
/// security-auditor 권고: LRU 상한으로 메모리 고갈 방지.
class PaperdollImageCache {
  PaperdollImageCache({
    this.partImageLimit = 50,
    this.composedLimit = 100,
  });

  final int partImageLimit;
  final int composedLimit;

  final _partImages = <String, ui.Image>{};
  final _partImageOrder = <String>[];

  final _composedImages = <String, ui.Image>{};
  final _composedOrder = <String>[];

  /// asset 경로 → ui.Image 로드(LRU). 같은 경로 재요청 시 캐시 히트.
  /// 에셋이 없으면 null 반환 (호출자가 placeholder 처리).
  Future<ui.Image?> loadPartImage(String assetPath) async {
    final hit = _partImages[assetPath];
    if (hit != null) {
      _touchPart(assetPath);
      return hit;
    }
    try {
      final data = await rootBundle.load(assetPath);
      final bytes = data.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      _putPart(assetPath, frame.image);
      return frame.image;
    } catch (_) {
      // 에셋이 아직 없거나 디코딩 실패 → null
      return null;
    }
  }

  ui.Image? getComposed(String key) {
    final hit = _composedImages[key];
    if (hit != null) _touchComposed(key);
    return hit;
  }

  void putComposed(String key, ui.Image image) {
    if (_composedImages.containsKey(key)) {
      _touchComposed(key);
      return;
    }
    _composedImages[key] = image;
    _composedOrder.add(key);
    if (_composedImages.length > composedLimit) {
      final evict = _composedOrder.removeAt(0);
      _composedImages.remove(evict)?.dispose();
    }
  }

  void _putPart(String key, ui.Image img) {
    _partImages[key] = img;
    _partImageOrder.add(key);
    if (_partImages.length > partImageLimit) {
      final evict = _partImageOrder.removeAt(0);
      _partImages.remove(evict)?.dispose();
    }
  }

  void _touchPart(String key) {
    _partImageOrder.remove(key);
    _partImageOrder.add(key);
  }

  void _touchComposed(String key) {
    _composedOrder.remove(key);
    _composedOrder.add(key);
  }

  /// 모든 캐시 비우기 (로그아웃/메모리 압박 시)
  void clear() {
    for (final img in _partImages.values) {
      img.dispose();
    }
    for (final img in _composedImages.values) {
      img.dispose();
    }
    _partImages.clear();
    _partImageOrder.clear();
    _composedImages.clear();
    _composedOrder.clear();
  }
}

/// PNG 바이트로 변환 (Mapbox addStyleImage 용)
Future<Uint8List> imageToPngBytes(ui.Image image) async {
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    throw StateError('Failed to encode ui.Image to PNG');
  }
  return byteData.buffer.asUint8List();
}
