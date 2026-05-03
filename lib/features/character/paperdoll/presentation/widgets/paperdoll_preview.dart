import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../data/paperdoll_renderer.dart';
import '../../domain/paperdoll_config.dart';

/// 도트 캐릭터 미리보기 위젯.
///
/// config가 바뀌면 자동으로 다시 렌더. 5프레임 워킹 애니메이션 재생(옵션).
class PaperdollPreview extends StatefulWidget {
  const PaperdollPreview({
    super.key,
    required this.renderer,
    required this.config,
    this.size = 192,
    this.animate = true,
    this.frameDuration = const Duration(milliseconds: 140),
    this.scale = 6.0,
  });

  final PaperdollRenderer renderer;
  final PaperdollConfig config;
  final double size;
  final bool animate;
  final Duration frameDuration;
  final double scale;

  @override
  State<PaperdollPreview> createState() => _PaperdollPreviewState();
}

class _PaperdollPreviewState extends State<PaperdollPreview> {
  List<ui.Image>? _frames;
  int _frameIdx = 0;
  late final _ticker = _Ticker(_advance);
  Object? _loadToken;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant PaperdollPreview old) {
    super.didUpdateWidget(old);
    if (old.config != widget.config || old.scale != widget.scale) {
      _load();
    }
    if (old.animate != widget.animate) {
      widget.animate ? _ticker.start(widget.frameDuration) : _ticker.stop();
    }
  }

  Future<void> _load() async {
    final token = Object();
    _loadToken = token;
    final frames = await widget.renderer.renderAllFrames(
      config: widget.config,
      scale: widget.scale,
    );
    if (!mounted || _loadToken != token) return;
    setState(() {
      _frames = frames;
      _frameIdx = 0;
    });
    if (widget.animate) _ticker.start(widget.frameDuration);
  }

  void _advance() {
    if (!mounted || _frames == null) return;
    setState(() {
      _frameIdx = (_frameIdx + 1) % _frames!.length;
    });
  }

  @override
  void dispose() {
    _ticker.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _frames?[_frameIdx];
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: image == null
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : CustomPaint(
              painter: _ImagePainter(image),
              size: Size(widget.size, widget.size),
            ),
    );
  }
}

class _ImagePainter extends CustomPainter {
  _ImagePainter(this.image);
  final ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    final src = Rect.fromLTWH(
        0, 0, image.width.toDouble(), image.height.toDouble());
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..filterQuality = FilterQuality.none
      ..isAntiAlias = false;
    canvas.drawImageRect(image, src, dst, paint);
  }

  @override
  bool shouldRepaint(_ImagePainter old) => old.image != image;
}

/// 간단한 자체 ticker — Flutter `Ticker`를 쓰지 않아 vsync 의존성을 피한다.
class _Ticker {
  _Ticker(this.onTick);
  final VoidCallback onTick;
  bool _running = false;

  void start(Duration interval) {
    if (_running) return;
    _running = true;
    Future<void>.delayed(interval).then((_) => _loop(interval));
  }

  void _loop(Duration interval) async {
    while (_running) {
      onTick();
      await Future<void>.delayed(interval);
    }
  }

  void stop() => _running = false;
}
