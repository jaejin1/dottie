import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/discover_remote_source.dart';
import '../domain/discover_course_model.dart';

part 'discover_provider.g.dart';

/// 디스커버리 화면 상태 — 필터(sort/tag/type) + 누적 카드 목록 + 커서.
class DiscoverFeedState {
  const DiscoverFeedState({
    required this.sort,
    required this.tag,
    required this.type,
    required this.courses,
    required this.cursor,
    required this.hasMore,
    required this.loadingMore,
  });

  final String sort; // 'trending' | 'new'
  final String? tag; // 단일 태그 필터
  final String? type; // 'trip' | 'collection' | null(전체)
  final List<DiscoverCourse> courses;
  final String? cursor;
  final bool hasMore;
  final bool loadingMore;

  DiscoverFeedState copyWith({
    String? sort,
    String? Function()? tag,
    String? Function()? type,
    List<DiscoverCourse>? courses,
    String? Function()? cursor,
    bool? hasMore,
    bool? loadingMore,
  }) =>
      DiscoverFeedState(
        sort: sort ?? this.sort,
        tag: tag != null ? tag() : this.tag,
        type: type != null ? type() : this.type,
        courses: courses ?? this.courses,
        cursor: cursor != null ? cursor() : this.cursor,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
      );
}

/// 공개 코스 디스커버리 피드. 초기 로드 + 필터 변경 시 재조회 + 커서 무한 스크롤.
@riverpod
class DiscoverFeed extends _$DiscoverFeed {
  @override
  Future<DiscoverFeedState> build() =>
      _load(sort: 'trending', tag: null, type: null);

  Future<DiscoverFeedState> _load({
    required String sort,
    required String? tag,
    required String? type,
  }) async {
    final page = await ref
        .read(discoverRemoteSourceProvider)
        .fetch(sort: sort, tag: tag, type: type);
    return DiscoverFeedState(
      sort: sort,
      tag: tag,
      type: type,
      courses: page.courses,
      cursor: page.nextCursor,
      hasMore: page.nextCursor != null,
      loadingMore: false,
    );
  }

  Future<void> _reload({String? sort, String? tag, String? type}) async {
    final cur = state.valueOrNull;
    final nextSort = sort ?? cur?.sort ?? 'trending';
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _load(sort: nextSort, tag: tag, type: type),
    );
  }

  Future<void> setSort(String sort) async {
    final cur = state.valueOrNull;
    if (cur != null && cur.sort == sort) return;
    await _reload(sort: sort, tag: cur?.tag, type: cur?.type);
  }

  /// 태그 토글 — 같은 태그 재선택 시 해제(null).
  Future<void> setTag(String? tag) async {
    final cur = state.valueOrNull;
    final next = (cur?.tag == tag) ? null : tag;
    await _reload(sort: cur?.sort, tag: next, type: cur?.type);
  }

  Future<void> setType(String? type) async {
    final cur = state.valueOrNull;
    await _reload(sort: cur?.sort, tag: cur?.tag, type: type);
  }

  Future<void> refresh() async {
    final cur = state.valueOrNull;
    await _reload(sort: cur?.sort, tag: cur?.tag, type: cur?.type);
  }

  /// 카드에서 좋아요 토글 (인스타 방식). 피드 상태를 낙관적으로 갱신하고
  /// 서버 확정값으로 보정, 실패 시 원복. 목록 전체 재조회 없음(스크롤 유지).
  Future<void> toggleLike(String courseId) async {
    final cur = state.valueOrNull;
    if (cur == null) return;
    final idx = cur.courses.indexWhere((c) => c.id == courseId);
    if (idx < 0) return;
    final before = cur.courses[idx];
    final next = !before.likedByMe;
    // 낙관적 반영
    _replaceCourse(
      courseId,
      (c) => c.copyWith(
        likedByMe: next,
        likeCount: (c.likeCount + (next ? 1 : -1)).clamp(0, 1 << 30),
      ),
    );
    try {
      final result =
          await ref.read(discoverRemoteSourceProvider).setLike(courseId, next);
      _replaceCourse(
        courseId,
        (c) => c.copyWith(
            likeCount: result.likeCount, likedByMe: result.likedByMe),
      );
    } catch (_) {
      _replaceCourse(courseId, (_) => before); // 원복
    }
  }

  /// 특정 코스 1건만 변환해 교체 — transform 시그니처를 명시해 타입 안전.
  void _replaceCourse(
      String courseId, DiscoverCourse Function(DiscoverCourse) transform) {
    final cur = state.valueOrNull;
    if (cur == null) return;
    final courses = [
      for (final c in cur.courses)
        if (c.id == courseId) transform(c) else c,
    ];
    state = AsyncData(cur.copyWith(courses: courses));
  }

  Future<void> loadMore() async {
    final cur = state.valueOrNull;
    if (cur == null || !cur.hasMore || cur.loadingMore) return;
    state = AsyncData(cur.copyWith(loadingMore: true));
    try {
      final page = await ref.read(discoverRemoteSourceProvider).fetch(
            sort: cur.sort,
            tag: cur.tag,
            type: cur.type,
            cursor: cur.cursor,
          );
      // 중복 방지 — 서버가 겹치는 id 를 줘도 카드가 중복되지 않게.
      final seen = cur.courses.map((c) => c.id).toSet();
      final merged = [
        ...cur.courses,
        ...page.courses.where((c) => seen.add(c.id)),
      ];
      state = AsyncData(cur.copyWith(
        courses: merged,
        cursor: () => page.nextCursor,
        hasMore: page.nextCursor != null,
        loadingMore: false,
      ));
    } catch (_) {
      state = AsyncData(cur.copyWith(loadingMore: false));
    }
  }
}
