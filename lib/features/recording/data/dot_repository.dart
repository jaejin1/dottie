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

  /// dot 단건 삭제 — 서버 + 로컬.
  /// - synced=false 인 dot 은 BE 가 모르는 상태이므로 서버 호출 skip, 로컬만 정리.
  /// - 서버 200 또는 404(이미 삭제) → 로컬에서도 제거.
  /// - 403/400/5xx → [DotDeleteException] re-throw, 로컬은 보존 (사용자 안내 필요).
  /// - 네트워크 오류 → false 반환, 로컬도 보존 (재시도 가능).
  /// 반환값: 성공적으로 (서버+로컬) 삭제됐는지 여부.
  Future<bool> deleteDot(Dot dot) async {
    if (!dot.synced) {
      await _local.deleteDotById(dot.id);
      return true;
    }
    try {
      await _remote.deleteDot(dot.id);
      await _local.deleteDotById(dot.id);
      return true;
    } on DotDeleteException catch (e) {
      // 404 멱등 — 서버에 없으면 로컬도 정리.
      if (e.isNotFound) {
        await _local.deleteDotById(dot.id);
        return true;
      }
      rethrow;
    }
  }

  /// 특정 룸에서 dot 숨김 — 본인 dot 만, BE 가 자동으로 그 룸 응답에서 필터링.
  Future<void> hideDotInRoom(String dotId, String roomId) =>
      _remote.hideDotInRoom(dotId, roomId);

  /// 룸별 숨김 해제 (멱등).
  Future<void> unhideDotInRoom(String dotId, String roomId) =>
      _remote.unhideDotInRoom(dotId, roomId);

  /// 본인이 그 룸에서 숨긴 dot 목록.
  Future<List<Dot>> getHiddenDotsByMe(String roomId) =>
      _remote.getHiddenDotsByMe(roomId);

  // ── Dot ──

  /// dot 저장 — 로컬 우선, 서버 성공 시 서버 (dayLogId, dotId) 반환.
  /// `photo_url` 은 `uploadDot` 페이로드에 함께 들어가므로 별도 PATCH 호출 불필요.
  /// 오프라인이면 (null, null) 반환 (로컬에만 client 임시 id 로 저장).
  ///
  /// 온라인 성공 시 로컬에도 **server dot id** 로 저장 — 이후 polling/검색/시트
  /// refresh 가 dot.id 매칭으로 동작하므로 client id 와 server id 가 다르면
  /// 매칭 실패 → 갱신 누락. id 일원화 필수.
  Future<({String? dayLogId, String? serverDotId})> saveDot(
    Dot dot, {
    required String userId,
  }) async {
    final (:dayLogId, :dotId) = await _remote.uploadDot(dot);

    if (dayLogId != null) {
      // 온라인: 서버 ID로 로컬 daylog 보장 + dot 도 server id 로 저장 (synced=true).
      await _local.ensureDayLog(dayLogId, dot.timestamp, userId);
      await _local.insertDot(dot.copyWith(
        id: dotId ?? dot.id,
        dayLogId: dayLogId,
        synced: true,
      ));
    } else {
      // 오프라인: temp dayLogId로 로컬 daylog 보장 후 dot 저장 (synced=false)
      // photo_url 은 dot.photoUrl 에 이미 들어 있어 다음 batch sync 시 함께 전송.
      await _local.ensureDayLog(dot.dayLogId, dot.timestamp, userId);
      await _local.insertDot(dot);
    }

    return (dayLogId: dayLogId, serverDotId: dotId);
  }

  /// 사진 파일 업로드 → 서버 URL 반환
  Future<String?> uploadPhoto(String filePath) =>
      _remote.uploadPhoto(filePath);

  /// 미동기화 dot 일괄 업로드.
  ///
  /// 응답에 `synced` / `failed` 가 분리돼서 옴.
  /// - `synced` → 로컬 row 를 `synced=true` 로 마킹 (정상)
  /// - `failed` reason 별로 분기:
  ///   - `rate_limited` → **unsynced 유지** (시간 흐름에 따라 자연 해소). 다음 sync
  ///     주기에 재시도. retryAfterSeconds 후엔 BE 가 accept 가능.
  ///   - 그 외 (영구 거절: 태그/메모 길이/timestamp 포맷 등) → markSynced 로 영구
  ///     drop (BE 가 영원히 거절할 데이터를 매 주기 보내면 무한 retry 발생).
  /// - 서버가 응답하지 않은 client_id 는 다음 sync 주기까지 unsynced 로 유지.
  /// 특정 날짜의 미동기화 dot — BG 자동기록이 임시 daylog(`local_y_m_d`)에
  /// 남긴 항목 포함. getDayLogByDate 는 daylog 1개만 반환하므로 임시 daylog 에
  /// 붙은 dot 이 누락될 수 있어, synced=false 전체에서 날짜로 거른다.
  Future<List<Dot>> getUnsyncedDotsForDate(DateTime date) async {
    final rows = await _local.getUnsyncedDots();
    return rows
        .map(_local.dotFromRow)
        .where((d) =>
            d.timestamp.year == date.year &&
            d.timestamp.month == date.month &&
            d.timestamp.day == date.day)
        .toList();
  }

  Future<void> syncUnsyncedDots() async {
    final unsyncedRows = await _local.getUnsyncedDots();
    if (unsyncedRows.isEmpty) return;
    final dots = unsyncedRows.map(_local.dotFromRow).toList();
    final result = await _remote.batchSyncDots(dots);
    if (result.isEmpty) return;

    for (final cid in result.syncedClientIds) {
      final serverId = result.clientToServer[cid];
      if (serverId != null) {
        // server id 로 remap — 이 dot 을 참조하는 todo 체크인도 함께 갱신돼
        // 다음 todo sync 에서 체크인이 서버에 반영된다.
        await _local.remapDotId(cid, serverId);
      } else {
        await _local.markDotSynced(cid);
      }
    }
    for (final f in result.failed) {
      if (f.isRateLimited) {
        // 일시적 — unsynced 유지. 다음 sync 주기에 자동 재시도.
        debugPrint(
            '[syncUnsynced] retry later client_id=${f.clientId} after ${f.retryAfterSeconds}s');
        continue;
      }
      // 영구 거절 — 무한 retry 차단을 위해 markSynced (drop).
      debugPrint(
          '[syncUnsynced] drop permanent client_id=${f.clientId} reason=${f.reason}');
      await _local.markDotSynced(f.clientId);
    }
  }
}

@riverpod
DotRepository dotRepository(Ref ref) => DotRepository(
      ref.watch(dotLocalSourceProvider),
      ref.watch(dotRemoteSourceProvider),
    );
