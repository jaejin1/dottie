import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/utils/date_utils.dart';
import '../domain/room_model.dart';
import 'room_remote_source.dart';

part 'room_repository.g.dart';

class RoomRepository {
  RoomRepository(this._remote);
  final RoomRemoteSource _remote;

  Future<List<Room>> getRooms() => _remote.getRooms();

  Future<Room?> getRoom(String id) => _remote.getRoom(id);

  Future<Room> createRoom(String name) async {
    final room = await _remote.createRoom(name);
    if (room != null) return room;
    throw Exception('방 만들기에 실패했습니다');
  }

  Future<({String code, DateTime expiresAt})> generateInviteCode(
      String roomId) async {
    final result = await _remote.generateInviteCode(roomId);
    if (result != null) return result;
    throw Exception('초대 코드 생성에 실패했습니다');
  }

  Future<Room?> joinRoom(String inviteCode) => _remote.joinRoom(inviteCode);

  Future<void> leaveRoom(String roomId) => _remote.leaveRoom(roomId);

  Future<void> deleteRoom(String roomId) => _remote.deleteRoom(roomId);

  Future<void> shareDayLog(String roomId, String dayLogId) =>
      _remote.shareDayLog(roomId, dayLogId);

  Future<Map<String, dynamic>?> getSharedMap(String roomId, DateTime date) =>
      _remote.getSharedMap(roomId, DottieDateUtils.toDateString(date));
}

@riverpod
RoomRepository roomRepository(Ref ref) =>
    RoomRepository(ref.watch(roomRemoteSourceProvider));
