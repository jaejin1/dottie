import 'package:flutter/foundation.dart';
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

  Future<DayLog?> getDayLogByDate(DateTime date, String userId) async {
    final row = await _local.getDayLogByDate(date, userId);
    if (row == null) return null;
    final dotRows = await _local.getDotsByDayLog(row.id);
    final dots = dotRows.map(_local.dotFromRow).toList();
    return _local.dayLogFromRow(row, dots);
  }

  Future<List<DayLog>> getAllDayLogs(String userId) async {
    final rows = await _local.getAllDayLogs(userId);
    final result = <DayLog>[];
    for (final row in rows) {
      final dotRows = await _local.getDotsByDayLog(row.id);
      final dots = dotRows.map(_local.dotFromRow).toList();
      result.add(_local.dayLogFromRow(row, dots));
    }
    // sync cleanup 누락/실패 시 같은 날짜에 여러 row 가 있을 수 있으므로 읽기 시점 dedup.
    return _dedupByDate(result);
  }

  /// 같은 날짜의 daylog 가 여러 개면 1개로 합침. server-synced 우선,
  /// dot 은 union (id 기준 중복 제거), isRecording 은 OR.
  /// drift cleanup(`mergeOrphanDayLogs`) 이 정상 작동하면 항상 1개여서 no-op.
  static List<DayLog> _dedupByDate(List<DayLog> list) {
    final byDate = <String, DayLog>{};
    for (final dl in list) {
      final key = '${dl.date.year}-${dl.date.month}-${dl.date.day}';
      final existing = byDate[key];
      if (existing == null) {
        byDate[key] = dl;
      } else {
        byDate[key] = _merge(existing, dl);
      }
    }
    return byDate.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  static DayLog _merge(DayLog a, DayLog b) {
    final canonical = _pickCanonical(a, b);
    final other = canonical.id == a.id ? b : a;
    final dotsById = <String, Dot>{};
    for (final d in canonical.dots) {
      dotsById[d.id] = d;
    }
    for (final d in other.dots) {
      dotsById.putIfAbsent(d.id, () => d);
    }
    final merged = dotsById.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return canonical.copyWith(
      dots: merged,
      isRecording: a.isRecording || b.isRecording,
    );
  }

  static DayLog _pickCanonical(DayLog a, DayLog b) {
    // 1) synced=true 우선 (server-synced row)
    if (a.synced != b.synced) return a.synced ? a : b;
    // 2) dot 더 많은 쪽
    if (a.dots.length != b.dots.length) {
      return a.dots.length > b.dots.length ? a : b;
    }
    // 3) isRecording=true 우선 (오늘의 active session)
    if (a.isRecording != b.isRecording) return a.isRecording ? a : b;
    return a;
  }

  /// 서버에서 DayLog의 dots 조회 (애니메이션 화면용)
  Future<List<Dot>?> getDayLogDots(String dayLogId) =>
      _remote.getDayLogDots(dayLogId);

  /// 서버에서 오늘 세션을 가져와 로컬 DB에 동기화 후 반환
  Future<DayLog?> restoreTodayFromServer() async {
    final now = DateTime.now();
    final localDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final today = await _remote.getTodayDayLog(localDate);
    if (today == null) return null;
    await _local.upsertDayLog(today);
    await _local.upsertDots(today.dots);
    return today;
  }

  /// 서버에서 전체 daylog를 가져와 로컬에 upsert.
  /// 네트워크 실패 시 false 반환 (로컬 데이터 그대로 유지).
  ///
  /// 각 server daylog upsert 후 같은 날짜의 임시 daylog 흔적을 정리해
  /// `'local_*'` 같은 orphan row 가 누적되지 않도록 한다 (timeline 중복 fix).
  Future<bool> syncAllDayLogsFromServer() async {
    final remote = await _remote.getAllDayLogs();
    if (remote == null) return false;
    for (final dl in remote) {
      await _local.upsertDayLog(dl);
      if (dl.dots.isNotEmpty) {
        await _local.upsertDots(dl.dots);
      }
      final merged = await _local.mergeOrphanDayLogs(dl.id, dl.date);
      if (merged > 0) {
        debugPrint(
            '[DotRepo] merged $merged orphan daylog(s) for ${dl.date}');
      }
    }
    return true;
  }

  /// daylog 삭제 — 서버 우선, 로컬도 함께 삭제.
  /// 오프라인이면 로컬만 삭제 (서버와 불일치 허용).
  Future<void> deleteDayLog(String id) async {
    await _remote.deleteDayLog(id); // 서버 실패 시 rethrow
    await _local.deleteDayLog(id);
  }

  // ── Dot ──

  /// dot 저장 — 로컬 우선, 서버 성공 시 서버 dayLogId 반환.
  /// 사진이 있으면 PATCH /dots/{id}/photo까지 호출해 DB에 사진 URL 연결.
  /// 오프라인이면 null 반환 (로컬에만 저장됨).
  Future<String?> saveDot(Dot dot, {required String userId}) async {
    final (:dayLogId, :dotId) = await _remote.uploadDot(dot);
    final effectiveDayLogId = dayLogId ?? dot.dayLogId;

    if (dayLogId != null) {
      // 온라인: 서버 ID로 로컬 daylog 보장 후 dot 저장 (synced=true)
      await _local.ensureDayLog(dayLogId, dot.timestamp, userId);
      await _local.insertDot(dot.copyWith(dayLogId: effectiveDayLogId, synced: true));

      // 사진이 있으면 PATCH로 photo_url 연결 (dot_id 필요)
      if (dot.photoUrl != null && dotId != null) {
        await _remote.patchDotPhoto(dotId, dot.photoUrl!);
      }
    } else {
      // 오프라인: temp dayLogId로 로컬 daylog 보장 후 dot 저장 (synced=false)
      await _local.ensureDayLog(dot.dayLogId, dot.timestamp, userId);
      await _local.insertDot(dot);
    }

    return dayLogId;
  }

  /// 사진 파일 업로드 → 서버 URL 반환
  Future<String?> uploadPhoto(String filePath) =>
      _remote.uploadPhoto(filePath);

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
