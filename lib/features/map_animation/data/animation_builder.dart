import '../../../core/utils/location_utils.dart';
import '../../recording/domain/dot_model.dart';
import '../domain/animation_frame.dart';

class AnimationBuilder {
  AnimationBuilder._();

  // 재생 속도별 1실제분 → 애니메이션 ms 비율
  // 실제 8시간(480분)을 약 2분 애니메이션으로
  static const double _msPerRealMinute = 250.0;

  static AnimationSequence build(List<Dot> dots) {
    if (dots.isEmpty) {
      return const AnimationSequence(
        frames: [],
        startTime: _epoch,
        endTime: _epoch,
        totalDurationMs: 0,
      );
    }

    final sorted = [...dots]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final frames = <AnimationFrame>[];
    double totalMs = 0;

    for (int i = 0; i < sorted.length; i++) {
      final dot = sorted[i];
      final nextDot = i < sorted.length - 1 ? sorted[i + 1] : null;

      double distKm = 0;
      Duration realDuration = Duration.zero;

      if (nextDot != null) {
        distKm = LocationUtils.distanceInKm(
          dot.latitude, dot.longitude,
          nextDot.latitude, nextDot.longitude,
        );
        realDuration = nextDot.timestamp.difference(dot.timestamp);
      }

      // 실제 경과시간(분) → 애니메이션 ms
      final animMs = realDuration.inMinutes * _msPerRealMinute;
      totalMs += animMs;

      final state = _resolveState(
        i: i,
        total: sorted.length,
        distKm: distKm,
        realDuration: realDuration,
        nextDot: nextDot,
      );

      frames.add(AnimationFrame(
        index: i,
        dot: dot,
        nextDot: nextDot,
        latitude: dot.latitude,
        longitude: dot.longitude,
        state: state,
        distanceKm: distKm,
        duration: realDuration,
      ));
    }

    return AnimationSequence(
      frames: frames,
      startTime: sorted.first.timestamp,
      endTime: sorted.last.timestamp,
      totalDurationMs: totalMs.clamp(3000, double.infinity), // 최소 3초
    );
  }

  static CharacterState _resolveState({
    required int i,
    required int total,
    required double distKm,
    required Duration realDuration,
    required Dot? nextDot,
  }) {
    if (nextDot == null) return CharacterState.idle;
    // 30분 이상 머문 경우
    if (realDuration.inMinutes >= 30 && distKm < 0.1) return CharacterState.sleeping;
    if (distKm >= 2.0) return CharacterState.driving;
    return CharacterState.walking;
  }

  /// progress(0.0~1.0)에서 현재 위치(lat, lng)와 상태 반환
  static ({double lat, double lng, CharacterState state, int frameIndex, bool isArrived})
      interpolate(AnimationSequence seq, double progress) {
    if (seq.frames.isEmpty) {
      return (lat: 0, lng: 0, state: CharacterState.idle, frameIndex: 0, isArrived: false);
    }

    final targetMs = seq.totalDurationMs * progress;
    double elapsed = 0;

    for (int i = 0; i < seq.frames.length; i++) {
      final frame = seq.frames[i];
      final segMs = frame.duration.inMinutes * _msPerRealMinute;

      if (frame.nextDot == null || targetMs <= elapsed + segMs) {
        // 이 구간 안에 있음
        final t = segMs > 0 ? ((targetMs - elapsed) / segMs).clamp(0.0, 1.0) : 0.0;
        final lat = _lerp(frame.dot.latitude, frame.nextDot?.latitude ?? frame.dot.latitude, t);
        final lng = _lerp(frame.dot.longitude, frame.nextDot?.longitude ?? frame.dot.longitude, t);
        final isArrived = t < 0.05 || t > 0.95;
        final state = isArrived ? CharacterState.arrived : frame.state;
        return (lat: lat, lng: lng, state: state, frameIndex: i, isArrived: isArrived);
      }
      elapsed += segMs;
    }

    final last = seq.frames.last;
    return (
      lat: last.dot.latitude,
      lng: last.dot.longitude,
      state: CharacterState.idle,
      frameIndex: seq.frames.length - 1,
      isArrived: true,
    );
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  static const _epoch = DateTime.utc(2000);
}
