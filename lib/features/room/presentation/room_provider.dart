import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../cumulative_map/presentation/cumulative_map_provider.dart';
import '../../notification/presentation/notification_provider.dart';
import '../../shared_map/presentation/shared_map_provider.dart';
import '../data/room_repository.dart';
import '../domain/room_exceptions.dart';
import '../domain/room_model.dart';

part 'room_provider.g.dart';

/// 룸 안에서 멤버십/공유가 바뀐 후 룸 관련 모든 캐시를 일괄 무효화.
/// kick / leave / shareDayLog / shareDate / unshareDate 등에서 공통 호출.
///
/// invalidate 를 **다음 frame** 으로 미룸 — leaveRoom 같은 destructive 액션
/// 직후 호출자가 `context.go` 로 화면 이동하기 전에 detail provider 가 즉시
/// refetch → BE 403 → "방을 찾을 수 없어요" 깜박임 race 회피. navigation 이
/// 적용된 *후* invalidate 가 실행되면 detail screen 은 이미 dispose 되어
/// refetch 가 트리거되지 않음.
void _invalidateRoomData(Ref ref, String roomId) {
  SchedulerBinding.instance.addPostFrameCallback((_) {
    ref.invalidate(roomDetailProvider(roomId));
    ref.invalidate(roomListProvider);
    ref.invalidate(cumulativeRoomDotsProvider(roomId));
    ref.invalidate(placeGroupsProvider(roomId));
    // sharedMap 은 (roomId, date) 패밀리 — date 별로 캐시되므로
    // family 전체 invalidate (다른 룸 캐시도 무효화되지만 작은 비용).
    ref.invalidate(sharedMapNotifierProvider);
    ref.invalidate(notificationProvider);
  });
}

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
      // BE 가 leave 시 shared_day_logs / dot_comments / notifications 정리.
      _invalidateRoomData(ref, roomId);
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

  /// 방 이름 변경 — owner 만 가능. PATCH /v1/rooms/:id { name }.
  /// 성공 시 roomDetail / roomList 모두 갱신.
  Future<void> renameRoom(String roomId, String name) async {
    await ref.read(roomRepositoryProvider).renameRoom(roomId, name);
    ref.invalidate(roomDetailProvider(roomId));
    ref.invalidate(roomListProvider);
  }

  /// 멤버 강퇴 — owner 만 가능.
  /// BE 가 자동으로: 멤버십 제거 + 그 룸 안 그 사용자의 shared_day_logs +
  /// dot_comments + notifications 일괄 삭제 (best-effort).
  /// 4xx 는 [KickMemberException] re-throw.
  Future<void> kickMember(String roomId, String userId) async {
    await ref.read(roomRepositoryProvider).kickMember(roomId, userId);
    _invalidateRoomData(ref, roomId);
  }

  Future<void> shareDayLog(String roomId, String dayLogId) async {
    state = const AsyncLoading();
    try {
      await ref.read(roomRepositoryProvider).shareDayLog(roomId, dayLogId);
      _invalidateRoomData(ref, roomId);
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

  // ── B12 자동 공유 토글 ──────────────────────────────

  Future<void> setAutoShare(String roomId, bool autoShare) async {
    final ok = await ref
        .read(roomRepositoryProvider)
        .updateAutoShare(roomId, autoShare);
    if (ok) {
      // auto_share ON 으로 켜면 BE 가 즉시 오늘 day_log 를 공유 — 지도 갱신 필요.
      _invalidateRoomData(ref, roomId);
    }
  }

  // ── B13 날짜별 공유 토글 ────────────────────────────

  Future<void> shareDate(String roomId, DateTime date) async {
    final ok =
        await ref.read(roomRepositoryProvider).shareDate(roomId, date);
    if (ok) {
      _invalidateRoomData(ref, roomId);
    }
  }

  Future<void> unshareDate(String roomId, DateTime date) async {
    final ok =
        await ref.read(roomRepositoryProvider).unshareDate(roomId, date);
    if (ok) {
      _invalidateRoomData(ref, roomId);
    }
  }
}
