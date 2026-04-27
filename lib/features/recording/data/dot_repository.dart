import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/dot_model.dart';
import '../../timeline/domain/day_log_model.dart';
import 'dot_local_source.dart';
import 'dot_remote_source.dart';

part 'dot_repository.g.dart';

class DotRepository {
  DotRepository(this._local, this._remote);
  final DotLocalSource _local;
  final DotRemoteSource _remote;

  // ── DayLog ──

  Future<DayLog?> getActiveDayLog() async {
    final row = await _local.getActiveDayLog();
    if (row == null) return null;
    final dotRows = await _local.getDotsByDayLog(row.id);
    final dots = dotRows.map(_local.dotFromRow).toList();
    return _local.dayLogFromRow(row, dots);
  }

  Future<DayLog?> getDayLogByDate(DateTime date) async {
    final row = await _local.getDayLogByDate(date);
    if (row == null) return null;
    final dotRows = await _local.getDotsByDayLog(row.id);
    final dots = dotRows.map(_local.dotFromRow).toList();
    return _local.dayLogFromRow(row, dots);
  }

  Future<List<DayLog>> getAllDayLogs() async {
    final rows = await _local.getAllDayLogs();
    final result = <DayLog>[];
    for (final row in rows) {
      final dotRows = await _local.getDotsByDayLog(row.id);
      final dots = dotRows.map(_local.dotFromRow).toList();
      result.add(_local.dayLogFromRow(row, dots));
    }
    return result;
  }

  /// 기록 시작 — 로컬 DayLog 생성, 서버에도 알림 (실패해도 로컬은 저장)
  Future<String> startRecording(String userId) async {
    final dayLogId = await _local.startDayLog(userId);
    _remote.startRecording(); // fire-and-forget
    return dayLogId;
  }

  /// 기록 종료 — 미동기화 dot 일괄 업로드 후 종료
  Future<void> endRecording(String dayLogId) async {
    await _local.endDayLog(dayLogId);
    await syncUnsyncedDots();
    _remote.endRecording(dayLogId); // fire-and-forget
  }

  // ── Dot ──

  /// dot 저장 — 로컬에 먼저, 네트워크 있으면 즉시 서버 동기화
  Future<void> saveDot(Dot dot) async {
    await _local.insertDot(dot);
    final synced = await _remote.uploadDot(dot);
    if (synced) await _local.markDotSynced(dot.id);
  }

  /// 미동기화 dot 일괄 업로드
  Future<void> syncUnsyncedDots() async {
    final unsyncedRows = await _local.getUnsyncedDots();
    if (unsyncedRows.isEmpty) return;
    final dots = unsyncedRows.map(_local.dotFromRow).toList();
    await _remote.batchSyncDots(dots);
    for (final row in unsyncedRows) {
      await _local.markDotSynced(row.id);
    }
  }
}

@riverpod
DotRepository dotRepository(Ref ref) => DotRepository(
      ref.watch(dotLocalSourceProvider),
      ref.watch(dotRemoteSourceProvider),
    );
