import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/todo_item_model.dart';
import '../domain/todo_list_model.dart';
import 'todo_local_source.dart';
import 'todo_remote_source.dart';

part 'todo_repository.g.dart';

/// 할일 repository — BE 우선 / 로컬 캐시 폴백.
///
/// **Read**:
///   1. BE fetch 시도 → 성공 시 응답을 로컬 upsert(synced=true) → 응답 반환
///   2. 네트워크 오류 → 로컬 캐시 반환 (오프라인 폴백)
///   3. 비즈니스 4xx → [TodoApiException] re-throw
///
/// **Write** (create/update/delete/addItem/etc):
///   1. BE 호출 시도 → 성공 시 server response 로 로컬 upsert
///   2. 네트워크 오류 → 로컬만 저장 (synced=false). 다음 [syncUnsynced] 에서 push
///   3. 비즈니스 4xx → re-throw
///
/// **체크인**: 호출자가 먼저 captureDot 으로 server dot.id 확보 후 [markCheckedIn] 호출.
class TodoRepository {
  TodoRepository(this._local, this._remote);
  final TodoLocalSource _local;
  final TodoRemoteSource _remote;

  /// 동시 호출 방지 — [syncUnsynced] 가 진행 중이면 같은 future 를 공유.
  Future<void>? _inFlightSync;

  // ── 조회 ──────────────────────────────────────────

  Future<List<TodoList>> getMyTodoLists(String userId) async {
    try {
      // BE 우선
      final remoteList = await _remote.listTodoLists();
      // 로컬 캐시 갱신 — BE 응답을 synced=true 로 upsert.
      // courseType 은 BE 가 저장/반환 (000021) — _resolveCourseType 이 BE 우선
      // + sentinel 폴백으로 판정.
      final remoteIds = <String>{};
      for (final list in remoteList) {
        remoteIds.add(list.id);
        final localRow = await _local.getTodoListById(list.id);
        // pending 로컬 편집(synced=false) 보호 — sync 실패로 남아 있는 편집을
        // 서버 stale 응답이 덮어쓰지 않게 skip (다음 sync 성공 후 정상화).
        if (localRow != null && !localRow.synced) continue;
        final localMeta = localRow != null
            ? _local.todoListFromRow(localRow, const [])
            : null;
        await _local.upsertTodoList(
          list.copyWith(
            synced: true,
            courseType: _resolveCourseType(list),
            isImported: list.isImported || (localMeta?.isImported ?? false),
            members: list.members.isNotEmpty
                ? list.members
                : (localMeta?.members ?? const []),
            // 로컬 고정 정보 보존 — 없으면 서버 값 사용(로그아웃 후 재로그인 복원).
            isPinned: localMeta?.isPinned ?? list.isPinned,
            pinOrder: localMeta?.pinOrder ?? list.pinOrder,
            // 리스트 API가 description을 생략할 수 있으므로 로컬 값 보존.
            description: list.description ?? localMeta?.description,
          ),
        );
        // items 가 응답에 포함된 경우 로컬 캐시 갱신 — 카드 진행률 최신화.
        // pending 로컬 편집(synced=false)은 덮지 않음.
        for (final item in list.items) {
          final localItem = await _local.getTodoItemById(item.id);
          if (localItem != null && !localItem.synced) continue;
          await _local.upsertTodoItem(item.copyWith(synced: true));
        }
      }
      // BE 응답이 *비어있지 않을 때만* 다른 디바이스에서 삭제된 synced row 를 정리.
      // BE 가 owner + member 코스 모두 반환하므로 getAllTodoLists() 로 전체 청소.
      if (remoteList.isNotEmpty) {
        final localRows = await _local.getAllTodoLists();
        for (final row in localRows) {
          if (row.synced && !remoteIds.contains(row.id)) {
            await _local.deleteTodoListById(row.id);
          }
        }
      }
      // 최종적으로는 로컬에서 읽음 — BE 동기화된 것 + local-only 모두 포함.
      return _localFallbackList(userId);
    } on DioException catch (e) {
      // 서버 4xx 면 비즈니스 에러 — 호출자에 전달
      if (e.response != null) rethrow;
      if (kDebugMode) {
        debugPrint('[TodoRepo] getMyTodoLists offline → local fallback');
      }
      return _localFallbackList(userId);
    } on TodoApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) debugPrint('[TodoRepo] getMyTodoLists error: $e');
      return _localFallbackList(userId);
    }
  }

  Future<TodoList?> getTodoListById(String id) async {
    // pending 로컬 편집이 서버 stale 응답으로 덮이지 않게 sync 선행
    // (best-effort — _inFlightSync 가드로 중복 호출 안전).
    await syncUnsynced();
    try {
      final remote = await _remote.getTodoList(id);
      if (remote == null) {
        await _local.deleteTodoListById(id);
        return null;
      }
      final localListRow = await _local.getTodoListById(id);
      final localMeta = localListRow != null
          ? _local.todoListFromRow(localListRow, const [])
          : null;
      final toStore = remote.copyWith(
        synced: true,
        courseType: _resolveCourseType(remote),
        // 로컬 고정 정보 보존 — 없으면 서버 값 사용(로그아웃 후 재로그인 복원).
        isPinned: localMeta?.isPinned ?? remote.isPinned,
        pinOrder: localMeta?.pinOrder ?? remote.pinOrder,
        // 단일 GET도 description을 생략할 수 있으므로 로컬 값 보존.
        description: remote.description ?? localMeta?.description,
      );
      if (localListRow == null || localListRow.synced) {
        await _local.upsertTodoList(toStore);
      }
      final remoteItemIds = <String>{};
      for (final item in remote.items) {
        remoteItemIds.add(item.id);
        // pending 로컬 편집/체크인(synced=false) 보호 — 덮지 않음.
        final localItem = await _local.getTodoItemById(item.id);
        if (localItem != null && !localItem.synced) continue;
        await _local.upsertTodoItem(item.copyWith(synced: true));
      }
      // 다른 기기에서 삭제된 item 정리 — synced 인데 서버 응답에 없는 것.
      // (GetList 는 전체 items 를 포함하므로 안전. 목록 API 는 items 를
      //  안 주므로 여기서만 수행)
      // 단, planned_at = null 인 item 은 BE GET 응답에서 제외되는 경우가 있어
      // 삭제 대상에서 제외하고 반환값에 병합한다.
      final localItems = await _local.getTodoItemsByList(id);
      final extraItems = <TodoItem>[];
      for (final li in localItems) {
        if (li.synced && !remoteItemIds.contains(li.id)) {
          if (li.plannedAt == null) {
            extraItems.add(_local.todoItemFromRow(li));
          } else {
            await _local.deleteTodoItemById(li.id);
          }
        }
      }
      if (extraItems.isEmpty) return toStore;
      final existingIds = toStore.items.map((e) => e.id).toSet();
      final deduped = extraItems.where((e) => !existingIds.contains(e.id)).toList();
      if (deduped.isEmpty) return toStore;
      return toStore.copyWith(items: [...toStore.items, ...deduped]);
    } on DioException catch (e) {
      if (e.response != null) rethrow;
      if (kDebugMode) debugPrint('[TodoRepo] getTodoListById offline → local fallback');
      return _localFallbackSingle(id);
    } on TodoApiException {
      rethrow;
    } catch (e) {
      if (kDebugMode) debugPrint('[TodoRepo] getTodoListById error: $e');
      return _localFallbackSingle(id);
    }
  }

  /// endDate sentinel(+50년) 기반 추론 — 기간이 비정상적으로 길면(>10년) 모음.
  static String _inferCourseType(TodoList list) =>
      list.endDate.difference(list.startDate).inDays > 3650
          ? 'collection'
          : 'trip';

  /// BE course_type 우선 판정. BE 가 'collection' 이면 그대로, 'trip'(구 BE
  /// 기본값 포함)인데 endDate 가 sentinel 이면 미백필 데이터로 보고 모음 유지.
  static String _resolveCourseType(TodoList remote) =>
      remote.courseType == 'collection'
          ? 'collection'
          : _inferCourseType(remote);

  Future<List<TodoList>> _localFallbackList(String _) async {
    // getAllTodoLists() — owner + member 코스 포함. BE 동기화 후에는 올바른 집합.
    final rows = await _local.getAllTodoLists();
    final out = <TodoList>[];
    for (final row in rows) {
      final itemRows = await _local.getTodoItemsByList(row.id);
      final items = itemRows.map(_local.todoItemFromRow).toList();
      out.add(_local.todoListFromRow(row, items));
    }
    return out;
  }

  Future<TodoList?> _localFallbackSingle(String id) async {
    final row = await _local.getTodoListById(id);
    if (row == null) return null;
    final itemRows = await _local.getTodoItemsByList(id);
    final items = itemRows.map(_local.todoItemFromRow).toList();
    return _local.todoListFromRow(row, items);
  }

  // ── TodoList 생성/수정/삭제 ──────────────────────────

  Future<TodoList?> createTodoList({
    required String localId,
    required String ownerId,
    required String name,
    String? coverEmoji,
    required DateTime startDate,
    required DateTime endDate,
    String courseType = 'trip',
    String? description,
    List<String> tags = const [],
    String visibility = 'private',
  }) async {
    try {
      final remote = await _remote.createTodoList(
        name: name,
        coverEmoji: coverEmoji,
        startDate: startDate,
        endDate: endDate,
        courseType: courseType,
        description: description,
        tags: tags.isNotEmpty ? tags : null,
        visibility: visibility != 'private' ? visibility : null,
      );
      final stored = remote.copyWith(
        synced: true,
        courseType: courseType,
        description: description ?? remote.description,
        tags: tags.isNotEmpty ? tags : remote.tags,
        visibility: visibility,
      );
      await _local.upsertTodoList(stored);
      return stored;
    } on DioException catch (e) {
      if (e.response != null) rethrow;
      final now = DateTime.now();
      final localList = TodoList(
        id: localId,
        ownerId: ownerId,
        name: name,
        coverEmoji: coverEmoji,
        startDate: startDate,
        endDate: endDate,
        createdAt: now,
        updatedAt: now,
        synced: false,
        courseType: courseType,
        description: description,
        tags: tags,
        visibility: visibility,
      );
      await _local.upsertTodoList(localList);
      return localList;
    }
  }

  Future<TodoList?> updateTodoList(TodoList list) async {
    try {
      final remote = await _remote.patchTodoList(
        list.id,
        name: list.name,
        coverEmoji: list.coverEmoji,
        startDate: list.startDate,
        endDate: list.endDate,
        courseType: list.courseType,
        description: list.description,
        tags: list.tags,
        visibility: list.visibility,
      );
      final stored = remote.copyWith(
        synced: true,
        courseType: list.courseType,
        description: list.description ?? remote.description,
        tags: list.tags.isNotEmpty ? list.tags : remote.tags,
        visibility: list.visibility,
      );
      await _local.upsertTodoList(stored);
      return stored;
    } on DioException catch (e) {
      if (e.response != null) rethrow;
      final next = list.copyWith(updatedAt: DateTime.now(), synced: false);
      await _local.upsertTodoList(next);
      return next;
    }
  }

  Future<void> togglePinCollection(TodoList list) async {
    final newPinned = !list.isPinned;
    final newOrder = newPinned ? DateTime.now().millisecondsSinceEpoch ~/ 1000 : 0;
    // 낙관적으로 로컬 먼저 업데이트
    await _local.upsertTodoList(list.copyWith(isPinned: newPinned, pinOrder: newOrder));
    try {
      // BE에도 저장 — 로그아웃 후 재로그인 시 pin 상태 복원을 위해.
      final updated = await _remote.pinTodoList(list.id, isPinned: newPinned, pinOrder: newOrder);
      // 서버 응답으로 로컬 갱신 (pin 외 필드는 로컬 메타 보존).
      await _local.upsertTodoList(updated.copyWith(isPinned: newPinned, pinOrder: newOrder, synced: true));
    } on DioException catch (e) {
      if (e.response != null) rethrow; // BE 비즈니스 에러는 전파
      // 오프라인 — 로컬만 저장된 상태로 유지 (다음 온라인 시 sync 필요)
    }
  }

  Future<bool> deleteTodoList(String id) async {
    try {
      await _remote.deleteTodoList(id);
      await _local.deleteTodoListById(id);
      return true;
    } on DioException catch (e) {
      if (e.response != null) rethrow;
      // 오프라인 — 로컬만 삭제. (tombstone 없음 → 다음 sync 에서 BE 에 그대로 남을 수
      // 있음. Phase 2 후속 — tombstone 도입 검토)
      await _local.deleteTodoListById(id);
      return true;
    }
  }

  // ── TodoItem ────────────────────────────────────────

  Future<TodoItem?> addItem({
    required String localId,
    required String todoListId,
    required double latitude,
    required double longitude,
    DateTime? plannedAt,
    required int dayIndex,
    required int orderInDay,
    String? placeName,
    String? placeCategory,
    String? placeId,
    String? notes,
    String? emotion,
  }) async {
    try {
      final remote = await _remote.addItem(
        todoListId: todoListId,
        latitude: latitude,
        longitude: longitude,
        plannedAt: plannedAt,
        dayIndex: dayIndex,
        orderInDay: orderInDay,
        placeName: placeName,
        placeCategory: placeCategory,
        placeId: placeId,
        notes: notes,
        emotion: emotion,
      );
      await _local.upsertTodoItem(remote.copyWith(synced: true));
      return remote.copyWith(synced: true);
    } on DioException catch (e) {
      if (e.response != null) rethrow;
      final local = TodoItem(
        id: localId,
        todoListId: todoListId,
        latitude: latitude,
        longitude: longitude,
        placeName: placeName,
        placeCategory: placeCategory,
        placeId: placeId,
        plannedAt: plannedAt,
        dayIndex: dayIndex,
        orderInDay: orderInDay,
        notes: notes,
        emotion: emotion,
        synced: false,
      );
      await _local.upsertTodoItem(local);
      return local;
    }
  }

  Future<TodoItem?> updateItem(TodoItem item) async {
    try {
      final remote = await _remote.patchItem(
        todoListId: item.todoListId,
        itemId: item.id,
        latitude: item.latitude,
        longitude: item.longitude,
        placeName: item.placeName,
        placeCategory: item.placeCategory,
        placeId: item.placeId,
        plannedAt: item.plannedAt,
        dayIndex: item.dayIndex,
        orderInDay: item.orderInDay,
        notes: item.notes,
        emotion: item.emotion,
        isPinned: item.isPinned,
      );
      await _local.upsertTodoItem(remote.copyWith(synced: true));
      return remote.copyWith(synced: true);
    } on DioException catch (e) {
      if (e.response != null) rethrow;
      final next = item.copyWith(synced: false);
      await _local.upsertTodoItem(next);
      return next;
    }
  }

  Future<TodoItem?> togglePin(TodoItem item) =>
      updateItem(item.copyWith(isPinned: !item.isPinned));

  Future<bool> deleteItem({
    required String todoListId,
    required String itemId,
  }) async {
    try {
      await _remote.deleteItem(todoListId: todoListId, itemId: itemId);
      await _local.deleteTodoItemById(itemId);
      return true;
    } on DioException catch (e) {
      if (e.response != null) rethrow;
      await _local.deleteTodoItemById(itemId);
      return true;
    }
  }

  /// 드래그 재정렬 — 낙관적 UI용.
  /// 단일 날([singleDayIndex] != null): 기존 reorderItems 엔드포인트 사용.
  /// 전체 뷰(null): 날이 바뀐 아이템은 patchItem으로 day_index 먼저 변경 후
  /// 영향받은 날마다 reorderItems 호출.
  Future<void> reorderItemsGlobal({
    required String todoListId,
    required List<TodoItem> originalItems,
    required List<TodoItem> updatedItems,
    required int? singleDayIndex,
  }) async {
    // 1. 로컬 DB 업데이트 — 단일 트랜잭션, 필요한 필드만 (dayIndex·orderInDay·synced).
    //    upsertTodoItem 루프(N개 트랜잭션·전체 필드 write) 대신 최적화된 bulk update 사용.
    await _local.reorderTodoItemsGlobal(
      todoListId: todoListId,
      items: updatedItems
          .map((i) => (id: i.id, dayIndex: i.dayIndex, orderInDay: i.orderInDay))
          .toList(),
    );

    // local_* id가 있으면 서버 동기화 건너뜀
    final hasLocal = todoListId.startsWith('local_') ||
        updatedItems.any((i) => i.id.startsWith('local_'));
    if (hasLocal) return;

    try {
      if (singleDayIndex != null) {
        // 단일 날 재정렬
        await _remote.reorderItems(
          todoListId: todoListId,
          dayIndex: singleDayIndex,
          orderedItemIds: updatedItems.map((i) => i.id).toList(),
        );
      } else {
        // 전체 뷰 재정렬 — 날이 바뀐 아이템 먼저 patch
        final origMap = {for (final i in originalItems) i.id: i};
        for (final item in updatedItems) {
          final orig = origMap[item.id];
          if (orig != null && orig.dayIndex != item.dayIndex) {
            await _remote.patchItem(
              todoListId: todoListId,
              itemId: item.id,
              dayIndex: item.dayIndex,
            );
          }
        }
        // 영향받은 날별 reorder
        final dayGroups = <int, List<String>>{};
        for (final item in updatedItems) {
          dayGroups.putIfAbsent(item.dayIndex, () => []).add(item.id);
        }
        for (final entry in dayGroups.entries) {
          await _remote.reorderItems(
            todoListId: todoListId,
            dayIndex: entry.key,
            orderedItemIds: entry.value,
          );
        }
      }
    } on DioException catch (e) {
      if (e.response != null) rethrow;
      // 오프라인 — 로컬에 저장됨, 다음 sync에서 처리
    }
  }

  Future<void> reorderItemsInDay({
    required String todoListId,
    required int dayIndex,
    required List<({String id, int orderInDay})> orderedItems,
  }) async {
    // local_* id 가 섞여 있으면 BE 가 INVALID_ID/404 로 거부 — 다음 sync 까지 기다림.
    // 단순히 local 만 갱신하고 [syncUnsynced] 가 server id 매핑된 뒤 재 reorder
    // 가능하게 둠. (Phase 2 정책)
    final hasLocalId = todoListId.startsWith('local_') ||
        orderedItems.any((e) => e.id.startsWith('local_'));
    if (hasLocalId) {
      await _local.reorderTodoItemsInDay(
        todoListId: todoListId,
        dayIndex: dayIndex,
        orderedItems: orderedItems,
      );
      return;
    }
    try {
      final remote = await _remote.reorderItems(
        todoListId: todoListId,
        dayIndex: dayIndex,
        orderedItemIds: orderedItems.map((e) => e.id).toList(),
      );
      for (final item in remote) {
        await _local.upsertTodoItem(item.copyWith(synced: true));
      }
    } on DioException catch (e) {
      if (e.response != null) rethrow;
      // 오프라인 — 로컬만 재정렬.
      await _local.reorderTodoItemsInDay(
        todoListId: todoListId,
        dayIndex: dayIndex,
        orderedItems: orderedItems,
      );
    }
  }

  // ── 체크인 ──────────────────────────────────────────

  Future<bool> markCheckedIn({
    required String todoListId,
    required String itemId,
    required String checkInDotId,
    required DateTime checkedInAt,
  }) async {
    // 오프라인에서 만든 dot(클라이언트 id)은 서버가 모르는 id — 바로 로컬
    // pending 으로 기록. dot batch sync(remapDotId) → todo sync 경로가
    // server id 로 교체 후 서버에 반영한다.
    if (!_isServerDotId(checkInDotId)) {
      return _local.markTodoItemCheckedIn(
        itemId: itemId,
        checkInDotId: checkInDotId,
        checkedInAt: checkedInAt,
      );
    }
    try {
      final remote = await _remote.checkIn(
        todoListId: todoListId,
        itemId: itemId,
        dotId: checkInDotId,
      );
      await _local.upsertTodoItem(remote.copyWith(synced: true));
      await _local.clearCheckInDirty(itemId); // 이전 오프라인 pending 해소
      return true;
    } on DioException catch (e) {
      if (e.response != null) rethrow;
      // 오프라인 — 로컬만 체크인. dotId 가 local 임시 id 면 추후 sync 시 server id 로
      // 교체 필요. (best-effort)
      return _local.markTodoItemCheckedIn(
        itemId: itemId,
        checkInDotId: checkInDotId,
        checkedInAt: checkedInAt,
      );
    }
  }

  Future<bool> unmarkCheckedIn({
    required String todoListId,
    required String itemId,
  }) async {
    try {
      final remote = await _remote.cancelCheckIn(
        todoListId: todoListId,
        itemId: itemId,
      );
      await _local.upsertTodoItem(remote.copyWith(synced: true));
      await _local.clearCheckInDirty(itemId); // 이전 오프라인 pending 해소
      return true;
    } on DioException catch (e) {
      if (e.response != null) rethrow;
      return _local.unmarkTodoItemCheckedIn(itemId);
    }
  }

  // ── 협업 멤버십 ──────────────────────────────────────

  /// 초대 코드 발급 — owner 만 가능. 오프라인 시 null.
  Future<({String code, DateTime expiresAt})?> generateCourseInviteCode(
      String todoListId, {String role = 'member'}) =>
      _remote.generateCourseInviteCode(todoListId, role: role);

  /// 초대 코드 미리보기 — 인증 불필요. items 미포함 (위치 PII 보호).
  Future<({
    String todoListId,
    String name,
    String? coverEmoji,
    String ownerNickname,
    int memberCount,
    DateTime expiresAt,
    String role,
  })?> getCourseInvitePreview(String code) =>
      _remote.getCourseInvitePreview(code);

  /// 공유 코스 참여 — 오프라인 불가(멤버십은 서버 상태).
  Future<TodoList?> joinCourse(String inviteCode) async {
    try {
      final remote = await _remote.joinCourse(inviteCode);
      // 모음 코스를 참여받아도 유형 유지 — BE course_type + sentinel 추론.
      final stored = remote.copyWith(
        synced: true,
        courseType: _resolveCourseType(remote),
      );
      await _local.upsertTodoList(stored);
      for (final item in remote.items) {
        await _local.upsertTodoItem(item.copyWith(synced: true));
      }
      return stored;
    } on DioException catch (e) {
      if (e.response != null) rethrow;
      return null;
    }
  }

  /// 공유 코스 나가기.
  Future<void> leaveCourse(String todoListId) async {
    await _remote.leaveCourse(todoListId);
    await _local.deleteTodoListById(todoListId);
  }

  /// 멤버 강퇴.
  Future<void> kickCourseMember(String todoListId, String userId) =>
      _remote.kickCourseMember(todoListId, userId);

  Future<TodoList> setListRoom(String todoListId, String? roomId) =>
      _remote.setListRoom(todoListId, roomId);

  Future<List<TodoList>> getListsByRoom(String roomId) =>
      _remote.getListsByRoom(roomId);

  // ── Sync (best-effort) ────────────────────────────────

  /// 미동기화 항목 (synced=false) 일괄 push. 오프라인 → 온라인 전환 시 호출.
  ///
  /// 단순 best-effort:
  ///   - local-only id (`local_*`) → POST 로 새로 생성 → server id 매핑 후 row 교체
  ///   - server-side id → PATCH 로 덮어쓰기
  ///
  /// 충돌은 last-writer-wins (server.updated_at 무시). Phase 3 에서 CRDT 검토.
  ///
  /// 동시 호출 가드 — 이미 진행 중이면 같은 future 를 공유 (BE 폭주 방지).
  Future<void> syncUnsynced() {
    final existing = _inFlightSync;
    if (existing != null) return existing;
    final future = _runSyncUnsynced();
    _inFlightSync = future;
    future.whenComplete(() {
      if (identical(_inFlightSync, future)) _inFlightSync = null;
    });
    return future;
  }

  Future<void> _runSyncUnsynced() async {
    try {
      // TodoList 먼저 (Item 의 FK 의존).
      final unsyncedLists = await _local.getUnsyncedTodoLists();
      for (final row in unsyncedLists) {
        try {
          if (row.id.startsWith('local_')) {
            final created = await _remote.createTodoList(
              name: row.name,
              coverEmoji: row.coverEmoji,
              startDate: row.startDate,
              endDate: row.endDate,
              courseType: row.courseType,
              description: row.description,
              tags: row.tagsJson != '[]' ? (jsonDecode(row.tagsJson) as List).cast<String>() : null,
              visibility: row.visibility,
            );
            await _local.remapTodoListId(row.id, created.id);
            await _local.upsertTodoList(
              created.copyWith(synced: true, courseType: row.courseType),
            );
          } else {
            final updated = await _remote.patchTodoList(
              row.id,
              name: row.name,
              coverEmoji: row.coverEmoji,
              startDate: row.startDate,
              endDate: row.endDate,
              courseType: row.courseType,
              description: row.description,
              tags: row.tagsJson != '[]'
                  ? (jsonDecode(row.tagsJson) as List).cast<String>()
                  : const [],
              visibility: row.visibility,
            );
            await _local.upsertTodoList(
              updated.copyWith(synced: true, courseType: row.courseType),
            );
          }
        } catch (e) {
          if (kDebugMode) debugPrint('[TodoRepo] sync list ${row.id} failed: $e');
        }
      }

      final unsyncedItems = await _local.getUnsyncedTodoItems();
      for (final row in unsyncedItems) {
        try {
          // 부모 list 가 아직 server-side 가 아니면 skip (다음 시도).
          if (row.todoListId.startsWith('local_')) continue;
          if (row.id.startsWith('local_')) {
            final created = await _remote.addItem(
              todoListId: row.todoListId,
              latitude: row.latitude,
              longitude: row.longitude,
              plannedAt: row.plannedAt,
              dayIndex: row.dayIndex,
              orderInDay: row.orderInDay,
              placeName: row.placeName,
              placeCategory: row.placeCategory,
              placeId: row.placeId,
              notes: row.notes,
              emotion: row.emotion,
            );
            await _local.remapTodoItemId(row.id, created.id);
            // 오프라인에서 추가 직후 체크인까지 한 경우 — 서버 응답(체크인
            // 없음)으로 덮지 말고 체크인 상태를 보존/반영한다.
            await _syncCheckInState(
              serverItem: created,
              localCheckInDotId: row.checkInDotId,
              localCheckedInAt: row.checkedInAt,
              checkInDirty: row.checkInDirty,
            );
          } else {
            final updated = await _remote.patchItem(
              todoListId: row.todoListId,
              itemId: row.id,
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
            );
            await _syncCheckInState(
              serverItem: updated,
              localCheckInDotId: row.checkInDotId,
              localCheckedInAt: row.checkedInAt,
              checkInDirty: row.checkInDirty,
            );
          }
        } catch (e) {
          if (kDebugMode) debugPrint('[TodoRepo] sync item ${row.id} failed: $e');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('[TodoRepo] syncUnsynced top-level error: $e');
    }
  }

  /// dot id 가 BE 발급 UUID 인지 — client 임시 id(타임스탬프)는 하이픈 없음.
  static bool _isServerDotId(String id) => id.contains('-');

  /// sync push 가 **영구 거절**됐는지 — 재시도해도 절대 성공 못 하므로 로컬
  /// pending 을 서버 진실로 정리해야 하는 케이스.
  /// - 4xx (403 viewer 권한 등) → 영구 (429 rate-limit 은 제외, 재시도)
  /// - 네트워크 오류(response 없음) / 5xx → 일시적, 다음 주기 재시도.
  static bool _isPermanentSyncError(Object e) {
    if (e is! DioException) return false;
    final s = e.response?.statusCode;
    if (s == null || s == 429) return false;
    return s >= 400 && s < 500;
  }

  /// sync 시 로컬 체크인 상태와 서버 응답을 조정.
  ///
  /// [checkInDirty] 가 false 면 로컬에 pending 체크인 변경이 없다는 뜻 —
  /// 서버 응답을 그대로 신뢰 (다른 멤버의 체크인이 로컬 stale 값으로
  /// 오인 취소되는 사고 방지). true 면:
  /// - 로컬 체크인 O: dot 이 server id 면 checkIn push, client id 면
  ///   보존 + synced/dirty 유지 (dot batch sync 의 remapDotId 가 server id
  ///   부여 후 재시도)
  /// - 로컬 체크인 X: cancelCheckIn push
  Future<void> _syncCheckInState({
    required TodoItem serverItem,
    required String? localCheckInDotId,
    required DateTime? localCheckedInAt,
    required bool checkInDirty,
  }) async {
    if (!checkInDirty) {
      await _local.upsertTodoItem(serverItem.copyWith(synced: true));
      await _local.clearCheckInDirty(serverItem.id);
      return;
    }

    if (localCheckInDotId != null) {
      // pending 체크인
      if (_isServerDotId(localCheckInDotId)) {
        try {
          final checked = await _remote.checkIn(
            todoListId: serverItem.todoListId,
            itemId: serverItem.id,
            dotId: localCheckInDotId,
          );
          await _local.upsertTodoItem(checked.copyWith(synced: true));
          await _local.clearCheckInDirty(serverItem.id);
          return;
        } catch (e) {
          if (kDebugMode) {
            debugPrint('[TodoRepo] sync checkIn ${serverItem.id} failed: $e');
          }
          if (_isPermanentSyncError(e)) {
            // 서버 영구 거절(예: viewer 403) — 유령 체크인 방지. 서버 진실로
            // 정리하고 재시도 중단.
            await _local.upsertTodoItem(serverItem.copyWith(synced: true));
            await _local.clearCheckInDirty(serverItem.id);
            return;
          }
        }
      }
      // dot 이 아직 client id (또는 checkIn 일시 실패) — 체크인 보존, 재시도 대상 유지.
      await _local.upsertTodoItem(serverItem.copyWith(
        synced: false,
        checkInDotId: localCheckInDotId,
        checkedInAt: localCheckedInAt,
      ));
      return;
    }

    // pending 체크인 취소
    try {
      final cancelled = await _remote.cancelCheckIn(
        todoListId: serverItem.todoListId,
        itemId: serverItem.id,
      );
      await _local.upsertTodoItem(cancelled.copyWith(synced: true));
      await _local.clearCheckInDirty(serverItem.id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[TodoRepo] sync cancelCheckIn ${serverItem.id} failed: $e');
      }
      if (_isPermanentSyncError(e)) {
        // 서버 영구 거절(예: viewer 403) — 서버 진실(체크인 유지)로 정리하고
        // 재시도 중단. 로컬 취소가 유령으로 남지 않게 함.
        await _local.upsertTodoItem(serverItem.copyWith(synced: true));
        await _local.clearCheckInDirty(serverItem.id);
        return;
      }
      // 일시 실패(네트워크/5xx) — 로컬 취소 상태 보존, 재시도 대상 유지.
      await _local.upsertTodoItem(serverItem.copyWith(
        synced: false,
        checkInDotId: null,
        checkedInAt: null,
      ));
    }
  }
}

@riverpod
TodoRepository todoRepository(Ref ref) => TodoRepository(
      ref.watch(todoLocalSourceProvider),
      ref.watch(todoRemoteSourceProvider),
    );
