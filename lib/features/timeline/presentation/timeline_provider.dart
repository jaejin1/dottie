import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../recording/data/dot_repository.dart';
import '../../recording/presentation/recording_provider.dart';
import '../domain/day_log_model.dart';

part 'timeline_provider.g.dart';

@riverpod
Future<List<DayLog>> timelineDayLogs(Ref ref) async {
  // recording 상태 변경 시 자동 갱신
  ref.watch(activeRecordingProvider);
  return ref.read(dotRepositoryProvider).getAllDayLogs();
}
