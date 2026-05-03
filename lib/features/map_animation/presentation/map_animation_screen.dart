import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../character/paperdoll/data/paperdoll_image_cache.dart';
import '../../character/paperdoll/domain/paperdoll_config.dart';
import '../../character/paperdoll/presentation/paperdoll_provider.dart';
import '../domain/animation_frame.dart';
import '../data/animation_builder.dart';
import 'animation_provider.dart';
import 'widgets/dot_popup.dart';

class MapAnimationScreen extends ConsumerStatefulWidget {
  const MapAnimationScreen({super.key, required this.dayLogId});
  final String dayLogId;

  @override
  ConsumerState<MapAnimationScreen> createState() => _MapAnimationScreenState();
}

class _MapAnimationScreenState extends ConsumerState<MapAnimationScreen> {
  mapbox.MapboxMap? _mapboxMap;
  Timer? _updateTimer;
  bool _styleLoaded = false;
  bool _mapSetupDone = false;

  // PaperdollRenderer로 5프레임 합성. iconSize 0.4 × addStyleImage scale 2.0 = 0.2 표시 비율
  static const double _charScale = 2.0;
  static const double _charRenderScale = 4.0; // 32px × 4 = 128px PNG
  static const int _frameCount = 5;

  // 합성된 프레임 PNG 바이트 (PaperdollConfig 기반)
  Map<int, Uint8List>? _frames;
  int _frameIdx = 0;
  Timer? _spriteTimer;

  // CharacterState → 재생할 프레임 인덱스 시퀀스
  static const Map<CharacterState, List<int>> _stateFrames = {
    CharacterState.walking:  [0, 1, 2, 3, 4],
    CharacterState.driving:  [0, 1, 2, 3, 4],
    CharacterState.idle:     [2],
    CharacterState.arrived:  [2],
    CharacterState.sleeping: [2],
  };

  @override
  void dispose() {
    _updateTimer?.cancel();
    _spriteTimer?.cancel();
    super.dispose();
  }

  Future<void> _trySetupMap() async {
    if (_mapSetupDone || !_styleLoaded || _mapboxMap == null) return;
    final seq = ref
        .read(animationSequenceProvider(widget.dayLogId))
        .valueOrNull;
    if (seq == null || seq.frames.isEmpty) {
      debugPrint('[MapAnim] sequence empty – skip setup');
      return;
    }
    _mapSetupDone = true;

    try {
      await _fitCamera(_mapboxMap!, seq);
      await _addTrailAndDotLayers(_mapboxMap!, seq);
      await _addCharacterLayer(_mapboxMap!, seq, DottieColors.primary);
      _startTimer(seq);
      debugPrint('[MapAnim] setup done, frames=${seq.frames.length}');
    } catch (e, st) {
      debugPrint('[MapAnim] setup error: $e\n$st');
    }
  }

  // ── 카메라 ────────────────────────────────────────────

  Future<void> _fitCamera(mapbox.MapboxMap map, AnimationSequence seq) async {
    final lats = seq.frames.map((f) => f.dot.latitude).toList();
    final lngs = seq.frames.map((f) => f.dot.longitude).toList();
    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);

    await map
        .cameraForCoordinateBounds(
          mapbox.CoordinateBounds(
            southwest: mapbox.Point(
                coordinates: mapbox.Position(minLng - 0.012, minLat - 0.012)),
            northeast: mapbox.Point(
                coordinates: mapbox.Position(maxLng + 0.012, maxLat + 0.012)),
            infiniteBounds: false,
          ),
          mapbox.MbxEdgeInsets(top: 100, left: 40, bottom: 220, right: 40),
          null, null, null, null,
        )
        .then((camera) => map.setCamera(camera));
  }

  // ── 경로 + Dot 마커 레이어 ────────────────────────────

  Future<void> _addTrailAndDotLayers(
      mapbox.MapboxMap map, AnimationSequence seq) async {
    final coords = seq.frames
        .map((f) => [f.dot.longitude, f.dot.latitude])
        .toList();

    await map.style.addSource(mapbox.GeoJsonSource(
      id: 'trail-source',
      data: jsonEncode({
        'type': 'Feature',
        'geometry': {'type': 'LineString', 'coordinates': coords},
      }),
    ));
    await map.style.addLayer(mapbox.LineLayer(
      id: 'trail-layer',
      sourceId: 'trail-source',
      lineColor: DottieColors.primary.withAlpha(210).toARGB32(),
      lineWidth: 3.5,
      lineCap: mapbox.LineCap.ROUND,
      lineJoin: mapbox.LineJoin.ROUND,
      lineDasharray: [3.0, 2.5],
    ));

    final dotFeatures = seq.frames.map((f) => {
          'type': 'Feature',
          'geometry': {
            'type': 'Point',
            'coordinates': [f.dot.longitude, f.dot.latitude],
          },
          'properties': {},
        }).toList();

    await map.style.addSource(mapbox.GeoJsonSource(
      id: 'dots-source',
      data: jsonEncode(
          {'type': 'FeatureCollection', 'features': dotFeatures}),
    ));
    await map.style.addLayer(mapbox.CircleLayer(
      id: 'dots-layer',
      sourceId: 'dots-source',
      circleRadius: 5.0,
      circleColor: Colors.white.withAlpha(220).toARGB32(),
      circleStrokeWidth: 2.0,
      circleStrokeColor: DottieColors.primary.toARGB32(),
    ));
  }

  // ── 캐릭터 레이어 ─────────────────────────────────────
  // PaperdollRenderer로 사용자 캐릭터 5프레임 합성 → sprite-0~4로 등록
  // → data-driven SymbolLayer(['get','icon'])로 state별 프레임 교체

  Future<void> _addCharacterLayer(
      mapbox.MapboxMap map, AnimationSequence seq, Color color) async {
    final first = seq.frames.first;
    final renderer = ref.read(paperdollRendererProvider);
    final config = ref.read(paperdollProvider).valueOrNull ??
        PaperdollConfig.defaults;

    // 5프레임 합성 (캐시 히트 시 즉시 반환)
    final images = await renderer.renderAllFrames(
      config: config,
      scale: _charRenderScale,
    );
    final frames = <int, Uint8List>{};
    for (var i = 0; i < images.length; i++) {
      frames[i] = await imageToPngBytes(images[i]);
    }
    _frames = frames;

    final width = images.first.width;
    final height = images.first.height;

    for (var i = 0; i < images.length; i++) {
      final bytes = frames[i];
      if (bytes == null) continue;
      await map.style.addStyleImage(
        'sprite-$i', _charScale,
        mapbox.MbxImage(
          width: width,
          height: height,
          data: bytes,
        ),
        false, [], [], null,
      );
    }

    await map.style.addSource(mapbox.GeoJsonSource(
      id: 'char-source',
      data: jsonEncode(_iconFeature(first.dot.latitude,
          first.dot.longitude, 'sprite-2')),
    ));
    await map.style.addLayer(mapbox.SymbolLayer(
      id: 'char-layer',
      sourceId: 'char-source',
      iconImage: '["get", "icon"]',
      iconSize: 0.4,
      iconAnchor: mapbox.IconAnchor.BOTTOM,
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
    ));

    _startSpriteFrameTimer();
    debugPrint('[MapAnim] char layer OK ($_frameCount frames)');
  }

  Map<String, dynamic> _iconFeature(double lat, double lng, String icon) => {
    'type': 'Feature',
    'geometry': {'type': 'Point', 'coordinates': [lng, lat]},
    'properties': {'icon': icon},
  };

  // ── 스프라이트 프레임 사이클 타이머 (150ms) ───────────

  void _startSpriteFrameTimer() {
    _spriteTimer?.cancel();
    _spriteTimer = Timer.periodic(
      const Duration(milliseconds: 150),
      (_) => _frameIdx = (_frameIdx + 1) % _frameCount,
    );
  }

  // ── 100ms 위치 동기화 타이머 ──────────────────────────

  void _startTimer(AnimationSequence seq) {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(
        const Duration(milliseconds: 100), (_) => _syncCharacter(seq));
    debugPrint('[MapAnim] timer started');
  }

  Future<void> _syncCharacter(AnimationSequence seq) async {
    if (!mounted || _mapboxMap == null || _frames == null) return;
    final animState =
        ref.read(animationControllerProvider(widget.dayLogId));
    if (animState == null) return;

    final interp = AnimationBuilder.interpolate(seq, animState.progress);
    try {
      final frames = _stateFrames[interp.state] ?? [2];
      final frameKey = 'sprite-${frames[_frameIdx % frames.length]}';
      final data = jsonEncode(_iconFeature(interp.lat, interp.lng, frameKey));
      await _mapboxMap!.style.setStyleSourceProperty('char-source', 'data', data);
    } catch (e) {
      debugPrint('[MapAnim] setStyleSourceProperty error: $e');
    }
  }

  // ── Build ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final sequenceAsync =
        ref.watch(animationSequenceProvider(widget.dayLogId));
    final animState =
        ref.watch(animationControllerProvider(widget.dayLogId));

    ref.listen(animationSequenceProvider(widget.dayLogId),
        (_, __) => _trySetupMap());

    return Scaffold(
      backgroundColor: Colors.black,
      body: sequenceAsync.when(
        loading: () => const _LoadingView(),
        error: (e, _) => _ErrorView(message: '$e'),
        data: (sequence) {
          if (animState == null && _styleLoaded) {
            Future.microtask(() => ref
                .read(animationControllerProvider(widget.dayLogId).notifier)
                .initialize(sequence));
          }
          return _buildMapStack(context, sequence, animState);
        },
      ),
    );
  }

  Widget _buildMapStack(
    BuildContext context,
    AnimationSequence sequence,
    AnimationState? animState,
  ) {
    return Stack(
      children: [
        mapbox.MapWidget(
          onMapCreated: (map) {
            _mapboxMap = map;
            map.scaleBar
                .updateSettings(mapbox.ScaleBarSettings(enabled: false));
            map.compass
                .updateSettings(mapbox.CompassSettings(enabled: false));
            map.logo.updateSettings(
                mapbox.LogoSettings(marginBottom: 220, marginLeft: 8));
            map.attribution.updateSettings(
                mapbox.AttributionSettings(marginBottom: 220));
          },
          onStyleLoadedListener: (_) async {
            _styleLoaded = true;
            await _trySetupMap();
          },
          styleUri: mapbox.MapboxStyles.DARK,
          cameraOptions: mapbox.CameraOptions(
            center: mapbox.Point(
                coordinates: mapbox.Position(126.9780, 37.5665)),
            zoom: 11.0,
          ),
        ),

        // 상단 유리 알약 바
        Positioned(
          top: 0, left: 0, right: 0,
          child: _TopBar(
            sequence: sequence,
            onBack: () => Navigator.of(context).pop(),
          ),
        ),

        // Dot 팝업
        if (animState?.showPopup == true && animState?.popupDot != null)
          Positioned(
            bottom: 220,
            left: Dimensions.md,
            right: Dimensions.md,
            child: DotPopup(
              dot: animState!.popupDot!,
              onDismiss: () => ref
                  .read(animationControllerProvider(widget.dayLogId).notifier)
                  .dismissPopup(),
            ),
          ),

        // 하단 유리 컨트롤 패널
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: _BottomPanel(
            dayLogId: widget.dayLogId,
            sequence: sequence,
          ),
        ),
      ],
    );
  }
}

// ─── 상단 유리 알약 바 ─────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.sequence, required this.onBack});
  final AnimationSequence sequence;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final date = sequence.frames.isNotEmpty
        ? DottieDateUtils.toKoreanDate(
            sequence.frames.first.dot.timestamp)
        : '';
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimensions.md, Dimensions.sm, Dimensions.md, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.xs, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(22),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                    color: Colors.white.withAlpha(45), width: 1),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                    onPressed: onBack,
                  ),
                  Expanded(
                    child: Text(
                      date,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 하단 유리 컨트롤 패널 ─────────────────────────────

class _BottomPanel extends ConsumerWidget {
  const _BottomPanel({required this.dayLogId, required this.sequence});
  final String dayLogId;
  final AnimationSequence sequence;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animState = ref.watch(animationControllerProvider(dayLogId));
    final notifier =
        ref.read(animationControllerProvider(dayLogId).notifier);

    if (animState == null) return const SizedBox.shrink();

    final startTime = sequence.frames.isNotEmpty
        ? sequence.frames.first.dot.timestamp
        : DateTime.now();
    final endTime = sequence.frames.isNotEmpty
        ? sequence.frames.last.dot.timestamp
        : DateTime.now();
    final totalMs = sequence.totalDurationMs;
    final currentMs = totalMs * animState.progress;
    final currentTime = startTime
        .add(Duration(milliseconds: currentMs.toInt() * 240));

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x00000000), Color(0xE0050510)],
              stops: [0.0, 0.35],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  Dimensions.md, Dimensions.md, Dimensions.md, Dimensions.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _GlowProgressBar(progress: animState.progress),
                  const SizedBox(height: Dimensions.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DottieDateUtils.toTimeString(startTime),
                          style: TextStyle(
                              color: Colors.white.withAlpha(140),
                              fontSize: 11)),
                      Text(DottieDateUtils.toTimeString(currentTime),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          )),
                      Text(DottieDateUtils.toTimeString(endTime),
                          style: TextStyle(
                              color: Colors.white.withAlpha(140),
                              fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 14),
                      activeTrackColor: DottieColors.primary,
                      inactiveTrackColor: Colors.white.withAlpha(50),
                      thumbColor: Colors.white,
                      overlayColor: DottieColors.primary.withAlpha(40),
                    ),
                    child: Slider(
                      value: animState.progress,
                      onChanged: notifier.scrubTo,
                      onChangeEnd: (_) {
                        if (animState.isPlaying) notifier.play();
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _GlassChip(
                        onTap: () => notifier.setSpeed(
                            _nextSpeed(animState.speed)),
                        child: Text(animState.speed.label,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: Dimensions.xl),
                      GestureDetector(
                        onTap: animState.isPlaying
                            ? notifier.pause
                            : notifier.play,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF7AABFF), DottieColors.primary],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: DottieColors.primary.withAlpha(130),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            animState.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.xl),
                      const SizedBox(width: 48),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PlaySpeed _nextSpeed(PlaySpeed s) => switch (s) {
        PlaySpeed.x1 => PlaySpeed.x2,
        PlaySpeed.x2 => PlaySpeed.x4,
        PlaySpeed.x4 => PlaySpeed.x1,
      };
}

// ─── 공유 위젯 ────────────────────────────────────────

class _GlowProgressBar extends StatelessWidget {
  const _GlowProgressBar({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(35),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF7AABFF), DottieColors.primary]),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: DottieColors.primary.withAlpha(180),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(22),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: Colors.white.withAlpha(45), width: 1),
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: DottieColors.primary),
          SizedBox(height: 16),
          Text('기록을 불러오는 중...',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('오류: $message',
          style: const TextStyle(color: Colors.white70)),
    );
  }
}
