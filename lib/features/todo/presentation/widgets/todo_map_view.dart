import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/media_thumbnail_loader.dart';
import '../../../../shared/utils/error_messages.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../cumulative_map/presentation/user_cumulative_provider.dart';
import '../../../recording/domain/dot_model.dart';
import '../../data/route_remote_source.dart';
import '../../domain/todo_item_model.dart';
import '../../domain/todo_list_model.dart';
import '../todo_provider.dart';
import '_category_util.dart';
import '_day_palette.dart';
import 'todo_item_detail_sheet.dart';

/// 갈곳 컬렉션 지도.
///
/// filterDayIndex: -1 = 전체, ≥0 = 해당 일자만 핀 + 라인 표시.
/// showFootprint: 내 발자취(본인 누적 dot) 반투명 레이어.
class TodoMapView extends ConsumerStatefulWidget {
  const TodoMapView({
    super.key,
    required this.todoListId,
    this.filterDayIndex = -1,
  });
  final String todoListId;
  final int filterDayIndex;

  @override
  ConsumerState<TodoMapView> createState() => _TodoMapViewState();
}

class _TodoMapViewState extends ConsumerState<TodoMapView> {
  mapbox.MapboxMap? _map;
  bool _styleLoaded = false;
  bool _layersAdded = false;
  bool _showFootprint = false;
  static const double _hitRadius = 22.0;

  // 레이어 ID
  static const _srcId = 'todo-items-source';
  static const _trailSrcId = 'todo-trail-source';
  static const _trailLayerId = 'todo-trail-layer';
  // 단일 day 뷰 전용 그라디언트 라인 (line-progress 기반이라 소스에
  // lineMetrics 필요 + 레이어 전역 속성이라 day 별 색상과 양립 불가 →
  // 별도 소스/레이어로 분리해 단일 day 일 때만 표시).
  static const _trailGradSrcId = 'todo-trail-grad-source';
  static const _trailGradLayerId = 'todo-trail-grad-layer';
  static const _itemsBaseId = 'todo-items-base';
  static const _itemsOrderId = 'todo-items-order';
  // 모음 전용 — 카테고리 이모지 아이콘 레이어
  static const _itemsCatId = 'todo-items-cat';
  static const _itemsPhotoId = 'todo-items-photo';
  static const _photoDefaultImg = 'todo-photo-default';
  static const _clusterCircleId = 'todo-cluster-circle';
  static const _clusterCountId = 'todo-cluster-count';
  // 발자취 레이어
  static const _footSrcId = 'todo-footprint-source';
  static const _footLayerId = 'todo-footprint-layer';

  final Map<String, String> _photoIconIds = {};

  /// day 별 도로 경로 캐시 — provider 도착분. null 이면 직선 폴백.
  Map<int, DayRoute?> _dayRoutes = {};

  /// 마지막 _buildTrailGeoJson 결과 메타 — 그라디언트 적용 판단용.
  int _trailFeatureCount = 0;
  String? _lastTrailColor;

  // day 색상은 공유 팔레트(_day_palette.dart) — 라인/핀/리스트 헤더/칩 일관.

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
        setState(() {
          _isDaytime = day;
          _styleLoaded = false;
          _layersAdded = false;
          _photoIconIds.clear(); // 스타일 리로드 시 등록 이미지 초기화
          _catIconsRegistered = false;
        });
        _map?.loadStyleURI(
          day ? mapbox.MapboxStyles.MAPBOX_STREETS : mapbox.MapboxStyles.DARK,
        );
      }
    });
  }

  @override
  void dispose() {
    _modeTimer?.cancel();
    _map = null;
    super.dispose();
  }

  @override
  void didUpdateWidget(TodoMapView old) {
    super.didUpdateWidget(old);
    // 코스 전환 (예: 초대 참여 → 같은 라우트에서 다른 id) — MapWidget 이
    // ValueKey 로 재생성돼 새 스타일이 뜨므로 이전 코스의 캐시/플래그를
    // 전부 리셋. 안 하면 stale _photoIconIds 가 존재하지 않는 이미지를
    // 참조해 핀이 아예 안 보이는 버그가 남.
    if (old.todoListId != widget.todoListId) {
      _map = null;
      _styleLoaded = false;
      _layersAdded = false;
      _photoIconIds.clear();
      _catIconsRegistered = false;
      _dayRoutes = {};
      _trailFeatureCount = 0;
      _lastTrailColor = null;
      return;
    }
    // 일자 필터 변경 시 레이어 데이터 갱신.
    if (old.filterDayIndex != widget.filterDayIndex && _layersAdded) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _trySetupLayers());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<TodoList?>>(
      todoListByIdProvider(widget.todoListId),
      (prev, next) {
        final list = next.valueOrNull;
        if (list != null) _trySetupLayers();
      },
    );
    ref.listen<AsyncValue<List<Dot>>>(
      userCumulativeDotsProvider,
      (_, __) {
        _loadPhotoThumbnails();
        if (_showFootprint) _updateFootprintLayer();
      },
    );
    // 상세 시트 "지도" 버튼 — 지도가 이미 떠 있는 상태에서 요청되면 즉시 이동.
    // (리스트 뷰에서 전환된 경우엔 onStyleLoadedListener 가 처리)
    ref.listen<TodoItem?>(todoMapFocusProvider, (_, item) {
      if (item != null) _tryFocusRequested();
    });

    final async = ref.watch(todoListByIdProvider(widget.todoListId));
    // ignore: unused_local_variable
    final _ = ref.watch(userCumulativeDotsProvider);

    // day 별 도로 경로 watch — 도착/갱신 시 트레일 라인 소스 교체.
    // 모음(collection)은 선/순서 없음 — watch 자체를 skip.
    final listForRoutes = async.valueOrNull;
    if (listForRoutes != null && listForRoutes.isTrip) {
      final days = listForRoutes.items.map((i) => i.dayIndex).toSet();
      final newRoutes = <int, DayRoute?>{
        for (final d in days)
          d: ref
              .watch(todoDayRouteProvider(widget.todoListId, d))
              .valueOrNull,
      };
      var changed = newRoutes.length != _dayRoutes.length;
      if (!changed) {
        for (final e in newRoutes.entries) {
          if (!identical(_dayRoutes[e.key], e.value)) {
            changed = true;
            break;
          }
        }
      }
      if (changed) {
        _dayRoutes = newRoutes;
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _updateTrailSource());
      }
    }

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(
        message: userMessageFor(e),
        onRetry: () =>
            ref.invalidate(todoListByIdProvider(widget.todoListId)),
      ),
      data: (list) {
        if (list == null) {
          return const Center(child: Text('이 코스를 찾을 수 없어요'));
        }
        return Stack(
          children: [
            mapbox.MapWidget(
              key: ValueKey('todo-map-${widget.todoListId}'),
              styleUri: _isDaytime
                  ? mapbox.MapboxStyles.MAPBOX_STREETS
                  : mapbox.MapboxStyles.DARK,
              cameraOptions: _initialCamera(list),
              onMapCreated: (map) => _map = map,
              onStyleLoadedListener: (_) async {
                _styleLoaded = true;
                _layersAdded = false;
                // 새 스타일엔 등록된 이미지가 없음 — 캐시 리셋해 재등록 유도.
                // (스타일 리로드·플랫폼 뷰 재생성 모두 이 콜백을 지나감)
                _photoIconIds.clear();
                _catIconsRegistered = false;
                await _map?.style.localizeLabels('ko', null);
                await _trySetupLayers();
                _tryFocusRequested();
              },
              onTapListener: (ctx) => _handleTap(ctx.touchPosition),
            ),
            // 발자취 토글 버튼 (우하단 FAB 위)
            Positioned(
              right: 16,
              bottom: 96,
              child: _FootprintToggle(
                active: _showFootprint,
                onToggle: () {
                  setState(() => _showFootprint = !_showFootprint);
                  _updateFootprintLayer();
                },
              ),
            ),
            if (list.items.isEmpty)
              const Positioned(
                left: 16,
                right: 16,
                bottom: 24,
                child: _EmptyHint(),
              ),
          ],
        );
      },
    );
  }

  /// 상세 시트에서 요청된 스팟으로 카메라 이동 후 요청 clear.
  void _tryFocusRequested() {
    final item = ref.read(todoMapFocusProvider);
    if (item == null || _map == null || !_styleLoaded || !mounted) return;
    ref.read(todoMapFocusProvider.notifier).clear();
    _map!.easeTo(
      mapbox.CameraOptions(
        center: mapbox.Point(
          coordinates: mapbox.Position(item.longitude, item.latitude),
        ),
        zoom: 16.0,
      ),
      mapbox.MapAnimationOptions(duration: 800),
    );
  }

  mapbox.CameraOptions _initialCamera(TodoList list) {
    final visible = _filteredItems(list);
    if (visible.isNotEmpty) {
      // 여행: 첫 스팟(Day 1 시작 지점) / 모음: 마지막 스팟(가장 최신 등록)
      final target = list.isTrip ? visible.first : visible.last;
      return mapbox.CameraOptions(
        center: mapbox.Point(
          coordinates: mapbox.Position(target.longitude, target.latitude),
        ),
        zoom: list.isTrip ? 11.0 : 15.0,
      );
    }
    return mapbox.CameraOptions(
      center: mapbox.Point(coordinates: mapbox.Position(126.9780, 37.5665)),
      zoom: 10.0,
    );
  }

  List<TodoItem> _filteredItems(TodoList list) {
    if (widget.filterDayIndex < 0) return list.items;
    return list.items
        .where((i) => i.dayIndex == widget.filterDayIndex)
        .toList();
  }

  Future<void> _trySetupLayers() async {
    if (!_styleLoaded || _map == null) return;
    final list = ref.read(todoListByIdProvider(widget.todoListId)).valueOrNull;
    if (list == null) return;

    if (_layersAdded) {
      final items = _filteredItems(list);
      await _map!.style
          .setStyleSourceProperty(_srcId, 'data', _buildItemsGeoJson(items));
      await _applyTrail(items);
    } else {
      _layersAdded = true;
      await _addLayers(list);
    }
  }

  Future<void> _addLayers(TodoList list) async {
    final map = _map!;
    final items = _filteredItems(list);

    // 사진 placeholder
    try {
      await map.style.addStyleImage(
        _photoDefaultImg,
        2.0,
        mapbox.MbxImage(
          width: 1,
          height: 1,
          data: Uint8List.fromList(const [0, 0, 0, 0]),
        ),
        false, [], [], null,
      );
    } catch (_) {}

    // 발자취 소스 (빈 상태로 먼저 생성)
    try {
      await map.style.addSource(mapbox.GeoJsonSource(
        id: _footSrcId,
        data: jsonEncode({'type': 'FeatureCollection', 'features': []}),
      ));
      await map.style.addLayer(mapbox.CircleLayer(
        id: _footLayerId,
        sourceId: _footSrcId,
        circleRadius: 5.0,
        circleColor: DottieColors.primary.withAlpha(100).toARGB32(),
        circleStrokeWidth: 1.0,
        circleStrokeColor: Colors.white.withAlpha(180).toARGB32(),
        circleOpacity: _showFootprint ? 0.7 : 0.0,
      ));
    } catch (_) {}

    // 일자별 연결선 source + layer — 도로 경로 도착 시 라인이 도로를 따라감.
    await map.style.addSource(mapbox.GeoJsonSource(
      id: _trailSrcId,
      data: _buildTrailGeoJson(items),
    ));
    await map.style.addLayer(mapbox.LineLayer(
      id: _trailLayerId,
      sourceId: _trailSrcId,
      lineColor: DottieColors.primary.withAlpha(200).toARGB32(),
      lineWidth: 3.2,
      lineOpacity: 0.85,
      lineCap: mapbox.LineCap.ROUND,
      lineJoin: mapbox.LineJoin.ROUND,
    ));
    // day 별 색상 — feature.properties.color 를 data-driven 으로 적용.
    try {
      await map.style.setStyleLayerProperty(
          _trailLayerId, 'line-color', '["get", "color"]');
    } catch (_) {}

    // 그라디언트 라인 (단일 day 뷰) — 시작점은 옅게, 끝점은 진하게.
    try {
      await map.style.addSource(mapbox.GeoJsonSource(
        id: _trailGradSrcId,
        data: jsonEncode({'type': 'FeatureCollection', 'features': []}),
        lineMetrics: true, // line-progress 계산에 필수
      ));
      await map.style.addLayer(mapbox.LineLayer(
        id: _trailGradLayerId,
        sourceId: _trailGradSrcId,
        lineWidth: 3.6,
        lineOpacity: 0.95,
        lineCap: mapbox.LineCap.ROUND,
        lineJoin: mapbox.LineJoin.ROUND,
        visibility: mapbox.Visibility.NONE,
      ));
    } catch (_) {}
    await _applyTrail(items);

    // 클러스터 source
    await map.style.addSource(mapbox.GeoJsonSource(
      id: _srcId,
      data: _buildItemsGeoJson(items),
      cluster: true,
      clusterMaxZoom: 13,
      clusterRadius: 50,
      clusterProperties: {
        'checked_in_count': [
          '+',
          ['case', ['==', ['get', 'checked_in'], true], 1, 0],
        ],
      },
    ));

    // 개별 핀 (사진 없는 경우) — 룸 스타일: 솔리드 컬러 원 + 흰 테두리
    await map.style.addLayer(mapbox.CircleLayer(
      id: _itemsBaseId,
      sourceId: _srcId,
      filter: [
        "all",
        ["!", ["has", "point_count"]],
        ["==", ["get", "has_photo"], false],
      ],
      circleRadius: 11.0,
      circleColor: DottieColors.primary.toARGB32(),
      circleStrokeWidth: 2.5,
      circleStrokeColor: Colors.white.withAlpha(220).toARGB32(),
    ));
    if (list.isTrip) {
      // 여행: 핀 색 = day 색 (트레일 라인과 동일 팔레트) — 일정별 구분이
      // 지도에서 즉시 읽힘. 다녀온 스팟은 투명도로 표현 (day 정체성 유지).
      await map.style.setStyleLayerProperty(
        _itemsBaseId,
        'circle-color',
        jsonEncode([
          'match',
          ['%', ['get', 'day_index'], kDayColorHexes.length],
          for (var i = 0; i < kDayColorHexes.length; i++) ...[
            i,
            kDayColorHexes[i],
          ],
          kDayColorHexes[0], // fallback
        ]),
      );
      await map.style.setStyleLayerProperty(
        _itemsBaseId,
        'circle-opacity',
        jsonEncode([
          'case',
          ['==', ['get', 'checked_in'], true], 0.45,
          1.0,
        ]),
      );
    } else {
      // 모음: 카테고리별 색상 원 + 이모지 아이콘 — 저장한 장소의 성격이 한눈에.
      await map.style.setStyleLayerProperty(
          _itemsBaseId, 'circle-color', '["get", "cat_color"]');
      await map.style
          .setStyleLayerProperty(_itemsBaseId, 'circle-radius', 13.0);
      await _registerCategoryIcons(map);
      await map.style.addLayer(mapbox.SymbolLayer(
        id: _itemsCatId,
        sourceId: _srcId,
        filter: [
          "all",
          ["!", ["has", "point_count"]],
          ["==", ["get", "has_photo"], false],
        ],
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
        iconSize: 0.9,
      ));
      await map.style.setStyleLayerProperty(
          _itemsCatId, 'icon-image', '["get", "cat_icon"]');
    }

    // 체크인 ✓ / 순서 번호 라벨 — 항상 흰색.
    // 모음(collection)은 순서 개념이 없어 라벨 자체를 숨김 (핀 원형만 표시).
    await map.style.addLayer(mapbox.SymbolLayer(
      id: _itemsOrderId,
      sourceId: _srcId,
      filter: [
        "all",
        ["!", ["has", "point_count"]],
        ["==", ["get", "has_photo"], false],
      ],
      textColor: Colors.white.toARGB32(),
      textSize: 11.0,
      textAllowOverlap: true,
      textIgnorePlacement: true,
      visibility:
          list.isTrip ? mapbox.Visibility.VISIBLE : mapbox.Visibility.NONE,
    ));
    await map.style.setStyleLayerProperty(
      _itemsOrderId,
      'text-field',
      jsonEncode([
        'case',
        ['==', ['get', 'checked_in'], true], '✓',
        ['to-string', ['get', 'order']],
      ]),
    );

    // 사진 핀
    await map.style.addLayer(mapbox.SymbolLayer(
      id: _itemsPhotoId,
      sourceId: _srcId,
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

    // 클러스터 원
    await map.style.addLayer(mapbox.CircleLayer(
      id: _clusterCircleId,
      sourceId: _srcId,
      filter: ["has", "point_count"],
      circleColor: DottieColors.primary.toARGB32(),
      circleStrokeColor: Colors.white.withAlpha(220).toARGB32(),
      circleStrokeWidth: 3.0,
    ));
    await map.style.setStyleLayerProperty(
      _clusterCircleId,
      'circle-radius',
      jsonEncode([
        'step', ['get', 'point_count'],
        18, 5, 22, 20, 26,
      ]),
    );

    await map.style.addLayer(mapbox.SymbolLayer(
      id: _clusterCountId,
      sourceId: _srcId,
      filter: ["has", "point_count"],
      textColor: Colors.white.toARGB32(),
      textSize: 13.0,
      textAllowOverlap: true,
      textIgnorePlacement: true,
    ));
    await map.style.setStyleLayerProperty(
      _clusterCountId,
      'text-field',
      '["to-string", ["get", "point_count_abbreviated"]]',
    );

    // 발자취 갱신
    if (_showFootprint) await _updateFootprintLayer();

    // 사진 핀 등록 — 데이터가 스타일보다 먼저 도착한 경우 첫 진입에도 표시
    await _loadPhotoThumbnails();
  }

  /// 도로 경로 도착/갱신 시 트레일 소스만 교체 (레이어 재생성 없음).
  Future<void> _updateTrailSource() async {
    if (_map == null || !_styleLoaded || !_layersAdded || !mounted) return;
    final list =
        ref.read(todoListByIdProvider(widget.todoListId)).valueOrNull;
    if (list == null) return;
    await _applyTrail(_filteredItems(list));
  }

  /// 트레일 데이터 적용 + 그라디언트/플랫 레이어 전환.
  ///
  /// day 가 1개만 보이면 line-progress 그라디언트 — 시작 옅음 → 끝 진함으로
  /// "시간의 흐름" 표현. 여러 day 동시 표시는 line-gradient 가 레이어 전역
  /// 속성이라 불가 → day 별 플랫 색상 유지.
  ///
  /// 모음(collection)은 저장용이라 순서·연결선 개념이 없음 — 두 레이어 모두 숨김.
  Future<void> _applyTrail(List<TodoItem> items) async {
    final map = _map;
    if (map == null) return;
    final isTrip = ref
            .read(todoListByIdProvider(widget.todoListId))
            .valueOrNull
            ?.isTrip ??
        true;
    if (!isTrip) {
      try {
        await map.style
            .setStyleLayerProperty(_trailLayerId, 'visibility', 'none');
        await map.style
            .setStyleLayerProperty(_trailGradLayerId, 'visibility', 'none');
      } catch (_) {}
      return;
    }
    final geoJson = _buildTrailGeoJson(items);
    final featureCount = _trailFeatureCount;
    try {
      await map.style.setStyleSourceProperty(_trailSrcId, 'data', geoJson);
      final single = featureCount == 1;
      if (single) {
        await map.style
            .setStyleSourceProperty(_trailGradSrcId, 'data', geoJson);
        final color = _lastTrailColor ?? kDayColorHexes[0];
        await map.style.setStyleLayerProperty(
          _trailGradLayerId,
          'line-gradient',
          jsonEncode([
            'interpolate',
            ['linear'],
            ['line-progress'],
            0, _lightenHex(color, 0.55),
            1, color,
          ]),
        );
      }
      await map.style.setStyleLayerProperty(
          _trailGradLayerId, 'visibility', single ? 'visible' : 'none');
      await map.style.setStyleLayerProperty(
          _trailLayerId, 'visibility', single ? 'none' : 'visible');
    } catch (_) {}
  }

  /// hex(#RRGGBB) 를 흰색과 t 비율로 혼합 — 그라디언트 시작색.
  static String _lightenHex(String hex, double t) {
    final v = int.parse(hex.substring(1), radix: 16);
    int mix(int c) => (c + ((255 - c) * t)).round().clamp(0, 255);
    final r = mix((v >> 16) & 0xff);
    final g = mix((v >> 8) & 0xff);
    final b = mix(v & 0xff);
    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  /// 모음 핀용 카테고리 이모지 아이콘 등록 (스타일 로드마다 1회).
  ///
  /// Mapbox 의 text-field 는 이모지 글리프를 렌더하지 못하므로
  /// (SDF 폰트 한계 — tofu 로 표시됨) 이모지를 PNG 로 그려 스타일 이미지로
  /// 등록하고 data-driven icon-image 로 사용한다.
  bool _catIconsRegistered = false;

  Future<void> _registerCategoryIcons(mapbox.MapboxMap map) async {
    if (_catIconsRegistered) return;
    _catIconsRegistered = true;
    const px = 44; // @2x — 논리 22px
    for (final style in kCategoryStyles) {
      try {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        final tp = TextPainter(
          text: TextSpan(
            text: style.emoji,
            style: const TextStyle(fontSize: px * 0.72),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
          canvas,
          Offset((px - tp.width) / 2, (px - tp.height) / 2),
        );
        final img = await recorder.endRecording().toImage(px, px);
        // rawRgba 금지 — Mapbox Android 가 PNG/JPEG 만 디코드 가능 (CLAUDE.md)
        final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
        if (bytes == null) continue;
        await map.style.addStyleImage(
          'todo-cat-${style.key}',
          2.0,
          mapbox.MbxImage(
            width: px,
            height: px,
            data: bytes.buffer.asUint8List(),
          ),
          false, [], [], null,
        );
      } catch (e) {
        debugPrint('[TodoMap] cat icon ${style.key} register failed: $e');
      }
    }
  }

  /// 일자별 정렬된 아이템 → day 별 연결선 GeoJSON.
  /// 해당 day 의 도로 경로(_dayRoutes)가 있으면 그 geometry 를, 없으면
  /// 스팟 좌표를 직선으로 잇는 폴백을 사용한다.
  String _buildTrailGeoJson(List<TodoItem> items) {
    final byDay = <int, List<TodoItem>>{};
    for (final item in items) {
      (byDay[item.dayIndex] ??= []).add(item);
    }
    for (final v in byDay.values) {
      v.sort((a, b) => a.orderInDay.compareTo(b.orderInDay));
    }
    final features = <Map<String, dynamic>>[];
    for (final entry in byDay.entries) {
      if (entry.value.length < 2) continue;
      final route = _dayRoutes[entry.key];
      final coordinates = route != null && route.coordinates.length >= 2
          ? route.coordinates
          : entry.value.map((i) => [i.longitude, i.latitude]).toList();
      features.add({
        'type': 'Feature',
        'geometry': {
          'type': 'LineString',
          'coordinates': coordinates,
        },
        'properties': {
          'day_index': entry.key,
          'color': dayColorHexOf(entry.key),
        },
      });
    }
    _trailFeatureCount = features.length;
    _lastTrailColor = features.isNotEmpty
        ? features.first['properties']!['color'] as String
        : null;
    return jsonEncode({'type': 'FeatureCollection', 'features': features});
  }

  /// 아이템 → 핀 GeoJSON. day 내 순서 라벨 포함.
  String _buildItemsGeoJson(List<TodoItem> items) {
    final byDay = <int, List<TodoItem>>{};
    for (final item in items) {
      (byDay[item.dayIndex] ??= []).add(item);
    }
    for (final v in byDay.values) {
      v.sort((a, b) => a.orderInDay.compareTo(b.orderInDay));
    }
    final features = <Map<String, dynamic>>[];
    for (final entry in byDay.entries) {
      for (var i = 0; i < entry.value.length; i++) {
        final item = entry.value[i];
        final iconId = _photoIconIds[item.id];
        features.add({
          'type': 'Feature',
          'geometry': {
            'type': 'Point',
            'coordinates': [item.longitude, item.latitude],
          },
          'properties': {
            'item_id': item.id,
            'checked_in': item.isCheckedIn,
            'has_photo': iconId != null,
            'photo_icon_id': iconId ?? _photoDefaultImg,
            'order': i + 1,
            'day_index': entry.key,
            // 모음 핀 스타일 — 카테고리별 색/이모지 (여행 뷰에선 미사용, 무해)
            'cat_color': categoryStyleOf(item.placeCategory).colorHex,
            'cat_icon': 'todo-cat-${categoryStyleOf(item.placeCategory).key}',
          },
        });
      }
    }
    return jsonEncode({'type': 'FeatureCollection', 'features': features});
  }

  Future<void> _loadPhotoThumbnails() async {
    if (_map == null || !_styleLoaded || !mounted || !_layersAdded) return;
    final list =
        ref.read(todoListByIdProvider(widget.todoListId)).valueOrNull;
    final dots = ref.read(userCumulativeDotsProvider).valueOrNull;
    if (list == null || dots == null || dots.isEmpty) return;

    final dotsById = {for (final d in dots) d.id: d};
    final candidates = <MapEntry<TodoItem, Dot>>[];
    for (final item in list.items) {
      if (_photoIconIds.containsKey(item.id)) continue;
      final dotId = item.checkInDotId;
      if (dotId == null) continue;
      final dot = dotsById[dotId];
      if (dot == null || dot.displayThumbUrl == null) continue;
      candidates.add(MapEntry(item, dot));
    }
    if (candidates.isEmpty) return;

    await Future.wait(candidates.map((entry) async {
      final item = entry.key;
      final dot = entry.value;
      final bytes = await MediaThumbnailLoader.loadCircle(
        dot.displayThumbUrl!,
        badgeColor: DottieColors.primary,
      );
      if (bytes == null || !mounted) return;
      final imgId = 'todo-photo-${item.id}';
      try {
        await _map!.style.addStyleImage(
          imgId, 2.0,
          mapbox.MbxImage(
            width: MediaThumbnailLoader.pixelSize,
            height: MediaThumbnailLoader.pixelSize,
            data: bytes,
          ),
          false, [], [], null,
        );
        _photoIconIds[item.id] = imgId;
      } catch (_) {}
    }));

    if (!mounted || _photoIconIds.isEmpty) return;
    final list2 = ref.read(todoListByIdProvider(widget.todoListId)).valueOrNull;
    if (list2 == null) return;
    try {
      await _map!.style.setStyleSourceProperty(
        _srcId, 'data',
        _buildItemsGeoJson(_filteredItems(list2)),
      );
    } catch (e) {
      debugPrint('[TodoMap] photo source refresh error: $e');
    }
  }

  /// 발자취 레이어 업데이트 (본인 누적 dot → 반투명 점).
  Future<void> _updateFootprintLayer() async {
    if (_map == null || !_styleLoaded || !_layersAdded) return;
    if (_showFootprint) {
      final dots = ref.read(userCumulativeDotsProvider).valueOrNull ?? [];
      final features = dots
          .map((d) => {
                'type': 'Feature',
                'geometry': {
                  'type': 'Point',
                  'coordinates': [d.longitude, d.latitude],
                },
                'properties': {},
              })
          .toList();
      try {
        await _map!.style.setStyleSourceProperty(
          _footSrcId,
          'data',
          jsonEncode({'type': 'FeatureCollection', 'features': features}),
        );
        await _map!.style
            .setStyleLayerProperty(_footLayerId, 'circle-opacity', 0.7);
      } catch (_) {}
    } else {
      try {
        await _map!.style
            .setStyleLayerProperty(_footLayerId, 'circle-opacity', 0.0);
      } catch (_) {}
    }
  }

  // ── 인터랙션 ──────────────────────────────────────

  Future<void> _handleTap(mapbox.ScreenCoordinate sc) async {
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
          layerIds: [_itemsBaseId, _itemsPhotoId, _clusterCircleId],
          filter: null,
        ),
      );
      if (features.isEmpty || !mounted) return;

      for (final f in features) {
        if (f == null) continue;
        final props = f.queriedFeature.feature['properties'] as Map?;
        if (props != null && props['point_count'] != null) {
          final geoPoint = await _map!.coordinateForPixel(sc);
          final camState = await _map!.getCameraState();
          await _map!.easeTo(
            mapbox.CameraOptions(center: geoPoint, zoom: camState.zoom + 2),
            mapbox.MapAnimationOptions(duration: 400),
          );
          return;
        }
      }

      String? itemId;
      for (final f in features) {
        if (f == null) continue;
        final props = f.queriedFeature.feature['properties'] as Map?;
        itemId = props?['item_id'] as String?;
        if (itemId != null) break;
      }
      if (itemId == null || !mounted) return;

      final list =
          ref.read(todoListByIdProvider(widget.todoListId)).valueOrNull;
      if (list == null) return;
      final item = list.items.where((e) => e.id == itemId).firstOrNull;
      if (item == null) return; // stale 탭 — 아이템이 이미 삭제됨
      await TodoItemDetailSheet.show(context, todoList: list, item: item);
    } catch (e) {
      debugPrint('[TodoMap] tap error: $e');
    }
  }
}

class _FootprintToggle extends StatelessWidget {
  const _FootprintToggle({required this.active, required this.onToggle});
  final bool active;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? DottieColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timeline_rounded,
              size: 16,
              color: active ? Colors.white : DottieColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              '내 발자취',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : DottieColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Icon(Icons.touch_app_outlined,
              size: 18, color: DottieColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '오른쪽 아래 + 버튼으로 스팟을 추가해 보세요',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: DottieColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
