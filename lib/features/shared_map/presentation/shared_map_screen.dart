import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/color_hex.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/map_marker_renderer.dart';
import '../../../../core/utils/media_thumbnail_loader.dart';
import '../../../../shared/utils/error_messages.dart';
import '../../../../shared/widgets/date_ui/all_days_toggle_chip.dart';
import '../../../../shared/widgets/date_ui/date_calendar_sheet.dart';
import '../../../../shared/widgets/date_ui/date_strip.dart';
import '../../../../shared/widgets/date_ui/glass_date_header.dart';
import '../../../../shared/widgets/dot_content_block.dart';
import '../../../../shared/widgets/dot_detail_sheet.dart';
import '../../map_animation/domain/animation_frame.dart';
import '../../recording/domain/dot_model.dart';
import '../../map_animation/presentation/animation_provider.dart'
    show PlaySpeed, PlaySpeedExt;
import '../../character/paperdoll/data/paperdoll_image_cache.dart';
import '../../character/paperdoll/domain/paperdoll_config.dart';
import '../../character/paperdoll/presentation/paperdoll_provider.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../recording/presentation/recording_provider.dart';
import '../../room/domain/room_exceptions.dart';
import '../../room/domain/room_model.dart';
import '../../room/presentation/room_provider.dart';
import '../../timeline/domain/day_log_model.dart';
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
  // 빈 룸 진입 시 "오늘 기록 이 방에 공유하기" 버튼 진행 상태.
  bool _sharingFromEmpty = false;
  // focusDotId 카메라 줌인 1회만 — 사용자가 줌 변경 후 layer 재초기화 등에 다시
  // 줌이 강제되면 어색하므로 첫 진입에서만 실행.
  bool _focusDotZoomed = false;

  // 멤버별 화살표 layer ID 모음 (memberId → layerId)
  final Map<String, String> _arrowLayerIdByMember = {};

  // 멤버별 dot.id → photo style image id 매핑.
  // _loadPhotoThumbnails 가 채우고, _refreshMemberSources 가 source 재갱신 시 재사용.
  // (이게 없으면 invalidate 후 source 재구성 시 photo dots 가 default 원으로 되돌아감)
  final Map<String, Map<String, String>> _photoIconIdsByMember = {};

  // 멤버별 캐릭터 layer ID 모음 — viewMode 토글 시 visibility 일괄 변경에 사용.
  // 재생 캐릭터 (SymbolLayer) + 그 아래 멤버색 ring (CircleLayer) 둘 다 포함.
  final List<String> _characterLayerIds = [];

  // 정적 end 마커 (마지막 dot의 아바타 + ring) layer ID 모음.
  // 재생 모드에선 캐릭터가 그 자리에서 시작해 움직이므로 end 마커는 숨김.
  final List<String> _endMarkerLayerIds = [];

  // 멤버별 순서 번호(text) layer ID 모음 — showOrderNumbers 토글 시 일괄 변경
  final List<String> _orderTextLayerIds = [];

  // 인카운터 marker hit-testing 대상 layer ID 모음
  final List<String> _meetingHitLayerIds = [];

  // 인카운터 펄스 ring layer ID (애니메이션 대상)
  String? _meetingPulseLayerId;
  Timer? _meetingPulseTimer;
  double _pulsePhase = 0; // 0 ~ 2π

  // 내 캐릭터 GPS 기반 표시 — explore 모드에서 마지막 dot 대신 현재 위치로 표시.
  String? _myUid;
  Timer? _locationTimer;
  bool _myGpsLayerAdded = false;
  // 내 위치 버튼용 — 5초 폴링이 받아온 마지막 GPS 좌표 캐시.
  Position? _lastGpsPos;
  // 내 위치 버튼 토글 상태. false: 다음 탭에 내 위치로 이동(A),
  // true: 다음 탭에 내 위치+dot 전체 보기(B).
  bool _myLocationFitAll = false;
  static const _myGpsSrcId = 'sm-my-gps-source';
  static const _myGpsLayerId = 'sm-my-gps-layer';

  // 시네마 모드 자동 숨김 — playback 중 무입력 N초 후 chrome 페이드아웃.
  // explore 모드에서는 사용 안 함(컨트롤이 거의 없으므로 항상 표시).
  bool _chromeVisible = true;
  Timer? _idleTimer;
  static const _idleHideAfter = Duration(seconds: 3);

  // 탭 hit-testing 대상 layer ID 모음 (멤버별로 누적)
  final List<String> _hitLayerIds = [];

  static const double _hitRadius = 22;
  static const double _charScale = 2.0;

  // 주/야간 자동 전환 — today_map / map_animation 와 동일 패턴.
  bool _isDaytime = _checkDaytime();
  Timer? _modeTimer;
  static bool _checkDaytime() {
    final h = DateTime.now().hour;
    return h >= 7 && h < 19;
  }

  // 멤버별 레이어/이미지 ID 헬퍼
  String _memberSrcId(String memberId) => 'sm-dots-source-$memberId';
  String _memberClusterCircleId(String memberId) => 'sm-cluster-circle-$memberId';
  String _memberClusterCountId(String memberId) => 'sm-cluster-count-$memberId';
  String _memberDotsCircleId(String memberId) => 'sm-dots-circle-$memberId';
  String _memberOrderTextId(String memberId) => 'sm-dots-order-text-$memberId';
  String _memberPhotoLayerId(String memberId) => 'sm-dots-photo-$memberId';
  String _memberAvatarEndLayerId(String memberId) => 'sm-avatar-end-$memberId';
  String _memberDefaultDotImg(String memberId) => 'sm-dot-default-$memberId';
  String _memberEndImg(String memberId) => 'sm-marker-end-$memberId';
  String _memberArrowsLayerId(String memberId) =>
      'sm-trail-arrows-$memberId';
  String _memberArrowImg(String memberId, int frame) =>
      'sm-arrow-$memberId-$frame';

  @override
  void initState() {
    super.initState();
    _myUid = ref.read(currentDottieUserProvider).valueOrNull?.uid;
    _startMyGpsUpdates();
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
    _arrowTimer?.cancel();
    _meetingPulseTimer?.cancel();
    _idleTimer?.cancel();
    _locationTimer?.cancel();
    _modeTimer?.cancel();
    super.dispose();
  }

  /// playback 모드일 때 idle 타이머 시작 — 3초 후 chrome 페이드아웃.
  /// 사용자 입력(지도 탭, 모드 전환 등)마다 호출해 카운트 리셋.
  void _resetIdleTimer({required bool isPlayback}) {
    _idleTimer?.cancel();
    if (!isPlayback) return; // explore 에서는 자동 숨김 안 함
    _idleTimer = Timer(_idleHideAfter, () {
      if (!mounted) return;
      setState(() => _chromeVisible = false);
    });
  }

  /// chrome(상단/하단 UI) 강제 표시 + idle 타이머 재시작.
  void _showChrome({required bool isPlayback}) {
    if (!_chromeVisible) {
      setState(() => _chromeVisible = true);
    }
    _resetIdleTimer(isPlayback: isPlayback);
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
      await _addMeetingLayers(
          _mapboxMap!, smState.meetings, smState.tracks);
      _startUpdateTimer();
      _startArrowMarch();
      _startMeetingPulse();
      debugPrint('[SharedMap] setup done, tracks=${smState.tracks.length}');

      // 사진 썸네일은 백그라운드 로드 (순서 뱃지 합성 + 멤버별 source 갱신)
      unawaited(_loadPhotoThumbnails(_mapboxMap!, smState.tracks));

      // 알림 진입(focusDotId)이면 짧은 지연 후 그 dot 위치로 부드럽게 줌인.
      // 트레일 전체 fit 결과를 사용자가 잠깐 인식한 뒤 자연스럽게 dot 으로 이동.
      if (widget.focusDotId != null) {
        unawaited(Future<void>.delayed(
          const Duration(milliseconds: 350),
          () => _zoomToFocusDot(),
        ));
      }
    } catch (e, st) {
      debugPrint('[SharedMap] setup error: $e\n$st');
    }
  }

  /// `focusDotId` 가 있을 때 그 dot 위치로 카메라 줌인 (1회).
  /// 시트가 화면 하단을 차지하므로 `padding.bottom` 으로 보정해 dot 이 시트
  /// 위쪽 영역의 가운데에 오도록.
  Future<void> _zoomToFocusDot() async {
    if (_focusDotZoomed || !mounted) return;
    final dotId = widget.focusDotId;
    if (dotId == null) return;
    final map = _mapboxMap;
    if (map == null) return;
    final smState =
        ref.read(sharedMapNotifierProvider(widget.roomId, widget.date));
    if (smState == null) return;

    for (final track in smState.tracks) {
      for (final frame in track.sequence.frames) {
        if (frame.dot.id != dotId) continue;
        _focusDotZoomed = true;
        try {
          // padding 없이 — dot 좌표 그대로 화면 정중앙에 배치.
          // 시트가 화면 하단 절반을 가리지만, 시트 자체가 dot 정보 노출용이고
          // 사용자가 시트 닫으면 그 자리에 dot 이 정중앙으로 보이는 게 자연.
          await map.flyTo(
            mapbox.CameraOptions(
              center: mapbox.Point(
                coordinates: mapbox.Position(
                  frame.dot.longitude,
                  frame.dot.latitude,
                ),
              ),
              zoom: 16.5,
            ),
            mapbox.MapAnimationOptions(duration: 800),
          );
          debugPrint(
              '[SharedMap] flyTo focus dot=${dotId.substring(0, 8)} zoom=16.5');
        } catch (e) {
          debugPrint('[SharedMap] flyTo focus error: $e');
        }
        return;
      }
    }
    debugPrint('[SharedMap] focusDotId=$dotId not in tracks for zoom');
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

        // 멘션 후보 = 그날 dot 있는 멤버가 아니라 전체 룸 멤버.
        // 룸 미로드 시 빈 리스트로 (직진입 직후 짧은 순간 — 다음 진입에 정상화).
        final room = ref.read(roomDetailProvider(widget.roomId)).valueOrNull;
        final membersByRoomId = <String, List<DotMemberHint>>{
          widget.roomId: (room?.members ?? const [])
              .map((m) => DotMemberHint(
                    userId: m.userId,
                    nickname: m.nickname,
                    color: colorFromHex(m.character.colorHex),
                  ))
              .toList(),
        };
        // 숨기기 다이얼로그에 정확한 방 이름 노출 — 단일 방 컨텍스트라 picker
        // 없이 바로 다이얼로그.
        final hideRoomNames = room != null
            ? <String, String>{widget.roomId: room.name}
            : <String, String>{};

        // 다음 프레임에 시트 — build 진행 중 호출 가능성 회피
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          DotDetailSheet.show(
            context,
            frame.dot,
            memberName: track.nickname,
            memberColor: colorFromHex(track.colorHex),
            roomId: widget.roomId,
            membersByRoomId: membersByRoomId,
            ownerUserId: track.memberId,
            hideRoomNames: hideRoomNames,
          );
        });
        return;
      }
    }

    // tracks 자체가 비어 있으면 "이 날짜엔 기록 없음"과 "로드 실패(네트워크
    // 오류/비멤버 등, shared_map_provider 가 에러도 빈 tracks 로 정규화함)"
    // 를 구분할 수 없다. 여기서 래치를 걸면 실패 케이스에서 재시도가
    // 성공해도 시트가 영영 안 열리므로, tracks 가 비어 있는 동안은 아직
    // 판단을 보류하고 다음 로드를 기다린다 (listen 이 다시 호출).
    if (smState.tracks.isEmpty) return;

    // tracks 는 로드됐지만 dot 이 이 날짜에 없음 (미공유/날짜 오차 등).
    // 이전에는 전날로 pushReplacement 하는 폴백이 있었으나, 무한 루프 방지
    // 가드가 State 인스턴스 필드라 pushReplacement 로 새 State 가 생성될
    // 때마다 리셋되어 dot 을 영영 못 찾는 경우 무한 연쇄 라우팅을 유발했음.
    // 화면 전환 없이 현재 날짜 지도를 유지하고 안내만 표시한다.
    assert(() {
      debugPrint('[SharedMap] focusDotId=$dotId not in ${widget.date} tracks');
      return true;
    }());
    _focusedDotShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이 날짜에서 해당 기록을 찾을 수 없어요')),
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

      // 재생 캐릭터 (SymbolLayer) — ring 없이 캐릭터만 이동.
      await map.style.addLayer(mapbox.SymbolLayer(
        id: layerId,
        sourceId: sourceId,
        iconImage: imgKey,
        iconSize: 0.6,
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

  /// 데이터 로딩 중 화면. 검은 배경 유지(시네마 톤), 가운데 spinner.
  Widget _buildLoadingScaffold() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            // 뒤로가기는 즉시 가능 — 검은 화면에서 멈춰 있는 인지 회피.
            Positioned(
              top: Dimensions.sm,
              left: Dimensions.sm,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 오늘(또는 선택 날짜) 멤버 기록이 없을 때 안내.
  /// 오늘 + 본인 dot 있음 → "이 방에 공유하기" 버튼 추가 (룸 설정 안 거치고 즉시 공유).
  /// 그 외엔 기존 안내 + 다른 날짜 보기.
  Widget _buildEmptyScaffold() {
    final selectedDate = DateTime.tryParse(widget.date);
    final dateLabel = selectedDate != null
        ? DottieDateUtils.toKoreanDate(selectedDate)
        : widget.date;
    final isToday = selectedDate != null &&
        DottieDateUtils.isSameDay(selectedDate, DateTime.now());

    // 오늘 + 본인 dot 있음일 때만 공유 가능. 그 외엔 null.
    DayLog? shareableTodayLog;
    if (isToday) {
      final todayLog = ref.watch(todayDayLogProvider).valueOrNull;
      if (todayLog != null && todayLog.dots.isNotEmpty) {
        shareableTodayLog = todayLog;
      }
    }
    final canShareToday = shareableTodayLog != null;

    return Scaffold(
      backgroundColor: DottieColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: DottieColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          dateLabel,
          style: GoogleFonts.notoSansKr(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: DottieColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: '방 설정',
            icon: const Icon(Icons.settings_outlined,
                color: DottieColors.textSecondary, size: 20),
            onPressed: () => context.push('/rooms/${widget.roomId}/info'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: DottieColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_off_outlined,
                    size: 34,
                    color: DottieColors.primary,
                  ),
                ),
                const SizedBox(height: Dimensions.md),
                Text(
                  isToday ? '오늘은 아직 기록이 없어요' : '이 날에는 기록이 없어요',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: DottieColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  canShareToday
                      ? '오늘 ${shareableTodayLog.dots.length}개 dot 을 이 방에 공유해 보세요'
                      : isToday
                          ? '홈에서 dot 을 찍으면 멤버들에게 공유돼요'
                          : '다른 날짜를 선택해 보세요',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 13,
                    color: DottieColors.textHint,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: Dimensions.lg),
                if (canShareToday) ...[
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _sharingFromEmpty
                          ? null
                          : () => _shareTodayFromEmpty(
                              shareableTodayLog!.id),
                      icon: _sharingFromEmpty
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.share_location_rounded),
                      label: const Text('오늘 기록 이 방에 공유하기'),
                      style: FilledButton.styleFrom(
                        backgroundColor: DottieColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusMd),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: Dimensions.sm),
                ],
                OutlinedButton.icon(
                  onPressed: _showCalendarSheet,
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
                  label: const Text('다른 날짜 보기'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: DottieColors.primary,
                    side: const BorderSide(color: DottieColors.primary),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusMd),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 빈 룸에서 "오늘 기록 이 방에 공유하기" 탭 — shareDayLog 호출 후
  /// sharedMap 재조회로 자연스럽게 화면 갱신.
  Future<void> _shareTodayFromEmpty(String todayDayLogId) async {
    if (_sharingFromEmpty) return;
    setState(() => _sharingFromEmpty = true);
    try {
      await ref
          .read(roomNotifierProvider.notifier)
          .shareDayLog(widget.roomId, todayDayLogId);
      if (!mounted) return;
      ref.invalidate(sharedMapNotifierProvider(widget.roomId, widget.date));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오늘 기록을 방에 공유했어요!')),
      );
    } on ShareDayLogException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userMessageFor(e)),
          backgroundColor: e.code == 'ALREADY_SHARED'
              ? Colors.orange
              : DottieColors.error,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('공유에 실패했어요. 잠시 후 다시 시도해 주세요.'),
          backgroundColor: DottieColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _sharingFromEmpty = false);
    }
  }

  /// 상단 바 날짜 영역 탭 → 다크 캘린더 시트.
  /// 같은 날짜를 다시 선택하면 무동작. 다른 날짜면 같은 라우트를 pushReplacement.
  /// 시트 표시 중 idle 타이머는 일시정지(닫힌 후 chrome 복원).
  Future<void> _showCalendarSheet() async {
    _idleTimer?.cancel();
    // roomDetail fetch 가 아직 안 끝났을 수 있음 → future 로 *기다림*.
    // valueOrNull 만 보면 첫 진입 시점 (fetch 진행 중) 에 빈 set 이 되어
    // "다른 날 안 보이는" 버그 발생. 시간 지나거나 dot 입력 후엔 fetch 끝나서
    // 정상 보임 — race condition.
    Room? room;
    try {
      room = await ref.read(roomDetailProvider(widget.roomId).future);
    } catch (_) {
      // 네트워크 오류 등 — 폴백으로 캐시 즉시 사용.
      room = ref.read(roomDetailProvider(widget.roomId)).valueOrNull;
    }
    if (!mounted) return;
    final activeDates = room?.sharedDates.toSet() ?? const <String>{};
    final selected = await DateCalendarSheet.show(
      context,
      selectedDate:
          DateTime.tryParse(widget.date) ?? DottieDateUtils.todayStart(),
      activeDates: activeDates,
    );
    if (!mounted) return;
    final isPlayback = ref
            .read(sharedMapNotifierProvider(widget.roomId, widget.date))
            ?.viewMode ==
        SharedMapViewMode.playback;
    _showChrome(isPlayback: isPlayback);
    if (selected == null) return;
    final newDate = DottieDateUtils.toDateString(selected);
    if (newDate == widget.date) return;
    context.pushReplacement(
      '/rooms/${widget.roomId}/map',
      extra: {'date': newDate},
    );
  }

  /// Mapbox 로고/attribution 의 하단 여백을 viewMode 에 맞춰 갱신.
  /// - explore: 24px (왼쪽 하단 자연 위치)
  /// - playback: 220px (재생 컨트롤 패널 위)
  /// 패널이 없는 explore 에서 220 을 유지하면 로고가 화면 중앙에 떠 보임.
  Future<void> _updateMapboxChromeMargins(bool isPlayback) async {
    if (_mapboxMap == null) return;
    final margin = isPlayback ? 220.0 : 24.0;
    try {
      await _mapboxMap!.logo.updateSettings(mapbox.LogoSettings(
        marginBottom: margin,
        marginLeft: 8,
      ));
      await _mapboxMap!.attribution
          .updateSettings(mapbox.AttributionSettings(marginBottom: margin));
    } catch (_) {}
  }

  /// 재생 모드 토글 시 캐릭터/end 마커 visibility 일괄 변경.
  /// - playback 진입 (visible=true): 재생 캐릭터+ring 표시, 정적 end 마커 숨김.
  /// - explore 복귀 (visible=false): 재생 캐릭터+ring 숨김, 정적 end 마커 표시.
  /// viewMode 변화에 따라 _SharedMapScreenState.build 의 ref.listen 에서 호출.
  Future<void> _setCharactersVisible(bool visible) async {
    if (_mapboxMap == null || !_styleLoaded) return;
    final charValue = visible ? 'visible' : 'none';
    final endValue = visible ? 'none' : 'visible';
    for (final id in _characterLayerIds) {
      try {
        await _mapboxMap!.style
            .setStyleLayerProperty(id, 'visibility', charValue);
      } catch (_) {}
    }
    for (final id in _endMarkerLayerIds) {
      try {
        await _mapboxMap!.style
            .setStyleLayerProperty(id, 'visibility', endValue);
      } catch (_) {}
    }
  }

  /// 순서 번호(text) layer 들의 visibility를 일괄 토글.
  /// (zoom>=14 필터는 그대로 유지 — 토글이 ON 이어도 줌 부족하면 안 보임)
  Future<void> _setOrderNumbersVisible(bool visible) async {
    if (_mapboxMap == null || !_styleLoaded) return;
    final value = visible ? 'visible' : 'none';
    for (final id in _orderTextLayerIds) {
      try {
        await _mapboxMap!.style.setStyleLayerProperty(id, 'visibility', value);
      } catch (_) {}
    }
  }

  // GeoJSON feature — properties 불필요 (icon을 literal로 지정)
  Map<String, dynamic> _posFeature(
    double lat,
    double lng, {
    String? dotId,
    String? memberId,
  }) =>
      {
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [lng, lat],
        },
        'properties': {
          if (dotId != null) 'dot_id': dotId,
          if (memberId != null) 'member_id': memberId,
        },
      };

  // ── 인카운터(만남) 레이어 ──────────────────────────────

  String _buildMeetingsGeoJson(
      List<MeetingEvent> meetings, List<MemberTrack> tracks) {
    // dot_id → Dot 인덱스. B4 dot_ids 로 댓글 합산.
    final dotById = <String, Dot>{};
    for (final t in tracks) {
      for (final f in t.sequence.frames) {
        dotById[f.dot.id] = f.dot;
      }
    }

    final features = <Map<String, dynamic>>[];
    for (var i = 0; i < meetings.length; i++) {
      final m = meetings[i];
      var hasComment = false;
      for (final id in m.dotIds) {
        if ((dotById[id]?.commentCount ?? 0) > 0) {
          hasComment = true;
          break;
        }
      }
      features.add({
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [m.lng, m.lat],
        },
        'properties': {
          'encounter_id': i,
          'member_count': m.userIds.length,
          'has_comment': hasComment,
        },
      });
    }
    return jsonEncode({'type': 'FeatureCollection', 'features': features});
  }

  Future<void> _addMeetingLayers(
    mapbox.MapboxMap map,
    List<MeetingEvent> meetings,
    List<MemberTrack> tracks,
  ) async {
    _meetingHitLayerIds.clear();
    if (meetings.isEmpty) return;

    const sourceId = 'meetings';
    const pulseLayerId = 'meeting-pulse';
    const baseLayerId = 'meeting-base';
    const countLayerId = 'meeting-count';
    const commentLayerId = 'meeting-comment';

    // 인카운터는 줌 14+ 에서만 표시 — clusterMaxZoom 14 와 동일 임계값.
    const meetingMinZoom = 14.0;

    await map.style.addSource(mapbox.GeoJsonSource(
      id: sourceId,
      data: _buildMeetingsGeoJson(meetings, tracks),
    ));

    // (1) 펄스 ring — 부드러운 글로우, 애니메이션 대상
    await map.style.addLayer(mapbox.CircleLayer(
      id: pulseLayerId,
      sourceId: sourceId,
      minZoom: meetingMinZoom,
      circleRadius: 20.0,
      circleColor: Colors.white.withAlpha(48).toARGB32(),
      circleBlur: 0.4,
    ));
    _meetingPulseLayerId = pulseLayerId;

    // (2) base — 어두운 글래스 + 흰 외곽 ring. 멤버 색은 시트에서 표현.
    // N명 가변 — 마커는 단색으로 통일하고 숫자만 노출 (확장성).
    await map.style.addLayer(mapbox.CircleLayer(
      id: baseLayerId,
      sourceId: sourceId,
      minZoom: meetingMinZoom,
      circleRadius: 14.0,
      circleColor: DottieColors.surfaceFloating.toARGB32(),
      circleStrokeWidth: 2.0,
      circleStrokeColor: Colors.white.withAlpha(220).toARGB32(),
    ));

    // (3) 카운트 텍스트 — 멤버 수 ("2", "3", "10" 등)
    await map.style.addLayer(mapbox.SymbolLayer(
      id: countLayerId,
      sourceId: sourceId,
      minZoom: meetingMinZoom,
      textColor: Colors.white.toARGB32(),
      textSize: 12.0,
      textAllowOverlap: true,
      textIgnorePlacement: true,
    ));
    await map.style.setStyleLayerProperty(
      countLayerId, 'text-field',
      '["to-string", ["get", "member_count"]]',
    );

    // (4) 댓글 indicator — 멤버 중 하나라도 댓글 있을 때.
    // dot/cluster indicator 와 동일 디자인 (5px 흰 원 + 어두운 stroke).
    await map.style.addLayer(mapbox.CircleLayer(
      id: commentLayerId,
      sourceId: sourceId,
      filter: ["==", ["get", "has_comment"], true],
      minZoom: meetingMinZoom,
      circleRadius: 5.0,
      circleColor: Colors.white.toARGB32(),
      circleStrokeWidth: 1.5,
      circleStrokeColor: Colors.black.withAlpha(180).toARGB32(),
      circleTranslate: [14.0, -14.0],
    ));

    _meetingHitLayerIds.addAll(
        [pulseLayerId, baseLayerId, countLayerId, commentLayerId]);
  }

  /// 인카운터 펄스 ring 의 반경/알파를 sin 곡선으로 주기 갱신.
  /// 60ms tick × phase step 0.18 ≈ 약 2초 한 사이클 (느린 호흡감).
  void _startMeetingPulse() {
    _meetingPulseTimer?.cancel();
    if (_meetingPulseLayerId == null) return;
    _pulsePhase = 0;
    _meetingPulseTimer = Timer.periodic(
      const Duration(milliseconds: 60),
      (_) async {
        if (_mapboxMap == null || !_styleLoaded) return;
        _pulsePhase = (_pulsePhase + 0.18) % (2 * math.pi);
        // 16 ↔ 22 px, alpha 28 ↔ 70
        final t = (1 + math.sin(_pulsePhase)) / 2; // 0~1
        final radius = 16.0 + 6.0 * t;
        final alpha = (28 + 42 * t).round().clamp(0, 255);
        try {
          await _mapboxMap!.style.setStyleLayerProperty(
            _meetingPulseLayerId!, 'circle-radius', radius,
          );
          await _mapboxMap!.style.setStyleLayerProperty(
            _meetingPulseLayerId!, 'circle-color',
            'rgba(255,255,255,${alpha / 255})',
          );
        } catch (_) {}
      },
    );
  }

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
    final color = colorFromHex(track.colorHex, fallback: DottieColors.primary);
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
        // BE 가 thumb/preview 만 응답에 보냄. 업로드 직후 transient 는 photoUrl 만
        // 로컬에 있을 수 있는데, R2 에서 fetch 못 하므로 photo 마커는 안 그리고
        // dotsCircle placeholder 로 표시.
        'has_photo': dot.hasPhotoData,
        'photo_icon_id': photoIconId ?? defaultIconId,
        // photo thumbnail 이 실제로 로드되어 styleImage 가 등록됐는지.
        // false 면 photoLayer 가 그려지더라도 fallback default 만 보이므로,
        // dotsCircle 가 placeholder 로 함께 그려지도록 분기 (회귀 방어).
        'thumbnail_loaded': photoIconId != null,
        'place_name': dot.placeName ?? '',
        'timestamp': dot.timestamp.toUtc().toIso8601String(),
        'memo': dot.memo ?? '',
        'emotion': dot.emotion ?? '',
        'has_comment': dot.commentCount > 0,
        'comment_count': dot.commentCount,
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
    // 진단 로그 — photo dot 별 thumbnail_loaded / has_comment / photo_icon_id 확인용
    if (kDebugMode) {
      final photoFrames = frames.where((f) => f.dot.hasPhotoData);
      for (final f in photoFrames) {
        final iconId = photoIconIds?[f.dot.id];
        debugPrint(
          '[SharedMap.geojson] member=${track.memberId.substring(0, 8)} '
          'dot=${f.dot.id.substring(0, 8)} '
          'thumb=${f.dot.photoThumbUrl != null ? "Y" : "N"} '
          'preview=${f.dot.photoPreviewUrl != null ? "Y" : "N"} '
          'thumbnail_loaded=${iconId != null} '
          'photo_icon_id=$iconId '
          'comment=${f.dot.commentCount}',
        );
      }
    }
    return jsonEncode({'type': 'FeatureCollection', 'features': features});
  }

  /// 클러스터 사진 / 댓글 indicator 이미지 ID — 멤버 무관 공용 1장씩.
  static const _clusterPhotoBadgeImg = 'sm-cluster-photo-badge';
  static const _clusterCommentBadgeImg = 'sm-cluster-comment-badge';

  Future<void> _addClusterDotLayers(
      mapbox.MapboxMap map, List<MemberTrack> tracks) async {
    _hitLayerIds.clear();
    _orderTextLayerIds.clear();

    // 클러스터 indicator 이미지 (전역 1장씩 등록).
    await _registerClusterPhotoBadge(map);
    await _registerClusterCommentBadge(map);

    // 멤버별 placeholder + 출발/도착 마커 PNG 등록
    for (final track in tracks) {
      final color =
          colorFromHex(track.colorHex, fallback: DottieColors.primary);
      await _registerMemberDefaultDot(map, track.memberId, color);
      await _registerMemberStartEndMarkers(map, track.memberId, color);
    }

    // 멤버별 source + 레이어 추가
    for (final track in tracks) {
      await _addMemberLayers(map, track);
    }
  }

  /// 클러스터 안에 사진 dot 이 있을 때 노출되는 작은 카메라 배지.
  Future<void> _registerClusterPhotoBadge(mapbox.MapboxMap map) =>
      _registerIconBadge(
        map,
        imageId: _clusterPhotoBadgeImg,
        iconData: Icons.photo_camera_rounded,
      );

  /// 클러스터 안에 댓글 단 dot 이 있을 때 노출되는 작은 채팅 배지.
  Future<void> _registerClusterCommentBadge(mapbox.MapboxMap map) =>
      _registerIconBadge(
        map,
        imageId: _clusterCommentBadgeImg,
        iconData: Icons.chat_bubble_rounded,
      );

  /// 22×22 흰 원 + 어두운 stroke + Material 아이콘 글리프. 클러스터 indicator 공용.
  Future<void> _registerIconBadge(
    mapbox.MapboxMap map, {
    required String imageId,
    required IconData iconData,
  }) async {
    const size = 22;
    const sizeF = 22.0;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    // 흰 원 배경
    canvas.drawCircle(
      const Offset(sizeF / 2, sizeF / 2),
      sizeF / 2,
      Paint()..color = Colors.white,
    );
    // 어두운 외곽 stroke (다크 맵에서도 읽힘 보장)
    canvas.drawCircle(
      const Offset(sizeF / 2, sizeF / 2),
      sizeF / 2 - 0.75,
      Paint()
        ..color = Colors.black.withAlpha(180)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    // Material 아이콘 글리프
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontFamily: iconData.fontFamily,
          package: iconData.fontPackage,
          fontSize: 13,
          color: Colors.black87,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset((sizeF - tp.width) / 2, (sizeF - tp.height) / 2),
    );

    final img = await recorder.endRecording().toImage(size, size);
    final bd = await img.toByteData(format: ui.ImageByteFormat.png);
    if (bd == null) return;
    try {
      await map.style.addStyleImage(
        imageId,
        2.0,
        mapbox.MbxImage(
          width: size,
          height: size,
          data: bd.buffer.asUint8List(),
        ),
        false,
        [],
        [],
        null,
      );
    } catch (_) {
      // 재진입 (스타일 전환) 시 이미 등록돼 있으면 무시.
    }
  }

  Future<void> _addMemberLayers(
      mapbox.MapboxMap map, MemberTrack track) async {
    final memberId = track.memberId;
    final color =
        colorFromHex(track.colorHex, fallback: DottieColors.primary);
    // 내 캐릭터는 마지막 dot 자리를 GPS 레이어로 비우므로(아바타 대신 현재
    // 위치로 이동), 그 dot 을 일반 dot 마커로 그려야 "빈 점"이 안 된다.
    // 타인은 마지막 dot 을 아바타가 덮으므로 기존대로 마커에서 제외 유지.
    final isMe = _myUid != null && memberId == _myUid;
    final excludeLast = !isMe;
    final srcId = _memberSrcId(memberId);
    final clusterCircleId = _memberClusterCircleId(memberId);
    final clusterCountId = _memberClusterCountId(memberId);
    final dotsCircleId = _memberDotsCircleId(memberId);
    final orderTextId = _memberOrderTextId(memberId);
    final photoLayerId = _memberPhotoLayerId(memberId);

    // 멤버별 cluster source.
    // clusterProperties: cluster 안 dot 들의 has_comment / has_photo 를 OR aggregate.
    // → 클러스터 표시 시 댓글 / 사진 존재 여부 시각 단서 노출용.
    await map.style.addSource(mapbox.GeoJsonSource(
      id: srcId,
      data: _buildMemberGeoJson(track),
      cluster: true,
      clusterMaxZoom: 14,
      clusterRadius: 50,
      clusterProperties: {
        'has_any_comment': ['any', ['get', 'has_comment']],
        'has_any_photo': ['any', ['get', 'has_photo']],
      },
    ));

    // 클러스터 원 — 다크 글래스 chip 스타일.
    // 두꺼운 멤버색 fill 대신 어두운 배경 + 멤버색 ring + 흰 카운트.
    // 시각 노이즈를 줄이고 정체성은 stroke 색으로 유지.
    await map.style.addLayer(mapbox.CircleLayer(
      id: clusterCircleId,
      sourceId: srcId,
      filter: ["has", "point_count"],
      circleRadius: 18.0,
      circleColor: DottieColors.surfaceFloating.toARGB32(),
      circleStrokeWidth: 2.5,
      circleStrokeColor: color.toARGB32(),
    ));

    // 클러스터 개수 텍스트
    await map.style.addLayer(mapbox.SymbolLayer(
      id: clusterCountId,
      sourceId: srcId,
      filter: ["has", "point_count"],
      textColor: Colors.white.toARGB32(),
      textSize: 13.0,
    ));
    await map.style.setStyleLayerProperty(
      clusterCountId, 'text-field',
      '["get", "point_count_abbreviated"]',
    );

    // 개별 dot 원 (멤버 색 + 흰 테두리, 마지막 제외).
    //
    // 사진 dot 도 **썸네일 로드 전엔 dotsCircle 로 placeholder 표시** —
    // 그렇지 않으면 photoLayer 의 default fallback styleImage 가 일부 시나리오
    // (등록 타이밍/이미지 누락) 에서 안 그려져 dot 이 invisible 이 되는 회귀가 있음.
    // (commentIndicator 만 우측 상단에 떠 있는 듯한 모양으로 보였던 버그.)
    await map.style.addLayer(mapbox.CircleLayer(
      id: dotsCircleId,
      sourceId: srcId,
      filter: [
        "all",
        ["!", ["has", "point_count"]],
        if (excludeLast) ["==", ["get", "is_last"], false],
        ["any",
          ["==", ["get", "has_photo"], false],
          ["==", ["get", "thumbnail_loaded"], false],
        ],
      ],
      circleRadius: 9.0,
      circleColor: color.toARGB32(),
      circleStrokeWidth: 2.5,
      circleStrokeColor: Colors.white.withAlpha(220).toARGB32(),
    ));

    // 사진 썸네일 — 실제로 thumbnail 이 로드된 dot 만 그린다.
    // (`photo_icon_id` 가 default fallback 일 때는 dotsCircle 가 대신 표시.)
    //
    // iconImage 는 정적 placeholder(default dot) 로 추가하고, data-driven 표현식은
    // setStyleLayerProperty 로 별도 적용한다 — 이 프로젝트의 다른 expression(text-field 등)
    // 과 동일한 패턴. mapbox_maps_flutter 2.x 에서 constructor 의 iconImage 에
    // `["get", ...]` 식을 직접 넣으면 풀리지 않는 케이스가 있어 photo dot 동그라미 자체가
    // 누락되는 회귀가 발생하므로 이렇게 분리.
    // minZoom 제거 — 줌 아웃 됐을 때도 (cluster 가 안 형성된 sparse 케이스)
    // 사진 dot 이 그대로 보이도록. dense 영역은 native cluster 가 자동으로
    // 카운트 뱃지로 합쳐 보여줌 (clusterMaxZoom 14, clusterRadius 50px).
    await map.style.addLayer(mapbox.SymbolLayer(
      id: photoLayerId,
      sourceId: srcId,
      filter: [
        "all",
        ["!", ["has", "point_count"]],
        ["==", ["get", "has_photo"], true],
        ["==", ["get", "thumbnail_loaded"], true],
        if (excludeLast) ["==", ["get", "is_last"], false],
      ],
      iconImage: _memberDefaultDotImg(memberId),
      iconSize: 1.0,
      iconAnchor: mapbox.IconAnchor.CENTER,
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
    ));
    await map.style.setStyleLayerProperty(
      photoLayerId, 'icon-image', '["get", "photo_icon_id"]',
    );

    // 순서 번호 (zoom ≥ 14, 마지막 제외, dotsCircle 가 그려질 때만 노출).
    await map.style.addLayer(mapbox.SymbolLayer(
      id: orderTextId,
      sourceId: srcId,
      filter: [
        "all",
        ["!", ["has", "point_count"]],
        if (excludeLast) ["==", ["get", "is_last"], false],
        ["any",
          ["==", ["get", "has_photo"], false],
          ["==", ["get", "thumbnail_loaded"], false],
        ],
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
    _orderTextLayerIds.add(orderTextId);
    // 기본 OFF — 사용자가 토글 버튼으로 켠다.
    final initialShowOrder = ref
            .read(sharedMapNotifierProvider(widget.roomId, widget.date))
            ?.showOrderNumbers ??
        false;
    if (!initialShowOrder) {
      await map.style.setStyleLayerProperty(orderTextId, 'visibility', 'none');
    }

    // 출발 깃발 제거 — 첫 dot 도 다른 dot 과 동일한 원형/사진 마커로 표시.

    // 도착 — 멤버 paperdoll 아바타.
    // 내 캐릭터는 GPS 기반 레이어로 대체 (현재 위치 표시). 타인은 마지막 dot 위치.
    final avatarRingLayerId = 'sm-avatar-ring-$memberId';
    final avatarEndLayerId = _memberAvatarEndLayerId(memberId);

    if (_myUid != null && memberId == _myUid) {
      // 내 캐릭터: GPS source + layer. 마지막 dot 좌표로 초기화 → GPS 도착 시 이동.
      await _addMyGpsLayer(map, memberId, track);
    } else {
      //  (a) 발 위치에 멤버색 ring (CircleLayer) — 정체성 강조
      //  (b) 그 위에 paperdoll 아바타 (SymbolLayer)
      // 두 layer가 같은 source/filter 를 공유해 같은 dot에 정렬.
      final endFilter = [
        "all",
        ["!", ["has", "point_count"]],
        ["==", ["get", "is_last"], true],
      ];
      await map.style.addLayer(mapbox.CircleLayer(
        id: avatarRingLayerId,
        sourceId: srcId,
        filter: endFilter,
        circleRadius: 16.0,
        circleColor: DottieColors.surfaceFloating.toARGB32(),
        circleStrokeWidth: 2.5,
        circleStrokeColor: color.toARGB32(),
      ));
      await map.style.addLayer(mapbox.SymbolLayer(
        id: avatarEndLayerId,
        sourceId: srcId,
        filter: endFilter,
        iconImage: _charImageKey(memberId),
        iconSize: 0.6,
        iconAnchor: mapbox.IconAnchor.BOTTOM,
        iconOffset: [0.0, 6.0], // 발이 ring 안에 정확히 닿도록 미세 조정
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
      ));
      // 재생 모드 시 숨기기 위해 추적
      _endMarkerLayerIds.add(avatarRingLayerId);
      _endMarkerLayerIds.add(avatarEndLayerId);
    }

    // 댓글 indicator — 줌 14+, 댓글이 있는 모든 dot에 표시.
    // (start/end 도 포함 — cluster aggregation 과 일관성. 안 그러면
    //  cluster 에선 보이다가 줌인 후 사라지는 누락 발생.)
    // photo 가 있는 dot 의 큰 썸네일 위에서도 자연스럽도록 우측 상단 오프셋.
    final commentIndicatorId = 'sm-dots-comment-$memberId';
    await map.style.addLayer(mapbox.CircleLayer(
      id: commentIndicatorId,
      sourceId: srcId,
      filter: [
        "all",
        ["!", ["has", "point_count"]],
        ["==", ["get", "has_comment"], true],
      ],
      minZoom: 14.0,
      circleRadius: 5.0,
      circleColor: Colors.white.toARGB32(),
      circleStrokeWidth: 1.5,
      circleStrokeColor: Colors.black.withAlpha(180).toARGB32(),
      circleTranslate: [10.0, -10.0], // 우측 상단 오프셋
    ));

    // 클러스터 사진 indicator — cluster 안 dot 중 하나라도 사진 있으면 표시.
    // 카메라 배지 아이콘, cluster 좌측 상단 (댓글 indicator 와 대칭).
    // **맨 마지막에 추가** — 인접한 다른 멤버 dot/avatar 위에 항상 노출되도록.
    final clusterPhotoId = 'sm-cluster-photo-$memberId';
    await map.style.addLayer(mapbox.SymbolLayer(
      id: clusterPhotoId,
      sourceId: srcId,
      filter: [
        "all",
        ["has", "point_count"],
        ["==", ["get", "has_any_photo"], true],
      ],
      iconImage: _clusterPhotoBadgeImg,
      iconSize: 1.0,
      iconAnchor: mapbox.IconAnchor.CENTER,
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
      iconTranslate: [-15.0, -15.0], // cluster 좌측 상단
    ));

    // 클러스터 댓글 indicator — cluster 안 dot 중 하나라도 댓글 있으면 표시.
    // 카메라 배지와 동일 디자인 (흰 원 + 채팅 아이콘), cluster 우측 상단.
    final clusterCommentId = 'sm-cluster-comment-$memberId';
    await map.style.addLayer(mapbox.SymbolLayer(
      id: clusterCommentId,
      sourceId: srcId,
      filter: [
        "all",
        ["has", "point_count"],
        ["==", ["get", "has_any_comment"], true],
      ],
      iconImage: _clusterCommentBadgeImg,
      iconSize: 1.0,
      iconAnchor: mapbox.IconAnchor.CENTER,
      iconAllowOverlap: true,
      iconIgnorePlacement: true,
      iconTranslate: [15.0, -15.0], // cluster 우측 상단
    ));

    // 탭 hit-testing 대상에 누적 (indicator 자체는 hit 대상 아님 — dot 마커가 커버)
    // 내 캐릭터는 GPS 레이어라 탭 대상 없음 — avatarEndLayerId 도 레이어 없으므로 제외.
    _hitLayerIds.addAll([
      clusterCircleId,
      dotsCircleId,
      photoLayerId,
      if (_myUid == null || memberId != _myUid) avatarEndLayerId,
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
    final end = await MapMarkerRenderer.renderEndPin(color: color);
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

  /// 내 캐릭터를 GPS 기반 별도 source/layer 로 추가.
  /// 초기 좌표: 마지막 dot (GPS fix 전 즉시 표시용). GPS 도착 시 _updateMyGpsLayer 가 이동.
  Future<void> _addMyGpsLayer(
      mapbox.MapboxMap map, String memberId, MemberTrack track) async {
    final last = track.sequence.frames.last;
    final feature = jsonEncode(_posFeature(
      last.dot.latitude,
      last.dot.longitude,
      dotId: last.dot.id,
      memberId: memberId,
    ));
    try {
      await map.style.addSource(mapbox.GeoJsonSource(
        id: _myGpsSrcId,
        data: feature,
      ));
      await map.style.addLayer(mapbox.SymbolLayer(
        id: _myGpsLayerId,
        sourceId: _myGpsSrcId,
        iconImage: _charImageKey(memberId),
        iconSize: 0.6,
        iconAnchor: mapbox.IconAnchor.BOTTOM,
        iconAllowOverlap: true,
        iconIgnorePlacement: true,
      ));
      _myGpsLayerAdded = true;
      _endMarkerLayerIds.add(_myGpsLayerId);
      _hitLayerIds.add(_myGpsLayerId);
    } catch (e) {
      debugPrint('[SharedMap] myGpsLayer error: $e');
    }
  }

  Future<void> _updateMyGpsLayer(Position pos) async {
    if (_mapboxMap == null || !_styleLoaded || !_myGpsLayerAdded) return;
    // GPS 위치가 이동해도 dot_id/member_id 는 마지막 dot 기준으로 유지 — 탭 가능하도록.
    final smState =
        ref.read(sharedMapNotifierProvider(widget.roomId, widget.date));
    final tracks = smState?.tracks ?? [];
    MemberTrack? myTrack;
    for (final t in tracks) {
      if (t.memberId == _myUid) {
        myTrack = t;
        break;
      }
    }
    final frames = myTrack?.sequence.frames ?? [];
    final lastDot = frames.isEmpty ? null : frames.last.dot;
    final feature = jsonEncode(_posFeature(
      pos.latitude,
      pos.longitude,
      dotId: lastDot?.id,
      memberId: _myUid,
    ));
    try {
      await _mapboxMap!.style
          .setStyleSourceProperty(_myGpsSrcId, 'data', feature);
    } catch (e) {
      debugPrint('[SharedMap] myGpsLayer update error: $e');
    }
  }

  void _startMyGpsUpdates() {
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
        if (!mounted) return;
        _lastGpsPos = pos;
        await _updateMyGpsLayer(pos);
      } catch (_) {}
    });
    Geolocator.getCurrentPosition(
      locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.high),
    ).then((pos) async {
      if (!mounted) return;
      _lastGpsPos = pos;
      await _updateMyGpsLayer(pos);
    }).catchError((_) {});
  }

  /// 내 위치 버튼 탭 — A/B 토글.
  /// A(기본): 내 현재 위치로 카메라 flyTo. 내 캐릭터가 GPS 위치에 그려져
  ///   있으므로 주변 dot 과의 위치 관계가 바로 보인다.
  /// B: 내 위치 + 그날 dot 전체가 한 화면에 들어오도록 bounds fit —
  ///   "내가 기록들에서 얼마나 떨어져 있나" 비교용.
  Future<void> _onMyLocationTap() async {
    final map = _mapboxMap;
    if (map == null) return;
    HapticFeedback.lightImpact();

    var pos = _lastGpsPos;
    if (pos == null) {
      // 폴링 첫 응답 전이거나 권한 거부로 폴링이 계속 실패 중 — 1회 직접 시도.
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
        _lastGpsPos = pos;
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('현재 위치를 가져올 수 없어요. 위치 권한을 확인해주세요.')),
        );
        return;
      }
    }
    if (!mounted) return;

    try {
      if (!_myLocationFitAll) {
        // A: 내 위치로 이동
        await map.flyTo(
          mapbox.CameraOptions(
            center: mapbox.Point(
              coordinates: mapbox.Position(pos.longitude, pos.latitude),
            ),
            zoom: 16.0,
          ),
          mapbox.MapAnimationOptions(duration: 900),
        );
        if (mounted) setState(() => _myLocationFitAll = true);
      } else {
        // B: 내 위치 + 그날 dot 전체 보기
        final smState =
            ref.read(sharedMapNotifierProvider(widget.roomId, widget.date));
        final tracks = smState?.tracks ?? [];
        final lats = tracks
            .expand((t) => t.sequence.frames.map((f) => f.dot.latitude))
            .toList()
          ..add(pos.latitude);
        final lngs = tracks
            .expand((t) => t.sequence.frames.map((f) => f.dot.longitude))
            .toList()
          ..add(pos.longitude);

        final minLat = lats.reduce((a, b) => a < b ? a : b);
        final maxLat = lats.reduce((a, b) => a > b ? a : b);
        final minLng = lngs.reduce((a, b) => a < b ? a : b);
        final maxLng = lngs.reduce((a, b) => a > b ? a : b);

        // maxZoom 16 — dot 이 없거나 내 위치와 가까우면 과도한 줌인 방지
        // (_fitCameraToAllDots 와 동일 정책).
        final camera = await map.cameraForCoordinateBounds(
          mapbox.CoordinateBounds(
            southwest: mapbox.Point(
                coordinates:
                    mapbox.Position(minLng - 0.012, minLat - 0.012)),
            northeast: mapbox.Point(
                coordinates:
                    mapbox.Position(maxLng + 0.012, maxLat + 0.012)),
            infiniteBounds: false,
          ),
          mapbox.MbxEdgeInsets(top: 100, left: 40, bottom: 220, right: 40),
          null, null, 16.0, null,
        );
        await map.flyTo(camera, mapbox.MapAnimationOptions(duration: 900));
        if (mounted) setState(() => _myLocationFitAll = false);
      }
    } catch (e) {
      debugPrint('[SharedMap] myLocation camera error: $e');
    }
  }

  Future<void> _loadPhotoThumbnails(
      mapbox.MapboxMap map, List<MemberTrack> tracks) async {
    for (final track in tracks) {
      final color =
          colorFromHex(track.colorHex, fallback: DottieColors.primary);
      final frames = _sortedFrames(track);

      // 멤버별 dot.id → 1-based order
      final orderById = <String, int>{};
      for (var i = 0; i < frames.length; i++) {
        orderById[frames[i].dot.id] = i + 1;
      }

      // BE variant 가 권위 — thumb URL 이 있는 dot 만 핀 썸네일 후보.
      // photoUrl(원본) 만 있는 transient dot 은 thumb 생성 후 다음 갱신 시 합류.
      final photoFrames = frames
          .where((f) => f.dot.displayThumbUrl != null)
          .toList();
      if (photoFrames.isEmpty) continue;

      final photoIconIds = <String, String>{};

      await Future.wait(photoFrames.map((f) async {
        final dot = f.dot;
        final thumbUrl = dot.displayThumbUrl!;
        final bytes = await MediaThumbnailLoader.loadCircle(
          thumbUrl,
          borderColor: color,
          orderNumber: orderById[dot.id],
          badgeColor: color,
        );
        if (bytes == null || !mounted) {
          debugPrint(
            '[SharedMap.thumb] LOAD_FAIL dot=${dot.id.substring(0, 8)} '
            'url=$thumbUrl',
          );
          return;
        }
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
          debugPrint(
            '[SharedMap.thumb] OK dot=${dot.id.substring(0, 8)} imgId=$imgId',
          );
        } catch (e) {
          debugPrint(
            '[SharedMap.thumb] addStyleImage_FAIL dot=${dot.id.substring(0, 8)} '
            'err=$e',
          );
        }
      }));

      debugPrint(
        '[SharedMap.thumb] member=${track.memberId.substring(0, 8)} '
        'photoFrames=${photoFrames.length} '
        'loaded=${photoIconIds.length}',
      );

      if (!mounted || photoIconIds.isEmpty) continue;

      // 멤버별 photo icon 매핑 캐시 — _refreshMemberSources 가 source 재갱신 시 재사용.
      _photoIconIdsByMember[track.memberId] = photoIconIds;

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
        debugPrint(
          '[SharedMap.thumb] source UPDATED member=${track.memberId.substring(0, 8)}',
        );
      } catch (e) {
        debugPrint('[SharedMap] thumbnail source update error: $e');
      }
    }
  }

  /// invalidate 후 sharedMap 의 tracks 가 갱신됐을 때 호출.
  /// 비싼 자산(레이어/이미지/캐릭터) 은 재로드 안 하고 멤버별 GeoJSON source 데이터만 교체.
  /// → 삭제된 dot 즉시 사라짐, 클러스터 집계도 자동 재계산, has_comment indicator 도 갱신.
  /// photo_icon_id 는 캐시(_photoIconIdsByMember)에서 재사용 — 새로 생긴 photo dots 는
  /// 다음 진입 / 재setup 시 _loadPhotoThumbnails 가 처리.
  Future<void> _refreshMemberSources(List<MemberTrack> tracks) async {
    if (_mapboxMap == null || !_styleLoaded) return;
    debugPrint(
      '[SharedMap.refresh] tracks=${tracks.length} '
      'cachedPhotoMembers=${_photoIconIdsByMember.length}',
    );
    for (final t in tracks) {
      final cached = _photoIconIdsByMember[t.memberId];
      try {
        await _mapboxMap!.style.setStyleSourceProperty(
          _memberSrcId(t.memberId),
          'data',
          _buildMemberGeoJson(t, photoIconIds: cached),
        );
        debugPrint(
          '[SharedMap.refresh] OK member=${t.memberId.substring(0, 8)} '
          'frames=${t.sequence.frames.length} '
          'cachedThumbs=${cached?.length ?? 0}',
        );
      } catch (e) {
        debugPrint(
          '[SharedMap.refresh] FAIL member=${t.memberId.substring(0, 8)} err=$e',
        );
      }
    }
  }

  // ── 지도 탭 처리 ──────────────────────────────────────

  Future<void> _handleMapTap(mapbox.ScreenCoordinate sc) async {
    if (_mapboxMap == null || !mounted) return;

    // 0) cinema 자동 숨김 상태에서는 첫 탭은 chrome 복원 전용 — feature 탭은 무시
    final isPlayback = ref
            .read(sharedMapNotifierProvider(widget.roomId, widget.date))
            ?.viewMode ==
        SharedMapViewMode.playback;
    if (isPlayback && !_chromeVisible) {
      _showChrome(isPlayback: true);
      return;
    }
    // 그 외에는 idle 타이머만 리셋 (탭으로 인한 활동)
    _resetIdleTimer(isPlayback: isPlayback);

    // 1) 인카운터 마커 우선 체크 — dot/start/photo 보다 위에 떠 있는 마커
    if (_meetingHitLayerIds.isNotEmpty) {
      try {
        final mFeatures = await _mapboxMap!.queryRenderedFeatures(
          mapbox.RenderedQueryGeometry.fromScreenBox(
            mapbox.ScreenBox(
              min: mapbox.ScreenCoordinate(
                  x: sc.x - _hitRadius, y: sc.y - _hitRadius),
              max: mapbox.ScreenCoordinate(
                  x: sc.x + _hitRadius, y: sc.y + _hitRadius),
            ),
          ),
          mapbox.RenderedQueryOptions(
            layerIds: List<String>.from(_meetingHitLayerIds),
            filter: null,
          ),
        );
        for (final f in mFeatures) {
          if (f == null) continue;
          final props = f.queriedFeature.feature['properties'] as Map?;
          final eid = (props?['encounter_id'] as num?)?.toInt();
          if (eid == null) continue;
          final smState = ref.read(
              sharedMapNotifierProvider(widget.roomId, widget.date));
          if (smState == null ||
              eid < 0 ||
              eid >= smState.meetings.length) {
            continue;
          }
          if (!mounted) return;
          HapticFeedback.lightImpact();
          _idleTimer?.cancel();
          // 시트 안에서 chip 탭 → dot 풀 콘텐츠(사진/메모/시간 + 댓글) inline.
          await _MeetingDetailSheet.show(
            context,
            smState.meetings[eid],
            smState.tracks,
            smState.paperdolls,
            widget.roomId,
          );
          if (!mounted) return;
          _showChrome(isPlayback: true);
          return;
        }
      } catch (e) {
        debugPrint('[SharedMap] meeting tap error: $e');
      }
    }

    // 2) 기존 dot/cluster 로직 — sheet 표시 동안 idle timer 보류
    _idleTimer?.cancel();
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

      // 멘션 자동완성용 — 전체 룸 멤버 (그날 dot 없는 멤버도 포함).
      final room = ref.read(roomDetailProvider(widget.roomId)).valueOrNull;
      final membersByRoomId = <String, List<DotMemberHint>>{
        widget.roomId: (room?.members ?? const [])
            .map((m) => DotMemberHint(
                  userId: m.userId,
                  nickname: m.nickname,
                  color: colorFromHex(m.character.colorHex),
                ))
            .toList(),
      };
      final hideRoomNames = room != null
          ? <String, String>{widget.roomId: room.name}
          : <String, String>{};

      if (matchedPairs.length == 1) {
        final pair = matchedPairs.first;
        await DotDetailSheet.show(
          context,
          pair.dot,
          memberName: pair.track.nickname,
          memberColor: colorFromHex(pair.track.colorHex),
          roomId: widget.roomId,
          membersByRoomId: membersByRoomId,
          ownerUserId: pair.track.memberId,
          hideRoomNames: hideRoomNames,
        );
      } else {
        // 여러 dot — 첫 번째 멤버 정보로 헤더 표시 (혼합 멤버면 memberName 생략)
        final allSameMember = matchedPairs
            .every((p) => p.track.memberId == matchedPairs.first.track.memberId);
        final track = allSameMember ? matchedPairs.first.track : null;
        final ownerByDotId = <String, String>{
          for (final p in matchedPairs) p.dot.id: p.track.memberId,
        };
        await DotListSheet.show(
          context,
          matchedPairs.map((p) => p.dot).toList(),
          memberName: track?.nickname,
          memberColor: track != null ? colorFromHex(track.colorHex) : null,
          roomId: widget.roomId,
          membersByRoomId: membersByRoomId,
          ownerByDotId: ownerByDotId,
        );
      }
    } catch (e) {
      debugPrint('[SharedMap] tap error: $e');
    } finally {
      if (mounted) _showChrome(isPlayback: isPlayback);
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

    // 공통 벽시계 기반 위치 — 모든 멤버를 같은 실제 시각에 동기화.
    // (globalStart~globalEnd 를 progress 로 선형 매핑한 시각 t)
    final t = smState.currentTimeAt(smState.progress);
    final positions = t != null
        ? SharedMapBuilder.interpolateAllAtTime(smState.tracks, t)
        : SharedMapBuilder.interpolateAll(smState.tracks, smState.progress);

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

    // maxZoom 16 — dot 1~2개로 좁은 범위면 너무 줌인되는 것 방지.
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
          null, null, 16.0, null,
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
          colorFromHex(track.colorHex, fallback: DottieColors.primary);
      final trailSourceId = 'trail-${track.memberId}';
      final trailHaloId = 'trail-halo-${track.memberId}';
      final trailLayerId = 'trail-layer-${track.memberId}';
      final trailHairlineId = 'trail-hairline-${track.memberId}';
      final arrowsLayerId = _memberArrowsLayerId(track.memberId);

      // line-gradient 사용 위해 lineMetrics 활성화 (Mapbox 요구사항).
      await map.style.addSource(mapbox.GeoJsonSource(
        id: trailSourceId,
        data: jsonEncode({
          'type': 'Feature',
          'geometry': {'type': 'LineString', 'coordinates': coords},
        }),
        lineMetrics: true,
      ));

      // (1) Halo — 멤버 색 글로우 (가장 아래). 다크 위 시끄럽지 않게 alpha 60.
      await map.style.addLayer(mapbox.LineLayer(
        id: trailHaloId,
        sourceId: trailSourceId,
        lineColor: memberColor.withAlpha(60).toARGB32(),
        lineWidth: 10.0,
        lineBlur: 4.0,
        lineCap: mapbox.LineCap.ROUND,
        lineJoin: mapbox.LineJoin.ROUND,
      ));

      // (2) Solid — 시간 흐름 페이드 (오래된 시작 alpha 0.35 → 최신 끝 alpha 1.0).
      // line-gradient 는 lineColor 를 덮어쓰므로 fallback 만 지정.
      await map.style.addLayer(mapbox.LineLayer(
        id: trailLayerId,
        sourceId: trailSourceId,
        lineColor: memberColor.withAlpha(200).toARGB32(),
        lineWidth: 3.0,
        lineCap: mapbox.LineCap.ROUND,
        lineJoin: mapbox.LineJoin.ROUND,
      ));
      final argb = memberColor.toARGB32();
      final r = (argb >> 16) & 0xff;
      final g = (argb >> 8) & 0xff;
      final b = argb & 0xff;
      await map.style.setStyleLayerProperty(
        trailLayerId,
        'line-gradient',
        jsonEncode([
          'interpolate',
          ['linear'],
          ['line-progress'],
          0.0, 'rgba($r, $g, $b, 0.35)',
          1.0, 'rgba($r, $g, $b, 1.0)',
        ]),
      );

      // (3) White hairline — 다크 맵 위 가독성 보강.
      await map.style.addLayer(mapbox.LineLayer(
        id: trailHairlineId,
        sourceId: trailSourceId,
        lineColor: Colors.white.withAlpha(60).toARGB32(),
        lineWidth: 0.5,
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
    // 사이드 이펙트는 분기와 무관하게 항상 등록 — null/empty/normal 어느 상태든
    // 데이터 변화에 반응해야 함.
    //
    // 데이터 도착 시 두 가지 동작을 병렬로:
    //  1) 지도 setup (카메라/레이어/캐릭터)
    //  2) focusDot 시트 (지도 setup 과 독립 — 즉시 표시)
    ref.listen<SharedMapState?>(
      sharedMapNotifierProvider(widget.roomId, widget.date),
      (prev, next) {
        debugPrint(
          '[SharedMap.listen] prev=${prev == null ? "null" : "tracks=${prev.tracks.length}"} '
          'next=${next == null ? "null" : "tracks=${next.tracks.length}"} '
          'setupDone=$_mapSetupDone '
          'tracksDiff=${prev != null && next != null ? !identical(prev.tracks, next.tracks) : "n/a"}',
        );
        _trySetupMap();
        _tryOpenFocusedSheet();
        // 초기 setup 이후 tracks 가 새로 들어오면 (예: dot 삭제 후 invalidate)
        // 레이어/이미지 재로드 없이 멤버 source 데이터만 갱신 — 즉시 반영.
        // prev != null 가드: 첫 진입 시 _trySetupMap 의 async 작업과 동시 실행돼
        // source 가 아직 안 만들어진 상태로 setStyleSourceProperty 가 silent 실패하는 race 방지.
        if (_mapSetupDone &&
            prev != null &&
            next != null &&
            !identical(prev.tracks, next.tracks)) {
          _refreshMemberSources(next.tracks);
        }
        // viewMode 전환 시 캐릭터 layer visibility 동기화 + chrome 표시 리셋
        // + Mapbox 로고/attribution 위치 (패널 위 vs 왼쪽 하단)
        if (prev?.viewMode != next?.viewMode && next != null) {
          final playback = next.viewMode == SharedMapViewMode.playback;
          _setCharactersVisible(playback);
          _showChrome(isPlayback: playback);
          _updateMapboxChromeMargins(playback);
        }
        // 순서번호 토글 시 layer visibility 동기화
        if (prev?.showOrderNumbers != next?.showOrderNumbers && next != null) {
          _setOrderNumbersVisible(next.showOrderNumbers);
        }
      },
    );
    // 캐시된 데이터로 진입한 경우 listen 이 안 fire 하므로 build 마다 시도
    // (가드 — `_focusedDotShown` 플래그로 중복 방지)
    _tryOpenFocusedSheet();

    // 데이터 분기 — null(로딩) / tracks 비어있음(empty) 일 때 명시적 화면 노출.
    // (예전엔 두 케이스 모두 검은 Scaffold + 빈 MapWidget 만 보여 "검은 화면"
    //  버그처럼 인지됐음.)
    final smState =
        ref.watch(sharedMapNotifierProvider(widget.roomId, widget.date));
    if (smState == null) {
      return _buildLoadingScaffold();
    }
    if (smState.tracks.isEmpty) {
      return _buildEmptyScaffold();
    }

    final viewMode = ref.watch(
      sharedMapNotifierProvider(widget.roomId, widget.date)
          .select((s) => s?.viewMode ?? SharedMapViewMode.explore),
    );
    final isPlayback = viewMode == SharedMapViewMode.playback;
    final showOrderNumbers = ref.watch(
      sharedMapNotifierProvider(widget.roomId, widget.date)
          .select((s) => s?.showOrderNumbers ?? false),
    );

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
              // 초기는 explore — 로고/attribution 왼쪽 하단으로.
              // viewMode 변화 시 ref.listen 에서 _updateMapboxChromeMargins 로 갱신.
              _updateMapboxChromeMargins(false);
            },
            onStyleLoadedListener: (_) async {
              _styleLoaded = true;
              // 스타일 전환 시 모든 레이어가 wipe 되므로 setup 플래그 + 멤버별 컬렉션을 리셋.
              _mapSetupDone = false;
              _arrowLayerIdByMember.clear();
              _characterLayerIds.clear();
              _endMarkerLayerIds.clear();
              _orderTextLayerIds.clear();
              _meetingHitLayerIds.clear();
              _hitLayerIds.clear();
              _photoIconIdsByMember.clear();
              _meetingPulseLayerId = null;
              _myGpsLayerAdded = false;
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

          // 상단 유리 알약 바 + 가로 데이트 스트립 (cinema 모드 자동 숨김 대상)
          Positioned(
            top: 0, left: 0, right: 0,
            child: _ChromeFader(
              visible: _chromeVisible,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GlassDateHeader.date(
                    date: widget.date,
                    onBack: () => Navigator.of(context).pop(),
                    onTapDate: () => _showCalendarSheet(),
                    isDaytime: _isDaytime,
                    trailing: IconButton(
                      icon: const Icon(Icons.settings_outlined,
                          color: Colors.white, size: 20),
                      onPressed: () =>
                          context.push('/rooms/${widget.roomId}/info'),
                      tooltip: '방 설정',
                    ),
                  ),
                  const SizedBox(height: Dimensions.xs),
                  Consumer(
                    builder: (_, ref, __) {
                      final activeDates = ref
                              .watch(roomDetailProvider(widget.roomId))
                              .valueOrNull
                              ?.sharedDates
                              .toSet() ??
                          const <String>{};
                      return DateStrip(
                        selectedDate: DateTime.tryParse(widget.date) ??
                            DottieDateUtils.todayStart(),
                        activeDates: activeDates,
                        isDaytime: _isDaytime,
                        onDateSelected: (date) {
                          context.pushReplacement(
                            '/rooms/${widget.roomId}/map',
                            extra: {
                              'date': DottieDateUtils.toDateString(date)
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: Dimensions.xs),
                  // 모든날 기록 토글 — 룸 누적(전체일) 보기로 전환.
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AllDaysToggleChip(
                          isDaytime: _isDaytime,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            context.pushReplacement(
                                '/rooms/${widget.roomId}/all');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 하단 유리 컨트롤 패널 — playback 모드에서만 슬라이드업 (+ cinema 페이드)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _ChromeFader(
              visible: _chromeVisible,
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
          ),

          // 우측 하단 컨트롤 스택 (순서번호 토글 + 재생 모드 토글)
          Positioned(
            right: Dimensions.md,
            bottom: Dimensions.md,
            child: SafeArea(
              child: _ChromeFader(
                visible: _chromeVisible,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 내 위치 버튼 — GPS 캐릭터가 그려지는 explore 모드 전용.
                    if (!isPlayback) ...[
                      _MyLocationFab(
                        fitAll: _myLocationFitAll,
                        onTap: _onMyLocationTap,
                      ),
                      const SizedBox(height: Dimensions.sm),
                    ],
                    _OrderNumbersToggle(
                      active: showOrderNumbers,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref
                            .read(sharedMapNotifierProvider(
                                    widget.roomId, widget.date)
                                .notifier)
                            .setShowOrderNumbers(!showOrderNumbers);
                      },
                    ),
                    const SizedBox(height: Dimensions.sm),
                    _PlaybackToggleFab(
                      isPlayback: isPlayback,
                      onToggle: () {
                        HapticFeedback.mediumImpact();
                        ref
                            .read(sharedMapNotifierProvider(
                                    widget.roomId, widget.date)
                                .notifier)
                            .setViewMode(
                              isPlayback
                                  ? SharedMapViewMode.explore
                                  : SharedMapViewMode.playback,
                            );
                      },
                    ),
                  ],
                ),
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

    // 공통 벽시계 — 첫 멤버가 아니라 전 멤버의 최소/최대 dot 시각 기준.
    // currentTime 은 progress 를 그 구간에 선형 매핑한 실제 시각(정확).
    final startTime = smState.globalStartTime ?? DateTime.now();
    final endTime = smState.globalEndTime ?? DateTime.now();
    final currentTime = smState.currentTimeAt(smState.progress) ?? startTime;

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
        final color = colorFromHex(t.colorHex, fallback: DottieColors.primary);
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
class _SharedMapEmptyOverlay extends ConsumerStatefulWidget {
  const _SharedMapEmptyOverlay({required this.roomId, required this.date});
  final String roomId;
  final String date;

  @override
  ConsumerState<_SharedMapEmptyOverlay> createState() =>
      _SharedMapEmptyOverlayState();
}

class _SharedMapEmptyOverlayState
    extends ConsumerState<_SharedMapEmptyOverlay> {
  bool _redirected = false;
  bool _sharing = false;

  bool get _isToday {
    final today = DottieDateUtils.toDateString(DateTime.now());
    return widget.date == today;
  }

  @override
  Widget build(BuildContext context) {
    final smState =
        ref.watch(sharedMapNotifierProvider(widget.roomId, widget.date));
    // null = 로딩 중, empty tracks = 멤버 누구도 dot 없음.
    // 한 명이라도 dot 있으면 tracks.isNotEmpty 라 여기 안 들어옴.
    if (smState == null || smState.tracks.isNotEmpty) {
      return const SizedBox.shrink();
    }

    if (_isToday) {
      // 오늘 dot 유무에 따라 분기:
      //   - 있음 → "이 방에 공유하기" 버튼 노출 (공유로 즉시 채움)
      //   - 없음 → /today 로 redirect (기록 먼저 유도)
      final todayAsync = ref.watch(todayDayLogProvider);
      return todayAsync.when(
        loading: () => _shell(child: const _Spinner()),
        error: (_, __) => _shell(child: _backOnly()),
        data: (todayLog) {
          final hasTodayDots =
              todayLog != null && todayLog.dots.isNotEmpty;
          if (!hasTodayDots) {
            if (!_redirected) {
              _redirected = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                context.go('/today');
              });
            }
            return const SizedBox.shrink();
          }
          return _shell(child: _todayWithDots(todayLog));
        },
      );
    }

    // 과거 날짜 빈 상태 — 그 날짜로는 공유 동작 의미가 모호하므로 back 만 제공.
    return _shell(child: _backOnly());
  }

  // ── building blocks ─────────────────────────────────────────

  Widget _shell({required Widget child}) => Positioned.fill(
        child: Container(
          color: Colors.black87,
          child: SafeArea(
            child: Center(child: child),
          ),
        ),
      );

  Widget _backOnly() => Column(
        mainAxisSize: MainAxisSize.min,
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
            widget.date,
            style: TextStyle(
              color: Colors.white.withAlpha(140),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            label:
                const Text('돌아가기', style: TextStyle(color: Colors.white)),
          ),
        ],
      );

  Widget _todayWithDots(DayLog todayLog) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🗺️', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            '오늘 기록을 이 방에 공유해 보세요',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '오늘 ${todayLog.dots.length}개 dot 이 있어요',
            style: TextStyle(
              color: Colors.white.withAlpha(160),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed:
                  _sharing ? null : () => _shareToday(todayLog.id),
              icon: _sharing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.share_location_rounded),
              label: const Text('오늘 기록 이 방에 공유하기'),
              style: FilledButton.styleFrom(
                backgroundColor: DottieColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            label:
                const Text('돌아가기', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _shareToday(String todayDayLogId) async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      await ref
          .read(roomNotifierProvider.notifier)
          .shareDayLog(widget.roomId, todayDayLogId);
      if (!mounted) return;
      // 공유 성공 → sharedMap 재조회 → tracks 들어오면 overlay 자동 사라짐.
      ref.invalidate(sharedMapNotifierProvider(widget.roomId, widget.date));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오늘 기록을 방에 공유했어요!')),
      );
    } on ShareDayLogException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userMessageFor(e)),
          backgroundColor: e.code == 'ALREADY_SHARED'
              ? Colors.orange
              : DottieColors.error,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('공유에 실패했어요. 잠시 후 다시 시도해 주세요.'),
          backgroundColor: DottieColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();
  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      );
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

// ─── 인카운터 상세 시트 ─────────────────────────────────
//
// 인카운터 마커 탭 시 표시되는 다크 글래스 시트.
// 두 멤버 닉네임 + 시각/지속시간 + 장소(있으면) 표시.
class _MeetingDetailSheet extends ConsumerStatefulWidget {
  const _MeetingDetailSheet({
    required this.meeting,
    required this.tracks,
    required this.paperdolls,
    required this.roomId,
  });

  final MeetingEvent meeting;
  final List<MemberTrack> tracks;
  final Map<String, PaperdollConfig> paperdolls;
  final String roomId;

  /// chip 을 탭하면 그 멤버의 dot 풀 콘텐츠 (사진/메모/시간 + 댓글) 가
  /// 시트 안에 inline 으로 펼쳐짐 — 시트 안 닫음.
  static Future<void> show(
    BuildContext context,
    MeetingEvent meeting,
    List<MemberTrack> tracks,
    Map<String, PaperdollConfig> paperdolls,
    String roomId,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MeetingDetailSheet(
        meeting: meeting,
        tracks: tracks,
        paperdolls: paperdolls,
        roomId: roomId,
      ),
    );
  }

  @override
  ConsumerState<_MeetingDetailSheet> createState() =>
      _MeetingDetailSheetState();
}

class _MeetingDetailSheetState extends ConsumerState<_MeetingDetailSheet> {
  Dot? _selectedDot;
  String? _selectedUserId;
  String? _selectedNickname;
  Color? _selectedColor;

  MemberTrack? _trackOf(String id) {
    for (final t in widget.tracks) {
      if (t.memberId == id) return t;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final meeting = widget.meeting;
    final tracks = widget.tracks;
    final paperdolls = widget.paperdolls;

    // dot_id → Dot 매핑 (댓글 카운트 + 선택 dot 조회)
    final dotById = <String, Dot>{};
    for (final t in tracks) {
      for (final f in t.sequence.frames) {
        dotById[f.dot.id] = f.dot;
      }
    }

    final memberCount = meeting.userIds.length;
    int totalComments = 0;
    final chipData = <_MeetingChipData>[];
    for (var i = 0; i < memberCount; i++) {
      final uid = meeting.userIds[i];
      final dotId = i < meeting.dotIds.length ? meeting.dotIds[i] : null;
      final dot = dotId != null ? dotById[dotId] : null;
      final track = _trackOf(uid);
      final color = track != null
          ? colorFromHex(track.colorHex, fallback: DottieColors.primary)
          : DottieColors.primary;
      final commentCount = dot?.commentCount ?? 0;
      totalComments += commentCount;
      chipData.add(_MeetingChipData(
        userId: uid,
        nickname: track?.nickname ?? '?',
        color: color,
        paperdoll: paperdolls[uid],
        commentCount: commentCount,
        dot: dot,
      ));
    }

    final timeLabel = meeting.startedAt != null
        ? DottieDateUtils.toTimeString(meeting.startedAt!)
        : null;
    final durationLabel = meeting.durationMinutes != null
        ? '${meeting.durationMinutes}분 함께'
        : null;
    final hasMeta = timeLabel != null || durationLabel != null;
    final hasPlace =
        meeting.placeName != null && meeting.placeName!.isNotEmpty;

    // 멘션 자동완성용 멤버 힌트 — 인카운터 안 모든 멤버
    final membersByRoomId = <String, List<DotMemberHint>>{
      widget.roomId: chipData
          .map((d) => DotMemberHint(
                userId: d.userId,
                nickname: d.nickname,
                color: d.color,
              ))
          .toList(),
    };

    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          // iOS 상단 swipe-down(제어 센터/알림) 영역과 안전한 거리 — 78%.
          // 부족한 콘텐츠는 시트 내부 스크롤로 처리.
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.78,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1B1E).withAlpha(240),
            border: Border(
              top: BorderSide(color: Colors.white.withAlpha(28), width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 고정 handle
                const SizedBox(height: Dimensions.sm),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(60),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: Dimensions.md),
                // 본문 — 스크롤. 키보드 올라오면 입력란이 가려지지 않도록
                // bottom padding 에 viewInsets 반영.
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      Dimensions.lg,
                      0,
                      Dimensions.lg,
                      viewInsets + Dimensions.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            '$memberCount명이 함께 있었어요',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: Dimensions.lg),
                        // N명 chip Wrap — 활성 chip 강조 (선택된 멤버)
                        Wrap(
                          spacing: Dimensions.md,
                          runSpacing: Dimensions.md,
                          alignment: WrapAlignment.center,
                          children: chipData.map((d) {
                            return _MeetingMemberChip(
                              color: d.color,
                              name: d.nickname,
                              paperdoll: d.paperdoll,
                              commentCount: d.commentCount,
                              active: d.userId == _selectedUserId,
                              onTap: d.dot != null
                                  ? () => setState(() {
                                        _selectedDot = d.dot;
                                        _selectedUserId = d.userId;
                                        _selectedNickname = d.nickname;
                                        _selectedColor = d.color;
                                      })
                                  : null,
                            );
                          }).toList(),
                        ),
                        if (hasMeta || hasPlace) ...[
                          const SizedBox(height: Dimensions.lg),
                          if (hasMeta)
                            Center(
                              child: Text(
                                [timeLabel, durationLabel]
                                    .whereType<String>()
                                    .join(' · '),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (hasPlace) ...[
                            const SizedBox(height: 4),
                            Center(
                              child: Text(
                                meeting.placeName!,
                                style: TextStyle(
                                  color: Colors.white.withAlpha(180),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ],
                        if (totalComments > 0 && _selectedDot == null) ...[
                          const SizedBox(height: Dimensions.md),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(20),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: DottieColors.borderGlass,
                                    width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.chat_bubble_outline_rounded,
                                      color: Colors.white.withAlpha(200),
                                      size: 14),
                                  const SizedBox(width: 6),
                                  Text(
                                    '댓글 $totalComments개 — 멤버를 선택하세요',
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(220),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        // 선택된 멤버의 dot 풀 콘텐츠 (사진/메모/감정/시간 + 댓글)
                        if (_selectedDot != null) ...[
                          const SizedBox(height: Dimensions.lg),
                          Divider(
                            color: Colors.white.withAlpha(40),
                            height: 1,
                          ),
                          const SizedBox(height: Dimensions.md),
                          // 선택 멤버 헤더 (chip 위 활성 강조와 함께)
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _selectedColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_selectedNickname ?? ''}의 게시글',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: Dimensions.sm),
                          // 다크 시트 안에 라이트 카드 — DotContentBlock 은
                          // 라이트 테마 가정. dot 본문(사진/메모/감정/시간) +
                          // 그 하위 댓글까지 한 스크롤로 자연 노출.
                          // showMemberHeader: false — chip 이 이미 멤버 정체성 노출.
                          Container(
                            padding: const EdgeInsets.fromLTRB(
                                Dimensions.md,
                                Dimensions.md,
                                Dimensions.md,
                                Dimensions.sm),
                            decoration: BoxDecoration(
                              color: DottieColors.surface,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: DotContentBlock(
                              key: ValueKey(_selectedDot!.id),
                              dot: _selectedDot!,
                              memberName: _selectedNickname,
                              memberColor: _selectedColor,
                              roomId: widget.roomId,
                              membersByRoomId: membersByRoomId,
                              showMemberHeader: false,
                            ),
                          ),
                        ],
                      ],
                    ),
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

/// 시트 chip 렌더링용 즉시 묶음 — 빌드 중 한 번만 계산.
class _MeetingChipData {
  const _MeetingChipData({
    required this.userId,
    required this.nickname,
    required this.color,
    required this.paperdoll,
    required this.commentCount,
    required this.dot,
  });
  final String userId;
  final String nickname;
  final Color color;
  final PaperdollConfig? paperdoll;
  final int commentCount;
  final Dot? dot;
}

class _MeetingMemberChip extends ConsumerWidget {
  const _MeetingMemberChip({
    required this.color,
    required this.name,
    this.paperdoll,
    this.commentCount = 0,
    this.active = false,
    this.onTap,
  });
  final Color color;
  final String name;
  final PaperdollConfig? paperdoll;
  final int commentCount;

  /// 활성 chip — 시트 안에서 현재 선택된 멤버. 외곽 강조.
  final bool active;

  /// 탭 시 해당 멤버 dot 의 댓글이 시트 inline 으로 펼쳐짐.
  /// null 이면 비활성 (dot 매칭 실패 케이스).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasComment = commentCount > 0;
    final tappable = onTap != null;
    final ringColor = active ? DottieColors.primary : color;
    final ringWidth = active ? 3.0 : 2.0;
    // 56px ring 우측 상단에 indicator 가 살짝 걸치도록 Stack + 양쪽 padding 4.
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 4,
                  top: 4,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: color.withAlpha(40),
                      shape: BoxShape.circle,
                      border: Border.all(color: ringColor, width: ringWidth),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: DottieColors.primary.withAlpha(120),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: paperdoll != null
                        ? _PaperdollAvatarImage(config: paperdoll!)
                        : Center(
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                  color: color, shape: BoxShape.circle),
                            ),
                          ),
                  ),
                ),
                // 댓글 indicator — 마커/dot indicator 와 동일 디자인
                if (hasComment)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black.withAlpha(180),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                // 탭 가능 affordance — 우측 하단 화살표 (댓글 indicator 와 위치 분리)
                // primary 색 배경 + drop shadow 로 명확히 "탭 가능" 시그널.
                if (tappable)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: DottieColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(120),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 80,
            child: Text(
              name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// PaperdollRenderer 로 idle 프레임을 렌더해 RawImage 로 표시.
/// 원형 컨테이너 안 BoxFit.cover + alignment top — 머리/상체 중심으로 보이게.
class _PaperdollAvatarImage extends ConsumerWidget {
  const _PaperdollAvatarImage({required this.config});
  final PaperdollConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final renderer = ref.watch(paperdollRendererProvider);
    return FutureBuilder<ui.Image>(
      future: renderer.renderFrame(
        config: config,
        frameIndex: 2, // idle
        scale: 1.8,    // 32 * 1.8 ≈ 58 — 컨테이너 56 보다 약간 크게
      ),
      builder: (_, snap) {
        if (snap.data == null) {
          return const SizedBox.shrink();
        }
        return FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: snap.data!.width.toDouble(),
            height: snap.data!.height.toDouble(),
            child: RawImage(image: snap.data, fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}


// ─── Chrome 페이드 래퍼 ────────────────────────────────
//
// cinema 모드 자동 숨김에서 chrome(상단 바/하단 패널/FAB)을 일괄 페이드.
// hidden 상태에서는 IgnorePointer 로 hit-testing 도 차단해 안 보이는 버튼이
// 탭되는 사고 방지.
class _ChromeFader extends StatelessWidget {
  const _ChromeFader({required this.visible, required this.child});
  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }
}

// ─── 순서 번호 토글 ────────────────────────────────────
//
// FAB 위쪽 글래스 pill 토글. 켜면 dot 위에 방문 순번(1·2·3) 표시.
// 기본 OFF — 화면 클러터를 줄이기 위해 사용자가 명시적으로 켤 때만.
// 라벨 "순서" + 아이콘으로 직관적으로 의미 전달 (이전 "1·2" 추상 표기 대체).
class _OrderNumbersToggle extends StatelessWidget {
  const _OrderNumbersToggle({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = active
        ? DottieColors.primary.withAlpha(180)
        : DottieColors.surfaceFloating;
    final border = active
        ? DottieColors.primary.withAlpha(220)
        : DottieColors.borderGlass;
    final fg = active ? Colors.white : Colors.white.withAlpha(200);

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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.format_list_numbered_rounded,
                    color: fg, size: 14),
                const SizedBox(width: 6),
                Text(
                  '순서',
                  style: TextStyle(
                    color: fg,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
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

// ─── 내 위치 버튼 ─────────────────────────────────────
//
// 우측 하단 컨트롤 스택의 40x40 글래스 원형 버튼 (explore 모드 전용).
// 탭할 때마다 A(내 위치로 이동) ↔ B(내 위치+dot 전체 보기) 토글.
// 아이콘은 "다음 탭에 일어날 동작" 을 나타냄 — my_location: 내 위치로,
// zoom_out_map: 전체 보기로.
class _MyLocationFab extends StatelessWidget {
  const _MyLocationFab({required this.fitAll, required this.onTap});

  /// true 면 다음 탭이 "전체 보기(B)" — 이미 내 위치로 이동한 상태.
  final bool fitAll;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: ShapeDecoration(
          color: DottieColors.surfaceFloating,
          shape: CircleBorder(
            side: BorderSide(color: DottieColors.borderGlass, width: 1),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withAlpha(80),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  fitAll
                      ? Icons.zoom_out_map_rounded
                      : Icons.my_location_rounded,
                  key: ValueKey(fitAll),
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
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
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: ShapeDecoration(
          color: DottieColors.surfaceFloating,
          shape: CircleBorder(
            side: BorderSide(color: DottieColors.borderGlass, width: 1),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withAlpha(80),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onToggle,
          child: SizedBox(
            width: 56,
            height: 56,
            child: Center(
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
      ),
    );
  }
}
