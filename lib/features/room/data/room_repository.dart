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

  Future<Room> renameRoom(String roomId, String name) async {
    final room = await _remote.renameRoom(roomId, name);
    if (room != null) return room;
    throw Exception('방 이름 변경에 실패했습니다');
  }

  Future<void> kickMember(String roomId, String userId) =>
      _remote.kickMember(roomId, userId);

  Future<void> shareDayLog(String roomId, String dayLogId) =>
      _remote.shareDayLog(roomId, dayLogId);

  Future<Map<String, dynamic>?> getSharedMap(String roomId, DateTime date) =>
      _remote.getSharedMap(roomId, DottieDateUtils.toDateString(date));

  // B7
  Future<Map<String, dynamic>?> getCumulativeDots(
    String roomId, {
    DateTime? from,
    DateTime? to,
    String? cursor,
    int limit = 200,
  }) =>
      _remote.getCumulativeDots(
        roomId,
        from: from != null ? DottieDateUtils.toDateString(from) : null,
        to: to != null ? DottieDateUtils.toDateString(to) : null,
        cursor: cursor,
        limit: limit,
      );

  // B9
  Future<List<Map<String, dynamic>>> getStarredPlaces(String roomId) =>
      _remote.getStarredPlaces(roomId);

  Future<void> starPlace(String roomId, String placeId) =>
      _remote.starPlace(roomId, placeId);

  Future<void> unstarPlace(String roomId, String placeId) =>
      _remote.unstarPlace(roomId, placeId);

  // B10
  Future<Map<String, dynamic>?> getPlaceInsights(
          String roomId, String placeId) =>
      _remote.getPlaceInsights(roomId, placeId);

  // B11
  Future<String?> getRoomThumbnail(String roomId) =>
      _remote.getRoomThumbnail(roomId);

  // B15 — 룸 places 집계
  Future<Map<String, dynamic>?> getRoomPlaces(
    String roomId, {
    DateTime? from,
    DateTime? to,
    String? cursor,
    int limit = 200,
    bool includeOrphans = false,
    String sort = 'recent',
  }) =>
      _remote.getRoomPlaces(
        roomId,
        from: from != null ? DottieDateUtils.toDateString(from) : null,
        to: to != null ? DottieDateUtils.toDateString(to) : null,
        cursor: cursor,
        limit: limit,
        includeOrphans: includeOrphans,
        sort: sort,
      );

  // B12
  Future<bool> updateAutoShare(String roomId, bool autoShare) =>
      _remote.updateAutoShare(roomId, autoShare);

  // B13
  Future<bool> shareDate(String roomId, DateTime date) =>
      _remote.shareDate(roomId, DottieDateUtils.toDateString(date));

  Future<bool> unshareDate(String roomId, DateTime date) =>
      _remote.unshareDate(roomId, DottieDateUtils.toDateString(date));
}

@riverpod
RoomRepository roomRepository(Ref ref) =>
    RoomRepository(ref.watch(roomRemoteSourceProvider));
