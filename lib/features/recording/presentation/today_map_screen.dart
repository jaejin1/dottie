import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/date_utils.dart';
import '../../onboarding/domain/onboarding_step.dart';
import '../../onboarding/presentation/onboarding_tour_provider.dart';
import '../../onboarding/presentation/tour_content.dart';
import '../../../core/utils/map_marker_renderer.dart';
import '../../../core/utils/media_thumbnail_loader.dart';
import '../../../shared/widgets/date_ui/all_days_toggle_chip.dart';
import '../../../shared/widgets/date_ui/date_calendar_sheet.dart';
import '../../../shared/widgets/date_ui/date_strip.dart';
import '../../../shared/widgets/date_ui/glass_date_header.dart';
import '../../../shared/widgets/dot_detail_sheet.dart';
import '../../timeline/domain/day_log_model.dart';
import '../../character/paperdoll/data/paperdoll_image_cache.dart';
import '../../character/paperdoll/domain/paperdoll_config.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../character/paperdoll/presentation/paperdoll_provider.dart';
import '../../map_animation/data/animation_builder.dart';
import '../../map_animation/domain/animation_frame.dart';
import '../../map_animation/presentation/animation_provider.dart';
import '../../map_animation/presentation/widgets/dot_popup.dart';
import '../domain/dot_model.dart';
import 'dot_input_sheet.dart';
import 'recording_provider.dart';
import 'widgets/first_dot_banner.dart';

class TodayMapScreen extends ConsumerStatefulWidget {
  const TodayMapScreen({super.key});

  @override
  ConsumerState<TodayMapScreen> createState() => _TodayMapScreenState();
}

class _TodayMapScreenState extends ConsumerState<TodayMapScreen>
    with WidgetsBindingObserver {
  final _backBtnKey = GlobalKey();
  TutorialCoachMark? _backCoachMark;
  ProviderSubscription<OnboardingStep>? _tourSub;

  mapbox.MapboxMap? _map;
  bool _styleLoaded = false;
  bool _dotsLayerAdded = false;
  Timer? _locationTimer;
  Timer? _arrowTimer;
  Timer? _modeTimer;
  int _arrowIdx = 0;
  Position? _currentPosition;

  bool _isDaytime = _checkDaytime();
  static bool _checkDaytime() {
    final h = DateTime.now().hour;
    return h >= 7 && h < 19;
  }

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
  static const _dotEndId = 'today-dot-end';
  static const _photoLayerId = 'today-dots-photo';
  static const _markerEndImg = 'today-marker-end';

  String _arrowImg(int i) => 'today-arrow-$i';

  // ── 인플레이스 재생 ──────────────────────────────────
  bool _playbackActive = false;
  Timer? _playbackSyncTimer;
  Timer? _playbackSpriteTimer;
  int _playbackFrameIdx = 0;
  Map<int, Uint8List>? _animFrames;
  // animationControllerProvider 가 autoDispose 라서 panel watch 시작 전에
  // state 가 날아가는 걸 막기 위해 활성화 동안 수동 listen 으로 유지.
  ProviderSubscription<AnimationState?>? _playbackKeepAlive;

  static const _animCharSrcId = 'today-anim-char-source';
  static const _animCharLayerId = 'today-anim-char-layer';
  String _animSpriteImg(int i) => 'today-anim-sprite-$i';
  static const double _animCharRenderScale = 4.0;
  static const double _animCharScale = 2.0;
  static const int _animFrameCount = 5;

  static const Map<CharacterState, List<int>> _animStateFrames = {
    CharacterState.walking: [0, 1, 2, 3, 4],
    CharacterState.driving: [0, 1, 2, 3, 4],
    CharacterState.idle: [2],
    CharacterState.arrived: [2],
    CharacterState.sleeping: [2],
  };

  // 재생 패널 높이 (시간/슬라이더/컨트롤 — SafeArea 없음, status bar 위에 위치)
  static const double _playbackPanelHeight = 150;
  // 하단 status bar 높이 (대략값) — FAB 위치 산출용
  static const double _statusBarHeight = 90;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 캘린더에서 오늘 날짜 탭 후 지도 진입 — 뒤로가기 버튼 안내
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          ref.read(onboardingTourProvider) == OnboardingStep.calendarDay &&
          _backBtnKey.currentContext != null) {
        _showBackBtnCoachMark();
      }
    });
    _tourSub = ref.listenManual(onboardingTourProvider, (_, next) {
      if (next == OnboardingStep.calendarDay) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _backBtnKey.currentContext != null) _showBackBtnCoachMark();
        });
      }
    });
    _startLocationUpdates();
    _modeTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      final day = _checkDaytime();
      if (day != _isDaytime && mounted) {
        setState(() => _isDaytime = day);
        _map?.loadStyleURI(
          day ? mapbox.MapboxStyles.MAPBOX_STREETS : mapbox.MapboxStyles.DARK,
        );
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 백그라운드에서 자동기록된 dot 반영 — 복귀 시 세션 재빌드
    // (build 안에서 syncUnsyncedDots + 서버/로컬 병합 수행)
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(activeRecordingProvider);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tourSub?.close();
    _backCoachMark?.finish();
    _locationTimer?.cancel();
    _arrowTimer?.cancel();
    _modeTimer?.cancel();
    _playbackSyncTimer?.cancel();
    _playbackSpriteTimer?.cancel();
    _playbackKeepAlive?.close();
    super.dispose();
  }

  void _showBackBtnCoachMark() {
    _backCoachMark = TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: 'todayMapBack',
          keyTarget: _backBtnKey,
          shape: ShapeLightFocus.Circle,
          radius: 28,
          paddingFocus: 8,
          enableOverlayTab: false,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (_, controller) => TourContent(
                message: '뒤로 가서\n방을 찾아볼게요',
                description: '지도를 확인했어요! 이제 친구와 함께할 방으로 이동해요',
                actionLabel: '뒤로 가기',
                onAction: () => controller.next(),
                onSkip: controller.skip,
              ),
            ),
          ],
        ),
      ],
      colorShadow: const Color(0xFF0A0908),
      opacityShadow: 0.72,
      focusAnimationDuration: const Duration(milliseconds: 350),
      pulseAnimationDuration: const Duration(milliseconds: 900),
      unFocusAnimationDuration: const Duration(milliseconds: 200),
      skipWidget: tourSkipIcon,
      onFinish: () {
        if (mounted) Navigator.of(context).pop();
      },
      onSkip: () {
        ref.read(onboardingTourProvider.notifier).skip();
        return true;
      },
    );
    _backCoachMark!.show(context: context, rootOverlay: true);
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
          'has_photo': dot.hasPhotoData,
          'photo_icon_id': photoIconId,
          'place_name': dot.placeName ?? '',
          'timestamp': dot.timestamp.toUtc().toIso8601String(),
          'memo': dot.memo ?? '',
          'emotion': dot.emotion ?? '',
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
    if (dots.isEmpty) return;
    _dotsLayerAdded = true;
    await _addDotLayers(_map!, dots);
  }

  Future<void> _addDotLayers(
    mapbox.MapboxMap map,
    List<Dot> rawDots,
  ) async {
    final dots = _sorted(rawDots);
    final coords = dots.map((d) => [d.longitude, d.latitude]).toList();

    final userColor = ref.read(currentUserColorProvider);

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
        lineColor: userColor.withAlpha(110).toARGB32(),
        lineWidth: 3.0,
        lineCap: mapbox.LineCap.ROUND,
        lineJoin: mapbox.LineJoin.ROUND,
      ));
      // 화살표 frame 5개 등록 + symbolLayer 추가 후 march 시작
      await _registerArrowFrames(map, userColor);
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
    await _registerDefaultDotImage(map, userColor);
    await _registerStartEndMarkers(map, userColor);

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
      circleRadius: 18.0,
      circleColor: DottieColors.surfaceFloating.toARGB32(),
      circleStrokeWidth: 2.5,
      circleStrokeColor: userColor.toARGB32(),
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

    // ⑥ 개별 dot — 사진 없음 + 마지막 아닌 것 (마커가 마지막을 대신함)
    await map.style.addLayer(mapbox.CircleLayer(
      id: _dotsCircleId,
      sourceId: _srcId,
      filter: [
        "all",
        ["!", ["has", "point_count"]],
        ["==", ["get", "has_photo"], false],
        ["==", ["get", "is_last"], false],
      ],
      circleRadius: 9.0,
      circleColor: userColor.toARGB32(),
      circleStrokeWidth: 2.5,
      circleStrokeColor: Colors.white.withAlpha(220).toARGB32(),
    ));

    // ⑦ 사진 썸네일 — 마지막 제외 (마커 우선).
    // minZoom 제거: 줌 아웃 됐을 때도 sparse 사진 dot 이 안 사라지도록.
    // dense 영역은 native cluster 가 카운트 뱃지로 합쳐 처리 (clusterMaxZoom 14).
    await map.style.addLayer(mapbox.SymbolLayer(
      id: _photoLayerId,
      sourceId: _srcId,
      filter: [
        "all",
        ["!", ["has", "point_count"]],
        ["==", ["get", "has_photo"], true],
        ["==", ["get", "is_last"], false],
      ],
      iconImage: '["get", "photo_icon_id"]',
      iconSize: 1.0,
      iconAnchor: mapbox.IconAnchor.CENTER,
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
    ));

    // ⑧ 순서 번호 (zoom ≥ 14, 사진/마지막 제외)
    await map.style.addLayer(mapbox.SymbolLayer(
      id: _dotsOrderTextId,
      sourceId: _srcId,
      filter: [
        "all",
        ["!", ["has", "point_count"]],
        ["==", ["get", "has_photo"], false],
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

    // ⑨ 도착 핀 — 마지막 dot (단일 dot 포함)
    await map.style.addLayer(mapbox.SymbolLayer(
      id: _dotEndId,
      sourceId: _srcId,
      filter: [
        "all",
        ["!", ["has", "point_count"]],
        ["==", ["get", "is_last"], true],
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

  Future<void> _registerArrowFrames(mapbox.MapboxMap map, Color color) async {
    final frames = await MapMarkerRenderer.renderArrowFrames(color: color);
    for (var i = 0; i < frames.length; i++) {
      try { await map.style.removeStyleImage(_arrowImg(i)); } catch (_) {}
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

  Future<void> _registerStartEndMarkers(mapbox.MapboxMap map, Color color) async {
    final end = await MapMarkerRenderer.renderEndPin(color: color);
    try { await map.style.removeStyleImage(_markerEndImg); } catch (_) {}
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

  Future<void> _registerDefaultDotImage(mapbox.MapboxMap map, Color color) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawCircle(const Offset(10, 10), 8, Paint()..color = color);
    final img = await recorder.endRecording().toImage(20, 20);
    final bd = await img.toByteData(format: ui.ImageByteFormat.png);
    if (bd == null) return;
    try { await map.style.removeStyleImage('dot-default'); } catch (_) {}
    await map.style.addStyleImage(
      'dot-default', 2.0,
      mapbox.MbxImage(width: 20, height: 20, data: bd.buffer.asUint8List()),
      false, [], [], null,
    );
  }

  /// paperdoll 색 변경 시 이미 추가된 레이어들의 색을 일괄 갱신.
  Future<void> _updateDotColors(Color color) async {
    final map = _map;
    if (map == null || !_styleLoaded) return;
    try {
      await map.style.setStyleLayerProperty(
          _clusterCircleId, 'circle-stroke-color', color.toARGB32());
      await map.style.setStyleLayerProperty(
          _dotsCircleId, 'circle-color', color.toARGB32());
      await map.style.setStyleLayerProperty(
          _trailLayerId, 'line-color', color.withAlpha(110).toARGB32());
    } catch (_) {}
    await _registerArrowFrames(map, color);
    await _registerStartEndMarkers(map, color);
    await _registerDefaultDotImage(map, color);
  }

  Future<void> _loadPhotoThumbnails(
      mapbox.MapboxMap map, List<Dot> sortedDots) async {
    // BE variant 가 권위 — thumb URL 이 있는 dot 만 핀 썸네일 후보.
    final photoDots = sortedDots
        .where((d) => d.displayThumbUrl != null)
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
        dot.displayThumbUrl!,
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
        mapbox.RenderedQueryGeometry.fromScreenBox(
          mapbox.ScreenBox(
            min: mapbox.ScreenCoordinate(
                x: sc.x - _hitRadius, y: sc.y - _hitRadius),
            max: mapbox.ScreenCoordinate(
                x: sc.x + _hitRadius, y: sc.y + _hitRadius),
          ),
        ),
        mapbox.RenderedQueryOptions(
          layerIds: [
            _clusterCircleId,
            _dotsCircleId,
            _photoLayerId,
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
      // 기존 등록 이미지가 있으면 제거 후 다시 추가 — paperdoll 변경 시 갱신용
      try {
        await _map!.style.removeStyleImage(_myLocImgId);
      } catch (_) {}
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

  Future<void> _updateCurrentLocationLayer(Position pos) =>
      _showCharacterAt(pos.latitude, pos.longitude);

  Future<void> _showCharacterAt(double lat, double lng) async {
    if (_map == null || !_styleLoaded) return;
    final feature = jsonEncode({
      'type': 'Feature',
      'geometry': {
        'type': 'Point',
        'coordinates': [lng, lat],
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

  // ── 인플레이스 재생 ──────────────────────────────────

  /// 현재 위치 캐릭터(라이브) 표시/숨김.
  Future<void> _setMyLocationVisible(bool visible) async {
    if (_map == null || !_myLocLayerAdded) return;
    try {
      await _map!.style.setStyleLayerProperty(
          _myLocLayerId, 'visibility', visible ? 'visible' : 'none');
    } catch (_) {}
  }

  /// 애니메이션 캐릭터 5프레임 등록 + char-source/layer 추가.
  Future<void> _addAnimCharacter(Dot first) async {
    if (_map == null) return;
    try {
      final renderer = ref.read(paperdollRendererProvider);
      final config = ref.read(paperdollProvider).valueOrNull ??
          PaperdollConfig.defaults;

      final images = await renderer.renderAllFrames(
        config: config, scale: _animCharRenderScale);
      final frames = <int, Uint8List>{};
      for (var i = 0; i < images.length; i++) {
        frames[i] = await imageToPngBytes(images[i]);
      }
      _animFrames = frames;
      final width = images.first.width;
      final height = images.first.height;

      // 중복 등록 방지
      for (var i = 0; i < images.length; i++) {
        try {
          await _map!.style.removeStyleImage(_animSpriteImg(i));
        } catch (_) {}
      }
      try { await _map!.style.removeStyleLayer(_animCharLayerId); } catch (_) {}
      try { await _map!.style.removeStyleSource(_animCharSrcId); } catch (_) {}

      for (var i = 0; i < images.length; i++) {
        final bytes = frames[i];
        if (bytes == null) continue;
        await _map!.style.addStyleImage(
          _animSpriteImg(i), _animCharScale,
          mapbox.MbxImage(width: width, height: height, data: bytes),
          false, [], [], null,
        );
      }

      await _map!.style.addSource(mapbox.GeoJsonSource(
        id: _animCharSrcId,
        data: jsonEncode({
          'type': 'Feature',
          'geometry': {
            'type': 'Point',
            'coordinates': [first.longitude, first.latitude],
          },
          'properties': const {},
        }),
      ));

      await _map!.style.addLayer(mapbox.SymbolLayer(
        id: _animCharLayerId,
        sourceId: _animCharSrcId,
        iconImage: _animSpriteImg(2),
        iconSize: 0.4,
        iconAnchor: mapbox.IconAnchor.BOTTOM,
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
      ));
    } catch (e) {
      debugPrint('[TodayMap] anim char setup error: $e');
    }
  }

  Future<void> _removeAnimCharacter() async {
    if (_map == null) return;
    try { await _map!.style.removeStyleLayer(_animCharLayerId); } catch (_) {}
    try { await _map!.style.removeStyleSource(_animCharSrcId); } catch (_) {}
    for (var i = 0; i < _animFrameCount; i++) {
      try {
        await _map!.style.removeStyleImage(_animSpriteImg(i));
      } catch (_) {}
    }
    _animFrames = null;
  }

  void _startPlaybackTimers(AnimationSequence seq, String dayLogId) {
    _playbackSyncTimer?.cancel();
    _playbackSpriteTimer?.cancel();

    _playbackSyncTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => _syncAnimCharacter(seq, dayLogId),
    );
    _playbackSpriteTimer = Timer.periodic(
      const Duration(milliseconds: 150),
      (_) => _playbackFrameIdx = (_playbackFrameIdx + 1) % _animFrameCount,
    );
  }

  Future<void> _syncAnimCharacter(
      AnimationSequence seq, String dayLogId) async {
    if (!mounted || _map == null || _animFrames == null) return;
    final animState = ref.read(animationControllerProvider(dayLogId));
    if (animState == null) return;

    final interp = AnimationBuilder.interpolate(seq, animState.progress);
    try {
      final framesForState = _animStateFrames[interp.state] ?? [2];
      final frameKey =
          _animSpriteImg(framesForState[_playbackFrameIdx % framesForState.length]);

      final data = jsonEncode({
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [interp.lng, interp.lat],
        },
        'properties': const {},
      });
      await _map!.style.setStyleSourceProperty(_animCharSrcId, 'data', data);
      await _map!.style
          .setStyleLayerProperty(_animCharLayerId, 'icon-image', frameKey);
    } catch (e) {
      debugPrint('[TodayMap] anim sync error: $e');
    }
  }

  Future<void> _activatePlayback() async {
    final session = ref.read(activeRecordingProvider).valueOrNull;
    final dots = session?.dots ?? [];
    if (dots.length < 2) return;
    final dayLogId = session?.dayLogId ?? 'today';

    final sortedDots = [...dots]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final sequence = AnimationBuilder.build(sortedDots);

    // autoDispose 방지 — panel watch 시작 전에 state가 날아가지 않게.
    _playbackKeepAlive?.close();
    _playbackKeepAlive = ref.listenManual<AnimationState?>(
      animationControllerProvider(dayLogId),
      (_, __) {},
    );

    await ref
        .read(animationControllerProvider(dayLogId).notifier)
        .initialize(sequence);

    await _setMyLocationVisible(false);
    await _addAnimCharacter(sortedDots.first);

    setState(() => _playbackActive = true);
    _locationTimer?.cancel();
    _startPlaybackTimers(sequence, dayLogId);
    if (mounted) {
      ref.read(animationControllerProvider(dayLogId).notifier).play();
    }
  }

  /// 현재 지도 뷰를 Snapshotter 로 오프스크린 렌더링해 공유 시트 표시.
  ///
  /// `MapboxMap.snapshot()`(위젯 캡처) 은 iOS 에서 불안정해 실패함 —
  /// 공식 예제대로 Snapshotter 를 쓰고, 런타임 레이어(경로/dot)는
  /// 공유용으로 단순화해 재구성한다 (캐릭터/사진핀/클러스터 제외).
  Future<void> _shareMapSnapshot() async {
    final map = _map;
    if (map == null || !mounted) return;
    mapbox.Snapshotter? snapshotter;
    try {
      final camera = await map.getCameraState();
      if (!mounted) return;
      final mq = MediaQuery.of(context);

      final styleLoaded = Completer<void>();
      snapshotter = await mapbox.Snapshotter.create(
        options: mapbox.MapSnapshotOptions(
          size: mapbox.Size(width: mq.size.width, height: mq.size.height),
          pixelRatio: mq.devicePixelRatio,
        ),
        onStyleLoadedListener: (_) {
          if (!styleLoaded.isCompleted) styleLoaded.complete();
        },
      );
      await snapshotter.style.setStyleURI(_isDaytime
          ? mapbox.MapboxStyles.MAPBOX_STREETS
          : mapbox.MapboxStyles.DARK);
      await styleLoaded.future.timeout(const Duration(seconds: 10));

      await snapshotter.setCamera(mapbox.CameraOptions(
        center: camera.center,
        zoom: camera.zoom,
        bearing: camera.bearing,
        pitch: camera.pitch,
      ));

      // 오늘 dot 경로/포인트 재구성
      final dots = _sorted(
          ref.read(activeRecordingProvider).valueOrNull?.dots ?? const []);
      final userColor = ref.read(currentUserColorProvider);
      if (dots.length >= 2) {
        await snapshotter.style.addSource(mapbox.GeoJsonSource(
          id: 'share-trail',
          data: jsonEncode({
            'type': 'Feature',
            'geometry': {
              'type': 'LineString',
              'coordinates':
                  dots.map((d) => [d.longitude, d.latitude]).toList(),
            },
          }),
        ));
        await snapshotter.style.addLayer(mapbox.LineLayer(
          id: 'share-trail-line',
          sourceId: 'share-trail',
          lineColor: userColor.withAlpha(200).toARGB32(),
          lineWidth: 3.5,
          lineCap: mapbox.LineCap.ROUND,
          lineJoin: mapbox.LineJoin.ROUND,
        ));
      }
      if (dots.isNotEmpty) {
        await snapshotter.style.addSource(mapbox.GeoJsonSource(
          id: 'share-dots',
          data: jsonEncode({
            'type': 'FeatureCollection',
            'features': dots
                .map((d) => {
                      'type': 'Feature',
                      'geometry': {
                        'type': 'Point',
                        'coordinates': [d.longitude, d.latitude],
                      },
                      'properties': const <String, dynamic>{},
                    })
                .toList(),
          }),
        ));
        await snapshotter.style.addLayer(mapbox.CircleLayer(
          id: 'share-dots-circle',
          sourceId: 'share-dots',
          circleRadius: 8.0,
          circleColor: userColor.toARGB32(),
          circleStrokeWidth: 2.5,
          circleStrokeColor: Colors.white.toARGB32(),
        ));
      }

      final bytes = await snapshotter.start();
      if (bytes == null) throw StateError('snapshot returned null');
      if (!mounted) return;

      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/dottie_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      if (!mounted) return;
      // iOS(iPad + iOS 18+)는 공유 팝오버 앵커(sharePositionOrigin) 필수 —
      // 미지정 시 PlatformException. 화면 중앙을 앵커로 사용.
      final anchor = Rect.fromCenter(
        center: Offset(mq.size.width / 2, mq.size.height / 2),
        width: 1,
        height: 1,
      );
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: '오늘의 발자국 🐾 Dottie',
        sharePositionOrigin: anchor,
      );
    } catch (e) {
      debugPrint('[TodayMap] snapshot share failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('지도 캡처에 실패했어요. 다시 시도해 주세요.')),
      );
    } finally {
      unawaited(snapshotter?.dispose());
    }
  }

  Future<void> _showCalendarSheet(BuildContext context) async {
    // fetch 가 아직 안 끝났을 수 있음 → future 로 *기다림*.
    // valueOrNull 만 보면 첫 진입 시 (fetch 진행 중) 빈 set 이 되어
    // "캘린더에 다른 날 안 보이는" 버그 발생.
    List<DayLog> logs;
    try {
      logs = await ref.read(allDayLogsProvider.future);
    } catch (_) {
      logs = ref.read(allDayLogsProvider).valueOrNull ?? const <DayLog>[];
    }
    if (!mounted) return;
    final activeDates = _activeDatesFromDayLogs(logs);
    final selected = await DateCalendarSheet.show(
      context,
      selectedDate: DottieDateUtils.todayStart(),
      activeDates: activeDates,
    );
    if (selected == null || !mounted) return;
    _onDateSelected(selected, logs);
  }

  /// 다른 날짜 탭 → 해당 dayLog 의 animation 화면으로 push.
  /// 오늘 탭은 무동작 (이미 today 화면).
  void _onDateSelected(DateTime date, List<DayLog> logs) {
    if (DottieDateUtils.isSameDay(date, DateTime.now())) return;
    final id = _findDayLogId(date, logs);
    if (id == null) return;
    context.push('/animation/$id');
  }

  String? _findDayLogId(DateTime date, List<DayLog> logs) {
    for (final l in logs) {
      if (DottieDateUtils.isSameDay(l.date.toLocal(), date)) return l.id;
    }
    return null;
  }

  Set<String> _activeDatesFromDayLogs(List<DayLog> logs) {
    return logs
        .map((l) => DottieDateUtils.toDateString(l.date.toLocal()))
        .toSet();
  }

  Future<void> _deactivatePlayback() async {
    final session = ref.read(activeRecordingProvider).valueOrNull;
    final dayLogId = session?.dayLogId ?? 'today';
    ref.read(animationControllerProvider(dayLogId).notifier).pause();

    _playbackSyncTimer?.cancel();
    _playbackSpriteTimer?.cancel();
    _playbackKeepAlive?.close();
    _playbackKeepAlive = null;

    await _removeAnimCharacter();
    await _setMyLocationVisible(true);

    if (mounted) setState(() => _playbackActive = false);
    _startLocationUpdates();
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

    // paperdoll 변경 시 라이브 캐릭터 이미지 + dot 색상 재렌더링
    ref.listen(paperdollProvider, (prev, next) {
      if (!next.hasValue) return;
      if (prev?.valueOrNull == next.valueOrNull) return;
      if (_map == null || !_styleLoaded) return;
      final newColor = ref.read(currentUserColorProvider);
      _setupCharacterImage().then((_) {
        if (_currentPosition != null) {
          _updateCurrentLocationLayer(_currentPosition!);
        }
      });
      if (_dotsLayerAdded) _updateDotColors(newColor);
    });

    // 위젯 트리 위치 계산 (재생 활성 시):
    //   [bottom]
    //   ↓ 재생 패널 (180px, SafeArea 포함)
    //   ↓ 기록중 status bar (~64px, SafeArea 미포함)
    //   ↓ dot FAB
    //   ↓ DotPopup (조건부)
    //   ↑ 지도 / 상단 바
    //
    // 비활성 시:
    //   [bottom]
    //   ↓ status bar (~88px, SafeArea 포함)
    //   ↓ dot FAB
    //   ↑ 지도 / 상단 바
    final dayLogId = session?.dayLogId ?? 'today';
    final animState = _playbackActive
        ? ref.watch(animationControllerProvider(dayLogId))
        : null;
    // 재생 활성 시 status bar는 패널 위에 — 패널이 SafeArea 포함하므로 미포함.
    final statusBarBottom = _playbackActive ? _playbackPanelHeight : 0.0;
    // 재생 활성 시 status bar 컴팩트 높이(~64), 비활성 시 SafeArea 포함(~88)
    final statusBarHeight = _playbackActive ? 64.0 : _statusBarHeight;
    final fabBottom = statusBarBottom + statusBarHeight + 8;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          mapbox.MapWidget(
            styleUri: _isDaytime
                ? mapbox.MapboxStyles.MAPBOX_STREETS
                : mapbox.MapboxStyles.DARK,
            onMapCreated: (map) => _map = map,
            onStyleLoadedListener: (_) async {
              _styleLoaded = true;
              _dotsLayerAdded = false;
              _myLocLayerAdded = false;
              await _map?.style.localizeLabels('ko', null);
              await _setupCharacterImage();
              await _trySetupDotLayers();
              if (_currentPosition != null) {
                await _updateCurrentLocationLayer(_currentPosition!);
              } else {
                // GPS fix 도착 전 마지막 dot 위치에 캐릭터 임시 표시.
                // GPS 도착 시 _updateCurrentLocationLayer 가 실제 위치로 이동.
                final dots =
                    ref.read(activeRecordingProvider).valueOrNull?.dots;
                if (dots != null && dots.isNotEmpty) {
                  final last = dots.reduce((a, b) =>
                      a.timestamp.isAfter(b.timestamp) ? a : b);
                  await _showCharacterAt(last.latitude, last.longitude);
                }
              }
            },
            onTapListener: (ctx) => _handleMapTap(ctx.touchPosition),
          ),

          // 상단 — 헤더 + 데이트 스트립 + 모든날 기록 칩 (룸 화면과 동일 UI).
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Consumer(
              builder: (_, ref, __) {
                final logs = ref.watch(allDayLogsProvider).valueOrNull ??
                    const <DayLog>[];
                final activeDates = _activeDatesFromDayLogs(logs);
                final today = DottieDateUtils.todayStart();
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GlassDateHeader.date(
                      date: DottieDateUtils.toDateString(today),
                      onBack: () => Navigator.of(context).pop(),
                      onTapDate: () => _showCalendarSheet(context),
                      isDaytime: _isDaytime,
                      backButtonKey: _backBtnKey,
                    ),
                    const SizedBox(height: Dimensions.xs),
                    DateStrip(
                      selectedDate: today,
                      activeDates: activeDates,
                      isDaytime: _isDaytime,
                      onDateSelected: (d) => _onDateSelected(d, logs),
                    ),
                    const SizedBox(height: Dimensions.xs),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Dimensions.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // 오늘 지도 스냅샷 공유
                          AllDaysToggleChip(
                            isDaytime: _isDaytime,
                            label: '공유',
                            icon: Icons.ios_share_rounded,
                            onTap: _shareMapSnapshot,
                          ),
                          const SizedBox(width: 8),
                          AllDaysToggleChip(
                            isDaytime: _isDaytime,
                            onTap: () {
                              context.push(AppRoutes.userCumulative);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            )
                .animate()
                .slideY(
                    begin: -0.4,
                    end: 0,
                    duration: 380.ms,
                    curve: Curves.easeOutCubic)
                .fadeIn(duration: 300.ms),
          ),

          // 재생 컨트롤 패널 — 활성 시 가장 하단
          if (_playbackActive)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _PlaybackPanel(
                dayLogId: dayLogId,
                onClose: _deactivatePlayback,
              ),
            ),

          // 기록중 status bar — 활성 시 패널 위, 비활성 시 가장 하단
          Positioned(
            bottom: statusBarBottom,
            left: 0,
            right: 0,
            child: _StatusBar(
              isRecording: isRecording,
              dotCount: dotCount,
              isDaytime: _isDaytime,
              bottomSafeArea: !_playbackActive,
            )
                .animate()
                .slideY(begin: 0.4, end: 0, duration: 380.ms, delay: 80.ms, curve: Curves.easeOutCubic)
                .fadeIn(duration: 300.ms, delay: 80.ms),
          ),

          // 우하단 FAB Row: 재생(비활성 시) + 캘린더 + dot 등록 (좌→우)
          Positioned(
            right: Dimensions.md,
            bottom: fabBottom,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_playbackActive) ...[
                  FloatingActionButton.small(
                    heroTag: 'today_play_fab',
                    onPressed: dotCount >= 2 ? _activatePlayback : null,
                    backgroundColor: dotCount >= 2
                        ? DottieColors.primary
                        : DottieColors.primary.withAlpha(80),
                    elevation: 4,
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                ],
                FloatingActionButton(
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
                ),
              ],
            ),
          ),

          // 첫 사용자 / 오늘 첫 dot 안내 — FAB 옆 작은 hint.
          // 자동 사라짐: dot 1개라도 찍으면 dotCount > 0 → 비표시.
          if (!_playbackActive && dotCount == 0)
            Positioned(
              right: Dimensions.md + 56 + 10,
              bottom: fabBottom + 12,
              child: const _EmptyHomeHint(),
            ),

          // dot 통과 시 위치 팝업 (재생 중)
          if (_playbackActive &&
              animState?.showPopup == true &&
              animState?.popupDot != null)
            Positioned(
              bottom: fabBottom + 56 + 12,
              left: Dimensions.md,
              right: Dimensions.md,
              child: DotPopup(
                dot: animState!.popupDot!,
                onDismiss: () => ref
                    .read(animationControllerProvider(dayLogId).notifier)
                    .dismissPopup(),
              ),
            ),
        ],
      ),
    );
  }
}


// ── 하단 상태 바 ────────────────────────────────────────

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.isRecording,
    required this.dotCount,
    required this.isDaytime,
    this.bottomSafeArea = true,
  });
  final bool isRecording;
  final int dotCount;
  final bool isDaytime;

  /// 재생 패널 위에 쌓일 땐 SafeArea를 패널이 이미 처리하므로 false.
  final bool bottomSafeArea;

  @override
  Widget build(BuildContext context) {
    if (!isRecording && dotCount == 0) return const SizedBox.shrink();

    final bg = isDaytime
        ? const Color(0xCC1C1C1E)
        : const Color(0xB3050510);
    final border = isDaytime
        ? Colors.white.withAlpha(20)
        : Colors.white.withAlpha(15);

    final content = Padding(
      padding: EdgeInsets.fromLTRB(16, bottomSafeArea ? 0 : 8, 16, 12),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isRecording ? DottieColors.error : Colors.greenAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isRecording ? DottieColors.error : Colors.greenAccent)
                              .withAlpha(120),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isRecording
                        ? '기록 중 · dot $dotCount개'
                        : '오늘 기록 완료 · dot $dotCount개',
                    style: GoogleFonts.notoSansKr(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'dot을 탭해 보세요',
                    style: GoogleFonts.notoSansKr(
                      color: Colors.white.withAlpha(120),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

    return bottomSafeArea
        ? SafeArea(top: false, child: content)
        : content;
  }
}


// ── 재생 컨트롤 패널 (인플레이스) ─────────────────────────

class _PlaybackPanel extends ConsumerWidget {
  const _PlaybackPanel({required this.dayLogId, required this.onClose});
  final String dayLogId;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animState = ref.watch(animationControllerProvider(dayLogId));
    final notifier = ref.read(animationControllerProvider(dayLogId).notifier);
    if (animState == null) return const SizedBox.shrink();

    final seq = animState.sequence;
    final startTime =
        seq.frames.isNotEmpty ? seq.frames.first.dot.timestamp : DateTime.now();
    final endTime =
        seq.frames.isNotEmpty ? seq.frames.last.dot.timestamp : DateTime.now();
    final totalMs = seq.totalDurationMs;
    final currentMs = totalMs * animState.progress;
    final currentTime =
        startTime.add(Duration(milliseconds: currentMs.toInt() * 240));

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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                Dimensions.md, Dimensions.md, Dimensions.md, Dimensions.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_fmtTime(startTime),
                        style: TextStyle(
                            color: Colors.white.withAlpha(140), fontSize: 11)),
                    Text(_fmtTime(currentTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        )),
                    Text(_fmtTime(endTime),
                        style: TextStyle(
                            color: Colors.white.withAlpha(140), fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 14),
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
                      onTap: () =>
                          notifier.setSpeed(_nextSpeed(animState.speed)),
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
                                color: Colors.white.withAlpha(70), width: 1),
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
    );
  }

  PlaySpeed _nextSpeed(PlaySpeed s) => switch (s) {
        PlaySpeed.x1 => PlaySpeed.x2,
        PlaySpeed.x2 => PlaySpeed.x4,
        PlaySpeed.x4 => PlaySpeed.x1,
      };

  String _fmtTime(DateTime dt) {
    final l = dt.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
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
              border: Border.all(color: Colors.white.withAlpha(45), width: 1),
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 신규/오늘 빈 사용자에게 + FAB 위치를 알려주는 작은 hint 카드.
/// FAB 좌측에 화살표와 함께 표시. dot 이 1개 이상이면 자동 비표시.
class _EmptyHomeHint extends StatelessWidget {
  const _EmptyHomeHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '오늘 첫 dot 찍어보세요',
            style: GoogleFonts.notoSansKr(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: DottieColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward_rounded,
              size: 16, color: DottieColors.primary),
        ],
      ),
    ).animate().fadeIn(duration: 380.ms, delay: 240.ms).slideX(
        begin: 0.08, end: 0, duration: 380.ms, curve: Curves.easeOutCubic);
  }
}
