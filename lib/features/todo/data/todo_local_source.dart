import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/database/app_database.dart';
import '../../recording/data/dot_local_source.dart';
import '../domain/course_member_model.dart';
import '../domain/todo_item_model.dart';
import '../domain/todo_list_model.dart';

part 'todo_local_source.g.dart';

class TodoLocalSource {
  TodoLocalSource(this._db);
  final AppDatabase _db;

  // ── TodoList ──

  Future<List<TodoListTableData>> getTodoListsForUser(String userId) =>
      _db.getTodoListsForUser(userId);

  Future<List<TodoListTableData>> getAllTodoLists() =>
      _db.getAllTodoLists();

  Future<TodoListTableData?> getTodoListById(String id) =>
      _db.getTodoListById(id);

  Future<void> upsertTodoList(TodoList list) =>
      _db.upsertTodoList(TodoListTableCompanion.insert(
        id: list.id,
        ownerId: list.ownerId,
        name: list.name,
        coverEmoji: Value(list.coverEmoji),
        startDate: list.startDate,
        endDate: list.endDate,
        shareToken: Value(list.shareToken),
        shareTokenExpiresAt: Value(list.shareTokenExpiresAt),
        createdAt: list.createdAt,
        updatedAt: list.updatedAt,
        synced: Value(list.synced),
        courseType: Value(list.courseType),
        description: Value(list.description),
        tagsJson: Value(
          list.tags.isEmpty ? '[]' : jsonEncode(list.tags),
        ),
        coverImageUrl: Value(list.coverImageUrl),
        visibility: Value(list.visibility),
        isImported: Value(list.isImported),
        membersJson: Value(
          list.members.isEmpty
              ? '[]'
              : jsonEncode(list.members.map((m) => m.toJson()).toList()),
        ),
        isPinned: Value(list.isPinned),
        pinOrder: Value(list.pinOrder),
        likeCount: Value(list.likeCount),
        region: Value(list.region),
      ));

  Future<int> deleteTodoListById(String id) => _db.deleteTodoListById(id);

  Future<List<TodoListTableData>> getUnsyncedTodoLists() =>
      _db.getUnsyncedTodoLists();

  Future<void> markTodoListSynced(String id) async {
    await (_db.update(_db.todoListTable)
          ..where((t) => t.id.equals(id)))
        .write(const TodoListTableCompanion(synced: Value(true)));
  }

  // ── TodoItem ──

  Future<List<TodoItemTableData>> getTodoItemsByList(String todoListId) =>
      _db.getTodoItemsByList(todoListId);

  Future<TodoItemTableData?> getTodoItemById(String id) =>
      _db.getTodoItemById(id);

  Future<void> upsertTodoItem(TodoItem item) =>
      _db.upsertTodoItem(TodoItemTableCompanion.insert(
        id: item.id,
        todoListId: item.todoListId,
        latitude: item.latitude,
        longitude: item.longitude,
        placeName: Value(item.placeName),
        placeCategory: Value(item.placeCategory),
        placeId: Value(item.placeId),
        plannedAt: Value(item.plannedAt),
        dayIndex: Value(item.dayIndex),
        orderInDay: Value(item.orderInDay),
        notes: Value(item.notes),
        emotion: Value(item.emotion),
        checkInDotId: Value(item.checkInDotId),
        checkedInAt: Value(item.checkedInAt),
        isPinned: Value(item.isPinned),
        pinOrder: Value(item.pinOrder),
        photoUrl: Value(item.photoUrl),
        synced: Value(item.synced),
      ));

  Future<int> deleteTodoItemById(String id) => _db.deleteTodoItemById(id);

  Future<List<TodoItemTableData>> getUnsyncedTodoItems() =>
      _db.getUnsyncedTodoItems();

  Future<void> markTodoItemSynced(String id) async {
    await (_db.update(_db.todoItemTable)
          ..where((t) => t.id.equals(id)))
        .write(const TodoItemTableCompanion(synced: Value(true)));
  }

  Future<bool> markTodoItemCheckedIn({
    required String itemId,
    required String checkInDotId,
    required DateTime checkedInAt,
  }) =>
      _db.markTodoItemCheckedIn(
        itemId: itemId,
        checkInDotId: checkInDotId,
        checkedInAt: checkedInAt,
      );

  Future<bool> unmarkTodoItemCheckedIn(String itemId) =>
      _db.unmarkTodoItemCheckedIn(itemId);

  /// 체크인 pending(dirty) 해소 — 서버 반영 성공 시.
  Future<void> clearCheckInDirty(String itemId) =>
      _db.clearTodoItemCheckInDirty(itemId);

  Future<void> reorderTodoItemsInDay({
    required String todoListId,
    required int dayIndex,
    required List<({String id, int orderInDay})> orderedItems,
  }) =>
      _db.reorderTodoItemsInDay(
        todoListId: todoListId,
        dayIndex: dayIndex,
        orderedItems: orderedItems,
      );

  Future<void> reorderTodoItemsGlobal({
    required String todoListId,
    required List<({String id, int dayIndex, int orderInDay})> items,
  }) =>
      _db.reorderTodoItemsGlobal(todoListId: todoListId, items: items);

  // ── id remap (sync 시 local_xxx → server uuid) ──

  Future<void> remapTodoListId(String oldId, String newId) async {
    if (oldId == newId) return;
    await _db.transaction(() async {
      final existing = await _db.getTodoListById(oldId);
      if (existing == null) return;
      await (_db.update(_db.todoItemTable)
            ..where((t) => t.todoListId.equals(oldId)))
          .write(TodoItemTableCompanion(todoListId: Value(newId)));
      await (_db.delete(_db.todoListTable)
            ..where((t) => t.id.equals(oldId)))
          .go();
      await _db.upsertTodoList(TodoListTableCompanion.insert(
        id: newId,
        ownerId: existing.ownerId,
        name: existing.name,
        coverEmoji: Value(existing.coverEmoji),
        startDate: existing.startDate,
        endDate: existing.endDate,
        shareToken: Value(existing.shareToken),
        shareTokenExpiresAt: Value(existing.shareTokenExpiresAt),
        createdAt: existing.createdAt,
        updatedAt: existing.updatedAt,
        synced: const Value(true),
        courseType: Value(existing.courseType),
        description: Value(existing.description),
        tagsJson: Value(existing.tagsJson),
        coverImageUrl: Value(existing.coverImageUrl),
        visibility: Value(existing.visibility),
        isImported: Value(existing.isImported),
        membersJson: Value(existing.membersJson),
        isPinned: Value(existing.isPinned),
        pinOrder: Value(existing.pinOrder),
        likeCount: Value(existing.likeCount),
        region: Value(existing.region),
      ));
    });
  }

  Future<void> remapTodoItemId(String oldId, String newId) async {
    if (oldId == newId) return;
    await _db.transaction(() async {
      final existing = await _db.getTodoItemById(oldId);
      if (existing == null) return;
      await (_db.delete(_db.todoItemTable)
            ..where((t) => t.id.equals(oldId)))
          .go();
      await _db.upsertTodoItem(TodoItemTableCompanion.insert(
        id: newId,
        todoListId: existing.todoListId,
        latitude: existing.latitude,
        longitude: existing.longitude,
        placeName: Value(existing.placeName),
        placeCategory: Value(existing.placeCategory),
        placeId: Value(existing.placeId),
        plannedAt: Value(existing.plannedAt),
        dayIndex: Value(existing.dayIndex),
        orderInDay: Value(existing.orderInDay),
        notes: Value(existing.notes),
        emotion: Value(existing.emotion),
        checkInDotId: Value(existing.checkInDotId),
        checkedInAt: Value(existing.checkedInAt),
        isPinned: Value(existing.isPinned),
        pinOrder: Value(existing.pinOrder),
        photoUrl: Value(existing.photoUrl),
        synced: const Value(true),
        // 오프라인 체크인 pending 표시 보존 — sync 가 이후 push 판단에 사용.
        checkInDirty: Value(existing.checkInDirty),
      ));
    });
  }

  // ── 변환 헬퍼 ──

  TodoList todoListFromRow(TodoListTableData row, List<TodoItem> items) {
    List<String> tags = const [];
    try {
      final decoded = jsonDecode(row.tagsJson);
      if (decoded is List) tags = decoded.whereType<String>().toList();
    } catch (_) {}
    List<CourseMember> members = const [];
    try {
      final decoded = jsonDecode(row.membersJson);
      if (decoded is List) {
        members = decoded
            .whereType<Map<String, dynamic>>()
            .map(CourseMember.fromJson)
            .toList();
      }
    } catch (_) {}
    return TodoList(
      id: row.id,
      ownerId: row.ownerId,
      name: row.name,
      coverEmoji: row.coverEmoji,
      startDate: row.startDate,
      endDate: row.endDate,
      shareToken: row.shareToken,
      shareTokenExpiresAt: row.shareTokenExpiresAt,
      items: items,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      synced: row.synced,
      courseType: row.courseType,
      description: row.description,
      tags: tags,
      coverImageUrl: row.coverImageUrl,
      visibility: row.visibility,
      isImported: row.isImported,
      members: members,
      isPinned: row.isPinned,
      pinOrder: row.pinOrder,
      likeCount: row.likeCount,
      region: row.region,
      // likedByMe 는 영속하지 않음 — 사용자별 transient. 상세 화면은 원격 응답을
      // 직접 반환하므로 정확하고, 목록 카드는 하트 채움을 쓰지 않는다.
    );
  }

  TodoItem todoItemFromRow(TodoItemTableData row) => TodoItem(
        id: row.id,
        todoListId: row.todoListId,
        latitude: row.latitude,
        longitude: row.longitude,
        placeName: row.placeName,
        placeCategory: row.placeCategory,
        placeId: row.placeId,
        plannedAt: row.plannedAt,
        dayIndex: row.dayIndex,
        orderInDay: row.orderInDay,
        notes: row.notes,
        emotion: row.emotion,
        checkInDotId: row.checkInDotId,
        checkedInAt: row.checkedInAt,
        photoUrl: row.photoUrl,
        synced: row.synced,
      );
}

@riverpod
TodoLocalSource todoLocalSource(Ref ref) =>
    TodoLocalSource(ref.watch(appDatabaseProvider));
