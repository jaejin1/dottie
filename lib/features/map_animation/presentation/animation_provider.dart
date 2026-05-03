import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../recording/data/dot_repository.dart';
import '../../recording/domain/dot_model.dart';
import '../data/animation_builder.dart';
import '../domain/animation_frame.dart';

part 'animation_provider.freezed.dart';
part 'animation_provider.g.dart';

enum PlaySpeed { x1, x2, x4 }

extension PlaySpeedExt on PlaySpeed {
  double get multiplier => switch (this) {
        PlaySpeed.x1 => 1.0,
        PlaySpeed.x2 => 2.0,
        PlaySpeed.x4 => 4.0,
      };

  String get label => switch (this) {
        PlaySpeed.x1 => '1x',
        PlaySpeed.x2 => '2x',
        PlaySpeed.x4 => '4x',
      };
}

@freezed
class AnimationState with _$AnimationState {
  const factory AnimationState({
    required AnimationSequence sequence,
    @Default(0.0) double progress,   // 0.0 ~ 1.0
    @Default(false) bool isPlaying,
    @Default(PlaySpeed.x1) PlaySpeed speed,
    @Default(0) int currentFrameIndex,
    @Default(false) bool showPopup,
    Dot? popupDot,
  }) = _AnimationState;
}

// DayLog ID로 서버에서 dots 로드 → AnimationSequence 빌드
@riverpod
Future<AnimationSequence> animationSequence(Ref ref, String dayLogId) async {
  final repo = ref.watch(dotRepositoryProvider);
  final dots = await repo.getDayLogDots(dayLogId) ?? [];
  return AnimationBuilder.build(dots);
}

// 애니메이션 재생 상태 관리
@riverpod
class AnimationController extends _$AnimationController {
  Ticker? _ticker;
  double _lastTimestamp = 0;

  @override
  AnimationState? build(String dayLogId) {
    ref.onDispose(() => _ticker?.dispose());
    return null;
  }

  Future<void> initialize(AnimationSequence sequence) async {
    state = AnimationState(sequence: sequence);
  }

  void play() {
    if (state == null) return;
    state = state!.copyWith(isPlaying: true);
    _startTicker();
  }

  void pause() {
    _ticker?.stop();
    if (state == null) return;
    state = state!.copyWith(isPlaying: false);
  }

  void setSpeed(PlaySpeed speed) {
    if (state == null) return;
    state = state!.copyWith(speed: speed);
  }

  void scrubTo(double progress) {
    _ticker?.stop();
    if (state == null) return;
    final p = progress.clamp(0.0, 1.0);
    final interp = AnimationBuilder.interpolate(state!.sequence, p);
    state = state!.copyWith(
      progress: p,
      isPlaying: false,
      currentFrameIndex: interp.frameIndex,
      showPopup: false,
    );
  }

  void dismissPopup() {
    if (state == null) return;
    state = state!.copyWith(showPopup: false, popupDot: null);
  }

  void _startTicker() {
    _ticker?.dispose();
    _lastTimestamp = 0;

    _ticker = Ticker((elapsed) {
      if (state == null || !state!.isPlaying) return;

      final ms = elapsed.inMilliseconds.toDouble();
      final delta = _lastTimestamp == 0 ? 0 : ms - _lastTimestamp;
      _lastTimestamp = ms;

      final totalMs = state!.sequence.totalDurationMs;
      if (totalMs <= 0) return;

      final increment = (delta * state!.speed.multiplier) / totalMs;
      final newProgress = (state!.progress + increment).clamp(0.0, 1.0);

      final interp = AnimationBuilder.interpolate(state!.sequence, newProgress);

      // dot 도착 감지 → 팝업
      final arrivedDot = interp.isArrived &&
              interp.frameIndex != state!.currentFrameIndex
          ? state!.sequence.frames[interp.frameIndex].dot
          : null;

      final shouldShowPopup = arrivedDot != null &&
          (arrivedDot.memo != null || arrivedDot.photoUrl != null || arrivedDot.placeName != null);

      if (newProgress >= 1.0) {
        _ticker?.stop();
        state = state!.copyWith(
          progress: 1.0,
          isPlaying: false,
          currentFrameIndex: interp.frameIndex,
          showPopup: shouldShowPopup,
          popupDot: shouldShowPopup ? arrivedDot : state!.popupDot,
        );
      } else {
        state = state!.copyWith(
          progress: newProgress,
          currentFrameIndex: interp.frameIndex,
          showPopup: shouldShowPopup || state!.showPopup,
          popupDot: shouldShowPopup ? arrivedDot : state!.popupDot,
        );
      }
    })
      ..start();
  }

}
