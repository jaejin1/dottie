import 'package:freezed_annotation/freezed_annotation.dart';

import 'feed_entry.dart';

part 'feed_state.freezed.dart';

/// `FeedNotifier` 의 상태 — 페이지 누적 + cursor + 추가 로딩 플래그.
///
/// - `entries`: 지금까지 fetch 한 모든 페이지 합본 (timestamp desc 정렬 유지)
/// - `nextCursor`: 다음 페이지 요청 시 BE 에 전달할 opaque cursor. null = 마지막
/// - `hasMore`: `nextCursor != null` 와 동치. 무한 스크롤 트리거 결정에 사용
/// - `isLoadingMore`: loadMore 진행 중 — 중복 호출 방지 + 푸터 로딩 인디케이터
@freezed
class FeedState with _$FeedState {
  const factory FeedState({
    required List<FeedEntry> entries,
    String? nextCursor,
    @Default(false) bool hasMore,
    @Default(false) bool isLoadingMore,
  }) = _FeedState;
}
