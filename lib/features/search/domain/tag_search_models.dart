import '../../recording/domain/dot_model.dart';

/// 태그 검색 결과 한 항목 — dot + 소유자 메타.
///
/// 검색 범위가 "본인 + 본인이 속한 룸의 멤버 dot" 으로 확장되면서 각 결과에
/// 소유자 정보가 필요. BE 가 응답 dot 마다 user_id / user_nickname /
/// user_color_hex / room_id 를 같이 보내고, FE 는 본인/타인 시각 구분 + 라우팅
/// 분기에 사용.
class TagSearchResult {
  const TagSearchResult({
    required this.dot,
    required this.userId,
    required this.userNickname,
    this.userColorHex,
    this.roomId,
  });

  final Dot dot;

  /// dot 소유자 BE UUID. 본인 / 타인 분기의 권위 (currentDottieUser.uid 비교).
  final String userId;

  /// UI 라벨용. BE 가 닉네임 못 줄 때 빈 문자열일 수도.
  final String userNickname;

  /// 멤버 정체성 색 hex. null 이면 default(`#7EB8F7`) 폴백.
  final String? userColorHex;

  /// 이 dot 이 노출된 룸 — 타인 dot 일 때 라우팅용. 본인 dot 이면 null.
  final String? roomId;

  /// 현재 로그인 user 와 비교해 본인 dot 인지.
  bool isOwnedBy(String? currentUserId) =>
      currentUserId != null && userId == currentUserId;
}

/// 태그 검색 결과 한 페이지.
class TagSearchPage {
  const TagSearchPage({
    required this.results,
    this.nextCursor,
  });

  final List<TagSearchResult> results;
  final String? nextCursor;

  bool get hasMore => nextCursor != null;
}

/// 태그 + 사용 횟수 (자동완성/인기 태그 공용).
class TagWithCount {
  const TagWithCount({required this.tag, required this.count});
  final String tag;
  final int count;
}

/// 다중 태그 검색 매칭 모드.
enum TagMatchMode { all, any }

extension TagMatchModeQuery on TagMatchMode {
  String get queryValue => switch (this) {
        TagMatchMode.all => 'all',
        TagMatchMode.any => 'any',
      };

  String get label => switch (this) {
        TagMatchMode.all => '모두 (AND)',
        TagMatchMode.any => '아무거나 (OR)',
      };
}
