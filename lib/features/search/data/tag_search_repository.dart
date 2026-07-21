import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_provider.dart';
import '../../recording/data/dot_local_source.dart';
import '../../recording/data/dot_remote_source.dart';
import '../../recording/domain/dot_model.dart';
import '../../recording/domain/tag_parser.dart';
import '../domain/tag_search_models.dart';

part 'tag_search_repository.g.dart';

/// 태그 검색 / 자동완성 / 인기 태그.
///
/// 기본은 BE 호출. **5xx · 네트워크 오류**는 로컬 drift 폴백, **4xx 비즈니스
/// 에러**는 [TagSearchException] 으로 호출자에게 전달.
///
/// 멀티계정 단말 격리: 로컬 폴백은 [_userId] 기준으로 dayLog 를 join 해
/// 다른 user 의 dot 이 검색 결과에 섞이지 않도록 한다.
class TagSearchRepository {
  TagSearchRepository(this._localSource, this._remote, this._userId);
  final DotLocalSource _localSource;
  final DotRemoteSource _remote;

  /// 현재 로그인된 user 의 BE UUID. null 이면 로컬 폴백을 비워서 반환 (안전).
  final String? _userId;

  /// 태그 기반 dot 검색.
  Future<TagSearchPage> search({
    required List<String> tags,
    TagMatchMode match = TagMatchMode.all,
    DateTime? from,
    DateTime? to,
    int limit = 30,
    String? cursor,
  }) async {
    final normalized = TagParser.normalizeAll(tags);
    if (normalized.isEmpty) return const TagSearchPage(results: []);

    try {
      final res = await _remote.searchDotsByTags(
        tags: normalized,
        match: match.queryValue,
        from: from,
        to: to,
        limit: limit,
        cursor: cursor,
      );
      final results = res.results
          .map((h) => TagSearchResult(
                dot: h.dot,
                userId: h.userId,
                userNickname: h.userNickname,
                userColorHex: h.userColorHex,
                roomId: h.roomId,
              ))
          .toList();
      return TagSearchPage(results: results, nextCursor: res.nextCursor);
    } on DioException catch (e) {
      // 4xx → 비즈니스 에러: typed exception. code 가 없어도 status 만으로 판단.
      // 5xx / 네트워크 → 로컬 폴백 (페이지네이션은 미지원 — 첫 호출만).
      if (_isBusinessError(e)) {
        throw TagSearchException(
          code: _errorCode(e) ?? 'BAD_REQUEST',
          message: _errorMessage(e),
        );
      }
      if (cursor != null) rethrow;
      debugPrint('[TagSearch] remote search failed → local fallback: $e');
      return _localSearch(
        tags: normalized,
        match: match,
        from: from,
        to: to,
        limit: limit,
      );
    }
  }

  /// 태그 자동완성.
  Future<List<String>> autocomplete(String prefix) async {
    final normalizedPrefix = prefix.trim().toLowerCase();
    // BE 는 prefix 필수. 빈 prefix 시 인기 태그로 대체 (입력창 # 직후 노출 용도).
    if (normalizedPrefix.isEmpty) {
      try {
        final pop = await _remote.popularTags(limit: 10);
        return pop.map((e) => e.tag).toList();
      } on DioException catch (e) {
        if (_isBusinessError(e)) return const [];
        final fallback = await _localPopular(limit: 10);
        return fallback.map((e) => e.tag).toList();
      }
    }
    try {
      final res = await _remote.autocompleteTags(normalizedPrefix);
      return res.map((e) => e.tag).toList();
    } on DioException catch (e) {
      if (_isBusinessError(e)) return const [];
      debugPrint('[TagSearch] autocomplete fallback: $e');
      final all = await _localPopular(limit: 100);
      return all
          .where((t) => t.tag.startsWith(normalizedPrefix))
          .take(10)
          .map((t) => t.tag)
          .toList();
    }
  }

  /// 인기 태그 (검색 화면 첫 진입 cloud).
  ///
  /// [roomId] 지정 시 그 방에 공유된 dot 의 태그만 집계 (멤버 dot 포함).
  /// 비멤버가 호출하면 BE 가 403 — 그 경우 빈 결과로 처리해 UI 가 비어 보이게.
  Future<List<TagWithCount>> popular({String? roomId, int limit = 20}) async {
    try {
      final res = await _remote.popularTags(roomId: roomId, limit: limit);
      return res
          .map((e) => TagWithCount(tag: e.tag, count: e.count))
          .toList();
    } on DioException catch (e) {
      if (_isBusinessError(e)) {
        // 403 FORBIDDEN (비멤버) / 400 (잘못된 room_id) → 빈 결과.
        debugPrint('[TagSearch] popular 4xx (roomId=$roomId): $e');
        return const [];
      }
      debugPrint('[TagSearch] popular fallback: $e');
      // 룸 단위 폴백은 의미 없으므로 (로컬 DB 에 멤버 dot 이 없음) 빈 리스트.
      // 본인 인기 태그만 로컬 폴백.
      if (roomId != null) return const [];
      return _localPopular(limit: limit);
    }
  }

  // ── 로컬 폴백 구현 ─────────────────────────────────────

  Future<TagSearchPage> _localSearch({
    required List<String> tags,
    required TagMatchMode match,
    DateTime? from,
    DateTime? to,
    required int limit,
  }) async {
    // 로컬 폴백은 본인 dot 만 (룸 멤버 dot 은 로컬에 없음). owner = 본인.
    final allDots = await _allLocalDots();
    final fromLocal = from?.toLocal();
    // BE 의 to 의미(YYYY-MM-DD 종일 끝)와 맞추기 위해 23:59:59.999 까지 포함.
    final toLocal = to == null
        ? null
        : DateTime(to.year, to.month, to.day, 23, 59, 59, 999);
    final filtered = allDots.where((d) {
      if (d.tags.isEmpty) return false;
      final ok = match == TagMatchMode.all
          ? tags.every((t) => d.tags.contains(t))
          : tags.any((t) => d.tags.contains(t));
      if (!ok) return false;
      final ts = d.timestamp.toLocal();
      if (fromLocal != null && ts.isBefore(fromLocal)) return false;
      if (toLocal != null && ts.isAfter(toLocal)) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final results = filtered.take(limit).map((d) => TagSearchResult(
          dot: d,
          userId: _userId ?? '',
          userNickname: '', // 로컬엔 본인 닉네임 캐시 없음. UI 가 "나" 라벨로 폴백.
          userColorHex: null,
          roomId: null, // 본인 dot — 룸 라우팅 안 함
        )).toList();

    return TagSearchPage(
      results: results,
      nextCursor: null, // 로컬 폴백은 페이지네이션 미지원
    );
  }

  Future<List<TagWithCount>> _localPopular({required int limit}) async {
    final dots = await _allLocalDots();
    final counts = <String, int>{};
    for (final d in dots) {
      for (final t in d.tags) {
        counts[t] = (counts[t] ?? 0) + 1;
      }
    }
    final list = counts.entries
        .map((e) => TagWithCount(tag: e.key, count: e.value))
        .toList()
      ..sort((a, b) {
        final byCount = b.count.compareTo(a.count);
        if (byCount != 0) return byCount;
        return a.tag.compareTo(b.tag);
      });
    return list.take(limit).toList();
  }

  Future<List<Dot>> _allLocalDots() async {
    if (_userId == null) return const [];
    try {
      final rows = await _localSource.getDotsForUser(_userId);
      return rows.map(_localSource.dotFromRow).toList();
    } catch (e, st) {
      debugPrint('[TagSearch] _allLocalDots error: $e\n$st');
      return const [];
    }
  }

  // ── 에러 분류 ─────────────────────────────────────────

  /// 4xx → 비즈니스 에러 (사용자에게 안내). 5xx / 네트워크 → 폴백 대상.
  static bool _isBusinessError(DioException e) {
    final code = e.response?.statusCode;
    return code != null && code >= 400 && code < 500;
  }

  static String? _errorCode(DioException e) {
    final r = e.response;
    if (r == null) return null;
    final body = r.data;
    if (body is! Map) return null;
    final err = body['error'];
    if (err is Map && err['code'] is String) return err['code'] as String;
    if (body['code'] is String) return body['code'] as String;
    return null;
  }

  static String? _errorMessage(DioException e) {
    final r = e.response;
    if (r == null) return null;
    final body = r.data;
    if (body is! Map) return null;
    final err = body['error'];
    if (err is Map && err['message'] is String) return err['message'] as String;
    if (body['message'] is String) return body['message'] as String;
    return null;
  }
}

/// BE 가 응답한 태그 검색 비즈니스 에러.
/// 화면 단에서 code 별 토스트/스낵바 메시지 분기.
class TagSearchException implements Exception {
  const TagSearchException({required this.code, this.message});
  final String code;
  final String? message;

  bool get isInvalidFormat => code == 'INVALID_TAG_FORMAT';
  bool get isTooMany => code == 'TAGS_TOO_MANY';
  bool get isInvalidDate => code == 'INVALID_DATE';
  bool get isInvalidDateRange => code == 'INVALID_DATE_RANGE';
  bool get isInvalidCursor => code == 'INVALID_CURSOR';

  @override
  String toString() => 'TagSearchException($code, $message)';
}

@riverpod
TagSearchRepository tagSearchRepository(Ref ref) {
  // BE UUID 우선, 없으면 Firebase UID. 둘 다 없으면 로컬 폴백 비활성.
  final userId = ref.watch(currentDottieUserProvider).valueOrNull?.uid ??
      ref.watch(currentUserProvider)?.uid;
  return TagSearchRepository(
    ref.watch(dotLocalSourceProvider),
    ref.watch(dotRemoteSourceProvider),
    userId,
  );
}
