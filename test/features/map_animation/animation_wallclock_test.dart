import 'package:flutter_test/flutter_test.dart';
import 'package:dottie/features/map_animation/data/animation_builder.dart';
import 'package:dottie/features/map_animation/domain/animation_frame.dart';
import 'package:dottie/features/recording/domain/dot_model.dart';

Dot _dot(String id, double lat, double lng, DateTime ts) => Dot(
      id: id,
      latitude: lat,
      longitude: lng,
      timestamp: ts,
      dayLogId: 'day1',
    );

void main() {
  group('AnimationBuilder.interpolateAtTime — 벽시계 동기화', () {
    // 09:00 (0,0) → 10:00 (0,10) → 11:00 (0,20)
    final seq = AnimationBuilder.build([
      _dot('a', 0, 0, DateTime.utc(2026, 1, 1, 9)),
      _dot('b', 0, 10, DateTime.utc(2026, 1, 1, 10)),
      _dot('c', 0, 20, DateTime.utc(2026, 1, 1, 11)),
    ]);

    test('첫 dot 이전 → 첫 dot 에 대기', () {
      final r = AnimationBuilder.interpolateAtTime(
          seq, DateTime.utc(2026, 1, 1, 8));
      expect(r.lng, 0);
      expect(r.frameIndex, 0);
    });

    test('마지막 dot 이후 → 마지막 dot 에 정지', () {
      final r = AnimationBuilder.interpolateAtTime(
          seq, DateTime.utc(2026, 1, 1, 12));
      expect(r.lng, 20);
      expect(r.state, CharacterState.idle);
    });

    test('구간 중간(09:30) → 절반 보간', () {
      final r = AnimationBuilder.interpolateAtTime(
          seq, DateTime.utc(2026, 1, 1, 9, 30));
      expect(r.lng, closeTo(5, 1e-9)); // 0→10 의 절반
      expect(r.frameIndex, 0);
    });

    test('두번째 구간 중간(10:30) → 10→20 의 절반', () {
      final r = AnimationBuilder.interpolateAtTime(
          seq, DateTime.utc(2026, 1, 1, 10, 30));
      expect(r.lng, closeTo(15, 1e-9));
      expect(r.frameIndex, 1);
    });

    test('정확히 dot 시각(10:00) → 그 dot 위치', () {
      final r = AnimationBuilder.interpolateAtTime(
          seq, DateTime.utc(2026, 1, 1, 10));
      expect(r.lng, closeTo(10, 1e-9));
    });

    test('빈 시퀀스 → 안전한 기본값', () {
      final empty = AnimationBuilder.build([]);
      final r =
          AnimationBuilder.interpolateAtTime(empty, DateTime.utc(2026, 1, 1));
      expect(r.lat, 0);
      expect(r.lng, 0);
    });

    test('단일 dot 멤버 → 항상 그 자리', () {
      final single = AnimationBuilder.build([
        _dot('x', 1, 2, DateTime.utc(2026, 1, 1, 10)),
      ]);
      final before = AnimationBuilder.interpolateAtTime(
          single, DateTime.utc(2026, 1, 1, 9));
      final after = AnimationBuilder.interpolateAtTime(
          single, DateTime.utc(2026, 1, 1, 11));
      expect(before.lng, 2);
      expect(after.lng, 2);
    });
  });

  group('서로 다른 활동 시간대 멤버 동기화', () {
    // A: 09:00~11:00 활동 / B: 10:00~10:30 만 활동
    final a = AnimationBuilder.build([
      _dot('a1', 0, 0, DateTime.utc(2026, 1, 1, 9)),
      _dot('a2', 0, 20, DateTime.utc(2026, 1, 1, 11)),
    ]);
    final b = AnimationBuilder.build([
      _dot('b1', 0, 100, DateTime.utc(2026, 1, 1, 10)),
      _dot('b2', 0, 110, DateTime.utc(2026, 1, 1, 10, 30)),
    ]);

    test('B 활동 시작 전(09:30) → B 는 첫 dot 에 대기', () {
      final rb = AnimationBuilder.interpolateAtTime(
          b, DateTime.utc(2026, 1, 1, 9, 30));
      expect(rb.lng, 100); // 아직 첫 dot
    });

    test('같은 시각(10:15)에 A·B 각자 실제 위치', () {
      final t = DateTime.utc(2026, 1, 1, 10, 15);
      final ra = AnimationBuilder.interpolateAtTime(a, t);
      final rb = AnimationBuilder.interpolateAtTime(b, t);
      // A: 09:00~11:00 구간의 10:15 = 62.5% → lng 12.5
      expect(ra.lng, closeTo(12.5, 1e-9));
      // B: 10:00~10:30 구간의 10:15 = 50% → 100~110 의 절반 = 105
      expect(rb.lng, closeTo(105, 1e-9));
    });

    test('B 활동 종료 후(10:45) → B 는 마지막 dot 에 정지', () {
      final rb = AnimationBuilder.interpolateAtTime(
          b, DateTime.utc(2026, 1, 1, 10, 45));
      expect(rb.lng, 110);
    });
  });
}
