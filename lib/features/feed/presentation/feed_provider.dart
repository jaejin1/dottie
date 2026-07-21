import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_provider.dart';
import '../data/feed_fallback.dart';
import '../data/feed_repository.dart';
import '../domain/feed_entry.dart';
import '../domain/feed_state.dart';
import '../feed_config.dart';

part 'feed_provider.g.dart';

/// 피드 페이지네이션 — `/v1/feed` cursor 기반.
///
/// family arg: `roomFilter` — null 이면 전체, 값 있으면 그 방만.
/// chip 마다 별도 인스턴스로 캐시 — `keepAlive` 라 chip 전환 후 복귀 시 재페치 X.
/// 새 dot/삭제 등 갱신은 호출자가 `ref.invalidate(feedNotifierProvider)`
/// (family 전체) 로 명시적으로 invalidate.
///
/// **BE fallback**: `/v1/feed` 미구현 (404/501) 시 자동으로
/// [FeedFallbackBuilder] (Phase 1 클라이언트 합치기) 로 우회. fallback 모드는
/// 페이지네이션 없이 100 개 cap. BE 배포 확인 후 fallback + 관련 모듈 제거.
///
/// **INVALID_CURSOR (400)**: BE 가 cursor 포맷 바꾸면 발생 — 자동으로 첫
/// 페이지부터 재페치 (`ref.invalidateSelf`).
@Riverpod(keepAlive: true)
class FeedNotifier extends _$FeedNotifier {
  @override
  Future<FeedState> build(String? roomFilter) async {
    final me = await ref.watch(currentDottieUserProvider.future);
    if (me == null) {
      return const FeedState(entries: []);
    }

    final repo = ref.watch(feedRepositoryProvider);
    try {
      final page = await repo.getFeed(
        limit: FeedConfig.pageSize,
        roomId: roomFilter,
      );
      return FeedState(
        entries: _markMine(page.entries, me.uid),
        nextCursor: page.nextCursor,
        hasMore: page.nextCursor != null,
      );
    } on DioException catch (e, st) {
      // BE 미배포 시 클라이언트 합치기 fallback. 502/503 등 일시 장애는
      // 진짜 에러로 올려서 사용자에게 에러 UI 표시.
      final status = e.response?.statusCode;
      if (status == 404 || status == 501) {
        debugPrint('[feed] /v1/feed not deployed (status=$status) — '
            'falling back to client-side merge');
        return FeedFallbackBuilder(ref).build(
          roomFilter: roomFilter,
          myUid: me.uid,
        );
      }
      // status 만 release 에 노출, raw exception (BE URL / body) 은 debug 만.
      debugPrint('[feed] /v1/feed failed status=$status');
      assert(() {
        debugPrint('[feed] err=$e');
        return true;
      }());
      Error.throwWithStackTrace(e, st);
    }
  }

  Future<void> loadMore() async {
    final s = state.valueOrNull;
    if (s == null || !s.hasMore || s.isLoadingMore) return;
    final cursor = s.nextCursor;
    if (cursor == null) return;

    state = AsyncData(s.copyWith(isLoadingMore: true));
    try {
      final me = ref.read(currentDottieUserProvider).valueOrNull;
      final repo = ref.read(feedRepositoryProvider);
      final page = await repo.getFeed(
        limit: FeedConfig.pageSize,
        cursor: cursor,
        roomId: roomFilter,
      );

      // ── race 가드 ────────────────────────────────────────
      // await 도중 사용자가 pull-to-refresh (`ref.invalidate`) 했거나, 또 다른
      // loadMore 가 cursor 를 바꿔놓았을 수 있다. 그 경우 이 응답은 stale —
      // 적용하면 새로 로드된 첫 페이지 entries 를 통째로 덮어쓴다.
      final latest = state.valueOrNull;
      if (latest == null || latest.nextCursor != cursor) {
        debugPrint('[feed] stale loadMore response — discarding '
            '(captured=$cursor, current=${latest?.nextCursor})');
        return;
      }

      final marked = _markMine(page.entries, me?.uid ?? '');
      // 같은 dot id 가 중복으로 올 일은 거의 없지만 BE bug 대비 dedup.
      final seen = {for (final e in latest.entries) e.dot.id};
      final fresh = marked.where((e) => seen.add(e.dot.id)).toList();
      state = AsyncData(latest.copyWith(
        entries: [...latest.entries, ...fresh],
        nextCursor: page.nextCursor,
        hasMore: page.nextCursor != null,
        isLoadingMore: false,
      ));
    } on DioException catch (e, st) {
      // INVALID_CURSOR (BE 배포로 cursor 포맷 변경 / 캐시 stale) → 첫 페이지부터
      // 자동 재페치. 사용자가 새로고침할 필요 없게.
      final isInvalidCursor = e.response?.statusCode == 400 &&
          (e.response?.data is Map &&
              (e.response!.data as Map)['code'] == 'INVALID_CURSOR');
      if (isInvalidCursor) {
        debugPrint('[feed] INVALID_CURSOR — auto re-fetching first page');
        ref.invalidateSelf();
        return;
      }
      assert(() {
        debugPrint('[feed] loadMore failed err=$e\n$st');
        return true;
      }());
      final cur = state.valueOrNull;
      if (cur != null) state = AsyncData(cur.copyWith(isLoadingMore: false));
    } catch (e, st) {
      assert(() {
        debugPrint('[feed] loadMore failed err=$e\n$st');
        return true;
      }());
      final cur = state.valueOrNull;
      if (cur != null) state = AsyncData(cur.copyWith(isLoadingMore: false));
    }
  }

  /// dot 저장 직후 낙관적 삽입 — 서버 응답 대기 없이 피드 상단에 즉시 표시.
  /// 이미 동일 dot.id 가 있으면 skip (서버 refresh 후 중복 방지).
  /// 서버 refresh 시 자연스럽게 서버 데이터로 교체됨.
  void prependEntry(FeedEntry entry) {
    final s = state.valueOrNull;
    if (s == null) return;
    if (s.entries.any((e) => e.dot.id == entry.dot.id)) return;
    state = AsyncData(s.copyWith(entries: [entry, ...s.entries]));
  }

  /// BE 가 `isMine` 안 보내므로 caller 가 본인 uid 와 비교해 보정.
  List<FeedEntry> _markMine(List<FeedEntry> entries, String myUid) {
    return [
      for (final e in entries)
        if (e.authorId == myUid) e.copyWith(isMine: true) else e,
    ];
  }
}
