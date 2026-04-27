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

  Future<List<DayLogTableData>> getAllDayLogs() =>
      select(dayLogTable).get();

  Future<DayLogTableData?> getDayLogByDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(dayLogTable)
          ..where(
            (t) => t.date.isBetweenValues(start, end),
          ))
        .getSingleOrNull();
  }

  Future<int> insertDayLog(DayLogTableCompanion log) =>
      into(dayLogTable).insert(log);

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

  Future<void> markDotSynced(String dotId) => (update(dotTable)
        ..where((t) => t.id.equals(dotId)))
      .write(const DotTableCompanion(synced: Value(true)));
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'dottie.db'));
    return NativeDatabase.createInBackground(file);
  });
}
