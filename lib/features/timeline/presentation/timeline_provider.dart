import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../recording/data/dot_repository.dart';
import '../../recording/presentation/recording_provider.dart';
import '../domain/day_log_model.dart';

part 'timeline_provider.g.dart';

@riverpod
Future<List<DayLog>> timelineDayLogs(Ref ref) async {
  // recording 상태 변경 시 자동 갱신
  ref.watch(activeRecordingProvider);

  // BE UUID 가 준비될 때까지 await — Firebase UID 폴백은 BE-synced daylog
  // (userId=BE UUID) 와 mismatch 되어 첫 SSO 로그인 직후 빈 결과 원인이 됐음.
  final dottie = await ref.watch(currentDottieUserProvider.future);
  if (dottie == null) {
    debugPrint('[Timeline] no dottie user — return empty');
    return const [];
  }
  final userId = dottie.uid;

  final repo = ref.read(dotRepositoryProvider);

  // 서버 → 로컬 동기화 (실패 시 로컬 그대로 사용)
  debugPrint('[Timeline] sync GET /daylogs');
  try {
    final synced = await repo.syncAllDayLogsFromServer();
    debugPrint(
        '[Timeline] userId=$userId sync ${synced ? "OK" : "skipped (offline)"}');
  } catch (e) {
    debugPrint('[Timeline] sync failed (ignored): $e');
  }

  try {
    final result = await repo.getAllDayLogs(userId);
    debugPrint('[Timeline] daylogs=${result.length}');
    return result;
  } catch (e) {
    debugPrint('[Timeline] getAllDayLogs failed (DB error?): $e');
    return const [];
  }
}
