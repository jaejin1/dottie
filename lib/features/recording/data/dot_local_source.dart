import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/app_database.dart';
import '../domain/dot_model.dart';
import '../../timeline/domain/day_log_model.dart';

part 'dot_local_source.g.dart';

class DotLocalSource {
  DotLocalSource(this._db);
  final AppDatabase _db;

  // ── DayLog ──

  Future<DayLogTableData?> getActiveDayLog() =>
      (_db.select(_db.dayLogTable)
            ..where((t) => t.isRecording.equals(true)))
          .getSingleOrNull();

  Future<DayLogTableData?> getDayLogByDate(DateTime date, String userId) =>
      _db.getDayLogByDate(date, userId);

  Future<String> startDayLog(String userId, {String? id}) async {
    final dayLogId = id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();
    await _db.insertDayLog(DayLogTableCompanion.insert(
      id: dayLogId,
      userId: userId,
      date: now,
      startedAt: now,
      isRecording: const Value(true),
    ));
    return dayLogId;
  }

  Future<void> endDayLog(String dayLogId) async {
    await (_db.update(_db.dayLogTable)
          ..where((t) => t.id.equals(dayLogId)))
        .write(DayLogTableCompanion(
      endedAt: Value(DateTime.now()),
      isRecording: const Value(false),
    ));
  }

  Future<List<DayLogTableData>> getAllDayLogs(String userId) =>
      _db.getAllDayLogs(userId);

  Future<void> upsertDayLog(DayLog dayLog) => _db.upsertDayLog(
        DayLogTableCompanion.insert(
          id: dayLog.id,
          userId: dayLog.userId,
          date: dayLog.date,
          startedAt: dayLog.startedAt,
          endedAt: Value(dayLog.endedAt),
          isRecording: Value(dayLog.isRecording),
          synced: const Value(true),
        ),
      );

  Future<void> upsertDots(List<Dot> dots) async {
    for (final dot in dots) {
      await _db.upsertDot(DotTableCompanion.insert(
        id: dot.id,
        latitude: dot.latitude,
        longitude: dot.longitude,
        timestamp: dot.timestamp,
        placeName: Value(dot.placeName),
        placeCategory: Value(dot.placeCategory),
        photoUrl: Value(dot.photoUrl),
        photoThumbUrl: Value(dot.photoThumbUrl),
        photoPreviewUrl: Value(dot.photoPreviewUrl),
        memo: Value(dot.memo),
        emotion: Value(dot.emotion),
        dayLogId: dot.dayLogId,
        tagsJson: Value(jsonEncode(dot.tags)),
        synced: const Value(true),
      ));
    }
  }

  // ── Dot ──

  Future<void> insertDot(Dot dot) async {
    await _db.insertDot(DotTableCompanion.insert(
      id: dot.id,
      latitude: dot.latitude,
      longitude: dot.longitude,
      timestamp: dot.timestamp,
      placeName: Value(dot.placeName),
      placeCategory: Value(dot.placeCategory),
      photoUrl: Value(dot.photoUrl),
      photoThumbUrl: Value(dot.photoThumbUrl),
      photoPreviewUrl: Value(dot.photoPreviewUrl),
      memo: Value(dot.memo),
      emotion: Value(dot.emotion),
      dayLogId: dot.dayLogId,
      tagsJson: Value(jsonEncode(dot.tags)),
      synced: Value(dot.synced),
    ));
  }

  Future<List<DotTableData>> getDotsByDayLog(String dayLogId) =>
      _db.getDotsByDayLog(dayLogId);

  /// 단말에 저장된 모든 dot — 태그 검색 등 글로벌 조회.
  /// **주의**: user 분리 안 됨. 멀티계정 단말에서 사용 시 [getDotsForUser] 권장.
  Future<List<DotTableData>> getAllDots() => _db.getAllDots();

  /// userId 로 필터링된 dot.
  Future<List<DotTableData>> getDotsForUser(String userId) =>
      _db.getDotsForUser(userId);

  /// user 의 가장 최신 dot timestamp. 없으면 null. rate-limit 게이트용.
  Future<DateTime?> getLastDotTimestampForUser(String userId) =>
      _db.getLastDotTimestampForUser(userId);

  Future<List<DotTableData>> getUnsyncedDots() => _db.getUnsyncedDots();

  Future<void> markDotSynced(String dotId) => _db.markDotSynced(dotId);

  /// client dot id → server id 치환 (+ todo 체크인 참조 갱신).
  Future<void> remapDotId(String oldId, String newId) =>
      _db.remapDotId(oldId, newId);

  Future<void> deleteDayLog(String id) async {
    await _db.deleteDotsByDayLog(id);
    await _db.deleteDayLog(id);
  }

  Future<void> deleteDotById(String id) => _db.deleteDotById(id);

  /// 서버 dayLogId로 로컬 daylog가 없으면 생성 (upsert)
  Future<void> ensureDayLog(String id, DateTime date, String userId) =>
      _db.upsertDayLog(DayLogTableCompanion.insert(
        id: id,
        userId: userId,
        date: date,
        startedAt: date,
        synced: const Value(true),
      ));

  /// 같은 날짜의 임시 daylog 들의 dot 을 canonical 로 이전 + 정리.
  /// server sync 직후 호출 — 임시 daylog (`local_*`) 흔적을 합침.
  Future<int> mergeOrphanDayLogs(String canonicalId, DateTime date) =>
      _db.mergeOrphanDayLogs(canonicalId, date);

  // DotTableData → Dot 변환
  Dot dotFromRow(DotTableData row) => Dot(
        id: row.id,
        latitude: row.latitude,
        longitude: row.longitude,
        timestamp: row.timestamp,
        placeName: row.placeName,
        placeCategory: row.placeCategory,
        photoUrl: row.photoUrl,
        photoThumbUrl: row.photoThumbUrl,
        photoPreviewUrl: row.photoPreviewUrl,
        memo: row.memo,
        emotion: row.emotion,
        dayLogId: row.dayLogId,
        tags: _decodeTags(row.tagsJson),
        synced: row.synced,
      );

  static List<String> _decodeTags(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final parsed = jsonDecode(raw);
      if (parsed is List) {
        return parsed.whereType<String>().toList(growable: false);
      }
    } catch (_) {}
    return const [];
  }

  // DayLogTableData → DayLog 변환
  DayLog dayLogFromRow(DayLogTableData row, List<Dot> dots) => DayLog(
        id: row.id,
        userId: row.userId,
        date: row.date,
        dots: dots,
        startedAt: row.startedAt,
        endedAt: row.endedAt,
        isRecording: row.isRecording,
        synced: row.synced,
      );
}

// AppDatabase 싱글턴 — keepAlive로 앱 생애주기 동안 단 하나만 존재
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) => AppDatabase();

@riverpod
DotLocalSource dotLocalSource(Ref ref) =>
    DotLocalSource(ref.watch(appDatabaseProvider));
