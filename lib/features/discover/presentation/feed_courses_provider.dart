import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/discover_remote_source.dart';
import '../domain/discover_course_model.dart';

part 'feed_courses_provider.g.dart';

/// 홈 피드 상단 "지금 뜨는 코스" 레일용 트렌딩 코스 top-N.
///
/// `GET /feed/courses` 를 호출하되, 홈 피드의 부가 요소이므로 어떤 에러에도
/// 빈 목록으로 degrade — 레일이 조용히 사라질 뿐 홈 화면은 멀쩡히 뜬다.
/// (discoverFeedProvider 와 별개: 이쪽은 표시 전용, 좋아요 토글 없음.)
@riverpod
Future<List<DiscoverCourse>> feedCourses(Ref ref) async {
  try {
    return await ref.read(discoverRemoteSourceProvider).fetchFeedStrip();
  } catch (e) {
    if (kDebugMode) debugPrint('[FeedCourses] hidden on error: $e');
    return const <DiscoverCourse>[];
  }
}
