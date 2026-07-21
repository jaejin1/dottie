import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/comment_remote_source.dart';
import '../domain/comment_model.dart';

/// roomKey = sorted roomIds.join(',') — Riverpod family equality 보장.
typedef MergedCommentKey = ({String dotId, String roomKey});

/// 여러 룸의 댓글을 한 번에 조회 — BE 가 단일 호출로 중복 없이 반환.
/// roomKey = sorted roomIds.join(',')
final mergedCommentListProvider = FutureProvider.autoDispose
    .family<List<DotComment>, MergedCommentKey>(
  (ref, key) async {
    if (key.roomKey.isEmpty) return const [];
    final roomIds = key.roomKey.split(',').toSet();
    final source = ref.watch(commentRemoteSourceProvider);
    return source.getComments(key.dotId, roomIds: roomIds);
  },
);
