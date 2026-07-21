import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/route_remote_source.dart';
import '../data/todo_remote_source.dart' show TodoApiException;
import '../data/todo_repository.dart';
import '../domain/course_exceptions.dart';
import '../domain/todo_item_model.dart';
import '../domain/todo_list_model.dart';

part 'todo_provider.g.dart';

/// 내 모든 할일 목록. BE 우선, 오프라인 시 로컬 캐시.
///
/// fetch 전 미동기화 항목을 일괄 push — 오프라인 → 온라인 전환 후 첫 진입 시
/// pending changes 가 BE 응답에 반영됨. [TodoRepository.syncUnsynced] 는
/// in-flight 가드가 있어 동시 호출 안전.
@riverpod
Future<List<TodoList>> myTodoLists(Ref ref) async {
  final user = await ref.watch(currentDottieUserProvider.future);
  if (user == null) return const [];
  final repo = ref.watch(todoRepositoryProvider);
  // best-effort sync — 실패해도 fetch 는 진행. 미동기화가 없으면 즉시 반환.
  await repo.syncUnsynced();
  return repo.getMyTodoLists(user.uid);
}

/// 단일 할일 상세 (items 포함). BE 우선.
@riverpod
Future<TodoList?> todoListById(Ref ref, String todoListId) =>
    ref.watch(todoRepositoryProvider).getTodoListById(todoListId);

/// 룸에 연결된 스팟 리스트 목록.
@riverpod
Future<List<TodoList>> roomTodoLists(Ref ref, String roomId) =>
    ref.watch(todoRepositoryProvider).getListsByRoom(roomId);

/// BE 경로 캐시 엔드포인트 호출 — 앱 공용 ApiClient (인증 헤더 자동 첨부).
@Riverpod(keepAlive: true)
RouteRemoteSource routeRemoteSource(Ref ref) =>
    RouteRemoteSource(ApiClient.instance);

/// day 별 도로 경로 (BE 캐시 + Mapbox Directions). 스팟 좌표/순서가 바뀌면
/// todoListById 갱신을 따라 자동 재조회 — 서버가 items hash 로 변경을 감지해
/// 재계산하므로 FE 는 무효화를 신경 쓸 필요 없음. null → 직선 폴백.
@riverpod
Future<DayRoute?> todoDayRoute(
    Ref ref, String todoListId, int dayIndex) async {
  final list = await ref.watch(todoListByIdProvider(todoListId).future);
  if (list == null) return null;
  // 모음(collection)은 저장용 — 순서/경로 개념이 없어 계산하지 않음.
  if (!list.isTrip) return null;
  // 스팟 2개 미만이면 서버도 null — 불필요한 왕복 생략.
  final count = list.items.where((i) => i.dayIndex == dayIndex).length;
  if (count < 2) return null;
  return ref.read(routeRemoteSourceProvider).fetchDayRoute(todoListId, dayIndex);
}

/// 상세 시트 "지도" 버튼 → 지도 뷰 전환 + 해당 스팟으로 카메라 이동 요청.
/// todo_map_screen 이 listen 해 지도 뷰로 전환하고, todo_map_view 가
/// 카메라 이동 후 clear() 한다.
@Riverpod(keepAlive: true)
class TodoMapFocus extends _$TodoMapFocus {
  @override
  TodoItem? build() => null;

  void request(TodoItem item) => state = item;
  void clear() => state = null;
}

/// 마지막 선택한 컬렉션 id 를 SharedPreferences 에 영속.
/// 재진입 시 사용자가 마지막 본 컬렉션이 자동 표시됨.
@Riverpod(keepAlive: true)
class SelectedTodoListId extends _$SelectedTodoListId {
  static const _prefsKey = 'todo.selected_list_id';

  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKey);
  }

  /// id 선택 + 영속화. null 전달 시 해제.
  Future<void> select(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, id);
    }
    state = AsyncData(id);
  }
}

/// 현재 활성 컬렉션 (없으면 null — 빈 상태).
///
/// 우선순위:
///   1) 마지막 선택 id 가 존재하고 해당 컬렉션이 살아있으면 그것
///   2) 컬렉션이 1개 이상 있으면 가장 최근 created
///   3) 아예 없으면 null (호출자가 빈 상태 UI 처리 — default 자동 생성 *안 함*)
///
/// 이전 동작에서 default "내 스팟" 자동 생성을 두었으나, 메인 화면이 *컬렉션
/// 리스트* 로 재설계되면서 사용자가 명시적으로 만드는 흐름으로 통일.
/// 빈 상태 UI 가 onboarding 역할.
@riverpod
Future<TodoList?> activeTodoList(Ref ref) async {
  final lists = await ref.watch(myTodoListsProvider.future);
  final selectedId = await ref.watch(selectedTodoListIdProvider.future);

  if (selectedId != null) {
    for (final l in lists) {
      if (l.id == selectedId) return l;
    }
  }
  if (lists.isNotEmpty) {
    final sorted = [...lists]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.first;
  }
  return null;
}

/// 할일 CRUD / 체크인 등 변경 작업.
/// `AsyncValue<void>` 로 로딩/에러 상태 관리.
@riverpod
class TodoNotifier extends _$TodoNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// 코스 생성. 성공 시 새 TodoList.id (server uuid 또는 local_*) 반환.
  Future<String?> createTodoList({
    required String name,
    String? coverEmoji,
    required DateTime startDate,
    required DateTime endDate,
    String courseType = 'trip',
    String? description,
    List<String> tags = const [],
    String visibility = 'private',
  }) async {
    state = const AsyncLoading();
    try {
      final user = await ref.read(currentDottieUserProvider.future);
      if (user == null) {
        state = const AsyncData(null);
        return null;
      }
      final localId = 'local_${DateTime.now().millisecondsSinceEpoch}';
      final created =
          await ref.read(todoRepositoryProvider).createTodoList(
                localId: localId,
                ownerId: user.uid,
                name: name,
                coverEmoji: coverEmoji,
                startDate: _dateOnly(startDate),
                endDate: _dateOnly(endDate),
                courseType: courseType,
                description: description,
                tags: tags,
                visibility: visibility,
              );
      _invalidate();
      state = const AsyncData(null);
      return created?.id;
    } on TodoApiException catch (e, st) {
      state = const AsyncData(null);
      Error.throwWithStackTrace(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  // ── 협업 멤버십 ──────────────────────────────────────

  /// 초대 코드 발급. 성공 시 (code, expiresAt).
  Future<({String code, DateTime expiresAt})?> generateCourseInviteCode(
      String todoListId, {String role = 'member'}) async {
    try {
      return await ref
          .read(todoRepositoryProvider)
          .generateCourseInviteCode(todoListId, role: role);
    } on TodoApiException catch (e, st) {
      Error.throwWithStackTrace(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// 초대 코드로 공유 코스 참여. 성공 시 TodoList.id 반환.
  Future<String?> joinCourse(String inviteCode) async {
    state = const AsyncLoading();
    try {
      final joined =
          await ref.read(todoRepositoryProvider).joinCourse(inviteCode);
      _invalidate();
      state = const AsyncData(null);
      return joined?.id;
    } on JoinCourseException catch (e, st) {
      state = const AsyncData(null);
      Error.throwWithStackTrace(e, st);
    } on TodoApiException catch (e, st) {
      state = const AsyncData(null);
      Error.throwWithStackTrace(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  /// 공유 코스 나가기.
  Future<void> leaveCourse(String todoListId) async {
    state = const AsyncLoading();
    try {
      await ref.read(todoRepositoryProvider).leaveCourse(todoListId);
      _invalidate();
      state = const AsyncData(null);
    } on LeaveCourseException catch (e, st) {
      state = const AsyncData(null);
      Error.throwWithStackTrace(e, st);
    } on TodoApiException catch (e, st) {
      state = const AsyncData(null);
      Error.throwWithStackTrace(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// 멤버 강퇴 (owner 전용).
  Future<void> kickCourseMember(String todoListId, String userId) async {
    try {
      await ref
          .read(todoRepositoryProvider)
          .kickCourseMember(todoListId, userId);
      _invalidate(todoListId: todoListId);
    } on KickCourseMemberException catch (e, st) {
      Error.throwWithStackTrace(e, st);
    } on TodoApiException catch (e, st) {
      Error.throwWithStackTrace(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// 할일 메타 수정 (이름/표지/기간).
  Future<void> updateTodoList(TodoList list) async {
    state = const AsyncLoading();
    try {
      await ref.read(todoRepositoryProvider).updateTodoList(list);
      _invalidate(todoListId: list.id);
      state = const AsyncData(null);
    } on TodoApiException catch (e, st) {
      state = const AsyncData(null);
      Error.throwWithStackTrace(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> deleteTodoList(String todoListId) async {
    state = const AsyncLoading();
    try {
      await ref.read(todoRepositoryProvider).deleteTodoList(todoListId);
      _invalidate();
      state = const AsyncData(null);
    } on TodoApiException catch (e, st) {
      state = const AsyncData(null);
      Error.throwWithStackTrace(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
      Error.throwWithStackTrace(e, st);
    }
  }

  /// 할일 항목 추가.
  Future<String?> addItem({
    required String todoListId,
    required double latitude,
    required double longitude,
    DateTime? plannedAt,
    required int dayIndex,
    String? placeName,
    String? placeCategory,
    String? placeId,
    String? notes,
    String? emotion,
  }) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(todoRepositoryProvider);
      // 현재 같은 dayIndex 내 maxOrder + 1 (로컬 캐시 기준)
      final list = await repo.getTodoListById(todoListId);
      final existing =
          list?.items.where((i) => i.dayIndex == dayIndex) ??
              const <TodoItem>[];
      final nextOrder = existing.isEmpty
          ? 0
          : existing.map((i) => i.orderInDay).reduce((a, b) => a > b ? a : b) +
              1;
      final localId = 'local_${DateTime.now().millisecondsSinceEpoch}';
      final created = await repo.addItem(
        localId: localId,
        todoListId: todoListId,
        latitude: latitude,
        longitude: longitude,
        plannedAt: plannedAt,
        dayIndex: dayIndex,
        orderInDay: nextOrder,
        placeName: placeName,
        placeCategory: placeCategory,
        placeId: placeId,
        notes: notes,
        emotion: emotion,
      );
      _invalidate(todoListId: todoListId);
      state = const AsyncData(null);
      return created?.id;
    } on TodoApiException catch (e, st) {
      state = const AsyncData(null);
      Error.throwWithStackTrace(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<void> updateItem(TodoItem item) async {
    try {
      await ref.read(todoRepositoryProvider).updateItem(item);
      _invalidate(todoListId: item.todoListId);
    } on TodoApiException catch (e, st) {
      Error.throwWithStackTrace(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> togglePin(TodoItem item) async {
    try {
      await ref.read(todoRepositoryProvider).togglePin(item);
      _invalidate(todoListId: item.todoListId);
    } on TodoApiException catch (e, st) {
      Error.throwWithStackTrace(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> togglePinCollection(TodoList list) async {
    try {
      await ref.read(todoRepositoryProvider).togglePinCollection(list);
      ref.invalidate(myTodoListsProvider);
    } on TodoApiException catch (e, st) {
      Error.throwWithStackTrace(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> setListRoom(String todoListId, String? roomId) async {
    try {
      await ref.read(todoRepositoryProvider).setListRoom(todoListId, roomId);
      _invalidate(todoListId: todoListId);
    } on TodoApiException catch (e, st) {
      Error.throwWithStackTrace(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> deleteItem({
    required String todoListId,
    required String itemId,
  }) async {
    try {
      await ref
          .read(todoRepositoryProvider)
          .deleteItem(todoListId: todoListId, itemId: itemId);
      _invalidate(todoListId: todoListId);
    } on TodoApiException catch (e, st) {
      Error.throwWithStackTrace(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// 같은 dayIndex 내 드래그 재정렬.
  Future<void> reorderItemsInDay({
    required String todoListId,
    required int dayIndex,
    required List<String> orderedItemIds,
  }) async {
    try {
      final entries = <({String id, int orderInDay})>[];
      for (var i = 0; i < orderedItemIds.length; i++) {
        entries.add((id: orderedItemIds[i], orderInDay: i));
      }
      await ref.read(todoRepositoryProvider).reorderItemsInDay(
            todoListId: todoListId,
            dayIndex: dayIndex,
            orderedItems: entries,
          );
      _invalidate(todoListId: todoListId);
    } on TodoApiException catch (e, st) {
      Error.throwWithStackTrace(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// 드래그 재정렬 — 낙관적 UI용 (invalidate 없음).
  /// [_DraggableContent]가 로컬 상태를 이미 반영했으므로 UI 갱신 없이 서버만 동기화.
  Future<void> reorderItemsSilently({
    required String todoListId,
    required List<TodoItem> originalItems,
    required List<TodoItem> updatedItems,
    required int filterDayIndex,
  }) async {
    try {
      await ref.read(todoRepositoryProvider).reorderItemsGlobal(
            todoListId: todoListId,
            originalItems: originalItems,
            updatedItems: updatedItems,
            singleDayIndex: filterDayIndex >= 0 ? filterDayIndex : null,
          );
    } catch (_) {
      // 백그라운드 실패 — 로컬 UI는 이미 반영됨. 다음 sync 시 복구.
    }
  }

  /// 체크인 — Dot.id (server 또는 local) 를 항목에 링크.
  Future<bool> markCheckedIn({
    required String todoListId,
    required String itemId,
    required String checkInDotId,
  }) async {
    try {
      final ok = await ref.read(todoRepositoryProvider).markCheckedIn(
            todoListId: todoListId,
            itemId: itemId,
            checkInDotId: checkInDotId,
            checkedInAt: DateTime.now(),
          );
      if (ok) _invalidate(todoListId: todoListId);
      return ok;
    } on TodoApiException catch (e, st) {
      Error.throwWithStackTrace(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> unmarkCheckedIn({
    required String todoListId,
    required String itemId,
  }) async {
    try {
      final ok = await ref
          .read(todoRepositoryProvider)
          .unmarkCheckedIn(todoListId: todoListId, itemId: itemId);
      if (ok) _invalidate(todoListId: todoListId);
      return ok;
    } on TodoApiException catch (e, st) {
      Error.throwWithStackTrace(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  void _invalidate({String? todoListId}) {
    ref.invalidate(myTodoListsProvider);
    if (todoListId != null) {
      ref.invalidate(todoListByIdProvider(todoListId));
    }
  }

  static DateTime _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);
}
