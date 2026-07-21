import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feed_local_photo_store.g.dart';

/// dot 저장 직후 BE 사진 variant 생성 완료 전까지 로컬 원본 경로를 임시 보관.
///
/// **흐름**:
/// 1. dot 저장 성공 → `set(dotId, localPath)` 등록
/// 2. FeedCard 가 이 경로로 `Image.file` 표시 (즉시 보임)
/// 3. 피드 새로고침 후 BE variant(`photo_thumb_url`) 가 채워지면
///    FeedCard 가 `remove(dotId)` 를 호출 → 맵 entry + 디스크 파일 모두 삭제
///
/// keepAlive — 피드 invalidate 이후에도 유지돼야 카드에서 조회 가능.
@Riverpod(keepAlive: true)
class FeedLocalPhotoStore extends _$FeedLocalPhotoStore {
  @override
  Map<String, String> build() => const {};

  void set(String dotId, String localPath) {
    if (state[dotId] == localPath) return;
    state = {...state, dotId: localPath};
  }

  void remove(String dotId) {
    if (!state.containsKey(dotId)) return;
    final path = state[dotId];
    if (path != null) {
      File(path).delete().catchError((Object _) => File(path));
    }
    state = Map.of(state)..remove(dotId);
  }
}
