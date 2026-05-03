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

  Future<Room?> joinRoom(String inviteCode) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.roomsJoin,
        data: {'invite_code': inviteCode},
      );
      final json = res.data['data'] as Map<String, dynamic>;
      return Room.fromJson(json);
    } catch (_) {
      return null;
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
}

@riverpod
RoomRemoteSource roomRemoteSource(Ref ref) =>
    RoomRemoteSource(ApiClient.instance);
