import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../recording/domain/dot_model.dart';
import '../../domain/animation_frame.dart';
import 'animation_provider.dart';
import 'widgets/character_overlay.dart';
import 'widgets/dot_popup.dart';

class MapAnimationScreen extends ConsumerStatefulWidget {
  const MapAnimationScreen({super.key, required this.dayLogId});

  final String dayLogId;

  @override
  ConsumerState<MapAnimationScreen> createState() => _MapAnimationScreenState();
}

class _MapAnimationScreenState extends ConsumerState<MapAnimationScreen> {
  mapbox.MapboxMap? _mapboxMap;
  // 캐릭터 오버레이 위치 (screen coords)
  Offset? _characterScreenPos;
  bool _mapReady = false;
  Timer? _positionTimer;

  @override
  void dispose() {
    _positionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sequenceAsync = ref.watch(animationSequenceProvider(widget.dayLogId));
    final animState = ref.watch(animationControllerProvider(widget.dayLogId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: sequenceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (sequence) => _buildMap(context, sequence, animState),
      ),
    );
  }

  Widget _buildMap(
    BuildContext context,
    AnimationSequence sequence,
    AnimationState? animState,
  ) {
    // 초기화 트리거
    if (animState == null && _mapReady) {
      Future.microtask(() {
        ref
            .read(animationControllerProvider(widget.dayLogId).notifier)
            .initialize(sequence);
      });
    }

    final interp = animState == null
        ? null
        : AnimationBuilder.interpolate(sequence, animState.progress);

    return Stack(
      children: [
        // 전체화면 Mapbox 지도
        mapbox.MapWidget(
          onMapCreated: (map) => _onMapCreated(map, sequence),
          styleUri: mapbox.MapboxStyles.LIGHT,
        ),

        // 캐릭터 오버레이
        if (_characterScreenPos != null && animState != null)
          Positioned(
            left: _characterScreenPos!.dx - Dimensions.characterSize / 2,
            top: _characterScreenPos!.dy - Dimensions.characterSize,
            child: CharacterOverlayWidget(
              color: DottieColors.primary,
              state: interp?.state ?? CharacterState.idle,
              size: Dimensions.characterSize,
            ),
          ),

        // 상단 반투명 헤더
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _TopBar(
            sequence: sequence,
            onBack: () => Navigator.of(context).pop(),
          ),
        ),

        // Dot 도착 팝업
        if (animState?.showPopup == true && animState?.popupDot != null)
          Positioned(
            bottom: 180,
            left: Dimensions.md,
            right: Dimensions.md,
            child: DotPopup(
              dot: animState!.popupDot!,
              onDismiss: () => ref
                  .read(animationControllerProvider(widget.dayLogId).notifier)
                  .dismissPopup(),
            ),
          ),

        // 하단 컨트롤
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: AnimationControls(
            dayLogId: widget.dayLogId,
            sequence: sequence,
          ),
        ),
      ],
    );
  }

  Future<void> _onMapCreated(
      mapbox.MapboxMap map, AnimationSequence sequence) async {
    _mapboxMap = map;
    _mapReady = true;

    // UI 컨트롤 숨기기
    map.scaleBar.updateSettings(mapbox.ScaleBarSettings(enabled: false));
    map.compass.updateSettings(mapbox.CompassSettings(enabled: false));

    if (sequence.frames.isEmpty) return;

    await _fitCameraToDots(map, sequence);
    await _addTrailLayer(map, sequence);

    // 캐릭터 위치 주기적 갱신
    _startPositionSync(sequence);
  }

  Future<void> _fitCameraToDots(
      mapbox.MapboxMap map, AnimationSequence sequence) async {
    final lats = sequence.frames.map((f) => f.dot.latitude).toList();
    final lngs = sequence.frames.map((f) => f.dot.longitude).toList();

    final minLat = lats.reduce((a, b) => a < b ? a : b);
    final maxLat = lats.reduce((a, b) => a > b ? a : b);
    final minLng = lngs.reduce((a, b) => a < b ? a : b);
    final maxLng = lngs.reduce((a, b) => a > b ? a : b);

    final bounds = mapbox.CoordinateBounds(
      southwest: mapbox.Point(
          coordinates: mapbox.Position(minLng - 0.01, minLat - 0.01)),
      northeast: mapbox.Point(
          coordinates: mapbox.Position(maxLng + 0.01, maxLat + 0.01)),
      infiniteBounds: false,
    );

    await map.setCamera(
      mapbox.CameraOptions(
        center: mapbox.Point(
          coordinates: mapbox.Position(
            (minLng + maxLng) / 2,
            (minLat + maxLat) / 2,
          ),
        ),
      ),
    );

    await map.cameraForCoordinateBounds(
      bounds,
      mapbox.MbxEdgeInsets(top: 120, left: 40, bottom: 200, right: 40),
      null,
      null,
      null,
      null,
    ).then((camera) => map.setCamera(camera));
  }

  Future<void> _addTrailLayer(
      mapbox.MapboxMap map, AnimationSequence sequence) async {
    final coords = sequence.frames
        .map((f) => [f.dot.longitude, f.dot.latitude])
        .toList();

    final geoJson = {
      'type': 'Feature',
      'geometry': {'type': 'LineString', 'coordinates': coords},
    };

    await map.style.addSource(mapbox.GeoJsonSource(
      id: 'trail-source',
      data: geoJson.toString(),
    ));

    await map.style.addLayer(mapbox.LineLayer(
      id: 'trail-layer',
      sourceId: 'trail-source',
      lineColor: DottieColors.trailLine.toARGB32(),
      lineWidth: 3.0,
      lineDasharray: [4.0, 3.0],
      lineCap: mapbox.LineCap.ROUND,
      lineJoin: mapbox.LineJoin.ROUND,
    ));
  }

  void _startPositionSync(AnimationSequence sequence) {
    _positionTimer?.cancel();
    _positionTimer = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => _updateCharacterPos(sequence),
    );
  }

  Future<void> _updateCharacterPos(AnimationSequence sequence) async {
    if (_mapboxMap == null || !mounted) return;
    final animState =
        ref.read(animationControllerProvider(widget.dayLogId));
    if (animState == null) return;

    final interp = AnimationBuilder.interpolate(sequence, animState.progress);
    final screenPt = await _mapboxMap!.pixelForCoordinate(
      mapbox.Point(
          coordinates: mapbox.Position(interp.lng, interp.lat)),
    );

    if (mounted) {
      setState(() {
        _characterScreenPos = Offset(screenPt.x, screenPt.y);
      });
    }
  }
}

// ─── 상단 헤더 ───────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.sequence, required this.onBack});

  final AnimationSequence sequence;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final date = sequence.frames.isNotEmpty
        ? DottieDateUtils.toKoreanDate(sequence.frames.first.dot.timestamp)
        : '';
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withAlpha(100),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.sm, vertical: Dimensions.xs),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
                onPressed: onBack,
              ),
              Expanded(
                child: Text(
                  date,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 하단 재생 컨트롤 ─────────────────────────────────────────

class AnimationControls extends ConsumerWidget {
  const AnimationControls({
    super.key,
    required this.dayLogId,
    required this.sequence,
  });

  final String dayLogId;
  final AnimationSequence sequence;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animState = ref.watch(animationControllerProvider(dayLogId));
    final notifier = ref.read(animationControllerProvider(dayLogId).notifier);

    if (animState == null) return const SizedBox.shrink();

    final totalMs = sequence.totalDurationMs;
    final startTime = sequence.frames.isNotEmpty
        ? sequence.frames.first.dot.timestamp
        : DateTime.now();

    final currentMs = totalMs * animState.progress;
    final currentTime =
        startTime.add(Duration(milliseconds: currentMs.toInt() * 240));

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withAlpha(160),
            Colors.transparent,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Dimensions.md, Dimensions.lg, Dimensions.md, Dimensions.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 시간 표시
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DottieDateUtils.toTimeString(startTime),
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  Text(
                    DottieDateUtils.toTimeString(currentTime),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    sequence.frames.isNotEmpty
                        ? DottieDateUtils.toTimeString(
                            sequence.frames.last.dot.timestamp)
                        : '',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // 스크럽 슬라이더
              SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 7),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: DottieColors.primary,
                  inactiveTrackColor: Colors.white30,
                  thumbColor: Colors.white,
                  overlayColor: Colors.white24,
                ),
                child: Slider(
                  value: animState.progress,
                  onChanged: notifier.scrubTo,
                  onChangeEnd: (_) {
                    if (animState.isPlaying) notifier.play();
                  },
                ),
              ),

              // 재생 버튼 + 속도 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 속도 토글
                  _SpeedButton(
                    speed: animState.speed,
                    onTap: () => notifier.setSpeed(_nextSpeed(animState.speed)),
                  ),
                  const SizedBox(width: Dimensions.lg),

                  // 재생/일시정지
                  GestureDetector(
                    onTap: animState.isPlaying ? notifier.pause : notifier.play,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: DottieColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        animState.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),

                  const SizedBox(width: Dimensions.lg),
                  const SizedBox(width: 48), // 균형용
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PlaySpeed _nextSpeed(PlaySpeed current) => switch (current) {
        PlaySpeed.x1 => PlaySpeed.x2,
        PlaySpeed.x2 => PlaySpeed.x4,
        PlaySpeed.x4 => PlaySpeed.x1,
      };
}

class _SpeedButton extends StatelessWidget {
  const _SpeedButton({required this.speed, required this.onTap});

  final PlaySpeed speed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(Dimensions.radiusSm),
          border: Border.all(color: Colors.white30),
        ),
        alignment: Alignment.center,
        child: Text(
          speed.label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
