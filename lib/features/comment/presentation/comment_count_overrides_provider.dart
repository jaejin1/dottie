import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'comment_count_overrides_provider.g.dart';

/// BE 응답의 `comment_count` 가 stale 인 dot 에 대한 클라이언트 측 정정 store.
///
/// **왜 필요한가**: `/v1/feed` 응답의 `dot.comment_count` 가 (a) BE
/// eventual-consistency 로 댓글 추가 직후 0 이거나 (b) BE 가 그 필드를 안
/// 채워 보내는 케이스가 관찰됨. invalidate 해도 BE 가 stale 값을 주면 사용자가
/// 회복 불가.
///
/// **해결**: `CommentListNotifier` 가 BE 댓글 응답 받을 때마다 그 카운트로
/// 여기 dotId 를 override. `FeedCard` 는 override 가 있으면 그 값 우선 표시.
///
/// 동작:
/// - 시트 진입 → `_load` → override.set → 카드 카운트 즉시 정확
/// - 댓글 추가/삭제 → override.set + feed invalidate → 카드 갱신
/// - 시트 안 들어가도 BE 응답이 정상이면 dot.commentCount 그대로 노출
///
/// keepAlive — 메모리 작음 (활성 dot 만), 앱 평생 유지.
@Riverpod(keepAlive: true)
class CommentCountOverrides extends _$CommentCountOverrides {
  @override
  Map<String, int> build() => const {};

  /// 같은 값이면 state 갱신 skip (불필요 rebuild 방지).
  void set(String dotId, int count) {
    if (state[dotId] == count) return;
    state = {...state, dotId: count};
  }

  /// 특정 dot 만 한 번 lookup. select 와 같은 효과 — caller 가 watch 시 사용.
  int? operator [](String dotId) => state[dotId];
}
