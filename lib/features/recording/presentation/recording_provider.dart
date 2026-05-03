import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/dot_repository.dart';
import '../data/location_service.dart';
import '../data/geocoding_service.dart';
import '../domain/dot_model.dart';
import '../domain/recording_session.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../timeline/domain/day_log_model.dart';

part 'recording_provider.g.dart';

// 오늘 dot이 있는 세션 (null = 오늘 첫 dot 전)
@riverpod
class ActiveRecording extends _$ActiveRecording {
  @override
  Future<RecordingSession?> build() async {
    final repo = ref.read(dotRepositoryProvider);

    // 서버 우선 복원
    final serverToday = await repo.restoreTodayFromServer();
    if (serverToday != null && serverToday.dots.isNotEmpty) {
      return RecordingSession(
        dayLogId: serverToday.id,
        dots: serverToday.dots,
      );
    }

    // 오프라인 폴백 — 로컬 DB
    // BE UUID 우선(서버 sync 결과와 매칭), Firebase UID는 폴백.
    final userId = ref.read(currentDottieUserProvider).valueOrNull?.uid ??
        ref.read(currentUserProvider)?.uid;
    if (userId == null) return null;
    final dayLog = await repo.getDayLogByDate(DateTime.now(), userId);
    if (dayLog == null || dayLog.dots.isEmpty) return null;
    return RecordingSession(
      dayLogId: dayLog.id,
      dots: dayLog.dots,
    );
  }

  /// dot 찍기 — 위치 수집 → 역지오코딩 → (사진 업로드) → 저장.
  /// 반환값: 저장된 Dot (실패 시 null). 오늘 첫 dot이면 [isFirst] = true.
  Future<({Dot? dot, bool isFirst})> captureDot({
    String? memo,
    String? emotion,
    String? photoLocalPath,
  }) async {
    final session = state.valueOrNull;
    final isFirst = session == null;

    if (session != null) {
      state = AsyncValue.data(session.copyWith(isCapturingLocation: true));
    }

    try {
      final locationService = ref.read(locationServiceProvider);
      final geocodingService = ref.read(geocodingServiceProvider);
      final repo = ref.read(dotRepositoryProvider);
      // BE UUID(currentDottieUser) 우선, 미로딩 시 Firebase UID 폴백.
      final userId = ref.read(currentDottieUserProvider).valueOrNull?.uid ??
          ref.read(currentUserProvider)?.uid;
      if (userId == null) throw StateError('dot 기록에는 로그인이 필요합니다.');

      final position = await locationService.getCurrentPosition();
      final geocoding = await geocodingService.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      String? uploadedPhotoUrl;
      if (photoLocalPath != null) {
        uploadedPhotoUrl = await repo.uploadPhoto(photoLocalPath);
      }

      final now = DateTime.now();
      // 오프라인 시 사용할 temp dayLogId
      final tempDayLogId =
          session?.dayLogId ?? 'local_${now.millisecondsSinceEpoch}';

      final dot = Dot(
        id: '${now.millisecondsSinceEpoch}',
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: now,
        placeName: geocoding?.placeName,
        placeCategory: geocoding?.placeCategory,
        memo: memo,
        emotion: emotion,
        photoUrl: uploadedPhotoUrl,
        dayLogId: tempDayLogId,
      );

      final serverDayLogId = await repo.saveDot(dot, userId: userId);
      final effectiveDayLogId = serverDayLogId ?? tempDayLogId;
      final savedDot = dot.copyWith(dayLogId: effectiveDayLogId);

      final current = state.valueOrNull;
      if (current == null) {
        state = AsyncValue.data(RecordingSession(
          dayLogId: effectiveDayLogId,
          dots: [savedDot],
        ));
      } else {
        state = AsyncValue.data(current.copyWith(
          dayLogId: effectiveDayLogId,
          dots: [...current.dots, savedDot],
          isCapturingLocation: false,
          error: null,
        ));
      }

      return (dot: savedDot, isFirst: isFirst);
    } catch (e) {
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncValue.data(
            current.copyWith(isCapturingLocation: false, error: e.toString()));
      }
      return (dot: null, isFirst: false);
    }
  }
}

// 오늘 DayLog — 서버 우선, 없으면 로컬 폴백
@riverpod
Future<DayLog?> todayDayLog(Ref ref) async {
  final repo = ref.watch(dotRepositoryProvider);
  final serverLog = await repo.restoreTodayFromServer();
  if (serverLog != null) return serverLog;
  final userId = ref.read(currentDottieUserProvider).valueOrNull?.uid ??
      ref.read(currentUserProvider)?.uid ??
      'anonymous';
  return repo.getDayLogByDate(DateTime.now(), userId);
}

// 전체 DayLog 목록 (타임라인용)
@riverpod
Future<List<DayLog>> allDayLogs(Ref ref) {
  final userId = ref.watch(currentDottieUserProvider).valueOrNull?.uid ??
      ref.watch(currentUserProvider)?.uid ??
      'anonymous';
  return ref.watch(dotRepositoryProvider).getAllDayLogs(userId);
}
