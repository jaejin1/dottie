import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_provider.dart';
import '../../cumulative_map/presentation/cumulative_map_provider.dart';
import '../../recording/presentation/recording_provider.dart';
import '../../room/presentation/room_provider.dart';
import '../domain/feed_entry.dart';
import '../domain/feed_state.dart';
import '../feed_config.dart';

/// BE `/v1/feed` 미배포 (404/501) 시 임시 fallback — Phase 1 의 클라이언트
/// 합치기 로직을 별도 모듈로 분리. BE 배포 확인 후 이 파일 전체 삭제 예정.
///
/// 동작:
/// 1. 본인 모든 dot (`allDayLogsProvider`) flatten
/// 2. 내가 속한 각 방 (`roomListProvider`) 의 누적 dot 병렬 fetch
///    (`cumulativeRoomDotsProvider`)
/// 3. dot.id 중복 제거 + 본인이 여러 방 공유한 케이스 `sharedRoomIds` 누적
/// 4. timestamp DESC 정렬 + roomFilter 적용 + [FeedConfig.fallbackCap] 으로 cap
///
/// 페이지네이션 없음 — 반환값의 `hasMore=false`.
class FeedFallbackBuilder {
  FeedFallbackBuilder(this.ref);
  final Ref ref;

  Future<FeedState> build({
    required String? roomFilter,
    required String myUid,
  }) async {
    final rooms = await ref.watch(roomListProvider.future);
    final myDayLogs = await ref.watch(allDayLogsProvider.future);
    final me = await ref.watch(currentDottieUserProvider.future);

    final entries = <String, FeedEntry>{};

    // 1. 본인 dot
    for (final log in myDayLogs) {
      for (final dot in log.dots) {
        entries[dot.id] = FeedEntry(
          dot: dot,
          authorId: myUid,
          authorNickname: me?.nickname ?? '',
          authorColorHex: me?.character.colorHex ?? '#7EB8F7',
          isMine: true,
        );
      }
    }

    // 2. 각 방 누적 dot 병렬
    final roomFutures = rooms.map(
      (r) => ref.watch(cumulativeRoomDotsProvider(r.id).future).then(
            (dots) => (r.id, dots),
          ),
    );
    final roomResults = await Future.wait(roomFutures);

    // 3. 합치기
    for (final (roomId, roomDots) in roomResults) {
      for (final rd in roomDots) {
        final existing = entries[rd.dot.id];
        if (existing != null) {
          entries[rd.dot.id] = existing.copyWith(
            sharedRoomIds: {...existing.sharedRoomIds, roomId},
            // 서버 응답이 commentCount 등 최신일 수 있으므로 dot 갱신.
            dot: rd.dot,
          );
        } else {
          entries[rd.dot.id] = FeedEntry(
            dot: rd.dot,
            authorId: rd.memberId,
            authorNickname: rd.nickname,
            authorColorHex: rd.colorHex,
            isMine: rd.memberId == myUid,
            sharedRoomIds: {roomId},
          );
        }
      }
    }

    // 4. 정렬 + 필터 + cap
    var sorted = entries.values.toList()
      ..sort((a, b) => b.dot.timestamp.compareTo(a.dot.timestamp));
    if (roomFilter != null) {
      sorted =
          sorted.where((e) => e.sharedRoomIds.contains(roomFilter)).toList();
    }
    if (sorted.length > FeedConfig.fallbackCap) {
      sorted = sorted.sublist(0, FeedConfig.fallbackCap);
    }
    return FeedState(entries: sorted, hasMore: false);
  }
}
