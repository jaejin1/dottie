import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/comment_remote_source.dart';
import '../domain/comment_model.dart';

final commentListProvider = StateNotifierProvider.autoDispose
    .family<CommentListNotifier, AsyncValue<List<DotComment>>, String>(
  (ref, dotId) {
    final source = ref.watch(commentRemoteSourceProvider);
    return CommentListNotifier(source, dotId);
  },
);

class CommentListNotifier extends StateNotifier<AsyncValue<List<DotComment>>> {
  final CommentRemoteSource _source;
  final String _dotId;

  CommentListNotifier(this._source, this._dotId)
      : super(const AsyncLoading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncLoading();
    try {
      final comments = await _source.getComments(_dotId);
      state = AsyncData(comments);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> post(String content, List<MentionSpan> mentions) async {
    try {
      final comment = await _source.postComment(
        _dotId,
        content: content,
        mentions: mentions,
      );
      final current = state.valueOrNull ?? [];
      state = AsyncData([...current, comment]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> delete(String commentId) async {
    try {
      await _source.deleteComment(commentId);
      final current = state.valueOrNull ?? [];
      state = AsyncData(current.where((c) => c.id != commentId).toList());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() => _load();
}
