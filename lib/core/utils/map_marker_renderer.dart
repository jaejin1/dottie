import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// 첫/끝 dot 시각화용 깃발/핀 마커 PNG 렌더러.
///
/// `addStyleImage` 용 PNG bytes 반환. 앵커는 BOTTOM 기준이므로
/// 깃대/꼬리의 끝을 PNG 하단에 맞췄다.
class MapMarkerRenderer {
  MapMarkerRenderer._();

  static const int pixelSize = 80;

  // ── 화살표 march 애니메이션 ─────────────────────────
  // SymbolLayer + symbolPlacement: LINE 위에 N프레임 화살표를 시간순으로
  // 갈아끼워 → → → 흐르는 효과. 화살표 내부 위치를 frame마다 시프트하고
  // symbolSpacing == 1주기 logical 시프트량으로 맞춰 cycle reset 시점이
  // 자연스럽게 이어지도록 했다.
  //
  // 디자인: 슬림한 노치 chevron 필을 + 부드러운 drop shadow.
  // (흰 halo + 두꺼운 stroke 조합은 스티커/AI 느낌 → 제거)
  //
  // source 120×40 / addStyleImage scale 2.0 / iconSize 1.0 → logical 60×20
  // 중심 x = 16 → 104 (5단계, source 88px = logical 44px) → spacing 44.
  static const int arrowFrameCount = 5;
  static const int arrowSourceWidth = 120;
  static const int arrowSourceHeight = 40;
  static const double arrowSymbolSpacing = 44.0;

  /// 줌 레벨별 iconSize. 줌 아웃 시 작게.
  /// (z=10 city / z=13 district / z=16 street)
  static const String arrowSizeExpression =
      '["interpolate",["linear"],["zoom"],10,0.4,13,0.6,16,0.9]';

  /// 줌 레벨별 symbol-spacing. iconSize × 44(seamless cycle 길이)와 동기.
  /// 다른 비율을 쓰면 cycle reset 시점이 어긋나 화살표가 점프함.
  static const String arrowSpacingExpression =
      '["interpolate",["linear"],["zoom"],10,17.6,13,26.4,16,39.6]';

  /// 라인 위 화살표 march 용 N프레임 PNG.
  /// 각 프레임은 노치 chevron을 source 좌표계 안에서 다른 x에 그린다.
  static Future<List<Uint8List>> renderArrowFrames({
    required Color color,
  }) async {
    const double startX = 16.0;
    const double endX = 104.0;
    const double step = (endX - startX) / (arrowFrameCount - 1);
    const double cy = arrowSourceHeight / 2.0;
    const double aw = 8.0;    // 진행 방향 half-width (슬림하게)
    const double ah = 12.5;   // 수직 half-height (acute angle)
    const double notch = 4.0; // 뒷면 V 노치 깊이
    final frames = <Uint8List>[];

    for (var i = 0; i < arrowFrameCount; i++) {
      final cx = startX + step * i;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // 노치가 있는 chevron 필을 path
      // A(back-top) → B(tip) → C(back-bottom) → D(notch) → close
      final path = Path()
        ..moveTo(cx - aw, cy - ah)
        ..lineTo(cx + aw, cy)
        ..lineTo(cx - aw, cy + ah)
        ..lineTo(cx - aw + notch, cy)
        ..close();

      // Drop shadow — 다크/라이트 맵 어디서도 살짝 떠 보이게
      canvas.save();
      canvas.translate(0.6, 1.4);
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.black.withAlpha(95)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2),
      );
      canvas.restore();

      // 본체 (단색 fill, halo 없음)
      canvas.drawPath(path, Paint()..color = color);

      final pic = recorder.endRecording();
      final img = await pic.toImage(arrowSourceWidth, arrowSourceHeight);
      final bd = await img.toByteData(format: ui.ImageByteFormat.png);
      frames.add(bd!.buffer.asUint8List());
    }
    return frames;
  }

  /// 출발 깃발 — 깃대 + 삼각 깃발.
  static Future<Uint8List> renderStartFlag({required Color color}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = pixelSize.toDouble();

    // 깃대 (왼쪽 정렬, 바닥부터 위로)
    canvas.drawLine(
      Offset(size * 0.34, size),
      Offset(size * 0.34, size * 0.10),
      Paint()
        ..color = const Color(0xFF3B2E22)
        ..strokeWidth = size * 0.06
        ..strokeCap = StrokeCap.round,
    );

    // 깃발 삼각형
    final flagPath = Path()
      ..moveTo(size * 0.34, size * 0.10)
      ..lineTo(size * 0.84, size * 0.26)
      ..lineTo(size * 0.34, size * 0.42)
      ..close();
    canvas.drawPath(flagPath, Paint()..color = color);
    canvas.drawPath(
      flagPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.04
        ..strokeJoin = StrokeJoin.round,
    );

    final pic = recorder.endRecording();
    final img = await pic.toImage(pixelSize, pixelSize);
    final bd = await img.toByteData(format: ui.ImageByteFormat.png);
    return bd!.buffer.asUint8List();
  }

  /// 도착 핀 — 동그란 머리 + 뾰족한 꼬리.
  static Future<Uint8List> renderEndPin({required Color color}) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = pixelSize.toDouble();
    final cx = size * 0.5;
    final headCenter = Offset(cx, size * 0.34);
    final headRadius = size * 0.30;

    // 꼬리 (삼각형, 머리 아래로 내려와 바닥에서 끝남)
    final tailPath = Path()
      ..moveTo(cx - size * 0.10, size * 0.55)
      ..lineTo(cx, size)
      ..lineTo(cx + size * 0.10, size * 0.55)
      ..close();
    final pinPaint = Paint()..color = color;
    canvas.drawPath(tailPath, pinPaint);

    // 머리 (원, 꼬리 위에 덮어 합성)
    canvas.drawCircle(headCenter, headRadius, pinPaint);
    canvas.drawCircle(
      headCenter,
      headRadius,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.05,
    );

    // 안쪽 흰 포인트
    canvas.drawCircle(
      headCenter,
      headRadius * 0.42,
      Paint()..color = Colors.white,
    );

    final pic = recorder.endRecording();
    final img = await pic.toImage(pixelSize, pixelSize);
    final bd = await img.toByteData(format: ui.ImageByteFormat.png);
    return bd!.buffer.asUint8List();
  }
}
