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

  Future<DayLogTableData?> getDayLogByDate(DateTime date) =>
      _db.getDayLogByDate(date);

  Future<String> startDayLog(String userId) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();
    await _db.insertDayLog(DayLogTableCompanion.insert(
      id: id,
      userId: userId,
      date: now,
      startedAt: now,
      isRecording: const Value(true),
    ));
    return id;
  }

  Future<void> endDayLog(String dayLogId) async {
    await (_db.update(_db.dayLogTable)
          ..where((t) => t.id.equals(dayLogId)))
        .write(DayLogTableCompanion(
      endedAt: Value(DateTime.now()),
      isRecording: const Value(false),
    ));
  }

  Future<List<DayLogTableData>> getAllDayLogs() => _db.getAllDayLogs();

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
      memo: Value(dot.memo),
      emotion: Value(dot.emotion),
      dayLogId: dot.dayLogId,
      synced: Value(dot.synced),
    ));
  }

  Future<List<DotTableData>> getDotsByDayLog(String dayLogId) =>
      _db.getDotsByDayLog(dayLogId);

  Future<List<DotTableData>> getUnsyncedDots() => _db.getUnsyncedDots();

  Future<void> markDotSynced(String dotId) => _db.markDotSynced(dotId);

  // DotTableData → Dot 변환
  Dot dotFromRow(DotTableData row) => Dot(
        id: row.id,
        latitude: row.latitude,
        longitude: row.longitude,
        timestamp: row.timestamp,
        placeName: row.placeName,
        placeCategory: row.placeCategory,
        photoUrl: row.photoUrl,
        memo: row.memo,
        emotion: row.emotion,
        dayLogId: row.dayLogId,
        synced: row.synced,
      );

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

@riverpod
DotLocalSource dotLocalSource(Ref ref) =>
    DotLocalSource(AppDatabase());
