import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/discover_course_model.dart';

part 'discover_remote_source.g.dart';

/// 한 페이지 결과 — 카드 목록 + 다음 커서(없으면 null → 끝).
typedef DiscoverPage = ({List<DiscoverCourse> courses, String? nextCursor});

/// `GET /discover/courses` 통신. 공개 코스 랭킹(트렌딩/최신) 조회.
///
/// BE 미배포(404) 또는 오프라인 시 빈 페이지로 degrade — 디스커버리는
/// 부가 화면이라 앱 크래시 대신 "아직 없어요" 빈 상태로 보인다.
class DiscoverRemoteSource {
  DiscoverRemoteSource(this._dio);
  final Dio _dio;

  Future<DiscoverPage> fetch({
    String sort = 'trending',
    String? tag,
    String? type,
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.discoverCourses,
        queryParameters: {
          'sort': sort,
          if (tag != null) 'tag': tag,
          if (type != null) 'type': type,
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );
      final data = _unwrap(res.data);
      final rawList = (data is Map ? data['courses'] : null) as List? ??
          (data is List ? data : const []);
      final courses = rawList
          .whereType<Map<String, dynamic>>()
          .map(DiscoverCourse.fromJson)
          .toList();
      final next = data is Map ? data['next_cursor'] as String? : null;
      return (courses: courses, nextCursor: next);
    } on DioException catch (e) {
      // 404(BE 미배포) / 네트워크 오류 → 빈 페이지로 degrade.
      if (e.response?.statusCode == 404 || e.response == null) {
        if (kDebugMode) {
          debugPrint('[Discover] fetch degraded '
              '(${e.response?.statusCode ?? 'offline'}) → empty');
        }
        return (courses: const <DiscoverCourse>[], nextCursor: null);
      }
      rethrow;
    }
  }

  /// `GET /feed/courses` — 홈 피드 상단 추천 스트립용 트렌딩 코스 top-N.
  ///
  /// 커서 없음(추천 스트립이라 무한스크롤 불필요). BE 미배포(404)/오프라인 시
  /// 빈 목록으로 degrade — 홈 피드에서 레일이 조용히 숨는다.
  Future<List<DiscoverCourse>> fetchFeedStrip({int limit = 10}) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.feedCourses,
        queryParameters: {'limit': limit},
      );
      final data = _unwrap(res.data);
      final rawList = (data is Map ? data['courses'] : null) as List? ??
          (data is List ? data : const []);
      return rawList
          .whereType<Map<String, dynamic>>()
          .map(DiscoverCourse.fromJson)
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 || e.response == null) {
        if (kDebugMode) {
          debugPrint('[Discover] feed strip degraded '
              '(${e.response?.statusCode ?? 'offline'}) → empty');
        }
        return const <DiscoverCourse>[];
      }
      rethrow;
    }
  }

  /// 좋아요 토글 (멱등). [like] true → POST, false → DELETE.
  /// 응답 `{ like_count, liked_by_me }`. 좋아요 시 BE 가 trending 순위 즉시 반영.
  Future<({int likeCount, bool likedByMe})> setLike(
      String courseId, bool like) async {
    final path = ApiEndpoints.todoListLike(courseId);
    final res = like ? await _dio.post(path) : await _dio.delete(path);
    final data = _unwrap(res.data) as Map<String, dynamic>;
    return (
      likeCount: (data['like_count'] as num?)?.toInt() ?? 0,
      likedByMe: data['liked_by_me'] as bool? ?? like,
    );
  }

  static dynamic _unwrap(dynamic body) {
    if (body is Map && body.containsKey('data')) return body['data'];
    return body;
  }
}

@riverpod
DiscoverRemoteSource discoverRemoteSource(Ref ref) =>
    DiscoverRemoteSource(ApiClient.instance);
