import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../domain/animation_frame.dart';

// 캐릭터를 Flutter CustomPainter로 그리고 Uint8List로 변환하는 유틸
class CharacterRenderer {
  static Future<ui.Image> render({
    required Color color,
    required CharacterState state,
    double size = 80,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = _CharacterPainter(color: color, state: state);
    painter.paint(canvas, Size(size, size));
    final picture = recorder.endRecording();
    return picture.toImage(size.toInt(), size.toInt());
  }

  /// Mapbox PointAnnotation에 직접 사용할 PNG bytes 반환
  static Future<Uint8List> renderToBytes({
    required Color color,
    required CharacterState state,
    double size = 80,
  }) async {
    final img = await render(color: color, state: state, size: size);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}

// 지도 위 캐릭터 오버레이 위젯 (Stack 사용)
class CharacterOverlayWidget extends StatefulWidget {
  const CharacterOverlayWidget({
    super.key,
    required this.color,
    required this.state,
    this.size = 48,
  });

  final Color color;
  final CharacterState state;
  final double size;

  @override
  State<CharacterOverlayWidget> createState() => _CharacterOverlayWidgetState();
}

class _CharacterOverlayWidgetState extends State<CharacterOverlayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _bounce = Tween<double>(begin: 0, end: -4).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _bounce.value),
        child: CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _CharacterPainter(
            color: widget.color,
            state: widget.state,
          ),
        ),
      ),
    );
  }
}

// 캐릭터 CustomPainter — 동그란 dot 기반 2등신 캐릭터
class _CharacterPainter extends CustomPainter {
  const _CharacterPainter({required this.color, required this.state});

  final Color color;
  final CharacterState state;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.3; // 머리 반지름

    // 그림자
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha(40)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + r * 1.8), width: r * 1.4, height: r * 0.4),
      shadowPaint,
    );

    // 몸통 (작은 원)
    if (state != CharacterState.idle) {
      final bodyPaint = Paint()..color = color.withAlpha(180);
      canvas.drawCircle(Offset(cx, cy + r * 0.9), r * 0.5, bodyPaint);
    }

    // 머리 (큰 원)
    final headPaint = Paint()..color = color;
    canvas.drawCircle(Offset(cx, cy), r, headPaint);

    // 테두리
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(cx, cy), r, borderPaint);

    // 눈
    _drawEyes(canvas, Offset(cx, cy), r);

    // 상태별 이모지 뱃지
    _drawStateBadge(canvas, size, r);
  }

  void _drawEyes(Canvas canvas, Offset center, double r) {
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = const Color(0xFF1A1A2E);

    switch (state) {
      case CharacterState.sleeping:
        // 눈 감은 선
        final linePaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          Offset(center.dx - r * 0.3, center.dy - r * 0.1),
          Offset(center.dx - r * 0.1, center.dy - r * 0.1),
          linePaint,
        );
        canvas.drawLine(
          Offset(center.dx + r * 0.1, center.dy - r * 0.1),
          Offset(center.dx + r * 0.3, center.dy - r * 0.1),
          linePaint,
        );
      case CharacterState.arrived:
        // 반짝이는 눈 (별 모양으로 표현)
        _drawStar(canvas, Offset(center.dx - r * 0.2, center.dy - r * 0.1), r * 0.15, Colors.yellow);
        _drawStar(canvas, Offset(center.dx + r * 0.2, center.dy - r * 0.1), r * 0.15, Colors.yellow);
      default:
        // 기본 눈
        canvas.drawCircle(Offset(center.dx - r * 0.22, center.dy - r * 0.1), r * 0.13, eyePaint);
        canvas.drawCircle(Offset(center.dx + r * 0.22, center.dy - r * 0.1), r * 0.13, eyePaint);
        canvas.drawCircle(Offset(center.dx - r * 0.2, center.dy - r * 0.08), r * 0.07, pupilPaint);
        canvas.drawCircle(Offset(center.dx + r * 0.2, center.dy - r * 0.08), r * 0.07, pupilPaint);
    }
  }

  void _drawStateBadge(Canvas canvas, Size size, double r) {
    final badge = switch (state) {
      CharacterState.walking => '🚶',
      CharacterState.driving => '🚗',
      CharacterState.sleeping => '💤',
      CharacterState.arrived => '📍',
      CharacterState.idle => null,
    };

    if (badge == null) return;

    final tp = TextPainter(
      text: TextSpan(text: badge, style: TextStyle(fontSize: r * 0.8)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(size.width - tp.width - 2, size.height - tp.height - 2),
    );
  }

  void _drawStar(Canvas canvas, Offset center, double r, Color color) {
    final paint = Paint()..color = color;
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - math.pi / 2;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CharacterPainter old) =>
      old.color != color || old.state != state;
}
