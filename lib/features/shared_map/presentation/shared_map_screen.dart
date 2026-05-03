import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/map_marker_renderer.dart';
import '../../../../core/utils/media_thumbnail_loader.dart';
import '../../../../shared/widgets/dot_detail_sheet.dart';
import '../../map_animation/domain/animation_frame.dart';
import '../../recording/domain/dot_model.dart';
import '../../map_animation/presentation/animation_provider.dart'
    show PlaySpeed, PlaySpeedExt;
import '../../character/paperdoll/data/paperdoll_image_cache.dart';
import '../../character/paperdoll/domain/paperdoll_config.dart';
import '../../character/paperdoll/presentation/paperdoll_provider.dart';
import '../../room/presentation/room_provider.dart';
import '../data/shared_map_builder.dart';
import '../domain/shared_map_model.dart';
import 'shared_map_provider.dart';

class SharedMapScreen extends ConsumerStatefulWidget {
  const SharedMapScreen({
    super.key,
    required this.roomId,
    required this.date,
    this.focusDotId,
  });
  final String roomId;
  final String date;

  /// 외부 진입(예: 알림 탭) 시 자동으로 DotDetailSheet를 띄울 dot ID.
  final String? focusDotId;

  @override
  ConsumerState<SharedMapScreen> createState() => _SharedMapScreenState();
}

class _SharedMapScreenState extends ConsumerState<SharedMapScreen> {
  mapbox.MapboxMap? _mapboxMap;

  Timer? _updateTimer;
  Timer? _arrowTimer;
  int _arrowIdx = 0;
  bool _styleLoaded = false;
  bool _mapSetupDone = false;
  bool _focusedDotShown = false;
  // focusDotId가 현재 날짜에 없을 때 전날로 1회만 재시도 (무한 루프 방지).
  // 정확한 해결은 BE notification 응답에 `dot_date` 추가 필요.
  bool _didDateFallback = false;

  // 멤버별 화살표 layer ID 모음 (memberId → layerId)
  final Map<String, String> _arrowLayerIdByMember = {};

  // 멤버별 캐릭터 layer ID 모음 — viewMode 토글 시 visibility 일괄 변경에 사용
  final List<String> _characterLayerIds = [];

  // 탭 hit-testing 대상 layer ID 모음 (멤버별로 누적)
  final List<String> _hitLayerIds = [];

  static const double _hitRadius = 22;
  static const double _charScale = 2.0;

  // 멤버별 레이어/이미지 ID 헬퍼
  String _memberSrcId(String memberId) => 'sm-dots-source-$memberId';
  String _memberClusterCircleId(String memberId) => 'sm-cluster-circle-$memberId';
  String _memberClusterCountId(String memberId) => 'sm-cluster-count-$memberId';
  String _memberDotsCircleId(String memberId) => 'sm-dots-circle-$memberId';
  String _memberOrderTextId(String memberId) => 'sm-dots-order-text-$memberId';
  String _memberPhotoLayerId(String memberId) => 'sm-dots-photo-$memberId';
  String _memberStartLayerId(String memberId) => 'sm-dot-start-$memberId';
  String _memberEndLayerId(String memberId) => 'sm-dot-end-$memberId';
  String _memberDefaultDotImg(String memberId) => 'sm-dot-default-$memberId';
  String _memberStartImg(String memberId) => 'sm-marker-start-$memberId';
  String _memberEndImg(String memberId) => 'sm-marker-end-$memberId';
  String _memberArrowsLayerId(String memberId) =>
      'sm-trail-arrows-$memberId';
  String _memberArrowImg(String memberId, int frame) =>
      'sm-arrow-$memberId-$frame';

  @override
  void dispose() {
    _updateTimer?.cancel();
    _arrowTimer?.cancel();
    super.dispose();
  }

  Future<void> _trySetupMap() async {
    if (_mapSetupDone || !_styleLoaded || _mapboxMap == null) return;
    final smState =
        ref.read(sharedMapNotifierProvider(widget.roomId, widget.date));
    if (smState == null) return;
    if (smState.tracks.isEmpty) return; // dot 시트는 _tryOpenFocusedSheet 가 별도 처리

    _mapSetupDone = true;

    try {
      await _fitCameraToTracks(_mapboxMap!, smState.tracks);
      await _addTrailLayers(_mapboxMap!, smState.tracks);
      await _addClusterDotLayers(_mapboxMap!, smState.tracks);
      await _addCharacterLayers(
          _mapboxMap!, smState.tracks, smState.paperdolls);
      _startUpdateTimer();
      _startArrowMarch();
      debugPrint('[SharedMap] setup done, tracks=${smState.tracks.length}');

      // 사진 썸네일은 백그라운드 로드 (순서 뱃지 합성 + 멤버별 source 갱신)
      unawaited(_loadPhotoThumbnails(_mapboxMap!, smState.tracks));
    } catch (e, st) {
      debugPrint('[SharedMap] setup error: $e\n$st');
    }
  }

  /// 200ms 간격으로 모든 멤버의 화살표 프레임을 시프트해 → → → 가 흘러가는 효과.
  void _startArrowMarch() {
    _arrowTimer?.cancel();
    if (_arrowLayerIdByMember.isEmpty) return;
    _arrowTimer = Timer.periodic(const Duration(milliseconds: 200), (_) async {
      if (_mapboxMap == null || !_styleLoaded) return;
      _arrowIdx = (_arrowIdx + 1) % MapMarkerRenderer.arrowFrameCount;
      for (final entry in _arrowLayerIdByMember.entries) {
        try {
          await _mapboxMap!.style.setStyleLayerProperty(
            entry.value,
            'icon-image',
            _memberArrowImg(entry.key, _arrowIdx),
          );
        } catch (_) {}
      }
    });
  }

  /// 알림에서 진입한 경우 해당 dot 의 상세 시트를 자동 표시.
  ///
  /// **지도 setup 과 독립적**으로 작동 — `_loadTracks` 가 끝나는 즉시 시트 띄움.
  /// (이전 구현은 `_trySetupMap` 끝에서 호출했어서 카메라/레이어 await 5단계 후에야
  /// 시트가 떴고, 그 사이 throw 가 나면 시트 자체가 안 떴음.)
  ///
  /// `fireImmediately` 로 첫 진입 시점에도 호출되며, `_focusedDotShown` 으로 중복 방지.
  void _tryOpenFocusedSheet() {
    final dotId = widget.focusDotId;
    if (dotId == null || _focusedDotShown || !mounted) return;
    final smState =
        ref.read(sharedMapNotifierProvider(widget.roomId, widget.date));
    if (smState == null) return; // 데이터 로딩 중 — listen 이 다시 호출

    for (final track in smState.tracks) {
      for (final frame in track.sequence.frames) {
        if (frame.dot.id != dotId) continue;
        _focusedDotShown = true;

        final memberHints = smState.tracks
            .map((t) => DotMemberHint(
                  userId: t.memberId,
                  nickname: t.nickname,
                  color: characterColorMap[t.colorKey],
                ))
            .toList();

        // 다음 프레임에 시트 — build 진행 중 호출 가능성 회피
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          DotDetailSheet.show(
            context,
            frame.dot,
            memberName: track.nickname,
            memberColor: characterColorMap[track.colorKey],
            roomId: widget.roomId,
            members: memberHints,
          );
        });
        return;
      }
    }

    // 데이터는 로드됐지만 dot 이 이 날짜에 없음 → 전날로 1회 fallback
    debugPrint(
        '[SharedMap] focusDotId=$dotId not in ${widget.date} tracks');
    _tryDateFallback();
  }

  /// 전날 날짜로 같은 화면을 pushReplacement.
  /// 한 번만 시도(`_didDateFallback`)해 무한 루프 방지.
  /// 정확한 해결: BE notification 응답에 `dot_date` 필드 추가.
  void _tryDateFallback() {
    if (_didDateFallback) return;
    _didDateFallback = true;

    final current = DateTime.tryParse(widget.date);
    if (current == null) return;
    final prev = current.subtract(const Duration(days: 1));
    final prevStr =
        '${prev.year}-${prev.month.toString().padLeft(2, '0')}-${prev.day.toString().padLeft(2, '0')}';
    debugPrint('[SharedMap] date fallback: ${widget.date} → $prevStr');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.pushReplacement(
        '/rooms/${widget.roomId}/map',
        extra: {'date': prevStr, 'dotId': widget.focusDotId},
      );
    });
  }

  // 멤버별 이미지 키: 'char-{memberId}' (expression 없이 literal ID 사용)
  String _charImageKey(String memberId) => 'char-img-$memberId';

  Future<void> _addCharacterLayers(
    mapbox.MapboxMap map,
    List<MemberTrack> tracks,
    Map<String, PaperdollConfig> paperdolls,
  ) async {
    _characterLayerIds.clear();
    final renderer = ref.read(paperdollRendererProvider);
    // 32px frame × 3.75 ≈ 120px (기존 _charRenderSize와 동등)
    const renderScale = 3.75;
    // explore 모드 진입이 기본값 — 캐릭터는 setup 직후 숨겨두고
    // viewMode == playback 으로 전환될 때 visibility를 켠다.
    final initialMode = ref.read(
        sharedMapNotifierProvider(widget.roomId, widget.date))?.viewMode ??
        SharedMapViewMode.explore;
    for (final track in tracks) {
      final imgKey = _charImageKey(track.memberId);
      debugPrint('[SharedMap] registering image key=$imgKey');

      // BE v2 응답의 멤버별 character_config 사용 (없으면 default).
      final config =
          paperdolls[track.memberId] ?? PaperdollConfig.defaults;
      final image = await renderer.renderFrame(
        config: config,
        frameIndex: 2, // idle frame
        scale: renderScale,
      );
      final bytes = await imageToPngBytes(image);

      await map.style.addStyleImage(
        imgKey, _charScale,
        mapbox.MbxImage(
          width: image.width,
          height: image.height,
          data: bytes,
        ),
        false, [], [], null,
      );
      debugPrint('[SharedMap] addStyleImage OK: $imgKey');

      final first = track.sequence.frames.first;
      final sourceId = 'char-source-${track.memberId}';
      final layerId  = 'char-layer-${track.memberId}';

      await map.style.addSource(mapbox.GeoJsonSource(
        id: sourceId,
        data: jsonEncode(_posFeature(first.dot.latitude, first.dot.longitude)),
      ));
      debugPrint('[SharedMap] addSource OK: $sourceId');

      await map.style.addLayer(mapbox.SymbolLayer(
        id: layerId,
        sourceId: sourceId,
        iconImage: imgKey,
        iconSize: 1.0,
        iconAnchor: mapbox.IconAnchor.BOTTOM,
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
      ));
      _characterLayerIds.add(layerId);
      if (initialMode == SharedMapViewMode.explore) {
        await map.style.setStyleLayerProperty(layerId, 'visibility', 'none');
      }
      debugPrint(
          '[SharedMap] addLayer OK: $layerId at ${first.dot.latitude},${first.dot.longitude}');
    }
  }

  /// 상단 바 날짜 영역 탭 → 다크 캘린더 시트.
  /// 같은 날짜를 다시 선택하면 무동작. 다른 날짜면 같은 라우트를 pushReplacement.
  Future<void> _showCalendarSheet() async {
    final selected = await _DateCalendarSheet.show(
      context,
      roomId: widget.roomId,
      selectedDate:
          DateTime.tryParse(widget.date) ?? DottieDateUtils.todayStart(),
    );
    if (selected == null || !mounted) return;
    final newDate = DottieDateUtils.toDateString(selected);
    if (newDate == widget.date) return;
    context.pushReplacement(
      '/rooms/${widget.roomId}/map',
      extra: {'date': newDate},
    );
  }

  /// 캐릭터 layer 들의 visibility를 일괄 토글.
  /// viewMode 변화에 따라 _SharedMapScreenState.build 의 ref.listen 에서 호출.
  Future<void> _setCharactersVisible(bool visible) async {
    if (_mapboxMap == null || !_styleLoaded) return;
    final value = visible ? 'visible' : 'none';
    for (final id in _characterLayerIds) {
      try {
        await _mapboxMap!.style.setStyleLayerProperty(id, 'visibility', value);
      } catch (_) {}
    }
  }

  // GeoJSON feature — properties 불필요 (icon을 literal로 지정)
  Map<String, dynamic> _posFeature(double lat, double lng) => {
    'type': 'Feature',
    'geometry': {
      'type': 'Point',
      'coordinates': [lng, lat],
    },
    'properties': {},
  };

  // ── 멤버별 클러스터 dot 레이어 ─────────────────────────

  /// timestamp 오름차순 정렬된 frame list. 멤버별 이동 순서 = order.
  List<AnimationFrame> _sortedFrames(MemberTrack track) {
    final frames = [...track.sequence.frames];
    frames.sort((a, b) => a.dot.timestamp.compareTo(b.dot.timestamp));
    return frames;
  }

  Map<String, dynamic> _dotFeature(
    Dot dot,
    MemberTrack track, {
    required int order,
    required int total,
    required String defaultIconId,
    String? photoIconId,
  }) {
    final color = characterColorMap[track.colorKey] ?? DottieColors.primary;
    final colorHex =
        '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    return {
      'type': 'Feature',
      'geometry': {
        'type': 'Point',
        'coordinates': [dot.longitude, dot.latitude],
      },
      'properties': {
        'dot_id': dot.id,
        'member_id': track.memberId,
        'nickname': track.nickname,
        'color_hex': colorHex,
        'order': order,
        'is_first': order == 0,
        'is_last': order == total - 1,
        'has_photo': dot.photoUrl != null && dot.photoUrl!.isNotEmpty,
        'photo_icon_id': photoIconId ?? defaultIconId,
        'photo_url': dot.photoUrl ?? '',
        'place_name': dot.placeName ?? '',
        'timestamp': dot.timestamp.toIso8601String(),
        'memo': dot.memo ?? '',
        'emotion': dot.emotion ?? '',
      },
    };
  }

  /// 한 멤버의 dots를 정렬해 GeoJSON FeatureCollection으로 직렬화.
  String _buildMemberGeoJson(
    MemberTrack track, {
    Map<String, String>? photoIconIds,
  }) {
    final frames = _sortedFrames(track);
    final defaultIconId = _memberDefaultDotImg(track.memberId);
    final features = <Map<String, dynamic>>[];
    for (var i = 0; i < frames.length; i++) {
      final dot = frames[i].dot;
      features.add(_dotFeature(
        dot,
        track,
        order: i,
        total: frames.length,
        defaultIconId: defaultIconId,
        photoIconId: photoIconIds?[dot.id],
      ));
    }
    return jsonEncode({'type': 'FeatureCollection', 'features': features});
  }

  Future<void> _addClusterDotLayers(
      mapbox.MapboxMap map, List<MemberTrack> tracks) async {
    _hitLayerIds.clear();

    // 멤버별 placeholder + 출발/도착 마커 PNG 등록
    for (final track in tracks) {
      final color =
          characterColorMap[track.colorKey] ?? DottieColors.primary;
      await _registerMemberDefaultDot(map, track.memberId, color);
      await _registerMemberStartEndMarkers(map, track.memberId, color);
    }

    // 멤버별 source + 6개 레이어 추가
    for (final track in tracks) {
      await _addMemberLayers(map, track);
    }
  }

  Future<void> _addMemberLayers(
      mapbox.MapboxMap map, MemberTrack track) async {
    final memberId = track.memberId;
    final color =
        characterColorMap[track.colorKey] ?? DottieColors.primary;
    final srcId = _memberSrcId(memberId);
    final clusterCircleId = _memberClusterCircleId(memberId);
    final clusterCountId = _memberClusterCountId(memberId);
    final dotsCircleId = _memberDotsCircleId(memberId);
    final orderTextId = _memberOrderTextId(memberId);
    final photoLayerId = _memberPhotoLayerId(memberId);
    final startLayerId = _memberStartLayerId(memberId);
    final endLayerId = _memberEndLayerId(memberId);

    // 멤버별 cluster source
    await map.style.addSource(mapbox.GeoJsonSource(
      id: srcId,
      data: _buildMemberGeoJson(track),
      cluster: true,
      clusterMaxZoom: 14,
      clusterRadius: 50,
    ));

    // 클러스터 원 (멤버 색)
    await map.style.addLayer(mapbox.CircleLayer(
      id: clusterCircleId,
      sourceId: srcId,
      filter: ["has", "point_count"],
      circleRadius: 20.0,
      circleColor: color.toARGB32(),
      circleStrokeWidth: 2.0,
      circleStrokeColor: Colors.white.toARGB32(),
    ));

    // 클러스터 개수 텍스트
    await map.style.addLayer(mapbox.SymbolLayer(
      id: clusterCountId,
      sourceId: srcId,
      filter: ["has", "point_count"],
      textColor: Colors.white.toARGB32(),
      textSize: 12.0,
    ));
    await map.style.setStyleLayerProperty(
      clusterCountId, 'text-field',
      '["get", "point_count_abbreviated"]',
    );

    // 개별 dot 원 (멤버 색 + 흰 테두리, 첫/마지막/사진 제외)
    await map.style.addLayer(mapbox.CircleLayer(
      id: dotsCircleId,
      sourceId: srcId,
      filter: [
        "all",
        ["!", ["has", "point_count"]],
        ["==", ["get", "has_photo"], false],
        ["==", ["get", "is_first"], false],
        ["==", ["get", "is_last"], false],
      ],
      circleRadius: 9.0,
      circleColor: color.toARGB32(),
      circleStrokeWidth: 2.0,
      circleStrokeColor: Colors.white.toARGB32(),
    ));

    // 사진 썸네일 (첫/마지막 제외 — 마커 우선)
    await map.style.addLayer(mapbox.SymbolLayer(
      id: photoLayerId,
      sourceId: srcId,
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

    // 순서 번호 (zoom ≥ 14, 첫/마지막/사진 제외)
    await map.style.addLayer(mapbox.SymbolLayer(
      id: orderTextId,
      sourceId: srcId,
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
      orderTextId, 'text-field',
      '["to-string", ["+", ["get", "order"], 1]]',
    );

    // 출발 깃발 (첫 dot)
    await map.style.addLayer(mapbox.SymbolLayer(
      id: startLayerId,
      sourceId: srcId,
      filter: [
        "all",
        ["!", ["has", "point_count"]],
        ["==", ["get", "is_first"], true],
      ],
      iconImage: _memberStartImg(memberId),
      iconSize: 0.7,
      iconAnchor: mapbox.IconAnchor.BOTTOM,
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
    ));

    // 도착 핀 (마지막 dot — 첫=마지막일 땐 핀 우선)
    await map.style.addLayer(mapbox.SymbolLayer(
      id: endLayerId,
      sourceId: srcId,
      filter: [
        "all",
        ["!", ["has", "point_count"]],
        ["==", ["get", "is_last"], true],
        ["==", ["get", "is_first"], false],
      ],
      iconImage: _memberEndImg(memberId),
      iconSize: 0.7,
      iconAnchor: mapbox.IconAnchor.BOTTOM,
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
    ));

    // 탭 hit-testing 대상에 누적
    _hitLayerIds.addAll([
      clusterCircleId,
      dotsCircleId,
      photoLayerId,
      startLayerId,
      endLayerId,
    ]);
  }

  Future<void> _registerMemberDefaultDot(
      mapbox.MapboxMap map, String memberId, Color color) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawCircle(const Offset(10, 10), 8, Paint()..color = color);
    final img = await recorder.endRecording().toImage(20, 20);
    final bd = await img.toByteData(format: ui.ImageByteFormat.png);
    if (bd == null) return;
    await map.style.addStyleImage(
      _memberDefaultDotImg(memberId), 2.0,
      mapbox.MbxImage(width: 20, height: 20, data: bd.buffer.asUint8List()),
      false, [], [], null,
    );
  }

  Future<void> _registerMemberStartEndMarkers(
      mapbox.MapboxMap map, String memberId, Color color) async {
    final start = await MapMarkerRenderer.renderStartFlag(color: color);
    final end = await MapMarkerRenderer.renderEndPin(color: color);
    await map.style.addStyleImage(
      _memberStartImg(memberId), 2.0,
      mapbox.MbxImage(
        width: MapMarkerRenderer.pixelSize,
        height: MapMarkerRenderer.pixelSize,
        data: start,
      ),
      false, [], [], null,
    );
    await map.style.addStyleImage(
      _memberEndImg(memberId), 2.0,
      mapbox.MbxImage(
        width: MapMarkerRenderer.pixelSize,
        height: MapMarkerRenderer.pixelSize,
        data: end,
      ),
      false, [], [], null,
    );
  }

  Future<void> _loadPhotoThumbnails(
      mapbox.MapboxMap map, List<MemberTrack> tracks) async {
    for (final track in tracks) {
      final color =
          characterColorMap[track.colorKey] ?? DottieColors.primary;
      final frames = _sortedFrames(track);

      // 멤버별 dot.id → 1-based order
      final orderById = <String, int>{};
      for (var i = 0; i < frames.length; i++) {
        orderById[frames[i].dot.id] = i + 1;
      }

      final photoFrames = frames
          .where((f) =>
              f.dot.photoUrl != null && f.dot.photoUrl!.isNotEmpty)
          .toList();
      if (photoFrames.isEmpty) continue;

      final photoIconIds = <String, String>{};

      await Future.wait(photoFrames.map((f) async {
        final dot = f.dot;
        final bytes = await MediaThumbnailLoader.loadCircle(
          dot.photoUrl!,
          borderColor: color,
          orderNumber: orderById[dot.id],
          badgeColor: color,
        );
        if (bytes == null || !mounted) return;
        final imgId = 'sm-dot-photo-${dot.id}';
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

      if (!mounted || photoIconIds.isEmpty) continue;

      // 멤버별 source 데이터 갱신 (photo_icon_id 반영)
      final smState =
          ref.read(sharedMapNotifierProvider(widget.roomId, widget.date));
      final latest = smState?.tracks
              .firstWhere((t) => t.memberId == track.memberId,
                  orElse: () => track) ??
          track;
      try {
        await map.style.setStyleSourceProperty(
          _memberSrcId(track.memberId),
          'data',
          _buildMemberGeoJson(latest, photoIconIds: photoIconIds),
        );
      } catch (e) {
        debugPrint('[SharedMap] thumbnail source update error: $e');
      }
    }
  }

  // ── 지도 탭 처리 ──────────────────────────────────────

  Future<void> _handleMapTap(mapbox.ScreenCoordinate sc) async {
    if (_mapboxMap == null || !mounted) return;
    try {
      final features = await _mapboxMap!.queryRenderedFeatures(
        mapbox.RenderedQueryGeometry(
          value: jsonEncode({
            'min': {'x': sc.x - _hitRadius, 'y': sc.y - _hitRadius},
            'max': {'x': sc.x + _hitRadius, 'y': sc.y + _hitRadius},
          }),
          type: mapbox.Type.SCREEN_BOX,
        ),
        mapbox.RenderedQueryOptions(
          layerIds: List<String>.from(_hitLayerIds),
          filter: null,
        ),
      );
      if (features.isEmpty || !mounted) return;

      // 클러스터 여부 먼저 확인
      for (final f in features) {
        if (f == null) continue;
        final props = f.queriedFeature.feature['properties'] as Map?;
        if (props != null && props['point_count'] != null) {
          final geoPoint = await _mapboxMap!.coordinateForPixel(sc);
          final camState = await _mapboxMap!.getCameraState();
          await _mapboxMap!.easeTo(
            mapbox.CameraOptions(center: geoPoint, zoom: camState.zoom + 2),
            mapbox.MapAnimationOptions(duration: 500),
          );
          return;
        }
      }

      // 개별 dot 수집 (dot_id 기준 중복 제거)
      final smState =
          ref.read(sharedMapNotifierProvider(widget.roomId, widget.date));
      if (smState == null) return;

      final seen = <String>{};

      // (dot, track) 쌍으로 수집 — 같은 위치의 다른 멤버 dot도 포함
      final matchedPairs = <({Dot dot, MemberTrack track})>[];
      for (final f in features) {
        if (f == null) continue;
        final props = f.queriedFeature.feature['properties'] as Map?;
        final dotId = props?['dot_id'] as String?;
        final memberId = props?['member_id'] as String?;
        if (dotId == null || seen.contains(dotId)) continue;
        seen.add(dotId);
        try {
          final track =
              smState.tracks.firstWhere((t) => t.memberId == memberId);
          final dot = track.sequence.frames
              .map((fr) => fr.dot)
              .firstWhere((d) => d.id == dotId);
          matchedPairs.add((dot: dot, track: track));
        } catch (_) {}
      }

      if (matchedPairs.isEmpty || !mounted) return;

      // 멘션 자동완성용 멤버 목록
      final memberHints = smState.tracks
          .map((t) => DotMemberHint(
                userId: t.memberId,
                nickname: t.nickname,
                color: characterColorMap[t.colorKey],
              ))
          .toList();

      if (matchedPairs.length == 1) {
        final pair = matchedPairs.first;
        await DotDetailSheet.show(
          context,
          pair.dot,
          memberName: pair.track.nickname,
          memberColor: characterColorMap[pair.track.colorKey],
          roomId: widget.roomId,
          members: memberHints,
        );
      } else {
        // 여러 dot — 첫 번째 멤버 정보로 헤더 표시 (혼합 멤버면 memberName 생략)
        final allSameMember = matchedPairs
            .every((p) => p.track.memberId == matchedPairs.first.track.memberId);
        final track = allSameMember ? matchedPairs.first.track : null;
        await DotListSheet.show(
          context,
          matchedPairs.map((p) => p.dot).toList(),
          memberName: track?.nickname,
          memberColor: track != null ? characterColorMap[track.colorKey] : null,
          roomId: widget.roomId,
          members: memberHints,
        );
      }
    } catch (e) {
      debugPrint('[SharedMap] tap error: $e');
    }
  }

  void _startUpdateTimer() {
    _updateTimer?.cancel();
    int tick = 0;
    _updateTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) {
        tick++;
        if (kDebugMode && tick % 20 == 0) {
          final s = ref.read(sharedMapNotifierProvider(widget.roomId, widget.date));
          debugPrint('[SharedMap] tick=$tick progress=${s?.progress.toStringAsFixed(3)} playing=${s?.isPlaying}');
        }
        _syncCharacters();
      },
    );
  }

  Future<void> _syncCharacters() async {
    if (!mounted || _mapboxMap == null) return;
    final smState =
        ref.read(sharedMapNotifierProvider(widget.roomId, widget.date));
    if (smState == null || smState.tracks.isEmpty) return;

    final positions =
        SharedMapBuilder.interpolateAll(smState.tracks, smState.progress);

    await Future.wait(positions.map((pos) async {
      try {
        await _mapboxMap!.style.setStyleSourceProperty(
          'char-source-${pos.memberId}',
          'data',
          jsonEncode(_posFeature(pos.lat, pos.lng)),
        );
      } catch (_) {}
    }));
  }

  Future<void> _fitCameraToTracks(
      mapbox.MapboxMap map, List<MemberTrack> tracks) async {
    final allLats = tracks
        .expand((t) => t.sequence.frames.map((f) => f.dot.latitude))
        .toList();
    final allLngs = tracks
        .expand((t) => t.sequence.frames.map((f) => f.dot.longitude))
        .toList();
    if (allLats.isEmpty) return;

    final minLat = allLats.reduce((a, b) => a < b ? a : b);
    final maxLat = allLats.reduce((a, b) => a > b ? a : b);
    final minLng = allLngs.reduce((a, b) => a < b ? a : b);
    final maxLng = allLngs.reduce((a, b) => a > b ? a : b);

    await map
        .cameraForCoordinateBounds(
          mapbox.CoordinateBounds(
            southwest: mapbox.Point(
                coordinates:
                    mapbox.Position(minLng - 0.012, minLat - 0.012)),
            northeast: mapbox.Point(
                coordinates:
                    mapbox.Position(maxLng + 0.012, maxLat + 0.012)),
            infiniteBounds: false,
          ),
          mapbox.MbxEdgeInsets(
              top: 100, left: 40, bottom: 220, right: 40),
          null, null, null, null,
        )
        .then((camera) => map.setCamera(camera));
  }

  Future<void> _addTrailLayers(
      mapbox.MapboxMap map, List<MemberTrack> tracks) async {
    _arrowLayerIdByMember.clear();
    for (final track in tracks) {
      // timestamp 정렬된 좌표 (멤버별 이동 순서)
      final frames = _sortedFrames(track);
      final coords = frames
          .map<List<double>>((f) => [f.dot.longitude, f.dot.latitude])
          .toList();
      if (coords.length < 2) continue;

      final memberColor =
          characterColorMap[track.colorKey] ?? DottieColors.primary;
      final trailSourceId = 'trail-${track.memberId}';
      final trailLayerId = 'trail-layer-${track.memberId}';
      final arrowsLayerId = _memberArrowsLayerId(track.memberId);

      await map.style.addSource(mapbox.GeoJsonSource(
        id: trailSourceId,
        data: jsonEncode({
          'type': 'Feature',
          'geometry': {'type': 'LineString', 'coordinates': coords},
        }),
      ));

      // 옅은 baseline 라인
      await map.style.addLayer(mapbox.LineLayer(
        id: trailLayerId,
        sourceId: trailSourceId,
        lineColor: memberColor.withAlpha(110).toARGB32(),
        lineWidth: 3.0,
        lineCap: mapbox.LineCap.ROUND,
        lineJoin: mapbox.LineJoin.ROUND,
      ));

      // 멤버 색 화살표 프레임 5장 등록
      await _registerMemberArrowFrames(map, track.memberId, memberColor);

      // 멤버별 화살표 march SymbolLayer
      await map.style.addLayer(mapbox.SymbolLayer(
        id: arrowsLayerId,
        sourceId: trailSourceId,
        iconImage: _memberArrowImg(track.memberId, 0),
        iconSize: 0.6, // expression fallback
        iconRotationAlignment: mapbox.IconRotationAlignment.MAP,
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
        symbolPlacement: mapbox.SymbolPlacement.LINE,
        symbolSpacing: MapMarkerRenderer.arrowSymbolSpacing,
      ));
      // 줌별 사이즈/간격 (멤버 화살표마다 같은 expression — cycle 이음새 유지)
      await map.style.setStyleLayerProperty(
        arrowsLayerId, 'icon-size',
        MapMarkerRenderer.arrowSizeExpression,
      );
      await map.style.setStyleLayerProperty(
        arrowsLayerId, 'symbol-spacing',
        MapMarkerRenderer.arrowSpacingExpression,
      );
      _arrowLayerIdByMember[track.memberId] = arrowsLayerId;
    }
  }

  Future<void> _registerMemberArrowFrames(
      mapbox.MapboxMap map, String memberId, Color color) async {
    final frames = await MapMarkerRenderer.renderArrowFrames(color: color);
    for (var i = 0; i < frames.length; i++) {
      await map.style.addStyleImage(
        _memberArrowImg(memberId, i), 2.0,
        mapbox.MbxImage(
          width: MapMarkerRenderer.arrowSourceWidth,
          height: MapMarkerRenderer.arrowSourceHeight,
          data: frames[i],
        ),
        false, [], [], null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 데이터 도착 시 두 가지 동작을 병렬로:
    //  1) 지도 setup (카메라/레이어/캐릭터)
    //  2) focusDot 시트 (지도 setup 과 독립 — 즉시 표시)
    ref.listen<SharedMapState?>(
      sharedMapNotifierProvider(widget.roomId, widget.date),
      (prev, next) {
        _trySetupMap();
        _tryOpenFocusedSheet();
        // viewMode 전환 시 캐릭터 layer visibility 동기화
        if (prev?.viewMode != next?.viewMode && next != null) {
          _setCharactersVisible(next.viewMode == SharedMapViewMode.playback);
        }
      },
    );
    // 캐시된 데이터로 진입한 경우 listen 이 안 fire 하므로 build 마다 시도
    // (가드 — `_focusedDotShown` 플래그로 중복 방지)
    _tryOpenFocusedSheet();

    final viewMode = ref.watch(
      sharedMapNotifierProvider(widget.roomId, widget.date)
          .select((s) => s?.viewMode ?? SharedMapViewMode.explore),
    );
    final isPlayback = viewMode == SharedMapViewMode.playback;

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
              map.logo.updateSettings(mapbox.LogoSettings(
                marginBottom: 220, marginLeft: 8,
              ));
              map.attribution.updateSettings(
                  mapbox.AttributionSettings(marginBottom: 220));
            },
            onStyleLoadedListener: (_) async {
              _styleLoaded = true;
              await _trySetupMap();
            },
            onTapListener: (ctx) => _handleMapTap(ctx.touchPosition),
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
            child: _SharedTopBar(
              date: widget.date,
              onBack: () => Navigator.of(context).pop(),
              onTapDate: () => _showCalendarSheet(),
            ),
          ),

          // 하단 유리 컨트롤 패널 — playback 모드에서만 슬라이드업
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: isPlayback
                  ? _SharedBottomPanel(
                      key: const ValueKey('panel'),
                      roomId: widget.roomId,
                      date: widget.date,
                    )
                  : const SizedBox.shrink(key: ValueKey('panel-hidden')),
            ),
          ),

          // 우측 하단 재생 토글 FAB
          Positioned(
            right: Dimensions.md,
            bottom: Dimensions.md,
            child: SafeArea(
              child: _PlaybackToggleFab(
                isPlayback: isPlayback,
                onToggle: () {
                  HapticFeedback.mediumImpact();
                  ref
                      .read(sharedMapNotifierProvider(widget.roomId, widget.date)
                          .notifier)
                      .setViewMode(
                        isPlayback
                            ? SharedMapViewMode.explore
                            : SharedMapViewMode.playback,
                      );
                },
              ),
            ),
          ),

          // 데이터 없음 오버레이
          _SharedMapEmptyOverlay(roomId: widget.roomId, date: widget.date),
        ],
      ),
    );
  }
}

// ─── 상단 유리 알약 바 ─────────────────────────────────

class _SharedTopBar extends StatelessWidget {
  const _SharedTopBar({
    required this.date,
    required this.onBack,
    required this.onTapDate,
  });
  final String date;
  final VoidCallback onBack;

  /// 날짜 영역 탭 → 캘린더 시트 오픈 (상위에서 처리).
  final VoidCallback onTapDate;

  @override
  Widget build(BuildContext context) {
    final parsed = DateTime.tryParse(date) ?? DottieDateUtils.todayStart();
    // 요일 자리: 오늘/어제/내일 이면 친근한 라벨, 아니면 "월요일" 같은 요일명.
    final topLabel = DottieDateUtils.relativeLabel(parsed) ??
        DottieDateUtils.toKoreanWeekday(parsed);
    final dateLabel = DottieDateUtils.toKoreanMonthDay(parsed);

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
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.xs),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(22),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                    color: Colors.white.withAlpha(45), width: 1),
              ),
              child: Row(
                children: [
                  // 좌: 뒤로가기
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                    onPressed: onBack,
                  ),
                  // 중: 2단 날짜 (탭 → 캘린더)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onTapDate();
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            topLabel,
                            style: TextStyle(
                              color: Colors.white.withAlpha(160),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dateLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white.withAlpha(160),
                                size: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 우: 시각적 균형용
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

class _SharedBottomPanel extends ConsumerWidget {
  const _SharedBottomPanel({super.key, required this.roomId, required this.date});
  final String roomId;
  final String date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final smState = ref.watch(sharedMapNotifierProvider(roomId, date));
    final notifier =
        ref.read(sharedMapNotifierProvider(roomId, date).notifier);

    if (smState == null) return const SizedBox.shrink();

    final startTime = smState.tracks.isNotEmpty &&
            smState.tracks.first.sequence.frames.isNotEmpty
        ? smState.tracks.first.sequence.frames.first.dot.timestamp
        : DateTime.now();
    final endTime = smState.tracks.isNotEmpty &&
            smState.tracks.first.sequence.frames.isNotEmpty
        ? smState.tracks.first.sequence.frames.last.dot.timestamp
        : DateTime.now();
    final totalMs = smState.totalDurationMs;
    final currentMs = totalMs * smState.progress;
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
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  Dimensions.md, Dimensions.md, Dimensions.md, Dimensions.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 멤버 색상 범례 칩
                  _MemberChips(tracks: smState.tracks),
                  const SizedBox(height: Dimensions.sm),

                  // 스토리 글로우 진행 바
                  _GlowProgressBar(progress: smState.progress),
                  const SizedBox(height: Dimensions.md),

                  // 시간 표시
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DottieDateUtils.toTimeString(startTime),
                        style: TextStyle(
                            color: Colors.white.withAlpha(140), fontSize: 11),
                      ),
                      Text(
                        DottieDateUtils.toTimeString(currentTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        DottieDateUtils.toTimeString(endTime),
                        style: TextStyle(
                            color: Colors.white.withAlpha(140), fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // 스크럽 슬라이더
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
                      value: smState.progress,
                      onChanged: notifier.scrubTo,
                      onChangeEnd: (_) {
                        if (smState.isPlaying) notifier.play();
                      },
                    ),
                  ),

                  // 재생 컨트롤
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _GlassChip(
                        onTap: () =>
                            notifier.setSpeed(_nextSpeed(smState.speed)),
                        child: Text(
                          smState.speed.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: Dimensions.xl),

                      GestureDetector(
                        onTap:
                            smState.isPlaying ? notifier.pause : notifier.play,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF7AABFF),
                                DottieColors.primary,
                              ],
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
                            smState.isPlaying
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

// ─── 멤버 색상 칩 ──────────────────────────────────────

class _MemberChips extends StatelessWidget {
  const _MemberChips({required this.tracks});
  final List<MemberTrack> tracks;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: tracks.map((t) {
        final color = characterColorMap[t.colorKey] ?? DottieColors.primary;
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withAlpha(40),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withAlpha(120), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    t.nickname,
                    style: TextStyle(
                      color: Colors.white.withAlpha(230),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── 공유 위젯 (두 화면 공통) ───────────────────────────

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
                  colors: [Color(0xFF7AABFF), DottieColors.primary],
                ),
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

// ─── 빈 데이터 오버레이 ────────────────────────────────────
class _SharedMapEmptyOverlay extends ConsumerWidget {
  const _SharedMapEmptyOverlay({required this.roomId, required this.date});
  final String roomId;
  final String date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final smState = ref.watch(sharedMapNotifierProvider(roomId, date));
    // null = 로딩 중, empty tracks = 데이터 없음
    if (smState == null || smState.tracks.isNotEmpty) return const SizedBox.shrink();

    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🗺️', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text(
                '아직 공유된 기록이 없어요',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                date,
                style: TextStyle(
                  color: Colors.white.withAlpha(140),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                label: const Text('돌아가기',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
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

// ─── 캘린더 바텀시트 ────────────────────────────────────
//
// 상단 바의 날짜를 탭하면 표시되는 다크 글래스 시트.
// activeDates(set of "YYYY-MM-DD")에 있는 날짜만 활성/탭 가능,
// 그 외는 비활성. 탭하면 시트 닫고 선택된 DateTime을 결과로 반환.
// 라우트 교체(pushReplacement)는 호출자가 처리한다.
class _DateCalendarSheet extends ConsumerStatefulWidget {
  const _DateCalendarSheet({
    required this.roomId,
    required this.selectedDate,
  });

  final String roomId;
  final DateTime selectedDate;

  static Future<DateTime?> show(
    BuildContext context, {
    required String roomId,
    required DateTime selectedDate,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DateCalendarSheet(
        roomId: roomId,
        selectedDate: selectedDate,
      ),
    );
  }

  @override
  ConsumerState<_DateCalendarSheet> createState() =>
      _DateCalendarSheetState();
}

class _DateCalendarSheetState extends ConsumerState<_DateCalendarSheet> {
  late DateTime _viewMonth;

  @override
  void initState() {
    super.initState();
    _viewMonth =
        DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  void _changeMonth(int delta) {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateUtils.getDaysInMonth(_viewMonth.year, _viewMonth.month);
    final firstWeekday =
        DateTime(_viewMonth.year, _viewMonth.month, 1).weekday % 7;
    final today = DottieDateUtils.todayStart();
    // 알림 직접 진입 등으로 Room 캐시가 없을 수 있으므로 watch 로 비동기 갱신.
    // 비어 있으면(로딩/에러) 모든 셀 비활성 — 데이터 도착 즉시 활성화됨.
    final activeDates = ref
            .watch(roomDetailProvider(widget.roomId))
            .valueOrNull
            ?.sharedDates
            .toSet() ??
        const <String>{};

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1B1E).withAlpha(240),
            border: Border(
              top: BorderSide(color: Colors.white.withAlpha(28), width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  Dimensions.md, Dimensions.sm, Dimensions.md, Dimensions.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // drag handle
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(60),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: Dimensions.md),
                  // 월 네비
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CalendarNavButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: () => _changeMonth(-1),
                      ),
                      Text(
                        DottieDateUtils.toKoreanYearMonth(_viewMonth),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _CalendarNavButton(
                        icon: Icons.chevron_right_rounded,
                        onTap: () => _changeMonth(1),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.md),
                  // 요일 헤더
                  Row(
                    children: ['일', '월', '화', '수', '목', '금', '토']
                        .map((d) => Expanded(
                              child: Text(
                                d,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withAlpha(120),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: Dimensions.sm),
                  // 날짜 그리드
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: firstWeekday + daysInMonth,
                    itemBuilder: (_, idx) {
                      if (idx < firstWeekday) return const SizedBox.shrink();
                      final day = idx - firstWeekday + 1;
                      final date =
                          DateTime(_viewMonth.year, _viewMonth.month, day);
                      final dateStr = DottieDateUtils.toDateString(date);
                      final hasRecord = activeDates.contains(dateStr);
                      final isSelected = DottieDateUtils.isSameDay(
                          date, widget.selectedDate);
                      final isToday = DottieDateUtils.isSameDay(date, today);
                      return _CalendarDayCell(
                        day: day,
                        active: hasRecord,
                        selected: isSelected,
                        today: isToday,
                        onTap: hasRecord
                            ? () {
                                HapticFeedback.lightImpact();
                                Navigator.of(context).pop(date);
                              }
                            : null,
                      );
                    },
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

class _CalendarNavButton extends StatelessWidget {
  const _CalendarNavButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          shape: BoxShape.circle,
          border:
              Border.all(color: Colors.white.withAlpha(38), width: 1),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.active,
    required this.selected,
    required this.today,
    required this.onTap,
  });

  final int day;
  final bool active;
  final bool selected;
  final bool today;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final BoxDecoration? decoration;
    final Color textColor;
    if (selected) {
      decoration = const BoxDecoration(
        color: DottieColors.primary,
        shape: BoxShape.circle,
      );
      textColor = Colors.white;
    } else if (today) {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: DottieColors.primary.withAlpha(180), width: 1.5),
      );
      textColor = Colors.white;
    } else {
      decoration = null;
      textColor = active
          ? Colors.white
          : Colors.white.withAlpha(60);
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: decoration,
            alignment: Alignment.center,
            child: Text(
              '$day',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: selected || today
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ),
          // 활동 있는 날 표시 (선택/오늘이 아닐 때만)
          if (active && !selected)
            Positioned(
              bottom: 2,
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: DottieColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── 재생 모드 토글 FAB ────────────────────────────────
//
// 우측 하단에 떠 있는 56x56 글래스 원형 버튼.
// explore 모드일 때는 Play 아이콘 → 탭하면 시네마(playback) 모드 진입.
// playback 모드일 때는 Close 아이콘 → 탭하면 explore 로 복귀.
class _PlaybackToggleFab extends StatelessWidget {
  const _PlaybackToggleFab({
    required this.isPlayback,
    required this.onToggle,
  });

  final bool isPlayback;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withAlpha(140),
              border: Border.all(
                color: Colors.white.withAlpha(38),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(80),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(
                isPlayback ? Icons.close_rounded : Icons.play_arrow_rounded,
                key: ValueKey(isPlayback),
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
