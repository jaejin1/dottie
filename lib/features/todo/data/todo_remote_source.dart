import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/course_exceptions.dart';
import '../domain/todo_item_model.dart';
import '../domain/todo_list_model.dart';

part 'todo_remote_source.g.dart';

/// BE `/v1/todo-lists` 및 `/v1/public/todo-lists/:token` 와 통신.
///
/// 응답 envelope `{"data": ...}` 언래핑은 [_unwrap] 으로 일관 처리.
/// 4xx 비즈니스 에러는 [TodoApiException] 으로 re-throw — 네트워크 오류(오프라인)는
/// 호출자가 로컬 폴백할 수 있도록 그대로 [DioException] 전파.
class TodoRemoteSource {
  TodoRemoteSource(this._dio);
  final Dio _dio;

  // ── 목록 / 상세 ──────────────────────────────────────

  Future<List<TodoList>> listTodoLists() async {
    try {
      final res = await _dio.get(ApiEndpoints.todoLists);
      final list = _unwrap(res.data) as List? ?? const [];
      return list
          .map((e) => TodoList.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // 컬렉션 endpoint 의 404 = BE 미배포 또는 라우트 부재. 정상 빈 목록으로 처리.
      // (개별 resource 의 404 와 의미가 다름 — REST 컬렉션은 보통 200 + [] 가 정상)
      if (e.response?.statusCode == 404) {
        if (kDebugMode) {
          debugPrint(
              '[TodoRemote] listTodoLists 404 — treating as empty (BE not deployed?)');
        }
        return const [];
      }
      _throwIfBusinessError(e);
      rethrow;
    }
  }

  Future<TodoList?> getTodoList(String id) async {
    try {
      final res = await _dio.get(ApiEndpoints.todoListById(id));
      final data = _unwrap(res.data) as Map<String, dynamic>;
      return TodoList.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      _throwIfBusinessError(e);
      rethrow;
    }
  }

  // ── 변경 ────────────────────────────────────────────

  Future<TodoList> createTodoList({
    required String name,
    String? coverEmoji,
    required DateTime startDate,
    required DateTime endDate,
    String? courseType,
    String? description,
    List<String>? tags,
    String? visibility,
    String? coverImageUrl,
  }) async {
    try {
      final res = await _dio.post(ApiEndpoints.todoLists, data: {
        'name': name,
        if (coverEmoji != null) 'cover_emoji': coverEmoji,
        'start_date': _formatDate(startDate),
        'end_date': _formatDate(endDate),
        if (courseType != null) 'course_type': courseType,
        if (description != null) 'description': description,
        if (tags != null && tags.isNotEmpty) 'tags': tags,
        if (visibility != null) 'visibility': visibility,
        if (coverImageUrl != null) 'cover_image_url': coverImageUrl,
      });
      final data = _unwrap(res.data) as Map<String, dynamic>;
      return TodoList.fromJson(data);
    } on DioException catch (e) {
      _throwIfBusinessError(e);
      rethrow;
    }
  }

  Future<TodoList> patchTodoList(
    String id, {
    String? name,
    Object? coverEmoji = _undef,
    DateTime? startDate,
    DateTime? endDate,
    String? courseType,
    Object? description = _undef,
    List<String>? tags,
    String? visibility,
    Object? coverImageUrl = _undef,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (!identical(coverEmoji, _undef)) body['cover_emoji'] = coverEmoji;
      if (startDate != null) body['start_date'] = _formatDate(startDate);
      if (endDate != null) body['end_date'] = _formatDate(endDate);
      if (courseType != null) body['course_type'] = courseType;
      if (!identical(description, _undef)) body['description'] = description;
      if (tags != null) body['tags'] = tags;
      if (visibility != null) body['visibility'] = visibility;
      if (!identical(coverImageUrl, _undef)) {
        body['cover_image_url'] = coverImageUrl;
      }
      final res = await _dio.patch(ApiEndpoints.todoListById(id), data: body);
      final data = _unwrap(res.data) as Map<String, dynamic>;
      return TodoList.fromJson(data);
    } on DioException catch (e) {
      _throwIfBusinessError(e);
      rethrow;
    }
  }

  /// 코스 고정 토글 (per-user). pin_order 는 BE 가 내 고정 MAX+1 로 자동 부여 —
  /// FE 는 보내지 않는다. 응답은 caller 기준 is_pinned/pin_order.
  Future<TodoList> pinTodoList(String id, {required bool isPinned}) async {
    try {
      final res = await _dio.patch(
        ApiEndpoints.todoListPin(id),
        data: {'is_pinned': isPinned},
      );
      final data = _unwrap(res.data) as Map<String, dynamic>;
      return TodoList.fromJson(data);
    } on DioException catch (e) {
      _throwIfBusinessError(e);
      rethrow;
    }
  }

  Future<bool> deleteTodoList(String id) async {
    try {
      final res = await _dio.delete(ApiEndpoints.todoListById(id));
      final data = _unwrap(res.data) as Map<String, dynamic>?;
      return data?['success'] == true || res.statusCode == 200;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return true; // 이미 삭제됨
      _throwIfBusinessError(e);
      rethrow;
    }
  }

  // ── 항목 ────────────────────────────────────────────

  Future<TodoItem> addItem({
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
      final reqBody = {
        'latitude': latitude,
        'longitude': longitude,
        if (placeName != null) 'place_name': placeName,
        if (placeCategory != null) 'place_category': placeCategory,
        if (placeId != null) 'place_id': placeId,
        if (plannedAt != null) 'planned_at': plannedAt.toUtc().toIso8601String(),
        'day_index': dayIndex,
        'order_in_day': orderInDay,
        if (notes != null) 'notes': notes,
        if (emotion != null) 'emotion': emotion,
      };
      // ignore: avoid_print
      if (kDebugMode) print('[TodoRemote.addItem] body=$reqBody notes=$notes');
      final res = await _dio.post(
        ApiEndpoints.todoListItems(todoListId),
        data: reqBody,
      );
      final data = _unwrap(res.data) as Map<String, dynamic>;
      return TodoItem.fromJson(data);
    } on DioException catch (e) {
      _throwIfBusinessError(e);
      rethrow;
    }
  }

  Future<TodoItem> patchItem({
    required String todoListId,
    required String itemId,
    double? latitude,
    double? longitude,
    Object? placeName = _undef,
    Object? placeCategory = _undef,
    Object? placeId = _undef,
    DateTime? plannedAt,
    int? dayIndex,
    int? orderInDay,
    Object? notes = _undef,
    Object? emotion = _undef,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;
      if (!identical(placeName, _undef)) body['place_name'] = placeName;
      if (!identical(placeCategory, _undef)) {
        body['place_category'] = placeCategory;
      }
      if (!identical(placeId, _undef)) body['place_id'] = placeId;
      if (plannedAt != null) {
        body['planned_at'] = plannedAt.toUtc().toIso8601String();
      }
      if (dayIndex != null) body['day_index'] = dayIndex;
      if (orderInDay != null) body['order_in_day'] = orderInDay;
      if (!identical(notes, _undef)) body['notes'] = notes;
      if (!identical(emotion, _undef)) body['emotion'] = emotion;
      // 고정(is_pinned)은 일반 편집에 싣지 않는다 — per-user 전용 [pinTodoItem].
      final res = await _dio.patch(
        ApiEndpoints.todoItemById(todoListId, itemId),
        data: body,
      );
      final data = _unwrap(res.data) as Map<String, dynamic>;
      return TodoItem.fromJson(data);
    } on DioException catch (e) {
      _throwIfBusinessError(e);
      rethrow;
    }
  }

  /// 항목 고정 토글 (per-user). 개인 뷰라 viewer 도 가능. 순서는 BE 계산.
  Future<TodoItem> pinTodoItem(
    String todoListId,
    String itemId, {
    required bool isPinned,
  }) async {
    try {
      final res = await _dio.patch(
        ApiEndpoints.todoItemPin(todoListId, itemId),
        data: {'is_pinned': isPinned},
      );
      final data = _unwrap(res.data) as Map<String, dynamic>;
      return TodoItem.fromJson(data);
    } on DioException catch (e) {
      _throwIfBusinessError(e);
      rethrow;
    }
  }

  Future<List<TodoItem>> reorderItems({
    required String todoListId,
    required int dayIndex,
    required List<String> orderedItemIds,
  }) async {
    try {
      final res = await _dio.put(
        ApiEndpoints.todoItemsReorder(todoListId),
        data: {
          'day_index': dayIndex,
          'ordered_item_ids': orderedItemIds,
        },
      );
      final data = _unwrap(res.data) as List? ?? const [];
      return data
          .map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      _throwIfBusinessError(e);
      rethrow;
    }
  }

  Future<bool> deleteItem({
    required String todoListId,
    required String itemId,
  }) async {
    try {
      final res =
          await _dio.delete(ApiEndpoints.todoItemById(todoListId, itemId));
      final data = _unwrap(res.data) as Map<String, dynamic>?;
      return data?['success'] == true || res.statusCode == 200;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return true;
      _throwIfBusinessError(e);
      rethrow;
    }
  }

  // ── 체크인 ──────────────────────────────────────────

  Future<TodoItem> checkIn({
    required String todoListId,
    required String itemId,
    required String dotId,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.todoItemCheckIn(todoListId, itemId),
        data: {'dot_id': dotId},
      );
      final data = _unwrap(res.data) as Map<String, dynamic>;
      return TodoItem.fromJson(data);
    } on DioException catch (e) {
      _throwIfBusinessError(e);
      rethrow;
    }
  }

  /// 체크인 취소. 멱등 — 미체크인이어도 BE 가 200 으로 반환.
  Future<TodoItem> cancelCheckIn({
    required String todoListId,
    required String itemId,
  }) async {
    try {
      final res = await _dio.delete(
        ApiEndpoints.todoItemCheckIn(todoListId, itemId),
      );
      final data = _unwrap(res.data) as Map<String, dynamic>;
      return TodoItem.fromJson(data);
    } on DioException catch (e) {
      _throwIfBusinessError(e);
      rethrow;
    }
  }

  // ── 협업 멤버십 ──────────────────────────────────────

  /// 초대 코드 발급 — owner 만 가능.
  Future<({String code, DateTime expiresAt})?> generateCourseInviteCode(
      String todoListId, {String role = 'member'}) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.todoListInvite(todoListId),
        data: {'role': role},
      );
      final data = _unwrap(res.data) as Map<String, dynamic>;
      return (
        code: data['invite_code'] as String,
        expiresAt: DateTime.parse(data['expires_at'] as String),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        _throwIfBusinessError(e);
        rethrow;
      }
      return null;
    }
  }

  /// 초대 코드 미리보기 — 인증 불필요.
  /// 응답에 items 가 포함되더라도 위치 PII 노출 방지를 위해 파싱하지 않음.
  /// 인증 후 joinCourse() 에서 전체 데이터를 가져옴.
  Future<({
    String todoListId,
    String name,
    String? coverEmoji,
    String ownerNickname,
    int memberCount,
    DateTime expiresAt,
    String role,
  })?> getCourseInvitePreview(String code) async {
    try {
      final res = await _dio.get(ApiEndpoints.todoListInvitePreview(code));
      final data = _unwrap(res.data) as Map<String, dynamic>;
      final listId = data['id'] as String;
      return (
        todoListId: listId,
        name: data['name'] as String,
        coverEmoji: data['cover_emoji'] as String?,
        ownerNickname: (data['owner_nickname'] as String?) ?? '',
        memberCount: (data['member_count'] as num).toInt(),
        expiresAt: DateTime.parse(data['expires_at'] as String),
        role: (data['role'] as String?) ?? 'member',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response?.statusCode == 410) {
        return null;
      }
      if (e.response != null) rethrow;
      return null;
    }
  }

  /// 초대 코드로 공유 코스 참여. 성공 시 참여한 TodoList 반환.
  Future<TodoList> joinCourse(String inviteCode) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.todoListsJoin,
        data: {'invite_code': inviteCode},
      );
      final data = _unwrap(res.data) as Map<String, dynamic>;
      return TodoList.fromJson(data);
    } on DioException catch (e) {
      if (e.response != null) {
        final code = e.response?.data?['error']?['code'] as String?;
        if (code != null) throw JoinCourseException(code);
        _throwIfBusinessError(e);
      }
      rethrow;
    }
  }

  /// 공유 코스 나가기 — 멤버만 가능 (소유자 불가).
  Future<void> leaveCourse(String todoListId) async {
    try {
      await _dio.delete(ApiEndpoints.todoListLeave(todoListId));
    } on DioException catch (e) {
      if (e.response != null) {
        final code = e.response?.data?['error']?['code'] as String?;
        if (code != null) throw LeaveCourseException(code);
        _throwIfBusinessError(e);
      }
      rethrow; // 나가기는 오프라인 폴백 무의미 — 반드시 서버 확인 필요
    }
  }

  /// 멤버 강퇴 — owner 만 가능.
  Future<void> kickCourseMember(String todoListId, String userId) async {
    try {
      await _dio.delete(ApiEndpoints.todoListMember(todoListId, userId));
    } on DioException catch (e) {
      if (e.response != null) {
        final code = e.response?.data?['error']?['code'] as String?;
        if (code != null) throw KickCourseMemberException(code);
        _throwIfBusinessError(e);
      }
      rethrow;
    }
  }

  // ── 좋아요 (Phase 2) ─────────────────────────────────────

  /// 좋아요 등록/취소 (멱등). [like] true → POST, false → DELETE.
  /// 응답 `{ like_count, liked_by_me }`. 비공개+비멤버 → COURSE_NOT_PUBLIC(403).
  Future<({int likeCount, bool likedByMe})> setLike(
      String todoListId, bool like) async {
    try {
      final path = ApiEndpoints.todoListLike(todoListId);
      final res = like ? await _dio.post(path) : await _dio.delete(path);
      final data = _unwrap(res.data) as Map<String, dynamic>;
      return (
        likeCount: (data['like_count'] as num?)?.toInt() ?? 0,
        likedByMe: data['liked_by_me'] as bool? ?? like,
      );
    } on DioException catch (e) {
      _throwIfBusinessError(e);
      rethrow;
    }
  }

  /// 커버 사진 설정/해제 — 전용 엔드포인트. [coverImageUrl] null → 해제.
  /// 업로드 시 같은 코스로 발급받은 R2 public_url 이어야 함(아니면 403/400).
  Future<TodoList> setCover(String todoListId, String? coverImageUrl) async {
    try {
      final res = await _dio.patch(
        ApiEndpoints.todoListCover(todoListId),
        data: {'cover_image_url': coverImageUrl},
      );
      final data = _unwrap(res.data) as Map<String, dynamic>;
      return TodoList.fromJson(data);
    } on DioException catch (e) {
      _throwIfBusinessError(e);
      rethrow;
    }
  }

  // ── 가져오기(복제) / 신고 (Phase 3) ─────────────────────

  /// 공개 코스를 내 소유 private 코스로 복제(items 포함, 체크인 제외).
  /// 비공개+비멤버 → COURSE_NOT_PUBLIC(403).
  Future<TodoList> cloneCourse(String todoListId, {String? name}) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.todoListClone(todoListId),
        data: name != null ? {'name': name} : null,
      );
      final data = _unwrap(res.data) as Map<String, dynamic>;
      return TodoList.fromJson(data);
    } on DioException catch (e) {
      _throwIfBusinessError(e);
      rethrow;
    }
  }

  /// 공개 코스 신고. 재신고는 서버가 no-op 200 으로 dedupe.
  Future<void> reportCourse(
    String todoListId, {
    required String reason,
    String? detail,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.todoListReport(todoListId),
        data: {
          'reason': reason,
          if (detail != null && detail.trim().isNotEmpty) 'detail': detail.trim(),
        },
      );
    } on DioException catch (e) {
      _throwIfBusinessError(e);
      rethrow;
    }
  }

  // ── 룸 연결 ────────────────────────────────────────────

  /// PATCH /todo-lists/:id/room — null이면 연결 해제.
  Future<TodoList> setListRoom(String todoListId, String? roomId) async {
    try {
      final res = await _dio.patch(
        '${ApiEndpoints.todoLists}/$todoListId/room',
        data: {'room_id': roomId},
      );
      final data = _unwrap(res.data) as Map<String, dynamic>;
      return TodoList.fromJson(data);
    } on DioException catch (e) {
      _throwIfBusinessError(e);
      rethrow;
    }
  }

  /// GET /rooms/:id/todo-lists
  Future<List<TodoList>> getListsByRoom(String roomId) async {
    try {
      final res = await _dio.get('/rooms/$roomId/todo-lists');
      final list = _unwrap(res.data) as List;
      return list.map((e) => TodoList.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      _throwIfBusinessError(e);
      rethrow;
    }
  }

  // ── 헬퍼 ────────────────────────────────────────────

  /// `{"data": ...}` envelope 언래핑. 일부 endpoint 가 envelope 없이 응답해도
  /// 그대로 전달 (방어적).
  static dynamic _unwrap(dynamic body) {
    if (body is Map && body.containsKey('data')) return body['data'];
    return body;
  }

  /// BE 가 4xx/5xx 와 함께 `{"error":{"code","message"}}` 응답하면
  /// [TodoApiException] 으로 변환. 그 외는 호출자가 [DioException] 직접 처리.
  static void _throwIfBusinessError(DioException e) {
    final res = e.response;
    if (res == null) return; // 네트워크 오류 — 그대로 흘려보냄
    final body = res.data;
    String? code;
    String? message;
    if (body is Map) {
      final err = body['error'];
      if (err is Map) {
        code = err['code'] as String?;
        message = err['message'] as String?;
      } else {
        code = body['code'] as String?;
        message = body['message'] as String?;
      }
    }
    if (kDebugMode) {
      debugPrint(
          '[TodoRemote] error status=${res.statusCode} code=$code msg=$message');
    }
    Error.throwWithStackTrace(
      TodoApiException(
        code: code,
        message: message,
        statusCode: res.statusCode,
      ),
      e.stackTrace,
    );
  }

  static String _formatDate(DateTime d) {
    final yyyy = d.year.toString().padLeft(4, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return '$yyyy-$mm-$dd';
  }
}

/// PATCH 의 nullable-vs-unspecified 구분을 위한 sentinel.
/// `cover_emoji = _undef` → 필드 미포함. `cover_emoji = null` → 명시적 null 설정.
const Object _undef = Object();

/// BE 비즈니스 에러. statusCode + code 기반으로 UI 분기.
class TodoApiException implements Exception {
  const TodoApiException({this.code, this.message, this.statusCode});
  final String? code;
  final String? message;
  final int? statusCode;

  bool get isNotFound =>
      statusCode == 404 ||
      code == 'TODO_LIST_NOT_FOUND' ||
      code == 'TODO_ITEM_NOT_FOUND';
  bool get isForbidden => statusCode == 403 || code == 'FORBIDDEN';
  bool get isAlreadyCheckedIn => code == 'ALREADY_CHECKED_IN';
  // Phase 2 — 공개/좋아요.
  bool get isCourseNotPublic => code == 'COURSE_NOT_PUBLIC';
  bool get isNotCourseOwner => code == 'NOT_COURSE_OWNER';
  bool get isInvalidCoverUrl => code == 'INVALID_COVER_URL';
  bool get isRateLimited =>
      statusCode == 429 || code == 'RATE_LIMIT_EXCEEDED';
  bool get isDateRangeTooLong => code == 'DATE_RANGE_TOO_LONG';
  bool get isInvalidDateRange => code == 'INVALID_DATE_RANGE';
  bool get isInvalidDayIndex => code == 'INVALID_DAY_INDEX';

  @override
  String toString() {
    if (isAlreadyCheckedIn) return '이미 다녀온 스팟이에요';
    if (isCourseNotPublic) return '비공개 코스예요';
    if (isNotCourseOwner) return '코스 소유자만 공개 설정을 바꿀 수 있어요';
    if (isInvalidCoverUrl) return '커버 이미지를 다시 업로드해 주세요';
    if (isForbidden) return '권한이 없어요';
    if (isNotFound) return '대상을 찾을 수 없어요';
    if (isRateLimited) return '요청이 너무 잦아요. 잠시 후 다시 시도해 주세요';
    if (isDateRangeTooLong) return '기간이 너무 길어요 (최대 30일)';
    if (isInvalidDateRange) return '종료일이 시작일보다 빠를 수 없어요';
    if (isInvalidDayIndex) return '잘못된 일자예요';
    return message ?? '요청에 실패했어요';
  }
}

@riverpod
TodoRemoteSource todoRemoteSource(Ref ref) =>
    TodoRemoteSource(ApiClient.instance);
