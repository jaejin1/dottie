import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/comment_model.dart';

final commentRemoteSourceProvider = Provider<CommentRemoteSource>((ref) {
  return CommentRemoteSource();
});

class CommentRemoteSource {
  final _dio = ApiClient.instance;

  /// 여러 룸의 댓글을 한 번에 조회 — `room_ids` 쿼리 파라미터 필수 (콤마 구분).
  /// 각 댓글에 `room_ids` 배열 포함. 권한 없거나 dot 이 룸에 미공유면 403.
  Future<List<DotComment>> getComments(
    String dotId, {
    required Set<String> roomIds,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.dotComments(dotId),
        queryParameters: {'room_ids': roomIds.join(',')},
      );
      final list = (res.data['data'] ?? res.data) as List;
      return list
          .map((e) => DotComment.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) rethrow;
      return []; // 오프라인 → 빈 목록
    }
  }

  /// 댓글 작성 — body 에 `room_ids` 배열 필수. 여러 룸에 동시 귀속 가능.
  /// 멘션 대상이 룸 멤버 아니면 BE 가 자동 skip (에러 없음).
  Future<DotComment> postComment(
    String dotId, {
    required List<String> roomIds,
    required String content,
    required List<MentionSpan> mentions,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.dotComments(dotId),
      data: {
        'room_ids': roomIds,
        'content': content,
        'mentions': mentions.map((m) => m.toJson()).toList(),
      },
    );
    final json = (res.data['data'] ?? res.data) as Map<String, dynamic>;
    return DotComment.fromJson(json);
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _dio.delete(ApiEndpoints.commentById(commentId));
    } on DioException catch (e) {
      if (e.response != null) rethrow;
    }
  }
}
