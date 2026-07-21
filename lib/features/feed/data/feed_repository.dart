import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../recording/data/dot_api_parser.dart';
import '../domain/feed_entry.dart';

part 'feed_repository.g.dart';

/// 페이지네이션된 피드 응답 — entries + 다음 cursor.
class FeedPage {
  const FeedPage({required this.entries, this.nextCursor});
  final List<FeedEntry> entries;
  final String? nextCursor;
}

/// `/v1/feed` 호출. 본인 + 내가 멤버인 방의 dot 시간순(desc) 합본.
///
/// 응답 envelope: `{ data: { dots: [{ ...dot snake_case, user_id,
/// user_nickname, user_color_hex, shared_room_ids }], next_cursor } }`.
///
/// dot 본문은 [dotFromApi] (recording/data/dot_api_parser) 로 파싱
/// (snake_case → Dot). 다른 dot-반환 endpoint 와 공통 파서.
/// `isMine` 은 BE 가 안 보내므로 caller (Notifier) 가 본인 uid 와 비교해 set.
///
/// 에러 코드 (BE spec):
///   - 400 BAD_REQUEST: room_id UUID 형식 오류
///   - 400 INVALID_CURSOR: cursor 디코딩 실패 (배포로 cursor 포맷 바뀌면 stale)
///   - 401: 미인증
///   - 403 FORBIDDEN: room_id 필터 — viewer 가 그 방 멤버 아님
/// Notifier 가 INVALID_CURSOR 만 cursor 리셋 후 재시도, 나머지는 throw.
class FeedRepository {
  FeedRepository(this._dio);
  final Dio _dio;

  /// [cursor] null = 첫 페이지. [roomId] null = 전체 방.
  Future<FeedPage> getFeed({
    int limit = 20,
    String? cursor,
    String? roomId,
  }) async {
    final res = await _dio.get(
      ApiEndpoints.feed,
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
        if (roomId != null) 'room_id': roomId,
      },
    );
    final raw = res.data;
    final data = (raw is Map && raw['data'] is Map)
        ? (raw['data'] as Map).cast<String, dynamic>()
        : (raw as Map).cast<String, dynamic>();
    final list = (data['dots'] as List? ?? const [])
        .whereType<Map>()
        .map((m) => _entryFromJson(m.cast<String, dynamic>()))
        .toList(growable: false);
    final next = data['next_cursor'];
    if (kDebugMode) {
      debugPrint('[feed] page fetched count=${list.length} '
          'cursor=$cursor → next=$next (roomId=$roomId)');
    }
    return FeedPage(
      entries: list,
      nextCursor: next is String && next.isNotEmpty ? next : null,
    );
  }

  /// dot 본문은 공통 파서 재사용 + author 메타 + shared_room_ids 만 별도 추출.
  FeedEntry _entryFromJson(Map<String, dynamic> json) {
    return FeedEntry(
      dot: dotFromApi(json),
      authorId: json['user_id'] as String? ?? '',
      authorNickname: json['user_nickname'] as String? ?? '',
      authorColorHex: json['user_color_hex'] as String? ?? '#7EB8F7',
      // isMine 은 Notifier 가 viewer uid 와 비교해 보정.
      isMine: false,
      sharedRoomIds: ((json['shared_room_ids'] as List?) ?? const [])
          .cast<String>()
          .toSet(),
    );
  }
}

@riverpod
FeedRepository feedRepository(Ref ref) => FeedRepository(ApiClient.instance);
