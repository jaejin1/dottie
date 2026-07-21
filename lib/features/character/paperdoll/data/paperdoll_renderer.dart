import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../domain/paperdoll_config.dart';
import '../domain/paperdoll_parts.dart';
import 'paperdoll_image_cache.dart';
import 'paperdoll_manifest.dart';

/// LPC universal sprite sheet의 정면(down/south) 방향 행 인덱스.
/// 시트 구조: row 0=up, 1=left, 2=down(front), 3=right.
const int kLpcFrontFacingRow = 2;

/// 부위별 PNG를 z-order대로 합성해 단일 프레임 ui.Image / PNG 바이트로 반환.
///
/// 캐릭터 state(walking/idle/sleeping/...)와 PaperdollConfig의 face_expression은
/// 별도다. state는 frame index 산출에만 사용, expression은 face 에셋 선택에 사용.
class PaperdollRenderer {
  PaperdollRenderer({
    PaperdollManifestLoader? loader,
    PaperdollImageCache? cache,
  })  : _loader = loader ?? PaperdollManifestLoader(),
        _cache = cache ?? PaperdollImageCache();

  final PaperdollManifestLoader _loader;
  final PaperdollImageCache _cache;

  PaperdollImageCache get cache => _cache;

  /// 단일 프레임 합성.
  /// - [scale]: 렌더 픽셀 크기 = frameSize × scale (지도용 4.0 권장, 미리보기 6.0~8.0)
  /// - [frameIndex]: 0 ≤ idx < frameCount
  Future<ui.Image> renderFrame({
    required PaperdollConfig config,
    int frameIndex = 2, // 기본은 idle 프레임
    double scale = 4.0,
  }) async {
    final manifest = await _loader.load();
    final cacheKey = _composedKey(config, frameIndex, scale);
    final cached = _cache.getComposed(cacheKey);
    if (cached != null) return cached;

    final frameW = manifest.frameWidth;
    final frameH = manifest.frameHeight;
    final outW = (frameW * scale).round();
    final outH = (frameH * scale).round();
    final clampedFrame = frameIndex.clamp(0, manifest.frameCount - 1);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    for (final part in kPartRenderOrder) {
      final layer = await _resolveLayer(manifest, config, part);
      if (layer == null) continue;
      final image = await _cache.loadPartImage(layer.assetPath);
      if (image == null) {
        // 에셋이 아직 없을 때 — placeholder 단색 채움 (개발 단계)
        _drawPlaceholder(canvas, outW, outH, part, layer.tint);
        continue;
      }
      _drawSpriteFrame(
        canvas: canvas,
        image: image,
        frameW: frameW,
        frameH: frameH,
        frameIndex: clampedFrame,
        outW: outW,
        outH: outH,
        tint: layer.tint,
        frameRow: kLpcFrontFacingRow,
      );
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(outW, outH);
    picture.dispose();
    _cache.putComposed(cacheKey, image);
    return image;
  }

  /// Mapbox addStyleImage용 PNG 바이트.
  Future<Uint8List> renderToBytes({
    required PaperdollConfig config,
    int frameIndex = 2,
    double scale = 4.0,
  }) async {
    final image = await renderFrame(
      config: config,
      frameIndex: frameIndex,
      scale: scale,
    );
    return imageToPngBytes(image);
  }

  /// 모든 프레임 일괄 렌더 (위젯 애니메이션용).
  Future<List<ui.Image>> renderAllFrames({
    required PaperdollConfig config,
    double scale = 6.0,
  }) async {
    final manifest = await _loader.load();
    final out = <ui.Image>[];
    for (var i = 0; i < manifest.frameCount; i++) {
      out.add(await renderFrame(
          config: config, frameIndex: i, scale: scale));
    }
    return out;
  }

  Future<({String assetPath, Color? tint})?> _resolveLayer(
    PaperdollManifestData manifest,
    PaperdollConfig config,
    PartType part,
  ) async {
    switch (part) {
      case PartType.skin:
        final item = manifest.findById(PartType.skin, config.skinId) ??
            manifest.defaultOf(PartType.skin);
        return item == null ? null : (assetPath: item.assetPath, tint: null);

      case PartType.hairBack:
        // 현재 manifest는 hair_back을 별도 슬롯으로 노출하지 않음.
        // 추후 hairId에 매핑된 hair_back이 있다면 여기서 해석.
        return null;

      case PartType.hairFront:
        final item = manifest.findById(PartType.hairFront, config.hairId) ??
            manifest.defaultOf(PartType.hairFront);
        if (item == null) return null;
        final tint =
            item.tintable ? _colorFromHex(config.hairColor) : null;
        return (assetPath: item.assetPath, tint: tint);

      case PartType.face:
        // 명시적 face 항목이 있으면 그것을, 없으면 skin의 headOverlay 자동 사용.
        // LPC 시트는 body(010)와 head(100)가 분리돼 있어 skin 항목 1개가 두
        // 레이어를 묶어 표현한다.
        final item = manifest.findById(PartType.face, config.faceId) ??
            manifest.defaultOf(PartType.face);
        if (item != null) {
          final asset = _faceAssetWithExpression(
              item.assetPath, config.faceExpression);
          return (assetPath: asset, tint: null);
        }
        final skin = manifest.findById(PartType.skin, config.skinId) ??
            manifest.defaultOf(PartType.skin);
        final overlay = skin?.headOverlay;
        if (overlay == null) return null;
        return (assetPath: overlay, tint: null);

      case PartType.top:
        final item = manifest.findById(PartType.top, config.topId) ??
            manifest.defaultOf(PartType.top);
        if (item == null) return null;
        final tint = item.tintable ? _colorFromHex(config.topColor) : null;
        return (assetPath: item.assetPath, tint: tint);

      case PartType.bottom:
        final item = manifest.findById(PartType.bottom, config.bottomId) ??
            manifest.defaultOf(PartType.bottom);
        if (item == null) return null;
        final tint =
            item.tintable ? _colorFromHex(config.bottomColor) : null;
        return (assetPath: item.assetPath, tint: tint);

      case PartType.shoes:
        final item = manifest.findById(PartType.shoes, config.shoesId) ??
            manifest.defaultOf(PartType.shoes);
        return item == null ? null : (assetPath: item.assetPath, tint: null);

      case PartType.accessory:
        if (config.accessoryId == 'none') return null;
        final item =
            manifest.findById(PartType.accessory, config.accessoryId);
        return item == null ? null : (assetPath: item.assetPath, tint: null);
    }
  }

  /// face 에셋 경로에서 `_default` 부분을 표정 키로 치환.
  /// 매뉴얼 규칙: 파일명이 `{id}_{expression}.png` 형태.
  String _faceAssetWithExpression(String defaultPath, String expression) {
    if (expression == 'default') return defaultPath;
    return defaultPath.replaceFirst(
        RegExp(r'_default(\.png)$'), '_$expression\$1');
  }

  void _drawSpriteFrame({
    required Canvas canvas,
    required ui.Image image,
    required int frameW,
    required int frameH,
    required int frameIndex,
    required int outW,
    required int outH,
    Color? tint,
    int frameRow = 0,
  }) {
    // 시트 범위를 벗어나는 row가 들어와도 안전하게 0으로 클램프.
    final maxRow = (image.height ~/ frameH) - 1;
    final safeRow = frameRow.clamp(0, maxRow < 0 ? 0 : maxRow);
    final src = Rect.fromLTWH(
      (frameIndex * frameW).toDouble(),
      (safeRow * frameH).toDouble(),
      frameW.toDouble(),
      frameH.toDouble(),
    );
    final dst = Rect.fromLTWH(0, 0, outW.toDouble(), outH.toDouble());
    final paint = Paint()
      ..filterQuality = FilterQuality.none
      ..isAntiAlias = false;
    if (tint != null) {
      paint.colorFilter = ColorFilter.mode(tint, BlendMode.modulate);
    }
    canvas.drawImageRect(image, src, dst, paint);
  }

  void _drawPlaceholder(
    Canvas canvas,
    int outW,
    int outH,
    PartType part,
    Color? tint,
  ) {
    // 에셋이 없는 동안 부위별 단색 직사각형으로 시각화 (개발 모드 한정)
    final color = tint ?? _placeholderColor(part);
    final rect = _placeholderRect(part, outW, outH);
    final paint = Paint()..color = color.withValues(alpha: 0.7);
    canvas.drawRect(rect, paint);
  }

  Rect _placeholderRect(PartType part, int outW, int outH) {
    final w = outW.toDouble();
    final h = outH.toDouble();
    switch (part) {
      case PartType.skin:
        return Rect.fromLTWH(w * 0.25, h * 0.15, w * 0.5, h * 0.7);
      case PartType.bottom:
        return Rect.fromLTWH(w * 0.28, h * 0.55, w * 0.44, h * 0.3);
      case PartType.shoes:
        return Rect.fromLTWH(w * 0.25, h * 0.85, w * 0.5, h * 0.1);
      case PartType.top:
        return Rect.fromLTWH(w * 0.25, h * 0.35, w * 0.5, h * 0.25);
      case PartType.hairBack:
      case PartType.hairFront:
        return Rect.fromLTWH(w * 0.22, h * 0.1, w * 0.56, h * 0.18);
      case PartType.face:
        return Rect.fromLTWH(w * 0.32, h * 0.22, w * 0.36, h * 0.12);
      case PartType.accessory:
        return Rect.fromLTWH(w * 0.3, h * 0.06, w * 0.4, h * 0.1);
    }
  }

  Color _placeholderColor(PartType part) => switch (part) {
        PartType.skin => const Color(0xFFEEC6A0),
        PartType.bottom => const Color(0xFF3F5BA9),
        PartType.shoes => const Color(0xFF4B3621),
        PartType.top => const Color(0xFFD64545),
        PartType.hairBack => const Color(0xFF5C3A21),
        PartType.hairFront => const Color(0xFF5C3A21),
        PartType.face => const Color(0xFF222222),
        PartType.accessory => const Color(0xFF333333),
      };

  String _composedKey(PaperdollConfig c, int frame, double scale) {
    // user_id 혼입 금지 — 합성 캐시 키는 config 자체 해시만 사용 (security-auditor)
    return '${c.skinId}|${c.hairId}|${c.hairColor}|'
        '${c.faceId}|${c.faceExpression}|'
        '${c.topId}|${c.topColor}|'
        '${c.bottomId}|${c.bottomColor}|'
        '${c.shoesId}|${c.accessoryId}|f$frame|s${scale.toStringAsFixed(2)}';
  }

  Color? _colorFromHex(String hex) {
    // PaperdollConfig에서 이미 검증된 `#RRGGBB` 형식만 들어옴
    final value = int.tryParse(hex.substring(1), radix: 16);
    if (value == null) return null;
    return Color(0xFF000000 | value);
  }
}
