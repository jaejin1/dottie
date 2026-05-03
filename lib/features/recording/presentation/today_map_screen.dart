import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/map_marker_renderer.dart';
import '../../../core/utils/media_thumbnail_loader.dart';
import '../../../shared/widgets/dot_detail_sheet.dart';
import '../../character/paperdoll/data/paperdoll_image_cache.dart';
import '../../character/paperdoll/domain/paperdoll_config.dart';
import '../../character/paperdoll/presentation/paperdoll_provider.dart';
import '../domain/dot_model.dart';
import 'dot_input_sheet.dart';
import 'recording_provider.dart';
import 'widgets/first_dot_banner.dart';

class TodayMapScreen extends ConsumerStatefulWidget {
  const TodayMapScreen({super.key});

  @override
  ConsumerState<TodayMapScreen> createState() => _TodayMapScreenState();
}

class _TodayMapScreenState extends ConsumerState<TodayMapScreen> {
  mapbox.MapboxMap? _map;
  bool _styleLoaded = false;
  bool _dotsLayerAdded = false;
  Timer? _locationTimer;
  Timer? _arrowTimer;
  int _arrowIdx = 0;
  Position? _currentPosition;

  static const double _hitRadius = 22;

  // 레이어 ID 상수
  static const _srcId = 'today-dots-source';
  static const _trailSrcId = 'today-trail-source';
  static const _trailLayerId = 'today-trail-layer';
  static const _trailArrowsLayerId = 'today-trail-arrows';
  static const _clusterCircleId = 'today-cluster-circle';
  static const _clusterCountId = 'today-cluster-count';
  static const _dotsCircleId = 'today-dots-circle';
  static const _dotsOrderTextId = 'today-dots-order-text';
  static const _dotStartId = 'today-dot-start';
  static const _dotEndId = 'today-dot-end';
  static const _photoLayerId = 'today-dots-photo';
  static const _markerStartImg = 'today-marker-start';
  static const _markerEndImg = 'today-marker-end';

  String _arrowImg(int i) => 'today-arrow-$i';

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _arrowTimer?.cancel();
    super.dispose();
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
        if (!mounted) return;
        setState(() => _currentPosition = pos);
        await _updateCurrentLocationLayer(pos);
      } catch (_) {}
    });
    Geolocator.getCurrentPosition(
      locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.high),
    ).then((pos) {
      if (!mounted) return;
      setState(() => _currentPosition = pos);
      _updateCurrentLocationLayer(pos);
      _moveCameraToPosition(pos);
    }).catchError((_) {});
  }

  // ── GeoJSON feature 빌더 ──────────────────────────────

  /// timestamp 오름차순 정렬된 dots 반환. 기록 순서 = order index.
  List<Dot> _sorted(List<Dot> dots) =>
      [...dots]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  Map<String, dynamic> _dotFeature(
    Dot dot, {
    required int order,
    required int total,
    String photoIconId = 'dot-default',
  }) =>
      {
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [dot.longitude, dot.latitude],
        },
        'properties': {
          'dot_id': dot.id,
          'order': order,
          'is_first': order == 0,
          'is_last': order == total - 1,
          'has_photo': dot.photoUrl != null && dot.photoUrl!.isNotEmpty,
          'photo_icon_id': photoIconId,
          'place_name': dot.placeName ?? '',
          'timestamp': dot.timestamp.toIso8601String(),
          'memo': dot.memo ?? '',
          'emotion': dot.emotion ?? '',
          'photo_url': dot.photoUrl ?? '',
        },
      };

  String _buildGeoJson(List<Dot> dots, {Map<String, String>? photoIconIds}) {
    final sorted = _sorted(dots);
    final features = <Map<String, dynamic>>[];
    for (var i = 0; i < sorted.length; i++) {
      features.add(_dotFeature(
        sorted[i],
        order: i,
        total: sorted.length,
        photoIconId: photoIconIds?[sorted[i].id] ?? 'dot-default',
      ));
    }
    return jsonEncode({'type': 'FeatureCollection', 'features': features});
  }

  // ── 레이어 초기 설정 ──────────────────────────────────

  List<Dot> _latestDots() =>
      ref.read(activeRecordingProvider).valueOrNull?.dots ?? [];

  Future<void> _trySetupDotLayers() async {
    if (_dotsLayerAdded || !_styleLoaded || _map == null) return;
    final dots = _latestDots();
    if (dots.isEmpty) return; // dots 도착 전이면 대기 — _dotsLayerAdded는 false 유지
    _dotsLayerAdded = true;
    await _addDotLayers(_map!, dots);
  }

  Future<void> _addDotLayers(
    mapbox.MapboxMap map,
    List<Dot> rawDots,
  ) async {
    final dots = _sorted(rawDots);
    final coords = dots.map((d) => [d.longitude, d.latitude]).toList();

    // ① 경로 라인 (solid, 화살표 receivers 역할) + 화살표 march 레이어
    if (coords.length >= 2) {
      await map.style.addSource(mapbox.GeoJsonSource(
        id: _trailSrcId,
        data: jsonEncode({
          'type': 'Feature',
          'geometry': {'type': 'LineString', 'coordinates': coords},
        }),
      ));
      // 옅은 baseline 라인 — 화살표가 어떤 경로를 따르는지 보여줌
      await map.style.addLayer(mapbox.LineLayer(
        id: _trailLayerId,
        sourceId: _trailSrcId,
        lineColor: DottieColors.primary.withAlpha(110).toARGB32(),
        lineWidth: 3.0,
        lineCap: mapbox.LineCap.ROUND,
        lineJoin: mapbox.LineJoin.ROUND,
      ));
      // 화살표 frame 5개 등록 + symbolLayer 추가 후 march 시작
      await _registerArrowFrames(map);
      await map.style.addLayer(mapbox.SymbolLayer(
        id: _trailArrowsLayerId,
        sourceId: _trailSrcId,
        iconImage: _arrowImg(0),
        iconSize: 0.6, // expression이 덮어쓰지 못할 때 fallback
        iconRotationAlignment: mapbox.IconRotationAlignment.MAP,
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
        symbolPlacement: mapbox.SymbolPlacement.LINE,
        symbolSpacing: MapMarkerRenderer.arrowSymbolSpacing,
      ));
      // 줌 레벨별 iconSize + symbolSpacing을 같은 비율로 (cycle 이음새 유지)
      await map.style.setStyleLayerProperty(
        _trailArrowsLayerId, 'icon-size',
        MapMarkerRenderer.arrowSizeExpression,
      );
      await map.style.setStyleLayerProperty(
        _trailArrowsLayerId, 'symbol-spacing',
        MapMarkerRenderer.arrowSpacingExpression,
      );
      _startArrowMarch();
    }

    // ② 기본 placeholder + 출발/도착 마커 이미지
    await _registerDefaultDotImage(map);
    await _registerStartEndMarkers(map);

    // ③ 클러스터 소스
    await map.style.addSource(mapbox.GeoJsonSource(
      id: _srcId,
      data: _buildGeoJson(dots),
      cluster: true,
      clusterMaxZoom: 14,
      clusterRadius: 50,
    ));

    // ④ 클러스터 원
    await map.style.addLayer(mapbox.CircleLayer(
      id: _clusterCircleId,
      sourceId: _srcId,
      filter: ["has", "point_count"],
      circleRadius: 20.0,
      circleColor: DottieColors.primary.toARGB32(),
      circleStrokeWidth: 2.0,
      circleStrokeColor: Colors.white.toARGB32(),
    ));

    // ⑤ 클러스터 개수 텍스트
    await map.style.addLayer(mapbox.SymbolLayer(
      id: _clusterCountId,
      sourceId: _srcId,
      filter: ["has", "point_count"],
      textColor: Colors.white.toARGB32(),
      textSize: 12.0,
    ));
    await map.style.setStyleLayerProperty(
      _clusterCountId, 'text-field',
      '["get", "point_count_abbreviated"]',
    );

    // ⑥ 개별 dot — 사진 없음 + 첫/마지막 아닌 것 (마커가 첫/마지막을 대신함)
    await map.style.addLayer(mapbox.CircleLayer(
      id: _dotsCircleId,
      sourceId: _srcId,
      filter: [
        "all",
        ["!", ["has", "point_count"]],
        ["==", ["get", "has_photo"], false],
        ["==", ["get", "is_first"], false],
        ["==", ["get", "is_last"], false],
      ],
      circleRadius: 9.0,
      circleColor: DottieColors.primary.toARGB32(),
      circleStrokeWidth: 2.0,
      circleStrokeColor: Colors.white.toARGB32(),
    ));

    // ⑦ 사진 썸네일 (zoom ≥ 14, 첫/마지막 제외 — 마커 우선)
    await map.style.addLayer(mapbox.SymbolLayer(
      id: _photoLayerId,
      sourceId: _srcId,
      filter: [
        "all",
        ["!", ["has", "point_count"]],
        ["==", ["get", "has_photo"], true],
        ["==", ["get", "is_first"], false],
        ["==", ["get", "is_last"], false],
      ],
      iconImage: '["get", "photo_icon_id"]',
      iconSize: 1.0,
      iconAnchor: mapbox.IconAnchor.CENTER,
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
      minZoom: 14.0,
    ));

    // ⑧ 순서 번호 (zoom ≥ 14, 사진/첫/마지막 제외)
    await map.style.addLayer(mapbox.SymbolLayer(
      id: _dotsOrderTextId,
      sourceId: _srcId,
      filter: [
        "all",
        ["!", ["has", "point_count"]],
        ["==", ["get", "has_photo"], false],
        ["==", ["get", "is_first"], false],
        ["==", ["get", "is_last"], false],
      ],
      textColor: Colors.white.toARGB32(),
      textSize: 11.0,
      textAllowOverlap: true,
      textIgnorePlacement: true,
      minZoom: 14.0,
    ));
    await map.style.setStyleLayerProperty(
      _dotsOrderTextId, 'text-field',
      '["to-string", ["+", ["get", "order"], 1]]',
    );

    // ⑨ 출발 깃발 (첫 dot)
    await map.style.addLayer(mapbox.SymbolLayer(
      id: _dotStartId,
      sourceId: _srcId,
      filter: [
        "all",
        ["!", ["has", "point_count"]],
        ["==", ["get", "is_first"], true],
      ],
      iconImage: _markerStartImg,
      iconSize: 0.7,
      iconAnchor: mapbox.IconAnchor.BOTTOM,
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
    ));

    // ⑩ 도착 핀 (마지막 dot — 첫=마지막일 땐 핀 우선)
    await map.style.addLayer(mapbox.SymbolLayer(
      id: _dotEndId,
      sourceId: _srcId,
      filter: [
        "all",
        ["!", ["has", "point_count"]],
        ["==", ["get", "is_last"], true],
        ["==", ["get", "is_first"], false],
      ],
      iconImage: _markerEndImg,
      iconSize: 0.7,
      iconAnchor: mapbox.IconAnchor.BOTTOM,
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
    ));

    // ⑪ 백그라운드에서 사진 썸네일 로드 (순서 뱃지 합성)
    _loadPhotoThumbnails(map, dots);
  }

  /// 200ms 간격으로 화살표 프레임을 시프트해 → → → 가 흘러가는 효과.
  void _startArrowMarch() {
    _arrowTimer?.cancel();
    _arrowTimer = Timer.periodic(const Duration(milliseconds: 200), (_) async {
      if (_map == null || !_styleLoaded) return;
      _arrowIdx = (_arrowIdx + 1) % MapMarkerRenderer.arrowFrameCount;
      try {
        await _map!.style.setStyleLayerProperty(
          _trailArrowsLayerId,
          'icon-image',
          _arrowImg(_arrowIdx),
        );
      } catch (_) {}
    });
  }

  Future<void> _registerArrowFrames(mapbox.MapboxMap map) async {
    final frames = await MapMarkerRenderer.renderArrowFrames(
      color: DottieColors.primary,
    );
    for (var i = 0; i < frames.length; i++) {
      await map.style.addStyleImage(
        _arrowImg(i), 2.0,
        mapbox.MbxImage(
          width: MapMarkerRenderer.arrowSourceWidth,
          height: MapMarkerRenderer.arrowSourceHeight,
          data: frames[i],
        ),
        false, [], [], null,
      );
    }
  }

  Future<void> _registerStartEndMarkers(mapbox.MapboxMap map) async {
    final start = await MapMarkerRenderer.renderStartFlag(
      color: DottieColors.primary,
    );
    final end = await MapMarkerRenderer.renderEndPin(
      color: DottieColors.primary,
    );
    await map.style.addStyleImage(
      _markerStartImg, 2.0,
      mapbox.MbxImage(
        width: MapMarkerRenderer.pixelSize,
        height: MapMarkerRenderer.pixelSize,
        data: start,
      ),
      false, [], [], null,
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

  Future<void> _registerDefaultDotImage(mapbox.MapboxMap map) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawCircle(
      const Offset(10, 10), 8,
      Paint()..color = DottieColors.primary,
    );
    final img = await recorder.endRecording().toImage(20, 20);
    final bd = await img.toByteData(format: ui.ImageByteFormat.png);
    if (bd == null) return;
    await map.style.addStyleImage(
      'dot-default', 2.0,
      mapbox.MbxImage(width: 20, height: 20, data: bd.buffer.asUint8List()),
      false, [], [], null,
    );
  }

  Future<void> _loadPhotoThumbnails(
      mapbox.MapboxMap map, List<Dot> sortedDots) async {
    final photoDots = sortedDots
        .where((d) => d.photoUrl != null && d.photoUrl!.isNotEmpty)
        .toList();
    if (photoDots.isEmpty) return;

    // sortedDots의 인덱스를 기준으로 순서 번호 부여 (1-based)
    final orderById = <String, int>{};
    for (var i = 0; i < sortedDots.length; i++) {
      orderById[sortedDots[i].id] = i + 1;
    }

    final photoIconIds = <String, String>{};

    await Future.wait(photoDots.map((dot) async {
      final bytes = await MediaThumbnailLoader.loadCircle(
        dot.photoUrl!,
        orderNumber: orderById[dot.id],
        badgeColor: DottieColors.primary,
      );
      if (bytes == null || !mounted) return;
      final imgId = 'dot-photo-${dot.id}';
      try {
        await map.style.addStyleImage(
          imgId, 2.0,
          mapbox.MbxImage(
            width: MediaThumbnailLoader.pixelSize,
            height: MediaThumbnailLoader.pixelSize,
            data: bytes,
          ),
          false, [], [], null,
        );
        photoIconIds[dot.id] = imgId;
      } catch (_) {}
    }));

    if (!mounted || photoIconIds.isEmpty) return;

    // 최신 dots로 GeoJSON 재빌드 (photo_icon_id 반영, 정렬은 _buildGeoJson에서)
    final latestDots = _latestDots().isNotEmpty ? _latestDots() : sortedDots;
    try {
      await map.style.setStyleSourceProperty(
        _srcId, 'data',
        _buildGeoJson(latestDots, photoIconIds: photoIconIds),
      );
    } catch (e) {
      debugPrint('[TodayMap] thumbnail source update error: $e');
    }
  }

  // ── dots 갱신 시 소스 데이터만 업데이트 ───────────────

  Future<void> _refreshDotSource(List<Dot> rawDots) async {
    if (_map == null || !_styleLoaded) return;
    final dots = _sorted(rawDots);
    try {
      await _map!.style.setStyleSourceProperty(
        _srcId, 'data', _buildGeoJson(dots),
      );
      if (dots.length >= 2) {
        final coords = dots.map((d) => [d.longitude, d.latitude]).toList();
        await _map!.style.setStyleSourceProperty(
          _trailSrcId, 'data',
          jsonEncode({
            'type': 'Feature',
            'geometry': {'type': 'LineString', 'coordinates': coords},
          }),
        );
      }
    } catch (_) {}
  }

  // ── 지도 탭 처리 ──────────────────────────────────────

  Future<void> _handleMapTap(mapbox.ScreenCoordinate sc) async {
    if (_map == null || !mounted) return;
    try {
      final features = await _map!.queryRenderedFeatures(
        mapbox.RenderedQueryGeometry(
          value: jsonEncode({
            'min': {'x': sc.x - _hitRadius, 'y': sc.y - _hitRadius},
            'max': {'x': sc.x + _hitRadius, 'y': sc.y + _hitRadius},
          }),
          type: mapbox.Type.SCREEN_BOX,
        ),
        mapbox.RenderedQueryOptions(
          layerIds: [
            _clusterCircleId,
            _dotsCircleId,
            _photoLayerId,
            _dotStartId,
            _dotEndId,
          ],
          filter: null,
        ),
      );
      if (features.isEmpty || !mounted) return;

      // 클러스터 여부 먼저 확인
      for (final f in features) {
        if (f == null) continue;
        final props = f.queriedFeature.feature['properties'] as Map?;
        if (props != null && props['point_count'] != null) {
          final geoPoint = await _map!.coordinateForPixel(sc);
          final camState = await _map!.getCameraState();
          await _map!.easeTo(
            mapbox.CameraOptions(center: geoPoint, zoom: camState.zoom + 2),
            mapbox.MapAnimationOptions(duration: 500),
          );
          return;
        }
      }

      // 개별 dot 수집 (dot_id 기준 중복 제거 — 레이어 여러 개에서 같은 dot이 반환될 수 있음)
      final allDots = _latestDots();
      final seen = <String>{};
      final matchedDots = <Dot>[];
      for (final f in features) {
        if (f == null) continue;
        final props = f.queriedFeature.feature['properties'] as Map?;
        final dotId = props?['dot_id'] as String?;
        if (dotId == null || seen.contains(dotId)) continue;
        seen.add(dotId);
        try {
          final dot = allDots.firstWhere((d) => d.id == dotId);
          matchedDots.add(dot);
        } catch (_) {}
      }

      if (matchedDots.isEmpty || !mounted) return;

      if (matchedDots.length == 1) {
        await DotDetailSheet.show(context, matchedDots.first);
      } else {
        await DotListSheet.show(context, matchedDots);
      }
    } catch (e) {
      debugPrint('[TodayMap] tap error: $e');
    }
  }

  // ── 현재 위치 레이어 (캐릭터) ────────────────────────

  static const _myLocSrcId = 'my-location-source';
  static const _myLocLayerId = 'my-location-layer';
  static const _myLocImgId = 'my-location-char';
  bool _myLocLayerAdded = false;

  Future<void> _setupCharacterImage() async {
    if (_map == null) return;
    try {
      final renderer = ref.read(paperdollRendererProvider);
      final config = ref.read(paperdollProvider).valueOrNull ??
          PaperdollConfig.defaults;
      // 32px frame × 2.5 = 80px (기존 size와 일치)
      final image = await renderer.renderFrame(
        config: config,
        frameIndex: 2, // idle frame
        scale: 2.5,
      );
      final bytes = await imageToPngBytes(image);
      await _map!.style.addStyleImage(
        _myLocImgId, 2.0,
        mapbox.MbxImage(
          width: image.width,
          height: image.height,
          data: bytes,
        ),
        false, [], [], null,
      );
    } catch (e) {
      debugPrint('[TodayMap] character image error: $e');
    }
  }

  Future<void> _updateCurrentLocationLayer(Position pos) async {
    if (_map == null || !_styleLoaded) return;
    final feature = jsonEncode({
      'type': 'Feature',
      'geometry': {
        'type': 'Point',
        'coordinates': [pos.longitude, pos.latitude],
      },
      'properties': {},
    });
    if (_myLocLayerAdded) {
      try {
        await _map!.style.setStyleSourceProperty(
            _myLocSrcId, 'data', feature);
      } catch (e) {
        debugPrint('[TodayMap] location update error: $e');
      }
      return;
    }
    try {
      await _map!.style.addSource(mapbox.GeoJsonSource(
        id: _myLocSrcId,
        data: feature,
      ));
      await _map!.style.addLayer(mapbox.SymbolLayer(
        id: _myLocLayerId,
        sourceId: _myLocSrcId,
        iconImage: _myLocImgId,
        iconSize: 1.0,
        iconAnchor: mapbox.IconAnchor.BOTTOM,
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
      ));
      _myLocLayerAdded = true;
    } catch (e) {
      debugPrint('[TodayMap] location layer error: $e');
    }
  }

  Future<void> _moveCameraToPosition(Position pos) async {
    if (_map == null) return;
    await _map!.setCamera(mapbox.CameraOptions(
      center: mapbox.Point(
          coordinates: mapbox.Position(pos.longitude, pos.latitude)),
      zoom: 14.0,
    ));
  }

  // ── Build ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeRecordingProvider).valueOrNull;
    final isRecording = session != null;
    final dotCount = session?.dots.length ?? 0;

    // dot 추가 시 지도 레이어 즉시 반영 — activeRecording이 저장 즉시 갱신됨
    ref.listen(activeRecordingProvider, (prev, next) {
      final dots = next.valueOrNull?.dots ?? [];
      if (_dotsLayerAdded) {
        _refreshDotSource(dots);
      } else {
        _trySetupDotLayers();
      }
    });

    final today = DateTime.now();
    final dateLabel = '${today.year}년 ${today.month}월 ${today.day}일';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          mapbox.MapWidget(
            styleUri: mapbox.MapboxStyles.DARK,
            onMapCreated: (map) => _map = map,
            onStyleLoadedListener: (_) async {
              _styleLoaded = true;
              await _setupCharacterImage();
              await _trySetupDotLayers();
              if (_currentPosition != null) {
                await _updateCurrentLocationLayer(_currentPosition!);
              }
            },
            onTapListener: (ctx) => _handleMapTap(ctx.touchPosition),
          ),

          // 상단 글라스 바
          Positioned(
            top: 0, left: 0, right: 0,
            child: _GlassTopBar(dateLabel: dateLabel)
                .animate()
                .slideY(begin: -0.4, end: 0, duration: 380.ms, curve: Curves.easeOutCubic)
                .fadeIn(duration: 300.ms),
          ),

          // 하단 상태 표시
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _StatusBar(isRecording: isRecording, dotCount: dotCount)
                .animate()
                .slideY(begin: 0.4, end: 0, duration: 380.ms, delay: 80.ms, curve: Curves.easeOutCubic)
                .fadeIn(duration: 300.ms, delay: 80.ms),
          ),

          // dot 찍기 FAB
          Positioned(
            bottom: 100,
            right: Dimensions.md,
            child: FloatingActionButton(
              heroTag: 'dot_fab',
              onPressed: () async {
                final isFirstDot = await DotInputSheet.show(context);
                if (isFirstDot && context.mounted) {
                  await showFirstDotFlow(context, ref);
                }
              },
              backgroundColor: DottieColors.primary,
              child: const Icon(Icons.add_location_alt_rounded,
                  color: Colors.white),
            )
                .animate()
                .scale(
                  begin: const Offset(0.0, 0.0),
                  duration: 360.ms,
                  delay: 200.ms,
                  curve: Curves.easeOutBack,
                )
                .fadeIn(duration: 200.ms, delay: 200.ms),
          ),
        ],
      ),
    );
  }
}

// ── 상단 글라스 바 ─────────────────────────────────────

class _GlassTopBar extends StatelessWidget {
  const _GlassTopBar({required this.dateLabel});
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        8,
        MediaQuery.of(context).padding.top + 8,
        8,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(140),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('오늘의 발자취',
                    style: GoogleFonts.notoSansKr(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 17)),
                Text(dateLabel,
                    style: GoogleFonts.notoSansKr(
                        color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 하단 상태 바 ────────────────────────────────────────

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.isRecording, required this.dotCount});
  final bool isRecording;
  final int dotCount;

  @override
  Widget build(BuildContext context) {
    if (!isRecording && dotCount == 0) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.fromLTRB(
        Dimensions.md,
        Dimensions.md,
        Dimensions.md,
        MediaQuery.of(context).padding.bottom + Dimensions.md,
      ),
      color: Colors.black.withAlpha(160),
      child: Row(
        children: [
          Icon(
            isRecording ? Icons.circle : Icons.check_circle_rounded,
            size: 10,
            color: isRecording ? DottieColors.error : Colors.greenAccent,
          ),
          const SizedBox(width: 8),
          Text(
            isRecording
                ? '기록 중 · dot $dotCount개'
                : '오늘 기록 완료 · dot $dotCount개',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const Spacer(),
          Text(
            'dot을 탭하면 상세 정보를 볼 수 있어요',
            style: TextStyle(color: Colors.white.withAlpha(120), fontSize: 11),
          ),
        ],
      ),
    );
  }
}
