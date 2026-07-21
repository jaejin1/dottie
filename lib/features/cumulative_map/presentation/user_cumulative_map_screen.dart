import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/media_thumbnail_loader.dart';
import '../../../shared/widgets/date_ui/date_calendar_sheet.dart';
import '../../../shared/widgets/date_ui/glass_date_header.dart';
import '../../../shared/widgets/dot_detail_sheet.dart';
import '../../recording/domain/dot_model.dart';
import '../../recording/presentation/recording_provider.dart';
import '../../timeline/domain/day_log_model.dart';
import 'user_cumulative_provider.dart';

/// 본인 누적 (모든날 본인 기록) 지도.
///
/// `/v1/dots/cumulative` 페이지네이션 fetch → native cluster 표시.
/// 단일 dot (cluster 풀린 줌) 은 사진 있으면 원형 썸네일, 없으면 색 원.
/// cluster 는 가운데 카운트 텍스트만 표시 (Apple-style 사진 cluster 는 미지원).
class UserCumulativeMapScreen extends ConsumerStatefulWidget {
  const UserCumulativeMapScreen({super.key});

  @override
  ConsumerState<UserCumulativeMapScreen> createState() =>
      _UserCumulativeMapScreenState();
}

class _UserCumulativeMapScreenState
    extends ConsumerState<UserCumulativeMapScreen> {
  mapbox.MapboxMap? _map;
  bool _styleLoaded = false;
  bool _setupDone = false;

  static const _dotSrcId = 'user-cumulative-dots';
  static const _heatmapLayerId = 'user-cumulative-heatmap';
  static const _circleLayerId = 'user-cumulative-circle';
  static const _photoLayerId = 'user-cumulative-photo';
  static const _clusterCircleId = 'user-cumulative-cluster-circle';
  static const _clusterCountId = 'user-cumulative-cluster-count';

  static const _hitLayerIds = [
    _circleLayerId,
    _photoLayerId,
    _clusterCircleId,
  ];

  bool _isDaytime = _checkDaytime();
  Timer? _modeTimer;
  static bool _checkDaytime() {
    final h = DateTime.now().hour;
    return h >= 7 && h < 19;
  }

  @override
  void initState() {
    super.initState();
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
  void dispose() {
    _modeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotsAsync = ref.watch(userCumulativeDotsProvider);
    ref.listen(userCumulativeDotsProvider, (_, __) => _trySetupMap());

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
              _setupDone = false;
              await _map?.style.localizeLabels('ko', null);
              await _trySetupMap();
            },
            onTapListener: (ctx) => _handleMapTap(ctx.touchPosition),
            cameraOptions: mapbox.CameraOptions(
              center: mapbox.Point(
                  coordinates: mapbox.Position(126.9780, 37.5665)),
              zoom: 11.0,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlassDateHeader.title(
              titleText: '모든날 기록',
              onBack: () => Navigator.of(context).pop(),
              onTapTitle: () => _showCalendarSheet(),
              isDaytime: _isDaytime,
            ),
          ),
          if (dotsAsync.isLoading && dotsAsync.valueOrNull == null)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
          if (dotsAsync.valueOrNull?.isEmpty ?? false)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(Dimensions.lg),
                    child: Text(
                      '아직 기록된 dot 이 없어요',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _trySetupMap() async {
    if (_setupDone || !_styleLoaded || _map == null) return;
    final dots = ref.read(userCumulativeDotsProvider).valueOrNull;
    if (dots == null || dots.isEmpty) return;
    _setupDone = true;
    try {
      await _addDotLayers(_map!, dots);
      await _fitCameraToDots(_map!, dots);
      unawaited(_loadPhotoThumbnails(_map!, dots));
    } catch (e) {
      debugPrint('[UC] setup error: $e');
    }
  }

  Map<String, dynamic> _dotFeature(Dot dot,
      {String photoIconId = 'uc-default'}) {
    return {
      'type': 'Feature',
      'geometry': {
        'type': 'Point',
        'coordinates': [dot.longitude, dot.latitude],
      },
      'properties': {
        'dot_id': dot.id,
        'has_photo': dot.hasPhotoData,
        'photo_icon_id': photoIconId,
      },
    };
  }

  String _buildGeoJson(List<Dot> dots, {Map<String, String>? photoIconIds}) {
    final features = dots
        .map((d) => _dotFeature(d,
            photoIconId: photoIconIds?[d.id] ?? 'uc-default'))
        .toList();
    return jsonEncode({'type': 'FeatureCollection', 'features': features});
  }

  Future<void> _addDotLayers(mapbox.MapboxMap map, List<Dot> dots) async {
    // 사진 placeholder — 썸네일 로드 전 fallback (투명 1x1).
    try {
      await map.style.addStyleImage(
        'uc-default',
        2.0,
        mapbox.MbxImage(
          width: 1,
          height: 1,
          data: Uint8List.fromList(const [0, 0, 0, 0]),
        ),
        false,
        [],
        [],
        null,
      );
    } catch (_) {}

    // Cluster source — native clustering.
    await map.style.addSource(mapbox.GeoJsonSource(
      id: _dotSrcId,
      data: _buildGeoJson(dots),
      cluster: true,
      clusterMaxZoom: 14,
      clusterRadius: 50,
    ));

    // (1) Heatmap.
    await map.style.addLayer(mapbox.HeatmapLayer(
      id: _heatmapLayerId,
      sourceId: _dotSrcId,
      maxZoom: 16.0,
    ));
    await map.style.setStyleLayerProperty(
      _heatmapLayerId,
      'heatmap-weight',
      jsonEncode(['interpolate', ['linear'], ['zoom'], 9, 0.5, 15, 1.0]),
    );
    await map.style.setStyleLayerProperty(
      _heatmapLayerId,
      'heatmap-radius',
      jsonEncode(['interpolate', ['linear'], ['zoom'], 9, 12, 15, 28]),
    );
    await map.style.setStyleLayerProperty(
      _heatmapLayerId,
      'heatmap-color',
      jsonEncode([
        'interpolate',
        ['linear'],
        ['heatmap-density'],
        0, 'rgba(0,0,0,0)',
        0.2, 'rgba(192,123,90,0.18)',
        0.5, 'rgba(192,123,90,0.35)',
        0.8, 'rgba(192,123,90,0.55)',
        1.0, 'rgba(192,123,90,0.7)',
      ]),
    );
    await map.style.setStyleLayerProperty(
      _heatmapLayerId,
      'heatmap-opacity',
      jsonEncode(
          ['interpolate', ['linear'], ['zoom'], 12, 0.85, 15, 0.4, 16, 0]),
    );

    // (2) Cluster 원 — point_count 가 있는 feature 만.
    await map.style.addLayer(mapbox.CircleLayer(
      id: _clusterCircleId,
      sourceId: _dotSrcId,
      filter: ["has", "point_count"],
      circleRadius: 20.0,
      circleColor: DottieColors.primary.toARGB32(),
      circleStrokeColor: Colors.white.toARGB32(),
      circleStrokeWidth: 2.0,
    ));
    await map.style.setStyleLayerProperty(
      _clusterCircleId,
      'circle-radius',
      jsonEncode([
        'step', ['get', 'point_count'],
        18, // <5
        5, 22, // 5~19
        20, 26, // ≥20
      ]),
    );

    // (3) Cluster 가운데 카운트.
    await map.style.addLayer(mapbox.SymbolLayer(
      id: _clusterCountId,
      sourceId: _dotSrcId,
      filter: ["has", "point_count"],
      textColor: Colors.white.toARGB32(),
      textSize: 13.0,
      textAllowOverlap: true,
      textIgnorePlacement: true,
    ));
    await map.style.setStyleLayerProperty(
      _clusterCountId,
      'text-field',
      '["get", "point_count_abbreviated"]',
    );

    // (4) 비클러스터 (단일 dot) — 사진 없는 dot.
    await map.style.addLayer(mapbox.CircleLayer(
      id: _circleLayerId,
      sourceId: _dotSrcId,
      filter: [
        "all",
        ["!", ["has", "point_count"]],
        ["==", ["get", "has_photo"], false],
      ],
      circleRadius: 7.0,
      circleColor: DottieColors.primary.toARGB32(),
      circleStrokeColor: Colors.white.withAlpha(220).toARGB32(),
      circleStrokeWidth: 2.0,
    ));

    // (5) 비클러스터 (단일 dot) — 사진 있는 dot, 원형 썸네일.
    await map.style.addLayer(mapbox.SymbolLayer(
      id: _photoLayerId,
      sourceId: _dotSrcId,
      filter: [
        "all",
        ["!", ["has", "point_count"]],
        ["==", ["get", "has_photo"], true],
      ],
      iconImage: '["get", "photo_icon_id"]',
      iconSize: 1.0,
      iconAnchor: mapbox.IconAnchor.CENTER,
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
    ));
  }

  /// 사진 dot 의 원형 썸네일 비동기 로드 → style image 등록 → source 갱신.
  Future<void> _loadPhotoThumbnails(
      mapbox.MapboxMap map, List<Dot> dots) async {
    final photoDots = dots.where((d) => d.displayThumbUrl != null).toList();
    if (photoDots.isEmpty) return;

    final photoIconIds = <String, String>{};
    await Future.wait(photoDots.map((dot) async {
      final bytes = await MediaThumbnailLoader.loadCircle(
        dot.displayThumbUrl!,
        badgeColor: DottieColors.primary,
      );
      if (bytes == null || !mounted) return;
      final imgId = 'uc-photo-${dot.id}';
      try {
        await map.style.addStyleImage(
          imgId,
          2.0,
          mapbox.MbxImage(
            width: MediaThumbnailLoader.pixelSize,
            height: MediaThumbnailLoader.pixelSize,
            data: bytes,
          ),
          false,
          [],
          [],
          null,
        );
        photoIconIds[dot.id] = imgId;
      } catch (_) {}
    }));

    if (!mounted || photoIconIds.isEmpty) return;
    try {
      await map.style.setStyleSourceProperty(
        _dotSrcId,
        'data',
        _buildGeoJson(dots, photoIconIds: photoIconIds),
      );
    } catch (e) {
      debugPrint('[UC] thumbnail source update error: $e');
    }
  }

  Future<void> _fitCameraToDots(mapbox.MapboxMap map, List<Dot> dots) async {
    final lats = dots.map((d) => d.latitude);
    final lngs = dots.map((d) => d.longitude);
    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);
    try {
      final camera = await map.cameraForCoordinateBounds(
        mapbox.CoordinateBounds(
          southwest: mapbox.Point(
              coordinates:
                  mapbox.Position(minLng - 0.005, minLat - 0.005)),
          northeast: mapbox.Point(
              coordinates:
                  mapbox.Position(maxLng + 0.005, maxLat + 0.005)),
          infiniteBounds: false,
        ),
        mapbox.MbxEdgeInsets(top: 140, left: 40, bottom: 120, right: 40),
        null,
        null,
        16.0,
        null,
      );
      await map.setCamera(camera);
    } catch (e) {
      debugPrint('[UC] fit camera error: $e');
    }
  }

  Future<void> _handleMapTap(mapbox.ScreenCoordinate sc) async {
    if (_map == null || !mounted) return;
    try {
      const r = 22.0;
      final features = await _map!.queryRenderedFeatures(
        mapbox.RenderedQueryGeometry.fromScreenBox(
          mapbox.ScreenBox(
            min: mapbox.ScreenCoordinate(x: sc.x - r, y: sc.y - r),
            max: mapbox.ScreenCoordinate(x: sc.x + r, y: sc.y + r),
          ),
        ),
        mapbox.RenderedQueryOptions(
          layerIds: List<String>.from(_hitLayerIds),
          filter: null,
        ),
      );
      for (final f in features) {
        if (f == null) continue;
        final feature = f.queriedFeature.feature;
        final props = feature['properties'] as Map?;

        // Cluster 탭 → 풀리는 줌으로 카메라 이동.
        if (props?['cluster'] == true || props?['cluster_id'] != null) {
          await _expandCluster(feature);
          return;
        }

        // 단일 dot → 상세 시트.
        final dotId = props?['dot_id'] as String?;
        if (dotId == null) continue;
        final dots = ref.read(userCumulativeDotsProvider).valueOrNull;
        if (dots == null || dots.isEmpty) return;
        final dot = dots.firstWhere(
          (d) => d.id == dotId,
          orElse: () => dots.first,
        );
        if (!mounted) return;
        HapticFeedback.lightImpact();
        await DotDetailSheet.show(context, dot);
        return;
      }
    } catch (e) {
      debugPrint('[UC] tap error: $e');
    }
  }

  Future<void> _expandCluster(Map<String?, Object?> feature) async {
    if (_map == null) return;
    try {
      HapticFeedback.lightImpact();
      final result = await _map!
          .getGeoJsonClusterExpansionZoom(_dotSrcId, feature);
      final zoom = double.tryParse(result.value ?? '');
      final geom = feature['geometry'] as Map?;
      final coords = geom?['coordinates'] as List?;
      if (zoom == null || coords == null || coords.length < 2) return;
      await _map!.flyTo(
        mapbox.CameraOptions(
          center: mapbox.Point(
            coordinates: mapbox.Position(
              (coords[0] as num).toDouble(),
              (coords[1] as num).toDouble(),
            ),
          ),
          zoom: zoom + 0.5,
        ),
        mapbox.MapAnimationOptions(duration: 500),
      );
    } catch (e) {
      debugPrint('[UC] expand cluster error: $e');
    }
  }

  Future<void> _showCalendarSheet() async {
    final logs =
        ref.read(allDayLogsProvider).valueOrNull ?? const <DayLog>[];
    final activeDates = logs
        .map((l) => DottieDateUtils.toDateString(l.date.toLocal()))
        .toSet();
    final selected = await DateCalendarSheet.show(
      context,
      selectedDate: DottieDateUtils.todayStart(),
      activeDates: activeDates,
    );
    if (selected == null || !mounted) return;
    final id = _findDayLogId(selected, logs);
    if (id == null) return;
    if (!context.mounted) return;
    context.push('/animation/$id');
  }

  String? _findDayLogId(DateTime date, List<DayLog> logs) {
    for (final l in logs) {
      if (DottieDateUtils.isSameDay(l.date.toLocal(), date)) return l.id;
    }
    return null;
  }
}
