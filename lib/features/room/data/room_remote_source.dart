import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/room_exceptions.dart';
import '../domain/room_model.dart';

export '../domain/room_exceptions.dart';

part 'room_remote_source.g.dart';

class RoomRemoteSource {
  RoomRemoteSource(this._dio);
  final Dio _dio;

  Future<List<Room>> getRooms() async {
    try {
      final res = await _dio.get(ApiEndpoints.rooms);
      final list = (res.data['data'] ?? res.data) as List;
      return list.map((e) => Room.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<Room?> getRoom(String id) async {
    try {
      final res = await _dio.get(ApiEndpoints.roomById(id));
      final json = (res.data['data'] ?? res.data) as Map<String, dynamic>;
      return Room.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<Room?> createRoom(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > 50) {
      throw ArgumentError('방 이름은 1자 이상 50자 이하로 입력해주세요.');
    }
    try {
      final res = await _dio.post(ApiEndpoints.rooms, data: {'name': trimmed});
      final json = res.data['data'] as Map<String, dynamic>;
      return Room.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// 방 이름 변경 — owner 만 가능. BE: PATCH /v1/rooms/:id { name: "..." }
  /// 4xx 는 [RenameRoomException] 으로 변환, 네트워크 오류는 null 반환.
  Future<Room?> renameRoom(String roomId, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > 50) {
      throw ArgumentError('방 이름은 1자 이상 50자 이하로 입력해주세요.');
    }
    try {
      final res = await _dio.patch(
        ApiEndpoints.roomById(roomId),
        data: {'name': trimmed},
      );
      final json = (res.data['data'] ?? res.data) as Map<String, dynamic>;
      return Room.fromJson(json);
    } on DioException catch (e) {
      if (e.response != null) {
        final code = e.response?.data?['error']?['code'] as String?;
        throw RenameRoomException(code ?? 'UNKNOWN');
      }
      return null;
    }
  }

  /// 멤버 강퇴 — owner 만 가능. DELETE /v1/rooms/:id/members/:userId.
  /// 4xx 는 [KickMemberException] 으로 변환.
  Future<void> kickMember(String roomId, String userId) async {
    try {
      await _dio.delete(ApiEndpoints.roomMember(roomId, userId));
    } on DioException catch (e) {
      if (e.response != null) {
        final code = e.response?.data?['error']?['code'] as String?;
        throw KickMemberException(code ?? 'UNKNOWN');
      }
      rethrow;
    }
  }

  Future<({String code, DateTime expiresAt})?> generateInviteCode(
      String roomId) async {
    try {
      final res = await _dio.post(ApiEndpoints.roomInvite(roomId));
      final data = res.data['data'] as Map<String, dynamic>;
      return (
        code: data['invite_code'] as String,
        expiresAt: DateTime.parse(data['expires_at'] as String),
      );
    } on DioException catch (e) {
      if (e.response != null) rethrow;
      return null;
    }
  }

  /// 초대 코드로 방 정보 미리보기 — 인증 불필요 (딥링크 폴백 화면용).
  /// 코드 만료 / 없으면 null 반환.
  Future<({String roomName, int memberCount, DateTime expiresAt})?> getRoomInvitePreview(
      String code) async {
    try {
      // 인증 없이 호출해야 하므로 AuthInterceptor 가 붙지 않는 별도 dio 인스턴스가
      // 이상적이지만, GET /rooms/invite/:code 는 BE 에서 토큰 없어도 허용하므로
      // 기존 dio 그대로 사용해도 무방.
      final res = await _dio.get(ApiEndpoints.roomInvitePreview(code));
      final data = res.data['data'] as Map<String, dynamic>;
      return (
        roomName: data['room_name'] as String,
        memberCount: (data['member_count'] as num).toInt(),
        expiresAt: DateTime.parse(data['expires_at'] as String),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      if (e.response != null) rethrow;
      return null;
    }
  }

  Future<Room?> joinRoom(String inviteCode) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.roomsJoin,
        data: {'invite_code': inviteCode},
      );
      final json = res.data['data'] as Map<String, dynamic>;
      return Room.fromJson(json);
    } on DioException catch (e) {
      if (e.response != null) {
        final code = e.response?.data?['error']?['code'] as String?;
        if (code != null) throw JoinRoomException(code);
        rethrow;
      }
      return null; // 네트워크 오류 → null
    }
  }

  Future<void> leaveRoom(String roomId) async {
    try {
      await _dio.delete(ApiEndpoints.roomLeave(roomId));
    } on DioException catch (e) {
      if (e.response != null) {
        final code = e.response?.data?['error']?['code'] as String?;
        if (code != null) throw LeaveRoomException(code);
        rethrow;
      }
      // 네트워크 오류는 무시 (오프라인 상황)
    }
  }

  Future<void> deleteRoom(String roomId) async {
    try {
      await _dio.delete(ApiEndpoints.roomDelete(roomId));
    } on DioException catch (e) {
      if (e.response != null) rethrow;
      // 네트워크 오류는 무시
    }
  }

  Future<void> shareDayLog(String roomId, String dayLogId) async {
    try {
      await _dio.post(
        ApiEndpoints.roomShare(roomId),
        data: {'day_log_id': dayLogId},
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final code = e.response?.data?['error']?['code'] as String?;
        if (code != null) throw ShareDayLogException(code);
      }
      // 네트워크 오류는 그대로 rethrow
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getSharedMap(
      String roomId, String date) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.roomSharedMap(roomId),
        queryParameters: {'date': date},
      );
      return res.data['data'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  // ── B7 누적 dot ─────────────────────────────────────

  /// 페이지네이션 지원 — cursor null 이면 처음부터.
  Future<Map<String, dynamic>?> getCumulativeDots(
    String roomId, {
    String? from,
    String? to,
    String? cursor,
    int limit = 200,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.roomCumulativeDots(roomId),
        queryParameters: {
          if (from != null) 'from': from,
          if (to != null) 'to': to,
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );
      return res.data['data'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  // ── B9 즐겨찾기 장소 ─────────────────────────────────

  Future<List<Map<String, dynamic>>> getStarredPlaces(String roomId) async {
    try {
      final res = await _dio.get(ApiEndpoints.roomStarredPlaces(roomId));
      final list = (res.data['data'] as List?) ?? [];
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  Future<void> starPlace(String roomId, String placeId) async {
    await _dio.post(
      ApiEndpoints.roomStarredPlaces(roomId),
      data: {'place_id': placeId},
    );
  }

  Future<void> unstarPlace(String roomId, String placeId) async {
    await _dio.delete(ApiEndpoints.roomStarredPlace(roomId, placeId));
  }

  // ── B10 장소 인사이트 ────────────────────────────────

  Future<Map<String, dynamic>?> getPlaceInsights(
      String roomId, String placeId) async {
    try {
      final res =
          await _dio.get(ApiEndpoints.roomPlaceInsights(roomId, placeId));
      return res.data['data'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  // ── B15 룸 places 집계 ───────────────────────────────

  /// `GET /v1/rooms/:id/places`. cursor pagination, 단계 1 파라미터.
  ///
  /// TODO(B15-stage2): bbox 파라미터 (viewport 기반 fetch)
  /// TODO(B15-stage3): mode=clusters 파라미터 (server clustering)
  /// TODO(B15-stage4): member_ids/category 필터
  /// TODO(B15-cache): If-None-Match 헤더 + 304 처리
  Future<Map<String, dynamic>?> getRoomPlaces(
    String roomId, {
    String? from,
    String? to,
    String? cursor,
    int limit = 200,
    bool includeOrphans = false,
    String sort = 'recent',
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.roomPlaces(roomId),
        queryParameters: {
          if (from != null) 'from': from,
          if (to != null) 'to': to,
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
          'include_orphans': includeOrphans,
          'sort': sort,
        },
      );
      return res.data['data'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  // ── B11 룸 썸네일 ────────────────────────────────────

  Future<String?> getRoomThumbnail(String roomId) async {
    try {
      final res = await _dio.get(ApiEndpoints.roomThumbnail(roomId));
      final data = res.data['data'] as Map<String, dynamic>?;
      return data?['url'] as String?;
    } catch (_) {
      return null;
    }
  }

  // ── B12 룸 설정 (auto_share) ─────────────────────────

  Future<bool> updateAutoShare(String roomId, bool autoShare) async {
    try {
      await _dio.patch(
        ApiEndpoints.roomSettings(roomId),
        data: {'auto_share': autoShare},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── B13 날짜별 공유 토글 ─────────────────────────────

  Future<bool> shareDate(String roomId, String date) async {
    try {
      await _dio.post(
        ApiEndpoints.roomSharedDates(roomId),
        data: {'date': date},
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> unshareDate(String roomId, String date) async {
    try {
      await _dio.delete(ApiEndpoints.roomSharedDate(roomId, date));
      return true;
    } catch (_) {
      return false;
    }
  }
}

@riverpod
RoomRemoteSource roomRemoteSource(Ref ref) =>
    RoomRemoteSource(ApiClient.instance);
