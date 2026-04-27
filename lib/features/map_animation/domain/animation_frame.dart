import 'package:freezed_annotation/freezed_annotation.dart';
import '../../recording/domain/dot_model.dart';

part 'animation_frame.freezed.dart';

enum CharacterState {
  idle,     // 정지 (첫 dot, 마지막 dot)
  walking,  // 걷기 (dot 간 거리 < 2km)
  driving,  // 이동 (dot 간 거리 >= 2km)
  arrived,  // 도착 (dot 지점에 도달)
  sleeping, // 잠 (같은 위치 30분+)
}

@freezed
class AnimationFrame with _$AnimationFrame {
  const factory AnimationFrame({
    required int index,          // 현재 dot 인덱스
    required Dot dot,            // 현재 dot
    Dot? nextDot,                // 다음 dot (null이면 마지막)
    required double latitude,    // 현재 보간된 위도
    required double longitude,   // 현재 보간된 경도
    required CharacterState state,
    required double distanceKm,  // 다음 dot까지 거리
    required Duration duration,  // 다음 dot까지 실제 경과 시간
    @Default(false) bool isArrived, // dot 지점 도달 여부
  }) = _AnimationFrame;
}

@freezed
class AnimationSequence with _$AnimationSequence {
  const factory AnimationSequence({
    required List<AnimationFrame> frames,
    required DateTime startTime,
    required DateTime endTime,
    required double totalDurationMs, // 애니메이션 총 길이 (ms)
  }) = _AnimationSequence;
}
