import '../../../core/utils/location_utils.dart';
import '../../recording/domain/dot_model.dart';
import '../domain/animation_frame.dart';

class AnimationBuilder {
  AnimationBuilder._();

  // 재생 속도별 1실제분 → 애니메이션 ms 비율
  // 실제 8시간(480분)을 약 2분 애니메이션으로
  static const double msPerRealMinute = 250.0;

  static AnimationSequence build(List<Dot> dots) {
    if (dots.isEmpty) {
      return AnimationSequence(
        frames: const [],
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
      final animMs = realDuration.inMinutes * msPerRealMinute;
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
      final segMs = frame.duration.inMinutes * msPerRealMinute;

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

  /// 실제 시각 [t] 기준으로 이 시퀀스의 위치/상태 반환.
  ///
  /// [interpolate] 는 시퀀스 자체 길이를 0~1 로 정규화하므로 여러 멤버를
  /// 같은 progress 로 그리면 각자 다른 실제 시간대를 밟는다(공통 시계 없음).
  /// 이 메서드는 **실제 dot 타임스탬프**를 기준으로 위치를 구해, 여러 멤버를
  /// 하나의 벽시계(wall-clock)에 동기화할 수 있게 한다.
  ///
  /// - t 가 이 멤버의 첫 dot 이전 → 첫 dot 에 대기(아직 이동 시작 안 함)
  /// - t 가 마지막 dot 이후 → 마지막 dot 에 정지
  /// - 그 사이 → 해당 구간 dot_i..dot_{i+1} 을 실제 시간 비율로 보간
  static ({double lat, double lng, CharacterState state, int frameIndex, bool isArrived})
      interpolateAtTime(AnimationSequence seq, DateTime t) {
    if (seq.frames.isEmpty) {
      return (lat: 0, lng: 0, state: CharacterState.idle, frameIndex: 0, isArrived: false);
    }
    final first = seq.frames.first;
    final last = seq.frames.last;

    if (!t.isAfter(first.dot.timestamp)) {
      return (
        lat: first.dot.latitude,
        lng: first.dot.longitude,
        state: CharacterState.idle,
        frameIndex: 0,
        isArrived: true,
      );
    }
    if (!t.isBefore(last.dot.timestamp)) {
      return (
        lat: last.dot.latitude,
        lng: last.dot.longitude,
        state: CharacterState.idle,
        frameIndex: seq.frames.length - 1,
        isArrived: true,
      );
    }

    for (int i = 0; i < seq.frames.length; i++) {
      final frame = seq.frames[i];
      final next = frame.nextDot;
      if (next == null) break;
      final segStart = frame.dot.timestamp;
      final segEnd = next.timestamp;
      if (!t.isBefore(segStart) && t.isBefore(segEnd)) {
        final segMs = segEnd.difference(segStart).inMilliseconds;
        final into = t.difference(segStart).inMilliseconds;
        final tt = segMs > 0 ? (into / segMs).clamp(0.0, 1.0) : 0.0;
        final lat = _lerp(frame.dot.latitude, next.latitude, tt);
        final lng = _lerp(frame.dot.longitude, next.longitude, tt);
        final isArrived = tt < 0.05 || tt > 0.95;
        final state = isArrived ? CharacterState.arrived : frame.state;
        return (lat: lat, lng: lng, state: state, frameIndex: i, isArrived: isArrived);
      }
    }

    // 부동소수/경계 안전망 — 마지막 dot.
    return (
      lat: last.dot.latitude,
      lng: last.dot.longitude,
      state: CharacterState.idle,
      frameIndex: seq.frames.length - 1,
      isArrived: true,
    );
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;

  static final _epoch = DateTime.utc(2000);
}
