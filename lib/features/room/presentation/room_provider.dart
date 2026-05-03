import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/room_repository.dart';
import '../domain/room_exceptions.dart';
import '../domain/room_model.dart';

part 'room_provider.g.dart';

@riverpod
Future<List<Room>> roomList(Ref ref) =>
    ref.watch(roomRepositoryProvider).getRooms();

@riverpod
Future<Room?> roomDetail(Ref ref, String roomId) =>
    ref.watch(roomRepositoryProvider).getRoom(roomId);

@riverpod
class RoomNotifier extends _$RoomNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<Room?> createRoom(String name) async {
    state = const AsyncLoading();
    try {
      final room = await ref.read(roomRepositoryProvider).createRoom(name);
      ref.invalidate(roomListProvider);
      state = const AsyncData(null);
      return room;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<Room?> joinRoom(String inviteCode) async {
    state = const AsyncLoading();
    try {
      final room =
          await ref.read(roomRepositoryProvider).joinRoom(inviteCode);
      ref.invalidate(roomListProvider);
      state = const AsyncData(null);
      return room;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  Future<void> leaveRoom(String roomId) async {
    state = const AsyncLoading();
    try {
      await ref.read(roomRepositoryProvider).leaveRoom(roomId);
      ref.invalidate(roomListProvider);
      state = const AsyncData(null);
    } on LeaveRoomException catch (e, st) {
      state = const AsyncData(null);
      Error.throwWithStackTrace(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteRoom(String roomId) async {
    state = const AsyncLoading();
    try {
      await ref.read(roomRepositoryProvider).deleteRoom(roomId);
      ref.invalidate(roomListProvider);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> shareDayLog(String roomId, String dayLogId) async {
    state = const AsyncLoading();
    try {
      await ref.read(roomRepositoryProvider).shareDayLog(roomId, dayLogId);
      state = const AsyncData(null);
    } on ShareDayLogException catch (e, st) {
      // 비즈니스 에러 — 버튼 유지, UI에서 스낵바로 처리
      state = const AsyncData(null);
      Error.throwWithStackTrace(e, st);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<({String code, DateTime expiresAt})> generateInviteCode(
      String roomId) async {
    return ref.read(roomRepositoryProvider).generateInviteCode(roomId);
  }
}
