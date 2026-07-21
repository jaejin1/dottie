import 'package:freezed_annotation/freezed_annotation.dart';

import '../../recording/domain/dot_model.dart';

part 'feed_entry.freezed.dart';

/// 피드의 단일 카드 단위. dot + 작성자 표시 메타 + 공유된 방 id 셋.
///
/// - `isMine = true` 면 본인 dot. `authorNickname` / `authorColorHex` 는 본인 정보.
/// - `sharedRoomIds` 비어 있으면: 본인 dot 인데 어디에도 공유 안 됨 (chip 없이 표시).
/// - 본인 dot 이 N 개 방에 공유되었으면 카드 1개로 합치고 chip N 개.
///
/// BE `/v1/feed` 응답 각 dot 은 inline 으로 `user_id` / `user_nickname` /
/// `user_color_hex` / `shared_room_ids` 를 포함 (멤버 메타 누락 회피).
/// 파싱은 [FeedRepository] 가 담당 — `isMine` 은 viewer uid 비교 후 세팅.
@freezed
class FeedEntry with _$FeedEntry {
  const factory FeedEntry({
    required Dot dot,
    required String authorId,
    required String authorNickname,
    required String authorColorHex,
    required bool isMine,
    @Default(<String>{}) Set<String> sharedRoomIds,
  }) = _FeedEntry;
}
