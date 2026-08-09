class ApiEndpoints {
  ApiEndpoints._();

  // 인증
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';

  // 사용자
  static const String usersMe = '/users/me';
  static const String usersMeCharacter = '/users/me/character';
  // 소셜 계정 연결(account linking)
  static const String usersMeIdentities = '/users/me/identities';
  static String usersMeIdentity(String provider) =>
      '/users/me/identities/$provider';

  // 기록
  static const String dots = '/dots';
  static const String dotsBatch = '/dots/batch';

  // 태그 (B16)
  static const String dotsSearch = '/dots/search';
  static const String dotsTags = '/dots/tags';
  static const String dotsTagsPopular = '/dots/tags/popular';

  // 본인 누적 dot — 페이지네이션 (cursor 기반).
  static const String dotsCumulative = '/dots/cumulative';

  // 하루 기록
  static const String daylogs = '/daylogs';
  static const String daylogsToday = '/daylogs/today';
  static String daylogById(String id) => '/daylogs/$id';

  // 방
  static const String rooms = '/rooms';
  static String roomById(String id) => '/rooms/$id';
  static String roomInvite(String id) => '/rooms/$id/invite';
  static const String roomsJoin = '/rooms/join';
  // 인증 불필요 — 딥링크 진입 시 방 이름/만료일 미리보기
  static String roomInvitePreview(String code) => '/rooms/invite/$code';
  static String roomLeave(String id) => '/rooms/$id/leave';
  static String roomDelete(String id) => '/rooms/$id';
  // owner 만 가능 — 다른 멤버를 강퇴.
  static String roomMember(String roomId, String userId) =>
      '/rooms/$roomId/members/$userId';

  // 공유 지도
  static String roomShare(String id) => '/rooms/$id/share';
  static String roomSharedMap(String id) => '/rooms/$id/shared-map';
  // B7 — 누적 dot
  static String roomCumulativeDots(String id) =>
      '/rooms/$id/cumulative-dots';
  // B9 — 즐겨찾기 장소
  static String roomStarredPlaces(String id) =>
      '/rooms/$id/starred-places';
  static String roomStarredPlace(String id, String placeId) =>
      '/rooms/$id/starred-places/$placeId';
  // B10 — 장소 인사이트
  static String roomPlaceInsights(String id, String placeId) =>
      '/rooms/$id/places/$placeId/insights';
  // B11 — 룸 썸네일
  static String roomThumbnail(String id) => '/rooms/$id/thumbnail';
  // B15 — 룸 places 집계 (단계 1)
  // TODO(B15-stage2): bbox/zoom/mode/member_ids/category 파라미터 활용
  static String roomPlaces(String id) => '/rooms/$id/places';
  // B12 — 룸 설정 (auto_share 등)
  static String roomSettings(String id) => '/rooms/$id/settings';
  // B13 — 날짜별 공유 토글
  static String roomSharedDates(String id) => '/rooms/$id/shared-dates';
  static String roomSharedDate(String id, String date) =>
      '/rooms/$id/shared-dates/$date';

  // B8 — 장소 검색
  static const String placesSearch = '/places/search';

  // 미디어
  static const String mediaUpload = '/media/upload';

  // dot 사진
  static String dotPhoto(String id) => '/dots/$id/photo';

  // dot 단건 삭제
  static String dotById(String id) => '/dots/$id';

  // dot 룸별 숨김 — 본인 dot 만, 그 룸에 day_log 가 공유된 상태에서.
  static String dotHide(String dotId) => '/dots/$dotId/hide';
  static String dotUnhide(String dotId, String roomId) =>
      '/dots/$dotId/hide/$roomId';
  // 본인이 그 룸에서 숨긴 dot 목록 — "내가 숨긴 기록" 섹션용.
  static String roomHiddenDotsByMe(String roomId) =>
      '/rooms/$roomId/hidden-dots-by-me';

  // 댓글
  static String dotComments(String dotId) => '/dots/$dotId/comments';
  static String commentById(String id) => '/comments/$id';

  // 알림
  static const String notifications = '/notifications';
  static const String notificationsReadAll = '/notifications/read-all';
  static String notificationRead(String id) => '/notifications/$id/read';

  // FCM 푸시 토큰 (단수형 — BE 결정)
  static const String pushToken = '/users/me/push-token';

  // 푸시 알림 사용자 환경설정 — type 별 ON/OFF.
  // GET 조회 / PATCH 부분 업데이트. 응답은 갱신 후 전체 echo.
  static const String notificationPreferences =
      '/users/me/notification-preferences';

  // ── 피드 ────────────────────────────────────────────
  // 본인 + 내가 멤버인 방의 멤버 dot 시간순(desc) 합본.
  // cursor 페이지네이션 — query: ?limit=20&cursor=<opaque>&room_id=<uuid?>
  // 응답: { data: { dots: [{ ...dot, user_id, user_nickname, user_color_hex, shared_room_ids }], next_cursor } }
  static const String feed = '/feed';
  // 홈 피드용 트렌딩 코스 추천 스트립 — top-N(커서 없음), discover 카드 재사용.
  // query: ?limit=10 (1~20). 응답: { data: { courses: [DiscoverCourse] } }
  static const String feedCourses = '/feed/courses';

  // ── 할일 (Todo) ──────────────────────────────────────
  static const String todoLists = '/todo-lists';
  static String todoListById(String id) => '/todo-lists/$id';
  static String todoListPin(String id) => '/todo-lists/$id/pin';
  // Phase 2 — 좋아요 토글 (POST 등록 / DELETE 취소, 멱등).
  static String todoListLike(String id) => '/todo-lists/$id/like';
  // 커버 사진 설정/해제 — 전용 엔드포인트(R2 스코프 URL 검증).
  static String todoListCover(String id) => '/todo-lists/$id/cover';
  // Phase 3 — 공개 디스커버리 / 가져오기(복제) / 신고.
  static const String discoverCourses = '/discover/courses';
  static String todoListClone(String id) => '/todo-lists/$id/clone';
  static String todoListReport(String id) => '/todo-lists/$id/report';
  static String todoListItems(String id) => '/todo-lists/$id/items';
  static String todoItemById(String listId, String itemId) =>
      '/todo-lists/$listId/items/$itemId';
  // per-user 항목 고정 전용 (일반 항목 PATCH 는 is_pinned 무시).
  static String todoItemPin(String listId, String itemId) =>
      '/todo-lists/$listId/items/$itemId/pin';
  static String todoItemsReorder(String listId) =>
      '/todo-lists/$listId/items/reorder';
  static String todoItemCheckIn(String listId, String itemId) =>
      '/todo-lists/$listId/items/$itemId/check-in';
  // day 별 도로 경로 (서버가 Mapbox Directions 계산 + 캐시).
  static String todoListRoute(String id) => '/todo-lists/$id/route';
  // 협업 코스 멤버십 (Room 패턴 미러).
  static String todoListInvite(String id) => '/todo-lists/$id/course-invite';
  // 인증 불필요 — 딥링크 진입 시 코스 이름/멤버수/스팟 미리보기.
  static String todoListInvitePreview(String code) =>
      '/todo-lists/invite/$code';
  static const String todoListsJoin = '/todo-lists/join';
  static String todoListLeave(String id) => '/todo-lists/$id/leave';
  // owner 만 가능 — 다른 멤버를 강퇴.
  static String todoListMember(String id, String userId) =>
      '/todo-lists/$id/members/$userId';
}
