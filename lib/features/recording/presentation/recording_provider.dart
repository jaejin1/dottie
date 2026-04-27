import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/dot_repository.dart';
import '../data/location_service.dart';
import '../data/geocoding_service.dart';
import '../data/notification_service.dart';
import '../domain/dot_model.dart';
import '../domain/recording_session.dart';
import '../../timeline/domain/day_log_model.dart';

part 'recording_provider.g.dart';

// 현재 활성 기록 세션 (없으면 null)
@riverpod
class ActiveRecording extends _$ActiveRecording {
  @override
  Future<RecordingSession?> build() async {
    final dayLog = await ref.read(dotRepositoryProvider).getActiveDayLog();
    if (dayLog == null) return null;
    return RecordingSession(
      dayLogId: dayLog.id,
      startedAt: dayLog.startedAt,
      dots: dayLog.dots,
    );
  }

  /// 기록 시작
  Future<void> startRecording(String userId) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(dotRepositoryProvider);
      final notifService = ref.read(notificationServiceProvider);

      await notifService.initialize();
      await notifService.requestPermission();
      final dayLogId = await repo.startRecording(userId);
      await notifService.scheduleDotReminders();

      state = AsyncValue.data(RecordingSession(
        dayLogId: dayLogId,
        startedAt: DateTime.now(),
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 기록 종료
  Future<void> endRecording() async {
    final session = state.valueOrNull;
    if (session == null) return;

    try {
      final repo = ref.read(dotRepositoryProvider);
      final notifService = ref.read(notificationServiceProvider);

      await notifService.cancelDotReminders();
      await repo.endRecording(session.dayLogId);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// dot 찍기 — 위치 수집 → 역지오코딩 → 저장
  Future<Dot?> captureDot({
    String? memo,
    String? emotion,
    String? photoUrl,
  }) async {
    final session = state.valueOrNull;
    if (session == null) return null;

    // 위치 수집 중 표시
    state = AsyncValue.data(session.copyWith(isCapturingLocation: true));

    try {
      final locationService = ref.read(locationServiceProvider);
      final geocodingService = ref.read(geocodingServiceProvider);
      final repo = ref.read(dotRepositoryProvider);

      final position = await locationService.getCurrentPosition();
      final geocoding = await geocodingService.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      final dot = Dot(
        id: '${DateTime.now().millisecondsSinceEpoch}',
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: DateTime.now(),
        placeName: geocoding?.placeName,
        placeCategory: geocoding?.placeCategory,
        memo: memo,
        emotion: emotion,
        photoUrl: photoUrl,
        dayLogId: session.dayLogId,
      );

      await repo.saveDot(dot);

      final updatedDots = [...session.dots, dot];
      state = AsyncValue.data(session.copyWith(
        dots: updatedDots,
        isCapturingLocation: false,
        error: null,
      ));

      return dot;
    } catch (e) {
      state = AsyncValue.data(session.copyWith(
        isCapturingLocation: false,
        error: e.toString(),
      ));
      return null;
    }
  }
}

// 전체 DayLog 목록 (타임라인용)
@riverpod
Future<List<DayLog>> allDayLogs(Ref ref) =>
    ref.watch(dotRepositoryProvider).getAllDayLogs();
