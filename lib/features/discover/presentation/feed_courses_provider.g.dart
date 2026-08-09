// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_courses_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedCoursesHash() => r'842d2c36e68fff1d228955a7fb2b8edf589e1c0c';

/// 홈 피드 상단 "지금 뜨는 코스" 레일용 트렌딩 코스 top-N.
///
/// `GET /feed/courses` 를 호출하되, 홈 피드의 부가 요소이므로 어떤 에러에도
/// 빈 목록으로 degrade — 레일이 조용히 사라질 뿐 홈 화면은 멀쩡히 뜬다.
/// (discoverFeedProvider 와 별개: 이쪽은 표시 전용, 좋아요 토글 없음.)
///
/// Copied from [feedCourses].
@ProviderFor(feedCourses)
final feedCoursesProvider =
    AutoDisposeFutureProvider<List<DiscoverCourse>>.internal(
      feedCourses,
      name: r'feedCoursesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$feedCoursesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeedCoursesRef = AutoDisposeFutureProviderRef<List<DiscoverCourse>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
