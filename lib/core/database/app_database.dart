import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// ─── 테이블 정의 ─────────────────────────────────────

class DotTable extends Table {
  TextColumn get id => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get placeName => text().nullable()();
  TextColumn get placeCategory => text().nullable()();
  TextColumn get photoLocalPath => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get memo => text().nullable()();
  TextColumn get emotion => text().nullable()();
  TextColumn get dayLogId => text()();
  BoolColumn get synced =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class DayLogTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  BoolColumn get isRecording =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get synced =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── 데이터베이스 ─────────────────────────────────────

@DriftDatabase(tables: [DotTable, DayLogTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ── DayLog CRUD ──

  Future<List<DayLogTableData>> getAllDayLogs(String userId) =>
      (select(dayLogTable)..where((t) => t.userId.equals(userId))).get();

  Future<DayLogTableData?> getDayLogByDate(DateTime date, String userId) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    // 임시 daylog 정리 누락 등으로 같은 날짜에 중복 row 가 있을 수 있으므로
    // getSingleOrNull(다중 시 throw) 대신 .get() 후 1개 선택.
    final rows = await (select(dayLogTable)
          ..where(
            (t) =>
                t.userId.equals(userId) & t.date.isBetweenValues(start, end),
          ))
        .get();
    if (rows.isEmpty) return null;
    if (rows.length == 1) return rows.first;
    // 다중 — synced=true 우선, 없으면 첫 번째
    final synced = rows.where((r) => r.synced);
    return synced.isNotEmpty ? synced.first : rows.first;
  }

  /// 같은 날짜의 임시 daylog (canonicalId 가 아닌) 의 dot 을 canonical 로 이전 +
  /// 임시 daylog row 삭제. server sync 직후 호출.
  Future<int> mergeOrphanDayLogs(String canonicalId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final orphans = await (select(dayLogTable)
          ..where((t) =>
              t.id.isNotValue(canonicalId) &
              t.date.isBetweenValues(start, end)))
        .get();
    if (orphans.isEmpty) return 0;
    for (final o in orphans) {
      await (update(dotTable)..where((t) => t.dayLogId.equals(o.id)))
          .write(DotTableCompanion(dayLogId: Value(canonicalId)));
      await (delete(dayLogTable)..where((t) => t.id.equals(o.id))).go();
    }
    return orphans.length;
  }

  Future<int> insertDayLog(DayLogTableCompanion log) =>
      into(dayLogTable).insert(log);

  Future<void> upsertDayLog(DayLogTableCompanion log) =>
      into(dayLogTable).insertOnConflictUpdate(log);

  Future<bool> updateDayLog(DayLogTableCompanion log) =>
      update(dayLogTable).replace(log);

  // ── Dot CRUD ──

  Future<List<DotTableData>> getDotsByDayLog(String dayLogId) =>
      (select(dotTable)..where((t) => t.dayLogId.equals(dayLogId)))
          .get();

  Future<List<DotTableData>> getUnsyncedDots() =>
      (select(dotTable)..where((t) => t.synced.equals(false))).get();

  Future<int> insertDot(DotTableCompanion dot) =>
      into(dotTable).insert(dot);

  Future<void> upsertDot(DotTableCompanion dot) =>
      into(dotTable).insertOnConflictUpdate(dot);

  Future<void> markDotSynced(String dotId) => (update(dotTable)
        ..where((t) => t.id.equals(dotId)))
      .write(const DotTableCompanion(synced: Value(true)));

  Future<int> deleteDayLog(String id) =>
      (delete(dayLogTable)..where((t) => t.id.equals(id))).go();

  Future<int> deleteDotsByDayLog(String dayLogId) =>
      (delete(dotTable)..where((t) => t.dayLogId.equals(dayLogId))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'dottie.db'));
    return NativeDatabase.createInBackground(file);
  });
}
