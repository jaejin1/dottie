import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/map_marker_renderer.dart';
import '../../character/paperdoll/data/paperdoll_image_cache.dart';
import '../../character/paperdoll/domain/paperdoll_config.dart';
import '../../character/paperdoll/presentation/paperdoll_provider.dart';
import '../../../shared/widgets/dot_detail_sheet.dart';
import '../../recording/domain/dot_model.dart';
import '../../timeline/presentation/widgets/day_calendar_sheet.dart';
import '../domain/animation_frame.dart';
import '../data/animation_builder.dart';
import 'animation_provider.dart';
import 'widgets/dot_popup.dart';

class MapAnimationScreen extends ConsumerStatefulWidget {
  const MapAnimationScreen({
    super.key,
    required this.dayLogId,
    this.focusDotId,
  });
  final String dayLogId;

  /// 검색 결과 등에서 진입 시 강조할 dot id.
  /// 화면 진입 직후 1회 해당 dot 의 [DotDetailSheet] 를 띄워 사용자에게 위치를 명확히 표시.
  final String? focusDotId;

  @override
  ConsumerState<MapAnimationScreen> createState() => _MapAnimationScreenState();
}

class _MapAnimationScreenState extends ConsumerState<MapAnimationScreen> {
  mapbox.MapboxMap? _mapboxMap;
  Timer? _updateTimer;
  bool _styleLoaded = false;
  bool _mapSetupDone = false;

  bool _isDaytime = _checkDaytime();
  Timer? _modeTimer;
  bool _playbackActive = false;
  static bool _checkDaytime() {
    final h = DateTime.now().hour;
    return h >= 7 && h < 19;
  }

  // PaperdollRenderer로 5프레임 합성. iconSize 0.4 × addStyleImage scale 2.0 = 0.2 표시 비율
  static const double _charScale = 2.0;
  static const double _charRenderScale = 4.0; // 32px × 4 = 128px PNG
  static const int _frameCount = 5;

  // 합성된 프레임 PNG 바이트 (PaperdollConfig 기반)
  Map<int, Uint8List>? _frames;
  int _frameIdx = 0;
  Timer? _spriteTimer;

  // 화살표 march 애니메이션
  Timer? _arrowTimer;
  int _arrowIdx = 0;

  // 레이어/이미지 ID 상수
  static const _markerEndImg = 'anim-marker-end';
  String _arrowImg(int i) => 'anim-arrow-$i';

  // CharacterState → 재생할 프레임 인덱스 시퀀스
  static const Map<CharacterState, List<int>> _stateFrames = {
    CharacterState.walking:  [0, 1, 2, 3, 4],
    CharacterState.driving:  [0, 1, 2, 3, 4],
    CharacterState.idle:     [2],
    CharacterState.arrived:  [2],
    CharacterState.sleeping: [2],
  };

  @override
  void initState() {
    super.initState();
    _modeTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final day = _checkDaytime();
      if (day != _isDaytime && mounted) {
        setState(() => _isDaytime = day);
        _mapboxMap?.loadStyleURI(
          day ? mapbox.MapboxStyles.MAPBOX_STREETS : mapbox.MapboxStyles.DARK,
        );
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _spriteTimer?.cancel();
    _arrowTimer?.cancel();
    _modeTimer?.cancel();
    super.dispose();
  }

  Future<void> _trySetupMap() async {
    if (_mapSetupDone || !_styleLoaded || _mapboxMap == null) return;
    final seq = ref
        .read(animationSequenceProvider(widget.dayLogId))
        .valueOrNull;
    if (seq == null || seq.frames.isEmpty) return;
    _mapSetupDone = true;

    try {
      await _fitCamera(_mapboxMap!, seq);
      await _addTrailAndDotLayers(_mapboxMap!, seq);
      await _addCharacterLayer(_mapboxMap!, seq, DottieColors.primary);
      _startTimer(seq);
      _maybeShowFocusDot(seq);
    } catch (e, st) {
      debugPrint('[MapAnim] setup error: $e\n$st');
    }
  }

  /// 검색 결과 등에서 [focusDotId] 와 함께 진입한 경우, 카메라가 자리잡은 후
  /// 해당 dot 의 상세 시트를 자동으로 띄워 어떤 dot 이 매칭됐는지 명확히 표시.
  bool _focusDotShown = false;
  void _maybeShowFocusDot(AnimationSequence seq) {
    final id = widget.focusDotId;
    if (id == null || _focusDotShown) return;
    Dot? dot;
    for (final f in seq.frames) {
      if (f.dot.id == id) {
        dot = f.dot;
        break;
      }
    }
    if (dot == null) return;
    _focusDotShown = true;
    final target = dot;
    // 카메라/레이어 안정화 후 시트 노출
    Future<void>.delayed(const Duration(milliseconds: 400), () async {
      if (!mounted) return;
      await DotDetailSheet.show(context, target);
    });
  }

  // ── 지도 탭 → dot 상세 ────────────────────────────────

  static const double _hitRadius = 22;

  Future<void> _handleMapTap(mapbox.ScreenCoordinate sc) async {
    if (_mapboxMap == null || !mounted) return;
    try {
      final features = await _mapboxMap!.queryRenderedFeatures(
        mapbox.RenderedQueryGeometry.fromScreenBox(
          mapbox.ScreenBox(
            min: mapbox.ScreenCoordinate(
                x: sc.x - _hitRadius, y: sc.y - _hitRadius),
            max: mapbox.ScreenCoordinate(
                x: sc.x + _hitRadius, y: sc.y + _hitRadius),
          ),
        ),
        mapbox.RenderedQueryOptions(layerIds: ['dots-layer'], filter: null),
      );
      if (features.isEmpty || !mounted) return;

      final seq = ref
          .read(animationSequenceProvider(widget.dayLogId))
          .valueOrNull;
      if (seq == null) return;

      final seen = <String>{};
      for (final f in features) {
        if (f == null) continue;
        final props = f.queriedFeature.feature['properties'] as Map?;
        final dotId = props?['dot_id'] as String?;
        if (dotId == null || seen.contains(dotId)) continue;
        seen.add(dotId);
        try {
          final dot = seq.frames.firstWhere((fr) => fr.dot.id == dotId).dot;
          if (!mounted) return;
          await DotDetailSheet.show(context, dot); // roomId 없음 → 댓글 숨김
          return;
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('[MapAnim] tap error: $e');
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
    final frames = seq.frames;
    final coords = frames
        .map((f) => [f.dot.longitude, f.dot.latitude])
        .toList();
    final total = frames.length;

    // ① 경로 라인 (baseline)
    if (coords.length >= 2) {
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
        lineColor: DottieColors.primary.withAlpha(110).toARGB32(),
        lineWidth: 3.0,
        lineCap: mapbox.LineCap.ROUND,
        lineJoin: mapbox.LineJoin.ROUND,
      ));

      // 화살표 march 레이어
      await _registerArrowFrames(map);
      await map.style.addLayer(mapbox.SymbolLayer(
        id: 'trail-arrows',
        sourceId: 'trail-source',
        iconImage: _arrowImg(0),
        iconSize: 0.6,
        iconRotationAlignment: mapbox.IconRotationAlignment.MAP,
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
        symbolPlacement: mapbox.SymbolPlacement.LINE,
        symbolSpacing: MapMarkerRenderer.arrowSymbolSpacing,
      ));
      await map.style.setStyleLayerProperty(
        'trail-arrows', 'icon-size',
        MapMarkerRenderer.arrowSizeExpression,
      );
      await map.style.setStyleLayerProperty(
        'trail-arrows', 'symbol-spacing',
        MapMarkerRenderer.arrowSpacingExpression,
      );
      _startArrowMarch();
    }

    // ② 출발/도착 마커 이미지 등록
    await _registerStartEndMarkers(map);

    // ③ Dot features (order, is_first, is_last, dot_id)
    final dotFeatures = <Map<String, dynamic>>[];
    for (var i = 0; i < total; i++) {
      final f = frames[i];
      dotFeatures.add({
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [f.dot.longitude, f.dot.latitude],
        },
        'properties': {
          'dot_id': f.dot.id,
          'order': i,
          'is_first': i == 0,
          'is_last': i == total - 1,
        },
      });
    }

    await map.style.addSource(mapbox.GeoJsonSource(
      id: 'dots-source',
      data: jsonEncode(
          {'type': 'FeatureCollection', 'features': dotFeatures}),
    ));

    // ④ 일반 dot 원 (마지막 제외)
    await map.style.addLayer(mapbox.CircleLayer(
      id: 'dots-layer',
      sourceId: 'dots-source',
      filter: [
        "all",
        ["==", ["get", "is_last"], false],
      ],
      circleRadius: 9.0,
      circleColor: DottieColors.primary.toARGB32(),
      circleStrokeWidth: 2.0,
      circleStrokeColor: Colors.white.toARGB32(),
    ));

    // ⑤ 순서 번호 텍스트 (zoom ≥ 14, 마지막 제외)
    await map.style.addLayer(mapbox.SymbolLayer(
      id: 'dots-order-text',
      sourceId: 'dots-source',
      filter: [
        "all",
        ["==", ["get", "is_last"], false],
      ],
      textColor: Colors.white.toARGB32(),
      textSize: 11.0,
      textAllowOverlap: true,
      textIgnorePlacement: true,
    ));
    await map.style.setStyleLayerProperty(
      'dots-order-text', 'text-field',
      '["to-string", ["+", ["get", "order"], 1]]',
    );

    // ⑥ 도착 핀 (마지막 dot, 첫=마지막이면 원형 dot 으로 통일)
    await map.style.addLayer(mapbox.SymbolLayer(
      id: 'dot-end',
      sourceId: 'dots-source',
      filter: [
        "all",
        ["==", ["get", "is_last"], true],
        ["==", ["get", "is_first"], false],
      ],
      iconImage: _markerEndImg,
      iconSize: 0.7,
      iconAnchor: mapbox.IconAnchor.BOTTOM,
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
    ));
  }

  // ── 화살표 march 등록 ─────────────────────────────────

  Future<void> _registerArrowFrames(mapbox.MapboxMap map) async {
    final arrowFrames = await MapMarkerRenderer.renderArrowFrames(
      color: DottieColors.primary,
    );
    for (var i = 0; i < arrowFrames.length; i++) {
      await map.style.addStyleImage(
        _arrowImg(i), 2.0,
        mapbox.MbxImage(
          width: MapMarkerRenderer.arrowSourceWidth,
          height: MapMarkerRenderer.arrowSourceHeight,
          data: arrowFrames[i],
        ),
        false, [], [], null,
      );
    }
  }

  void _startArrowMarch() {
    _arrowTimer?.cancel();
    _arrowTimer = Timer.periodic(const Duration(milliseconds: 200), (_) async {
      if (_mapboxMap == null || !_styleLoaded) return;
      _arrowIdx = (_arrowIdx + 1) % MapMarkerRenderer.arrowFrameCount;
      try {
        await _mapboxMap!.style.setStyleLayerProperty(
          'trail-arrows',
          'icon-image',
          _arrowImg(_arrowIdx),
        );
      } catch (_) {}
    });
  }

  // ── 출발/도착 마커 이미지 등록 ───────────────────────

  Future<void> _registerStartEndMarkers(mapbox.MapboxMap map) async {
    final end = await MapMarkerRenderer.renderEndPin(
      color: DottieColors.primary,
    );
    await map.style.addStyleImage(
      _markerEndImg, 2.0,
      mapbox.MbxImage(
        width: MapMarkerRenderer.pixelSize,
        height: MapMarkerRenderer.pixelSize,
        data: end,
      ),
      false, [], [], null,
    );
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

    // 스타일 전환/캐릭터 변경 시 중복 등록 방지
    for (var i = 0; i < images.length; i++) {
      try {
        await map.style.removeStyleImage('sprite-$i');
      } catch (_) {}
    }
    try {
      await map.style.removeStyleLayer('char-layer');
    } catch (_) {}
    try {
      await map.style.removeStyleSource('char-source');
    } catch (_) {}

    for (var i = 0; i < images.length; i++) {
      final bytes = frames[i];
      if (bytes == null) continue;
      await map.style.addStyleImage(
        'sprite-$i', _charScale,
        mapbox.MbxImage(width: width, height: height, data: bytes),
        false, [], [], null,
      );
    }

    await map.style.addSource(mapbox.GeoJsonSource(
      id: 'char-source',
      data: jsonEncode({
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [first.dot.longitude, first.dot.latitude],
        },
        'properties': const {},
      }),
    ));

    await map.style.addLayer(mapbox.SymbolLayer(
      id: 'char-layer',
      sourceId: 'char-source',
      iconImage: 'sprite-2', // 초기 idle frame, 애니메이션 시 setStyleLayerProperty로 교체
      iconSize: 0.4,
      iconAnchor: mapbox.IconAnchor.BOTTOM,
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
    ));

    _startSpriteFrameTimer();
  }

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

      // ① 좌표 갱신 (source data)
      final data = jsonEncode({
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [interp.lng, interp.lat],
        },
        'properties': const {},
      });
      await _mapboxMap!.style
          .setStyleSourceProperty('char-source', 'data', data);

      // ② 프레임 갱신 (layer icon-image)
      await _mapboxMap!.style
          .setStyleLayerProperty('char-layer', 'icon-image', frameKey);
    } catch (e) {
      debugPrint('[MapAnim] sync error: $e');
    }
  }

  // ── 재생 활성화 ───────────────────────────────────────

  Future<void> _activatePlayback(AnimationSequence sequence) async {
    setState(() => _playbackActive = true);
    await ref
        .read(animationControllerProvider(widget.dayLogId).notifier)
        .initialize(sequence);
    await _updateMapboxMargins(true);
    if (mounted) {
      ref.read(animationControllerProvider(widget.dayLogId).notifier).play();
    }
  }

  Future<void> _deactivatePlayback() async {
    ref.read(animationControllerProvider(widget.dayLogId).notifier).pause();
    if (mounted) setState(() => _playbackActive = false);
    await _updateMapboxMargins(false);
  }

  // 재생 패널 높이 ≈ 180px (시간/슬라이더/컨트롤+패딩+SafeArea).
  // FAB/워터마크/팝업 위치 계산의 단일 진실원본.
  static const double _bottomPanelHeight = 180;
  static const double _fabHeight = 40; // FloatingActionButton.small

  Future<void> _updateMapboxMargins(bool playback) async {
    if (_mapboxMap == null) return;
    // 재생 중: 재생바 바로 위 / 비활성: 화면 하단
    final margin = playback ? _bottomPanelHeight + 8 : 24.0;
    try {
      await _mapboxMap!.logo.updateSettings(
          mapbox.LogoSettings(marginBottom: margin, marginLeft: 8));
      await _mapboxMap!.attribution
          .updateSettings(mapbox.AttributionSettings(marginBottom: margin));
    } catch (_) {}
  }

  // ── 캘린더 시트 ───────────────────────────────────────

  void _showCalendarSheet(BuildContext context) {
    DayCalendarSheet.show(
      context,
      currentDayLogId: widget.dayLogId,
      onDateSelected: (dayLog) {
        // 오늘 선택 시 today_map_screen 으로 이동 (과거 날짜 화면이 아니라).
        // .toLocal() 필수 — BE UTC vs local 불일치 방지.
        if (DottieDateUtils.isSameDay(
            dayLog.date.toLocal(), DateTime.now())) {
          context.pushReplacement('/today');
        } else {
          context.pushReplacement('/animation/${dayLog.id}');
        }
      },
    );
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

    // 사용자 캐릭터 config가 늦게 도착하면 캐릭터 레이어 재등록
    ref.listen(paperdollProvider, (prev, next) {
      if (!next.hasValue) return;
      if (prev?.valueOrNull == next.valueOrNull) return;
      if (!_mapSetupDone || _mapboxMap == null) return;
      final seq = ref
          .read(animationSequenceProvider(widget.dayLogId))
          .valueOrNull;
      if (seq == null) return;
      _addCharacterLayer(_mapboxMap!, seq, DottieColors.primary);
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: sequenceAsync.when(
        loading: () => const _LoadingView(),
        error: (e, _) => _ErrorView(message: '$e'),
        data: (sequence) => _buildMapStack(context, sequence, animState),
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
                mapbox.LogoSettings(marginBottom: 24, marginLeft: 8));
            map.attribution.updateSettings(
                mapbox.AttributionSettings(marginBottom: 24));
          },
          onStyleLoadedListener: (_) async {
            _styleLoaded = true;
            _mapSetupDone = false; // 스타일 전환 시 레이어 재설정
            await _mapboxMap?.style.localizeLabels('ko', null);
            await _trySetupMap();
          },
          onTapListener: (ctx) => _handleMapTap(ctx.touchPosition),
          styleUri: _isDaytime
              ? mapbox.MapboxStyles.MAPBOX_STREETS
              : mapbox.MapboxStyles.DARK,
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
            isDaytime: _isDaytime,
          ),
        ),

        // Dot 팝업 — 캘린더/워터마크 위에 표시
        if (_playbackActive &&
            animState?.showPopup == true &&
            animState?.popupDot != null)
          Positioned(
            bottom: _bottomPanelHeight + _fabHeight + 16,
            left: Dimensions.md,
            right: Dimensions.md,
            child: DotPopup(
              dot: animState!.popupDot!,
              onDismiss: () => ref
                  .read(animationControllerProvider(widget.dayLogId).notifier)
                  .dismissPopup(),
            ),
          ),

        // 우하단 액션 FAB (재생 + 캘린더) — 좌→우
        Positioned(
          right: Dimensions.md,
          bottom: _playbackActive
              ? _bottomPanelHeight + 8
              : MediaQuery.of(context).padding.bottom + 24,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_playbackActive) ...[
                FloatingActionButton.small(
                  heroTag: 'anim_play_fab',
                  onPressed: () => _activatePlayback(sequence),
                  backgroundColor: DottieColors.primary,
                  elevation: 4,
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 22),
                ),
                const SizedBox(width: 10),
              ],
              FloatingActionButton.small(
                heroTag: 'anim_calendar_fab',
                onPressed: () => _showCalendarSheet(context),
                backgroundColor: DottieColors.primary,
                elevation: 4,
                child: const Icon(Icons.calendar_today_rounded,
                    color: Colors.white, size: 18),
              ),
            ],
          ),
        ),

        // 하단 컨트롤 패널 — 활성 시에만
        if (_playbackActive)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _BottomPanel(
              dayLogId: widget.dayLogId,
              sequence: sequence,
              onClose: _deactivatePlayback,
            ),
          ),
      ],
    );
  }
}


// ─── 상단 유리 알약 바 ─────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.sequence,
    required this.onBack,
    required this.isDaytime,
  });
  final AnimationSequence sequence;
  final VoidCallback onBack;
  final bool isDaytime;

  @override
  Widget build(BuildContext context) {
    final date = sequence.frames.isNotEmpty
        ? DottieDateUtils.toKoreanDate(
            sequence.frames.first.dot.timestamp)
        : '';
    final bg = isDaytime
        ? const Color(0xCC1C1C1E)
        : Colors.white.withAlpha(22);
    final border = isDaytime
        ? Colors.white.withAlpha(20)
        : Colors.white.withAlpha(45);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            Dimensions.md, Dimensions.sm, Dimensions.md, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.xs),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: border, width: 1),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
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
  const _BottomPanel({
    required this.dayLogId,
    required this.sequence,
    required this.onClose,
  });
  final String dayLogId;
  final AnimationSequence sequence;
  final VoidCallback onClose;

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
                  const SizedBox(height: 4),
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 2,
                      thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 14),
                      activeTrackColor: Colors.white.withAlpha(220),
                      inactiveTrackColor: Colors.white.withAlpha(40),
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withAlpha(30),
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
                      Material(
                        color: Colors.transparent,
                        child: Ink(
                          decoration: ShapeDecoration(
                            color: Colors.white.withAlpha(28),
                            shape: CircleBorder(
                              side: BorderSide(
                                  color: Colors.white.withAlpha(70),
                                  width: 1),
                            ),
                          ),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: animState.isPlaying
                                ? notifier.pause
                                : notifier.play,
                            child: SizedBox(
                              width: 56,
                              height: 56,
                              child: Icon(
                                animState.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.xl),
                      _GlassChip(
                        onTap: onClose,
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 22),
                      ),
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
