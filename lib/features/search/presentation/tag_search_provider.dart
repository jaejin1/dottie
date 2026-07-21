import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/tag_search_repository.dart';
import '../domain/tag_search_models.dart';

part 'tag_search_provider.g.dart';

/// 인기 태그 (검색 화면 첫 진입 chip cloud).
///
/// [roomId] null → 본인 모든 dot. [roomId] 지정 → 그 방에 공유된 dot.
/// FE 는 본인 1회 + 룸 N회 (1+N) 호출 패턴.
@riverpod
Future<List<TagWithCount>> popularTags(Ref ref, {String? roomId}) {
  return ref.watch(tagSearchRepositoryProvider).popular(roomId: roomId);
}

/// 자동완성 — `prefix` 별로 family.
/// dot_input_sheet 의 MemoWithTagsField suggestionFetcher 가 호출.
@riverpod
Future<List<String>> tagAutocomplete(Ref ref, String prefix) {
  return ref.watch(tagSearchRepositoryProvider).autocomplete(prefix);
}

/// 검색 화면 상태 — 입력된 태그 + 매칭 모드 + 결과.
@riverpod
class TagSearch extends _$TagSearch {
  @override
  TagSearchState build() => const TagSearchState.initial();

  /// `INVALID_CURSOR` 자동 재시도는 한 build 사이클당 1회만 허용 — 무한 루프 방어.
  bool _cursorRecoveredOnce = false;

  /// 새 태그 추가 (이미 있으면 no-op). 추가 후 즉시 검색.
  Future<void> addTag(String tag) async {
    if (state.tags.contains(tag)) return;
    state = state.copyWith(tags: [...state.tags, tag]);
    await runSearch();
  }

  /// 태그 제거. 모두 비면 결과도 비움.
  Future<void> removeTag(String tag) async {
    final next = [...state.tags]..remove(tag);
    if (next.isEmpty) {
      state = const TagSearchState.initial();
      _cursorRecoveredOnce = false;
      return;
    }
    state = state.copyWith(tags: next);
    await runSearch();
  }

  void setMatchMode(TagMatchMode mode) {
    state = state.copyWith(matchMode: mode);
    if (state.tags.isNotEmpty) runSearch();
  }

  Future<void> runSearch() async {
    if (state.tags.isEmpty) return;
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearException: true,
    );
    try {
      final repo = ref.read(tagSearchRepositoryProvider);
      final page = await repo.search(
        tags: state.tags,
        match: state.matchMode,
      );
      state = state.copyWith(page: page, isLoading: false);
      _cursorRecoveredOnce = false; // 정상 응답 → 가드 리셋
    } catch (e) {
      state = state.copyWith(
        clearPage: true,
        isLoading: false,
        isLoadingMore: false,
        error: e is TagSearchException ? e.code : e.toString(),
        latestException: e is TagSearchException ? e : null,
      );
    }
  }

  /// 다음 페이지 로드 (cursor 기반). 결과가 더 없으면 no-op.
  /// 새로 받은 결과를 기존 page.results 뒤에 append.
  Future<void> loadMore() async {
    final current = state.page;
    if (current == null) return;
    if (!current.hasMore) return;
    if (state.isLoadingMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final repo = ref.read(tagSearchRepositoryProvider);
      final next = await repo.search(
        tags: state.tags,
        match: state.matchMode,
        cursor: current.nextCursor,
      );
      final merged = TagSearchPage(
        results: <TagSearchResult>[...current.results, ...next.results],
        nextCursor: next.nextCursor,
      );
      state = state.copyWith(page: merged, isLoadingMore: false);
    } on TagSearchException catch (e) {
      // INVALID_CURSOR 등 cursor 무효 → state 에 반영해 화면에서 재검색 결정.
      debugPrint('[TagSearch] loadMore typed error: $e');
      state = state.copyWith(
        isLoadingMore: false,
        error: e.code,
        latestException: e,
      );
    } catch (e) {
      debugPrint('[TagSearch] loadMore error: $e');
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// `INVALID_CURSOR` 처럼 한 번만 자동 복구해야 하는 케이스.
  /// 이미 한 번 복구한 적이 있으면 false 반환 — UI 가 이중 복구 시도 안 하도록.
  bool tryRecoverFromCursorError() {
    if (_cursorRecoveredOnce) return false;
    _cursorRecoveredOnce = true;
    runSearch();
    return true;
  }

  void clear() {
    state = const TagSearchState.initial();
    _cursorRecoveredOnce = false;
  }
}

class TagSearchState {
  const TagSearchState({
    required this.tags,
    required this.matchMode,
    required this.page,
    required this.isLoading,
    required this.isLoadingMore,
    required this.error,
    required this.latestException,
  });

  const TagSearchState.initial()
      : tags = const [],
        matchMode = TagMatchMode.all,
        page = null,
        isLoading = false,
        isLoadingMore = false,
        error = null,
        latestException = null;

  final List<String> tags;
  final TagMatchMode matchMode;
  final TagSearchPage? page;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  /// 가장 최근 BE 비즈니스 에러 (UI 에서 code 별 메시지 분기 시 사용).
  final TagSearchException? latestException;

  /// `clearXxx` 플래그로 nullable 필드를 명시적으로 비울 수 있게 함.
  /// (Dart copyWith 패턴 한계 — null 인자가 "변경 없음"인지 "null 로 셋"인지 구분 불가.)
  TagSearchState copyWith({
    List<String>? tags,
    TagMatchMode? matchMode,
    TagSearchPage? page,
    bool clearPage = false,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
    TagSearchException? latestException,
    bool clearException = false,
  }) {
    return TagSearchState(
      tags: tags ?? this.tags,
      matchMode: matchMode ?? this.matchMode,
      page: clearPage ? null : (page ?? this.page),
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      latestException:
          clearException ? null : (latestException ?? this.latestException),
    );
  }
}
