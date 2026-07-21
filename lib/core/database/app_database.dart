import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../features/recording/domain/tag_parser.dart';
import '../storage/secure_storage.dart';

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
  // BE 가 비동기로 생성하는 사진 variant URL. 업로드 직후엔 null,
  // 수초 내 BE 백그라운드 워커가 채움. UI 는 null 이면 photoUrl 폴백.
  TextColumn get photoThumbUrl => text().nullable()();
  TextColumn get photoPreviewUrl => text().nullable()();
  TextColumn get memo => text().nullable()();
  TextColumn get emotion => text().nullable()();
  TextColumn get dayLogId => text()();
  // 정규화된 해시태그 — JSON 직렬화 (예: `["회의","피곤"]`).
  // 검색은 본인 dot 단위라 N 작음 → JSON LIKE 로 충분.
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
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

/// 할일(todo) 묶음 — "코스" (여행 or 상시 모음).
class TodoListTable extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get name => text()();
  TextColumn get coverEmoji => text().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  // 공개 공유 토큰 (비로그인 사용자 read-only 접근용).
  TextColumn get shareToken => text().nullable()();
  DateTimeColumn get shareTokenExpiresAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get synced =>
      boolean().withDefault(const Constant(false))();
  // v5 — 코스 유형 ('trip' | 'collection'). BE 도 저장 (course_type).
  TextColumn get courseType =>
      text().withDefault(const Constant('trip'))();
  // v5 — 메타 정보 (BE 동기화 예정).
  TextColumn get description => text().nullable()();
  TextColumn get tagsJson =>
      text().withDefault(const Constant('[]'))();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get visibility =>
      text().withDefault(const Constant('private'))();
  // v6 — 다른 사람이 공유한 코스를 import 한 경우 true.
  BoolColumn get isImported =>
      boolean().withDefault(const Constant(false))();
  // v7 — 협업 멤버 목록 JSON (CourseMember 배열).
  TextColumn get membersJson =>
      text().withDefault(const Constant('[]'))();
  // v11 — 컬렉션 상단 고정.
  BoolColumn get isPinned =>
      boolean().withDefault(const Constant(false))();
  IntColumn get pinOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// 할일 1건 — 가야 할 장소 1개. plannedAt 도래 시 체크인 가능.
/// 체크인 성공 시 checkInDotId 에 정상 Dot.id 가 들어가 trail 에 자동 편입됨.
class TodoItemTable extends Table {
  TextColumn get id => text()();
  TextColumn get todoListId =>
      text().references(TodoListTable, #id)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get placeName => text().nullable()();
  TextColumn get placeCategory => text().nullable()();
  TextColumn get placeId => text().nullable()();
  DateTimeColumn get plannedAt => dateTime().nullable()();
  IntColumn get dayIndex => integer().withDefault(const Constant(0))();
  IntColumn get orderInDay => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  TextColumn get emotion => text().nullable()();
  // 체크인 시 생성된 Dot.id 약한 참조 (FK 아님 — Dot 은 삭제 가능).
  TextColumn get checkInDotId => text().nullable()();
  DateTimeColumn get checkedInAt => dateTime().nullable()();
  // v5 — 계획 시점 첨부 이미지.
  TextColumn get photoUrl => text().nullable()();
  BoolColumn get synced =>
      boolean().withDefault(const Constant(false))();
  // v8 — 체크인 상태에 *로컬 미반영 변경* 이 있는지 (오프라인 체크인/취소).
  // sync 시 이 플래그가 true 일 때만 checkIn/cancelCheckIn 을 서버에 push —
  // 공유 코스에서 다른 멤버의 서버측 체크인을 오인 취소하지 않기 위한 구분자.
  BoolColumn get checkInDirty =>
      boolean().withDefault(const Constant(false))();
  // v9 — 즐겨찾기 고정.
  BoolColumn get isPinned =>
      boolean().withDefault(const Constant(false))();
  IntColumn get pinOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// ─── 데이터베이스 ─────────────────────────────────────

@DriftDatabase(tables: [DotTable, DayLogTable, TodoListTable, TodoItemTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 12;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          // v2 — DotTable.tagsJson 컬럼 추가 + 기존 메모에서 #태그 백필.
          if (from < 2) {
            await m.addColumn(dotTable, dotTable.tagsJson);
            await _backfillTagsJson();
          }
          // v3 — DotTable.photoThumbUrl / photoPreviewUrl 컬럼 추가.
          if (from < 3) {
            await m.addColumn(dotTable, dotTable.photoThumbUrl);
            await m.addColumn(dotTable, dotTable.photoPreviewUrl);
          }
          // v4 — TodoListTable, TodoItemTable 신규 추가.
          if (from < 4) {
            await m.createTable(todoListTable);
            await m.createTable(todoItemTable);
          }
          // v5 — TodoListTable: courseType/description/tagsJson/coverImageUrl/visibility.
          //      TodoItemTable: photoUrl.
          if (from < 5) {
            await m.addColumn(todoListTable, todoListTable.courseType);
            await m.addColumn(todoListTable, todoListTable.description);
            await m.addColumn(todoListTable, todoListTable.tagsJson);
            await m.addColumn(todoListTable, todoListTable.coverImageUrl);
            await m.addColumn(todoListTable, todoListTable.visibility);
            await m.addColumn(todoItemTable, todoItemTable.photoUrl);
          }
          // v6 — TodoListTable: isImported 컬럼 추가.
          if (from < 6) {
            await m.addColumn(todoListTable, todoListTable.isImported);
          }
          // v7 — TodoListTable: membersJson 컬럼 추가.
          if (from < 7) {
            await m.addColumn(todoListTable, todoListTable.membersJson);
          }
          // v8 — TodoItemTable: checkInDirty (오프라인 체크인/취소 pending 표시).
          if (from < 8) {
            await m.addColumn(todoItemTable, todoItemTable.checkInDirty);
          }
          // v9 — TodoItemTable: isPinned / pinOrder (즐겨찾기 고정).
          if (from < 9) {
            await m.addColumn(todoItemTable, todoItemTable.isPinned);
            await m.addColumn(todoItemTable, todoItemTable.pinOrder);
          }
          // v10 — TodoItemTable: plannedAt nullable (시간 선택 옵션화).
          // SQLite는 ALTER COLUMN 미지원 — 기존 NOT NULL 행은 값 보존.
          // drift 스키마 선언만 nullable()로 변경. 마이그레이션 별도 쿼리 불필요.
          // v11 — TodoListTable: isPinned / pinOrder (컬렉션 상단 고정).
          if (from < 11) {
            await m.addColumn(todoListTable, todoListTable.isPinned);
            await m.addColumn(todoListTable, todoListTable.pinOrder);
          }
          // v12 — TodoItemTable.plannedAt NOT NULL → nullable 실제 적용.
          // v10에서 drift 선언만 바꿨지만 SQLite는 기존 컬럼 제약을 유지해
          // plannedAt=null 삽입 시 NOT NULL constraint 에러가 발생했음.
          // alterTable(TableMigration)으로 현재 스키마(nullable)로 테이블을 재생성.
          if (from < 12) {
            await m.alterTable(TableMigration(todoItemTable));
          }
        },
      );

  /// 로그아웃/회원탈퇴 시 로컬 DB 전체 삭제.
  ///
  /// 보안: 이 DB 는 사용자별로 격리되지 않으며(`getAllDots`/`getAllTodoLists`
  /// 는 user 필터가 없음), 로그아웃 후 잔존하면 공용/중고 기기에서 다음
  /// 사용자에게 이전 사용자의 위치 이력·할일이 노출될 수 있다. 계정 정리
  /// 시점에 모든 테이블을 비운다. 스키마는 유지(재로그인 시 재사용).
  Future<void> wipeAll() async {
    await transaction(() async {
      await delete(dotTable).go();
      await delete(dayLogTable).go();
      await delete(todoItemTable).go();
      await delete(todoListTable).go();
    });
  }

  /// 기존 dot 메모에서 `#태그` 추출해 `tagsJson` 채우기 (1회성, v1→v2).
  ///
  /// 큰 데이터셋(수천+) 사용자 보호:
  /// - 500건 단위 chunk 로 메모리 사용량 제한
  /// - chunk 단위 transaction — 중간 crash 시 재실행 안전 (idempotent: 이미
  ///   tagsJson 이 채워진 row 는 다음 시도에 같은 결과를 만들어냄).
  /// - 메모가 없거나 태그 미포함 row 는 skip (write 안 함).
  Future<void> _backfillTagsJson() async {
    const chunkSize = 500;
    var offset = 0;
    while (true) {
      final rows = await (select(dotTable)
            ..limit(chunkSize, offset: offset))
          .get();
      if (rows.isEmpty) break;
      await transaction(() async {
        for (final row in rows) {
          final memo = row.memo;
          if (memo == null || memo.isEmpty) continue;
          final tags = TagParser.extractFromText(memo);
          if (tags.isEmpty) continue;
          await (update(dotTable)..where((t) => t.id.equals(row.id)))
              .write(DotTableCompanion(tagsJson: Value(jsonEncode(tags))));
        }
      });
      if (rows.length < chunkSize) break;
      offset += chunkSize;
    }
  }

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

  /// 전체 dot row — 태그 검색 등 user-agnostic 조회용.
  /// **주의**: user 분리 안 됨. 멀티계정 단말에서 호출 시 다른 user 의 dot 노출.
  /// 일반 검색/집계는 [getDotsForUser] 사용 권장.
  Future<List<DotTableData>> getAllDots() => select(dotTable).get();

  /// dayLog.userId 로 필터링된 dot. 검색/집계의 멀티계정 격리에 사용.
  /// dayLog row 가 사라진(orphan) dot 은 결과에서 제외 — 정상 데이터 흐름에서는
  /// `mergeOrphanDayLogs` 가 처리하지만 안전하게 inner join.
  Future<List<DotTableData>> getDotsForUser(String userId) {
    final query = select(dotTable).join([
      innerJoin(
        dayLogTable,
        dayLogTable.id.equalsExp(dotTable.dayLogId) &
            dayLogTable.userId.equals(userId),
      ),
    ]);
    return query.map((row) => row.readTable(dotTable)).get();
  }

  /// user 의 가장 최신 dot timestamp. 없으면 null.
  /// rate-limit 게이트 (60초) FE 사전 검증에 사용.
  Future<DateTime?> getLastDotTimestampForUser(String userId) async {
    final maxTs = dotTable.timestamp.max();
    final query = selectOnly(dotTable).join([
      innerJoin(
        dayLogTable,
        dayLogTable.id.equalsExp(dotTable.dayLogId) &
            dayLogTable.userId.equals(userId),
      ),
    ])
      ..addColumns([maxTs]);
    final row = await query.getSingleOrNull();
    return row?.read(maxTs);
  }

  Future<List<DotTableData>> getUnsyncedDots() =>
      (select(dotTable)..where((t) => t.synced.equals(false))).get();

  Future<int> insertDot(DotTableCompanion dot) =>
      into(dotTable).insert(dot);

  Future<void> upsertDot(DotTableCompanion dot) =>
      into(dotTable).insertOnConflictUpdate(dot);

  Future<void> markDotSynced(String dotId) => (update(dotTable)
        ..where((t) => t.id.equals(dotId)))
      .write(const DotTableCompanion(synced: Value(true)));

  /// batch sync 성공 시 client dot id → BE 발급 server id 치환.
  ///
  /// 이 dot 을 참조하는 todo 체크인(checkInDotId)도 함께 server id 로
  /// 갱신하고 해당 item 을 재동기화 대상(synced=false)으로 되돌린다 —
  /// 오프라인 dot 으로 체크인한 경우 todo sync 가 서버에 체크인을 반영할
  /// 수 있는 유일한 연결 고리.
  Future<void> remapDotId(String oldId, String newId) async {
    if (oldId == newId) {
      await markDotSynced(oldId);
      return;
    }
    await transaction(() async {
      await (update(dotTable)..where((t) => t.id.equals(oldId))).write(
        DotTableCompanion(id: Value(newId), synced: const Value(true)),
      );
      await (update(todoItemTable)
            ..where((t) => t.checkInDotId.equals(oldId)))
          .write(TodoItemTableCompanion(
        checkInDotId: Value(newId),
        synced: const Value(false),
        checkInDirty: const Value(true),
      ));
    });
  }

  Future<int> deleteDayLog(String id) =>
      (delete(dayLogTable)..where((t) => t.id.equals(id))).go();

  Future<int> deleteDotsByDayLog(String dayLogId) =>
      (delete(dotTable)..where((t) => t.dayLogId.equals(dayLogId))).go();

  Future<int> deleteDotById(String id) =>
      (delete(dotTable)..where((t) => t.id.equals(id))).go();

  // ── TodoList CRUD ──

  Future<List<TodoListTableData>> getTodoListsForUser(String userId) =>
      (select(todoListTable)
            ..where((t) => t.ownerId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
          .get();

  /// owner 뿐 아니라 멤버로 참여한 코스까지 포함 — BE가 참여 코스 전체를 반환하므로
  /// local fallback 도 같은 범위가 필요. 단일 계정 앱에서만 사용.
  Future<List<TodoListTableData>> getAllTodoLists() =>
      (select(todoListTable)
            ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
          .get();

  Future<TodoListTableData?> getTodoListById(String id) =>
      (select(todoListTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> upsertTodoList(TodoListTableCompanion list) =>
      into(todoListTable).insertOnConflictUpdate(list);

  Future<int> deleteTodoListById(String id) async {
    // CASCADE 가 명시적 FK 없으므로 자식 행 먼저 정리.
    await (delete(todoItemTable)..where((t) => t.todoListId.equals(id))).go();
    return (delete(todoListTable)..where((t) => t.id.equals(id))).go();
  }

  Future<List<TodoListTableData>> getUnsyncedTodoLists() =>
      (select(todoListTable)..where((t) => t.synced.equals(false))).get();

  // ── TodoItem CRUD ──

  Future<List<TodoItemTableData>> getTodoItemsByList(String todoListId) =>
      (select(todoItemTable)
            ..where((t) => t.todoListId.equals(todoListId))
            ..orderBy([
              (t) => OrderingTerm.asc(t.dayIndex),
              (t) => OrderingTerm.asc(t.orderInDay),
            ]))
          .get();

  Future<TodoItemTableData?> getTodoItemById(String id) =>
      (select(todoItemTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<void> upsertTodoItem(TodoItemTableCompanion item) =>
      into(todoItemTable).insertOnConflictUpdate(item);

  Future<int> deleteTodoItemById(String id) =>
      (delete(todoItemTable)..where((t) => t.id.equals(id))).go();

  Future<List<TodoItemTableData>> getUnsyncedTodoItems() =>
      (select(todoItemTable)..where((t) => t.synced.equals(false))).get();

  /// 체크인 — Dot.id 를 link 하고 checkedInAt 기록.
  /// (오프라인 경로 전용 — checkInDirty 로 sync 시 서버 push 대상 표시)
  Future<bool> markTodoItemCheckedIn({
    required String itemId,
    required String checkInDotId,
    required DateTime checkedInAt,
  }) async {
    final count = await (update(todoItemTable)
          ..where((t) => t.id.equals(itemId)))
        .write(TodoItemTableCompanion(
      checkInDotId: Value(checkInDotId),
      checkedInAt: Value(checkedInAt),
      synced: const Value(false), // 서버 sync 필요
      checkInDirty: const Value(true),
    ));
    return count > 0;
  }

  /// 체크인 취소 — Dot 삭제 시 호출. checkInDotId / checkedInAt 모두 null 로.
  /// (오프라인 경로 전용 — checkInDirty 로 sync 시 cancelCheckIn push 표시)
  Future<bool> unmarkTodoItemCheckedIn(String itemId) async {
    final count = await (update(todoItemTable)
          ..where((t) => t.id.equals(itemId)))
        .write(const TodoItemTableCompanion(
      checkInDotId: Value(null),
      checkedInAt: Value(null),
      synced: Value(false),
      checkInDirty: Value(true),
    ));
    return count > 0;
  }

  /// 체크인 pending 해소 — 서버 반영 성공 시 호출.
  Future<void> clearTodoItemCheckInDirty(String itemId) =>
      (update(todoItemTable)..where((t) => t.id.equals(itemId)))
          .write(const TodoItemTableCompanion(checkInDirty: Value(false)));

  /// 드래그 재정렬 — 같은 dayIndex 내 여러 item 의 orderInDay 일괄 갱신.
  /// transaction 으로 묶어 중간 실패 시 부분 갱신 방지.
  Future<void> reorderTodoItemsInDay({
    required String todoListId,
    required int dayIndex,
    required List<({String id, int orderInDay})> orderedItems,
  }) =>
      transaction(() async {
        for (final entry in orderedItems) {
          await (update(todoItemTable)
                ..where((t) =>
                    t.id.equals(entry.id) &
                    t.todoListId.equals(todoListId) &
                    t.dayIndex.equals(dayIndex)))
              .write(TodoItemTableCompanion(
            orderInDay: Value(entry.orderInDay),
            synced: const Value(false),
          ));
        }
      });

  /// 전체 뷰 재정렬 — dayIndex + orderInDay 동시 변경, 단일 트랜잭션.
  Future<void> reorderTodoItemsGlobal({
    required String todoListId,
    required List<({String id, int dayIndex, int orderInDay})> items,
  }) =>
      transaction(() async {
        for (final entry in items) {
          await (update(todoItemTable)
                ..where((t) =>
                    t.id.equals(entry.id) & t.todoListId.equals(todoListId)))
              .write(TodoItemTableCompanion(
            dayIndex: Value(entry.dayIndex),
            orderInDay: Value(entry.orderInDay),
            synced: const Value(false),
          ));
        }
      });
}

// ── 로컬 DB 오픈 전략 — 평문 + 자가 복구 ─────────────────────
//
// SQLCipher 암호화는 제거했다. 이유:
//  1. iOS 에서 Mapbox 등 다른 네이티브 SDK 가 시스템 libsqlite3 를 먼저
//     링크하면 심볼이 시스템 SQLite 로 바인딩돼, 빌드 모드(debug/release)에
//     따라 암호화 가능 여부가 달라짐 → 같은 기기에서 상태 전이가 꼬임.
//  2. Keychain(first_unlock_this_device) 이 일시적으로 null 을 반환하는
//     시점(재부팅 직후 백그라운드 실행 등)에 키가 재생성되면 기존 암호화
//     DB 를 영영 못 열게 됨 — 실제 발생한 사고.
//  3. iOS Data Protection / Android FBE 가 이미 저장소 수준 암호화를 제공.
//
// 대신 오픈 전에 파일 무결성을 확인하고, 읽을 수 없는 DB(과거 암호화 잔재,
// 키 유실, 부분 마이그레이션)는 아래 순서로 복구한다:
//  1) 과거 빌드가 암호화해 둔 DB → 저장된 키로 복호화해 평문 복원 (데이터 보존)
//  2) 복호화 불가(키 유실 등) → 파일 삭제 후 재생성. 로컬 DB 는 캐시이고
//     원본은 서버에 있으므로 재동기화로 복구된다. 영구 먹통보다 낫다.
const _dbPassphraseKey = 'db_passphrase_v1';
const _dbEncryptedFlagKey = 'db_encrypted_v1';

/// 과거 암호화 빌드가 남긴 SQLCipher 라이브러리 연결 (복호화 전용).
void _useSqlCipher() {
  if (Platform.isAndroid) {
    open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
  }
}

/// 이 프로세스의 sqlite3 가 실제로 SQLCipher 인지 확인 (복호화 가능 여부).
bool _sqlCipherAvailable() {
  try {
    final probe = sqlite3.openInMemory();
    try {
      final rows = probe.select('PRAGMA cipher_version;');
      return rows.isNotEmpty;
    } finally {
      probe.dispose();
    }
  } catch (_) {
    return false;
  }
}

/// 파일이 평문 SQLite DB 로 읽히는지 probe.
bool _isReadablePlaintext(File file) {
  if (!file.existsSync()) return true; // 신규 생성 — 문제 없음
  try {
    final db = sqlite3.open(file.path);
    try {
      db.select('SELECT count(*) FROM sqlite_master;');
      return true;
    } finally {
      db.dispose();
    }
  } catch (_) {
    return false;
  }
}

/// DB 파일 + WAL/SHM 부속 파일 삭제.
void _deleteDbFiles(File file) {
  for (final path in [file.path, '${file.path}-wal', '${file.path}-shm',
      '${file.path}.enc', '${file.path}.plain']) {
    final f = File(path);
    if (f.existsSync()) {
      try {
        f.deleteSync();
      } catch (_) {}
    }
  }
}

/// 과거 빌드가 암호화한 DB 를 평문으로 복원 (성공 시 데이터 보존).
/// 실패하면 false — 호출자가 재생성으로 폴백.
Future<bool> _tryDecryptToPlaintext(
    File file, FlutterSecureStorage storage) async {
  if (!_sqlCipherAvailable()) return false;
  final String? passphrase;
  try {
    passphrase = await storage.read(key: _dbPassphraseKey);
  } catch (_) {
    return false;
  }
  if (passphrase == null || passphrase.isEmpty) return false;

  final plainPath = '${file.path}.plain';
  final plainTmp = File(plainPath);
  if (plainTmp.existsSync()) plainTmp.deleteSync();

  try {
    final db = sqlite3.open(file.path);
    try {
      final escapedPassphrase = passphrase.replaceAll("'", "''");
      db.execute("PRAGMA key = '$escapedPassphrase';");
      // 키가 맞는지 검증 — 틀리면 여기서 throw.
      db.select('SELECT count(*) FROM sqlite_master;');
      db.execute("ATTACH DATABASE '$plainPath' AS plain KEY '';");
      db.execute("SELECT sqlcipher_export('plain');");
      db.execute('DETACH DATABASE plain;');
    } finally {
      db.dispose();
    }
    file.deleteSync();
    plainTmp.renameSync(file.path);
    debugPrint('[AppDatabase] encrypted DB decrypted back to plaintext');
    return true;
  } catch (e) {
    debugPrint('[AppDatabase] decrypt failed: $e');
    if (plainTmp.existsSync()) {
      try {
        plainTmp.deleteSync();
      } catch (_) {}
    }
    return false;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    _useSqlCipher();
    const storage = kSecureStorage;
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'dottie.db'));

    // 평문으로 읽을 수 없는 파일 — 과거 암호화 잔재. 복호화 시도 후
    // 실패하면 재생성 (로컬 캐시 손실 감수, 서버에서 재동기화).
    if (!_isReadablePlaintext(file)) {
      final recovered = await _tryDecryptToPlaintext(file, storage);
      if (!recovered) {
        debugPrint(
            '[AppDatabase] unreadable DB — recreating (cache resync from server)');
        _deleteDbFiles(file);
      }
    }

    // 암호화 관련 상태 키 정리 — 이후 빌드에서 재사용되지 않도록.
    try {
      await storage.delete(key: _dbPassphraseKey);
      await storage.delete(key: _dbEncryptedFlagKey);
    } catch (_) {}

    // isolateSetup: 백그라운드 isolate에서도 Android SQLCipher 라이브러리를
    // 로드하도록 설정. 미설정 시 배경 isolate가 libsqlite3.so를 못 찾아
    // Android 신규 사용자의 첫 DB 열기가 실패할 수 있음.
    return NativeDatabase.createInBackground(file, isolateSetup: _useSqlCipher);
  });
}
