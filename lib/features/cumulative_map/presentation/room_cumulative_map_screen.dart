import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import '../../../core/constants/colors.dart';
import '../../../core/utils/color_hex.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/date_utils.dart';
import '../../room/domain/room_model.dart';
import '../../room/presentation/room_provider.dart';
import '../domain/place_group.dart';
import '../domain/room_dot.dart';
import 'cumulative_map_provider.dart';
import 'widgets/cumulative_calendar_sheet.dart';
import 'widgets/place_card_sheet.dart';

/// 룸 진입 시 기본 화면 — 모든 dot 누적 표시.
/// 캘린더는 우하단 FAB → 시트, 하루 지도는 캘린더에서 날짜 선택 시 진입.
///
/// Phase 1: place 단위 핀 (mock 클러스터링 — Phase 2 작업) + 일반 dot cluster.
class RoomCumulativeMapScreen extends ConsumerStatefulWidget {
  const RoomCumulativeMapScreen({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<RoomCumulativeMapScreen> createState() =>
      _RoomCumulativeMapScreenState();
}

class _RoomCumulativeMapScreenState
    extends ConsumerState<RoomCumulativeMapScreen> {
  mapbox.MapboxMap? _mapboxMap;
  bool _styleLoaded = false;
  bool _setupDone = false;

  // 핀 hit-testing 대상 (place 단위)
  final List<String> _placeHitLayerIds = [];

  // place id → PlaceGroup (탭 시 시트 띄우기용)
  Map<String, PlaceGroup> _groupsById = {};

  /// 멤버 필터 (Phase 4) — null = 전체. 특정 userId 선택 시 그 멤버 dot 만.
  String? _filterMemberId;

  // 낮/밤 자동 스타일 전환
  bool _isDaytime = _checkDaytime();
  Timer? _modeTimer;

  static bool _checkDaytime() {
    final h = DateTime.now().hour;
    return h >= 7 && h < 19;
  }

  @override
  void initState() {
    super.initState();
    // 1분마다 시간 체크 — 낮/밤 경계에서 자동 전환
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
    _modeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomAsync = ref.watch(roomDetailProvider(widget.roomId));
    final groupsAsync = ref.watch(placeGroupsProvider(widget.roomId));

    // 데이터 도착 시 setup 시도
    ref.listen(placeGroupsProvider(widget.roomId), (_, __) => _trySetupMap());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          mapbox.MapWidget(
            onMapCreated: (map) {
              _mapboxMap = map;
              map.scaleBar
                  .updateSettings(mapbox.ScaleBarSettings(enabled: false));
              map.compass
                  .updateSettings(mapbox.CompassSettings(enabled: false));
              map.logo
                  .updateSettings(mapbox.LogoSettings(marginBottom: 24, marginLeft: 8));
              map.attribution
                  .updateSettings(mapbox.AttributionSettings(marginBottom: 24));
            },
            onStyleLoadedListener: (_) async {
              _styleLoaded = true;
              _setupDone = false; // 스타일 전환 시 레이어 재설정
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

          // 상단 알약 바 — 룸 이름 + 멤버 수
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _CumulativeTopBar(
              title: roomAsync.valueOrNull?.name ?? '',
              onBack: () => Navigator.of(context).pop(),
              onInfo: () =>
                  context.push('/rooms/${widget.roomId}/info'),
              isDaytime: _isDaytime,
            ),
          ),

          // 상단 바 아래 — 멤버 필터 chip + 오늘 보기 토글
          Positioned(
            top: 96,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.md),
                child: Row(
                  children: [
                    Expanded(
                      child: _FilterChipRow(
                        members: roomAsync.valueOrNull?.members ?? [],
                        selectedMemberId: _filterMemberId,
                        isDaytime: _isDaytime,
                        onMemberTap: (uid) {
                          HapticFeedback.lightImpact();
                          setState(() {
                            if (uid.isEmpty) {
                              _filterMemberId = null;
                            } else {
                              _filterMemberId =
                                  _filterMemberId == uid ? null : uid;
                            }
                          });
                          _refreshMemberFilter();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    _TodayToggleChip(
                      isDaytime: _isDaytime,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.pushReplacement('/rooms/${widget.roomId}');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 우하단 캘린더 FAB
          Positioned(
            right: Dimensions.md,
            bottom: Dimensions.md,
            child: SafeArea(
              child: _CalendarFab(
                onTap: () => _showCalendarSheet(context),
                isDaytime: _isDaytime,
              ),
            ),
          ),

          // 빈 데이터 / 로딩 오버레이
          if (groupsAsync.isLoading && groupsAsync.valueOrNull == null)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
          if (groupsAsync.valueOrNull?.isEmpty ?? false)
            _CumulativeEmpty(
                onCalendar: () => _showCalendarSheet(context)),
        ],
      ),
    );
  }

  Future<void> _trySetupMap() async {
    if (_setupDone || !_styleLoaded || _mapboxMap == null) return;
    final groups = ref.read(placeGroupsProvider(widget.roomId)).valueOrNull;
    final dots = ref.read(cumulativeRoomDotsProvider(widget.roomId)).valueOrNull;
    if (groups == null || dots == null || dots.isEmpty) return;
    _setupDone = true;
    try {
      _groupsById = {for (final g in groups) g.id: g};
      await _fitCameraToDots(_mapboxMap!, dots);
      await _addHeatmapLayer(_mapboxMap!, dots); // Phase 3 — heatmap 먼저 (z-order 아래)
      await _addPlaceLayers(_mapboxMap!, groups);
    } catch (e, st) {
      debugPrint('[CumulativeMap] setup error: $e\n$st');
    }
  }

  // ── 히트맵 (Phase 3) ─────────────────────────────────

  Future<void> _addHeatmapLayer(
      mapbox.MapboxMap map, List<RoomDot> dots) async {
    const sourceId = 'cumulative-heatmap';
    const layerId = 'cumulative-heatmap-layer';

    final features = dots
        .map((rd) => {
              'type': 'Feature',
              'geometry': {
                'type': 'Point',
                'coordinates': [rd.dot.longitude, rd.dot.latitude],
              },
              'properties': {},
            })
        .toList();

    await map.style.addSource(mapbox.GeoJsonSource(
      id: sourceId,
      data: jsonEncode(
          {'type': 'FeatureCollection', 'features': features}),
    ));

    // HeatmapLayer — 룸 액센트(primary) 색 ramp.
    // 줌 작을 때만 잘 보이고 줌 클수록 fade out (개별 핀 정보 우선).
    await map.style.addLayer(mapbox.HeatmapLayer(
      id: layerId,
      sourceId: sourceId,
      maxZoom: 16.0,
    ));
    await map.style.setStyleLayerProperty(
      layerId,
      'heatmap-weight',
      jsonEncode([
        'interpolate',
        ['linear'],
        ['zoom'],
        9, 0.5,
        15, 1.0,
      ]),
    );
    await map.style.setStyleLayerProperty(
      layerId,
      'heatmap-intensity',
      jsonEncode([
        'interpolate',
        ['linear'],
        ['zoom'],
        9, 1,
        15, 3,
      ]),
    );
    await map.style.setStyleLayerProperty(
      layerId,
      'heatmap-radius',
      jsonEncode([
        'interpolate',
        ['linear'],
        ['zoom'],
        9, 12,
        15, 28,
      ]),
    );
    // 색 ramp — 투명 → primary 갈색
    await map.style.setStyleLayerProperty(
      layerId,
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
    // 줌 클수록 사라짐 (개별 핀에 자리 양보)
    await map.style.setStyleLayerProperty(
      layerId,
      'heatmap-opacity',
      jsonEncode([
        'interpolate',
        ['linear'],
        ['zoom'],
        12, 0.85,
        15, 0.4,
        16, 0,
      ]),
    );
  }

  // ── camera ─────────────────────────────────────────────

  Future<void> _fitCameraToDots(
      mapbox.MapboxMap map, List<RoomDot> dots) async {
    final lats = dots.map((rd) => rd.dot.latitude).toList();
    final lngs = dots.map((rd) => rd.dot.longitude).toList();
    if (lats.isEmpty) return;
    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);

    // maxZoom 16 — dot 1~2개로 좁은 범위면 너무 줌인되는 것 방지.
    await map
        .cameraForCoordinateBounds(
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
        )
        .then((camera) => map.setCamera(camera));
  }

  // ── place 핀 layer ────────────────────────────────────

  Future<void> _addPlaceLayers(
      mapbox.MapboxMap map, List<PlaceGroup> groups) async {
    _placeHitLayerIds.clear();

    const sourceId = 'cumulative-places';
    const baseLayerId = 'cumulative-place-base';
    const countLayerId = 'cumulative-place-count';
    const symbolLayerId = 'cumulative-place-symbol';
    const clusterCircleId = 'cumulative-cluster-circle';
    const clusterCountId = 'cumulative-cluster-count';

    // 줌 ≤ 13 에서 Mapbox 네이티브 클러스터링.
    // sum_visit_count: 클러스터 안 PlaceGroup 들의 visit_count 합산 → 누적 방문수.
    // visited_count: dimmed=false (필터 멤버가 방문) 인 feature 개수.
    //   필터 OFF 면 모든 feature 의 dimmed=false → visited_count == point_count.
    //   필터 ON 이고 그 멤버가 클러스터 안 어디라도 방문했으면 > 0.
    await map.style.addSource(mapbox.GeoJsonSource(
      id: sourceId,
      data: _buildPlacesGeoJson(groups),
      cluster: true,
      clusterMaxZoom: 13,
      clusterRadius: 50,
      clusterProperties: {
        'sum_visit_count': ['+', ['get', 'visit_count']],
        'visited_count': [
          '+',
          ['case', ['==', ['get', 'dimmed'], true], 0, 1],
        ],
      },
    ));

    // (1) base — 둥근 글래스 chip. 클러스터가 아닌 핀에만 표시.
    //  - 색: properties.color_hex (필터 상태 반영)
    //  - 투명도: properties.dimmed (필터 OFF 멤버만 방문한 곳 30%)
    await map.style.addLayer(mapbox.CircleLayer(
      id: baseLayerId,
      sourceId: sourceId,
      filter: ["!", ["has", "point_count"]],
      circleRadius: 14.0,
      circleColor: Colors.white.toARGB32(), // expression 으로 덮어씀
      circleStrokeWidth: 2.0,
      circleStrokeColor: Colors.white.withAlpha(220).toARGB32(),
    ));
    await map.style.setStyleLayerProperty(
      baseLayerId, 'circle-color', '["get", "color_hex"]',
    );
    // 필터 흐림 expression — 멤버 chip 선택 시 안 간 곳 30%.
    await _applyFilterDimmer();

    // (2) 카운트 텍스트 — visit count. 비클러스터 핀에만.
    await map.style.addLayer(mapbox.SymbolLayer(
      id: countLayerId,
      sourceId: sourceId,
      filter: ["!", ["has", "point_count"]],
      textColor: Colors.white.toARGB32(),
      textSize: 12.0,
      textAllowOverlap: true,
      textIgnorePlacement: true,
    ));
    await map.style.setStyleLayerProperty(
      countLayerId, 'text-field',
      '["to-string", ["get", "visit_count"]]',
    );

    // (3) 특별 심볼 — 첫 함께(★) / 단골(🔥). 비클러스터 핀에만.
    //     mock — placeName 옆에 작은 텍스트 배지
    await map.style.addLayer(mapbox.SymbolLayer(
      id: symbolLayerId,
      sourceId: sourceId,
      filter: ["!", ["has", "point_count"]],
      textColor: Colors.white.toARGB32(),
      textSize: 11.0,
      textAllowOverlap: true,
      textIgnorePlacement: true,
      textOffset: [1.6, -1.4],
    ));
    await map.style.setStyleLayerProperty(
      symbolLayerId, 'text-field',
      jsonEncode([
        'case',
        ['==', ['get', 'is_first_together'], true], '⭐',
        ['>=', ['get', 'visit_count'], 5], '🔥',
        ''
      ]),
    );

    // (4) 클러스터 원 — 줌 아웃 시 누적 핀.
    //   step 으로 카운트 구간별 크기 차등 (시각적 위계).
    //   필터 ON 일 때는 _applyClusterColor 가 그 멤버 색으로 덮어씀.
    await map.style.addLayer(mapbox.CircleLayer(
      id: clusterCircleId,
      sourceId: sourceId,
      filter: ["has", "point_count"],
      circleColor: DottieColors.primary.toARGB32(),
      circleStrokeColor: Colors.white.withAlpha(220).toARGB32(),
      circleStrokeWidth: 3.0,
    ));
    await map.style.setStyleLayerProperty(
      clusterCircleId, 'circle-radius',
      jsonEncode([
        'step', ['get', 'point_count'],
        20, // <5
        5, 24, // 5~19
        20, 28, // ≥20
      ]),
    );
    await _applyClusterColor();

    // (5) 클러스터 카운트 텍스트 — sum_visit_count (총 방문 수).
    await map.style.addLayer(mapbox.SymbolLayer(
      id: clusterCountId,
      sourceId: sourceId,
      filter: ["has", "point_count"],
      textColor: Colors.white.toARGB32(),
      textSize: 14.0,
      textAllowOverlap: true,
      textIgnorePlacement: true,
    ));
    await map.style.setStyleLayerProperty(
      clusterCountId, 'text-field',
      '["to-string", ["get", "sum_visit_count"]]',
    );

    _placeHitLayerIds.addAll([baseLayerId, clusterCircleId]);
  }

  /// PlaceGroup 들을 GeoJSON 으로 직렬화.
  /// 필터 상태(_filterMemberId)에 따라 color_hex / dimmed 결정:
  ///   - 필터 OFF (전체): 단독→멤버색, 다인→룸 액센트(primary)
  ///   - 필터 ON (사용자 N): 그 멤버가 방문한 곳 → 그 멤버색 (정체성 강조)
  ///                         그 멤버가 안 방문한 곳 → 단독/다인 규칙 + dimmed=true
  String _buildPlacesGeoJson(List<PlaceGroup> groups) {
    final features = <Map<String, dynamic>>[];
    final filterId = _filterMemberId;
    for (final g in groups) {
      final isShared = g.memberIds.length >= 2;
      final filterMemberWasHere =
          filterId != null && g.memberIds.contains(filterId);

      final String colorHex;
      final bool dimmed;
      if (filterId == null) {
        // 전체 모드 — 기존 규칙
        colorHex = isShared
            ? _toHex(DottieColors.primary)
            : _firstMemberColorHex(g);
        dimmed = false;
      } else if (filterMemberWasHere) {
        // 그 멤버가 방문한 곳 — 그 멤버 색으로 강조 (함께 간 곳 포함)
        colorHex = _hexForMember(filterId, g);
        dimmed = false;
      } else {
        // 그 멤버는 안 갔음 — 흐림 처리 (지도 컨텍스트 유지)
        colorHex = isShared
            ? _toHex(DottieColors.primary)
            : _firstMemberColorHex(g);
        dimmed = true;
      }

      features.add({
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [g.centerLng, g.centerLat],
        },
        'properties': {
          'place_id': g.id,
          'visit_count': g.visitCount,
          'color_hex': colorHex,
          'dimmed': dimmed,
          'is_first_together': g.isFirstTogether,
          'is_frequent': g.visitCount >= 5,
          'first_visit_ms': g.firstVisitedAt.millisecondsSinceEpoch,
        },
      });
    }
    return jsonEncode({'type': 'FeatureCollection', 'features': features});
  }

  /// 그룹의 대표 멤버 색.
  /// - dots 가 있으면 (orphan 좌표 그룹) 첫 dot 의 colorHex
  /// - dots 가 비어있으면 (BE place 그룹) memberIds 첫 번째 → roomDetail lookup
  String _firstMemberColorHex(PlaceGroup g) {
    if (g.dots.isNotEmpty) return g.dots.first.colorHex;
    final firstMid = g.memberIds.firstOrNull;
    if (firstMid != null) {
      final hex = _memberColorHexById(firstMid);
      if (hex != null) return hex;
    }
    return _toHex(DottieColors.primary);
  }

  /// 특정 멤버 ID 의 색을 그룹 안에서 찾음. 못 찾으면 roomDetail 멤버 lookup.
  String _hexForMember(String memberId, PlaceGroup g) {
    for (final rd in g.dots) {
      if (rd.memberId == memberId) return rd.colorHex;
    }
    final hex = _memberColorHexById(memberId);
    if (hex != null) return hex;
    return _firstMemberColorHex(g);
  }

  /// roomDetailProvider 의 members 에서 userId 로 colorHex lookup.
  /// 룸 데이터 미로드 / 멤버 미발견 시 null.
  String? _memberColorHexById(String userId) {
    final room = ref.read(roomDetailProvider(widget.roomId)).valueOrNull;
    if (room == null) return null;
    for (final m in room.members) {
      if (m.userId == userId) return m.character.colorHex;
    }
    return null;
  }

  String _toHex(Color c) {
    final argb = c.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${argb.substring(2)}';
  }

  // ── 멤버 필터 (Phase 4 / D+F) ─────────────────────────

  /// _filterMemberId 변경 시 place layer GeoJSON 재빌드.
  /// 핀 필터링 X — 핀은 모두 그대로 두고, 색/투명도만 properties 로 조정.
  /// (D+F) 필터 멤버 핀은 그 멤버 색 강조, 안 간 곳은 dimmed=true 흐림.
  Future<void> _refreshMemberFilter() async {
    if (_mapboxMap == null || !_styleLoaded) return;
    final groups =
        ref.read(placeGroupsProvider(widget.roomId)).valueOrNull ?? [];
    try {
      await _mapboxMap!.style.setStyleSourceProperty(
          'cumulative-places', 'data', _buildPlacesGeoJson(groups));
      await _applyFilterDimmer();
      await _applyClusterColor();
    } catch (_) {}
  }

  /// 클러스터 원의 색/투명도를 필터 상태에 맞춰 갱신.
  /// 데이터 드리븐 expression 사용 — 같은 클러스터 레이어 위에서 visited_count
  /// 기준으로 클러스터별 색·투명도 결정.
  /// - 필터 OFF: 모든 visited_count == point_count > 0 → 항상 primary, 풀 불투명.
  /// - 필터 ON:
  ///     · visited_count > 0 (필터 멤버 dot 이 클러스터 안에 있음) → 그 멤버 색, 풀 불투명.
  ///     · visited_count == 0 (필터 멤버가 클러스터에 없음) → primary, 30% 투명.
  Future<void> _applyClusterColor() async {
    if (_mapboxMap == null || !_styleLoaded) return;
    final filterId = _filterMemberId;
    final primaryHex = _toHex(DottieColors.primary);
    final filterHex = filterId == null
        ? primaryHex
        : (_memberColorHexById(filterId) ?? primaryHex);

    // visited_count > 0 → filterHex, else primaryHex.
    // 필터 OFF 면 filterHex == primaryHex 라 어느 분기든 동일색.
    final colorExpr = jsonEncode([
      'case',
      ['>', ['get', 'visited_count'], 0], filterHex,
      primaryHex,
    ]);
    final opacityExpr = jsonEncode([
      'case',
      ['>', ['get', 'visited_count'], 0], 1.0,
      0.3,
    ]);

    try {
      await _mapboxMap!.style.setStyleLayerProperty(
          'cumulative-cluster-circle', 'circle-color', colorExpr);
      await _mapboxMap!.style.setStyleLayerProperty(
          'cumulative-cluster-circle', 'circle-opacity', opacityExpr);
      await _mapboxMap!.style.setStyleLayerProperty(
          'cumulative-cluster-count', 'text-opacity', opacityExpr);
    } catch (_) {}
  }

  /// dimmed=true feature 의 circle-opacity / text-opacity 를 30% 로 보간.
  Future<void> _applyFilterDimmer() async {
    if (_mapboxMap == null || !_styleLoaded) return;
    final dimExpr = jsonEncode([
      'case',
      ['==', ['get', 'dimmed'], true], 0.3,
      1.0,
    ]);
    try {
      await _mapboxMap!.style.setStyleLayerProperty(
          'cumulative-place-base', 'circle-opacity', dimExpr);
      await _mapboxMap!.style.setStyleLayerProperty(
          'cumulative-place-count', 'text-opacity', dimExpr);
      await _mapboxMap!.style.setStyleLayerProperty(
          'cumulative-place-symbol', 'text-opacity', dimExpr);
    } catch (_) {}
  }

  // ── 탭 처리 — 핀 → PlaceCardSheet ─────────────────────

  Future<void> _handleMapTap(mapbox.ScreenCoordinate sc) async {
    if (_mapboxMap == null || !mounted) return;
    try {
      const r = 22.0;
      final features = await _mapboxMap!.queryRenderedFeatures(
        mapbox.RenderedQueryGeometry.fromScreenBox(
          mapbox.ScreenBox(
            min: mapbox.ScreenCoordinate(x: sc.x - r, y: sc.y - r),
            max: mapbox.ScreenCoordinate(x: sc.x + r, y: sc.y + r),
          ),
        ),
        mapbox.RenderedQueryOptions(
          layerIds: List<String>.from(_placeHitLayerIds),
          filter: null,
        ),
      );
      for (final f in features) {
        if (f == null) continue;
        final feature = f.queriedFeature.feature;
        final props = feature['properties'] as Map?;

        // 클러스터 탭 → 풀어지는 줌 레벨로 카메라 이동.
        if (props?['cluster'] == true || props?['cluster_id'] != null) {
          await _expandCluster(feature);
          return;
        }

        // 일반 핀 탭 → PlaceCardSheet
        final pid = props?['place_id'] as String?;
        if (pid == null) continue;
        final group = _groupsById[pid];
        if (group == null) continue;
        if (!mounted) return;
        HapticFeedback.lightImpact();
        await PlaceCardSheet.show(
          context,
          group: group,
          roomId: widget.roomId,
        );
        return;
      }
    } catch (e) {
      debugPrint('[CumulativeMap] tap error: $e');
    }
  }

  /// 클러스터를 풀어주는 줌 레벨로 카메라를 이동.
  /// `getGeoJsonClusterExpansionZoom` 이 String 으로 줌 값을 반환하므로 파싱 필요.
  Future<void> _expandCluster(Map<String?, Object?> feature) async {
    if (_mapboxMap == null) return;
    try {
      HapticFeedback.lightImpact();
      final result = await _mapboxMap!.getGeoJsonClusterExpansionZoom(
          'cumulative-places', feature);
      final zoom = double.tryParse(result.value ?? '');
      final geom = feature['geometry'] as Map?;
      final coords = geom?['coordinates'] as List?;
      if (zoom == null || coords == null || coords.length < 2) return;
      await _mapboxMap!.flyTo(
        mapbox.CameraOptions(
          center: mapbox.Point(
            coordinates: mapbox.Position(
              (coords[0] as num).toDouble(),
              (coords[1] as num).toDouble(),
            ),
          ),
          // +0.5 — 풀린 직후 핀들이 살짝 더 떨어져 보이도록.
          zoom: zoom + 0.5,
        ),
        mapbox.MapAnimationOptions(duration: 500),
      );
    } catch (e) {
      debugPrint('[CumulativeMap] expand cluster error: $e');
    }
  }

  // ── 캘린더 시트 ───────────────────────────────────────

  Future<void> _showCalendarSheet(BuildContext context) async {
    final selected = await CumulativeCalendarSheet.show(
      context,
      roomId: widget.roomId,
    );
    if (selected == null || !mounted || !context.mounted) return;
    final dateStr = DottieDateUtils.toDateString(selected);
    context.push(
      '/rooms/${widget.roomId}/map',
      extra: {'date': dateStr},
    );
  }
}

// ─── 상단 알약 바 ──────────────────────────────────────

class _CumulativeTopBar extends StatelessWidget {
  const _CumulativeTopBar({
    required this.title,
    required this.onBack,
    required this.onInfo,
    required this.isDaytime,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onInfo;
  final bool isDaytime;

  @override
  Widget build(BuildContext context) {
    // 낮: 지도가 밝아서 어두운 배경으로 대비 확보
    // 밤: 지도가 어두워서 반투명 유리 효과
    final bg = isDaytime
        ? const Color(0xCC1C1C1E) // 80% 불투명 다크
        : Colors.white.withAlpha(22);
    final border = isDaytime
        ? Colors.white.withAlpha(20)
        : DottieColors.borderGlass;

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
                    tooltip: '뒤로',
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: onInfo,
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Text(
                          title.isEmpty ? '룸' : title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined,
                        color: Colors.white, size: 20),
                    onPressed: onInfo,
                    tooltip: '방 설정',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 캘린더 FAB ────────────────────────────────────────

class _CalendarFab extends StatelessWidget {
  const _CalendarFab({required this.onTap, required this.isDaytime});
  final VoidCallback onTap;
  final bool isDaytime;

  @override
  Widget build(BuildContext context) {
    final bg = isDaytime
        ? const Color(0xE61C1C1E) // 90% 불투명 다크
        : DottieColors.surfaceFloating;
    final border = isDaytime
        ? Colors.white.withAlpha(20)
        : DottieColors.borderGlass;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: ShapeDecoration(
          color: bg,
          shape: CircleBorder(side: BorderSide(color: border, width: 1)),
          shadows: [
            BoxShadow(
              color: Colors.black.withAlpha(isDaytime ? 50 : 80),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const SizedBox(
            width: 56,
            height: 56,
            child: Icon(Icons.calendar_today_rounded,
                color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

// ─── 오늘 보기 토글 ─────────────────────────────────────
//
// 누적(전체일) 지도에서 오늘 SharedMapScreen 으로 돌아가는 글래스 pill 칩.
// 룸 메인은 오늘 SharedMap 이 기본이고, 누적(/all) 에서 이 칩으로 복귀.
class _TodayToggleChip extends StatelessWidget {
  const _TodayToggleChip({
    required this.onTap,
    required this.isDaytime,
  });
  final VoidCallback onTap;
  final bool isDaytime;

  @override
  Widget build(BuildContext context) {
    final bg = isDaytime
        ? const Color(0xCC1C1C1E)
        : DottieColors.surfaceFloating;
    final border = isDaytime
        ? Colors.white.withAlpha(20)
        : DottieColors.borderGlass;
    const fg = Colors.white;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: bg,
              border: Border.all(color: border, width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.today_rounded, color: fg, size: 14),
                SizedBox(width: 6),
                Text(
                  '오늘',
                  style: TextStyle(
                    color: fg,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 멤버 필터 chip row (Phase 4) ──────────────────────

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({
    required this.members,
    required this.selectedMemberId,
    required this.onMemberTap,
    required this.isDaytime,
  });

  final List<RoomMember> members;
  final String? selectedMemberId;
  final void Function(String userId) onMemberTap;
  final bool isDaytime;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: '전체',
            color: DottieColors.primary,
            active: selectedMemberId == null,
            isDaytime: isDaytime,
            onTap: () => onMemberTap(selectedMemberId ?? ''),
          ),
          for (final m in members) ...[
            const SizedBox(width: 6),
            _FilterChip(
              label: m.nickname,
              color: colorFromHex(m.character.colorHex,
                  fallback: DottieColors.primary),
              active: selectedMemberId == m.userId,
              isDaytime: isDaytime,
              onTap: () => onMemberTap(m.userId),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
    required this.isDaytime,
  });

  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;
  final bool isDaytime;

  @override
  Widget build(BuildContext context) {
    final inactiveBg = isDaytime
        ? const Color(0xCC1C1C1E)
        : DottieColors.surfaceFloating;
    final inactiveBorder = isDaytime
        ? Colors.white.withAlpha(20)
        : DottieColors.borderGlass;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: active ? color.withAlpha(180) : inactiveBg,
              border: Border.all(
                color: active ? color : inactiveBorder,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color:
                        active ? Colors.white : Colors.white.withAlpha(200),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 빈 데이터 ─────────────────────────────────────────

class _CumulativeEmpty extends StatelessWidget {
  const _CumulativeEmpty({required this.onCalendar});
  final VoidCallback onCalendar;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Container(
          color: Colors.black.withAlpha(160),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🗺️', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              const Text(
                '아직 누적된 dot 이 없어요',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                '날짜를 골라 dot 을 공유해보세요',
                style: TextStyle(
                    color: Colors.white.withAlpha(180), fontSize: 13),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onCalendar,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: DottieColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '캘린더 열기',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
