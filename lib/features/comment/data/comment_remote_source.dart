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

  Future<List<DotComment>> getComments(String dotId) async {
    try {
      final res = await _dio.get(ApiEndpoints.dotComments(dotId));
      final list = (res.data['data'] ?? res.data) as List;
      return list
          .map((e) => DotComment.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) rethrow;
      return []; // 오프라인 → 빈 목록
    }
  }

  Future<DotComment> postComment(
    String dotId, {
    required String content,
    required List<MentionSpan> mentions,
  }) async {
    // 서버 에러는 그대로 propagate (비즈니스 오류 처리를 위해)
    final res = await _dio.post(
      ApiEndpoints.dotComments(dotId),
      data: {
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
