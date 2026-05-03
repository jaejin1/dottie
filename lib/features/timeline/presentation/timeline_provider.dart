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

  // BE UUID(currentDottieUser.uid) 우선, 미로딩 시 Firebase UID로 폴백.
  // 서버 sync 결과가 BE UUID로 저장되므로 BE UUID로 필터해야 매칭됨.
  final dottie = ref.watch(currentDottieUserProvider).valueOrNull;
  final userId = dottie?.uid ??
      ref.watch(currentUserProvider)?.uid ??
      'anonymous';
  debugPrint('[Timeline] userId=$userId (dottie=${dottie?.uid != null})');

  final repo = ref.read(dotRepositoryProvider);

  // 서버 → 로컬 동기화 (실패 시 로컬 그대로 사용)
  debugPrint('[Timeline] sync GET /daylogs');
  final synced = await repo.syncAllDayLogsFromServer();
  debugPrint('[Timeline] sync ${synced ? "OK" : "skipped (offline)"}');

  final result = await repo.getAllDayLogs(userId);
  debugPrint('[Timeline] daylogs=${result.length}');
  return result;
}
