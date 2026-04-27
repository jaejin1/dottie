class ApiEndpoints {
  ApiEndpoints._();

  // 인증
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';

  // 사용자
  static const String usersMe = '/users/me';
  static const String usersMeCharacter = '/users/me/character';

  // 기록
  static const String recordingsStart = '/recordings/start';
  static const String recordingsEnd = '/recordings/end';
  static const String dots = '/dots';
  static const String dotsBatch = '/dots/batch';

  // 하루 기록
  static const String daylogs = '/daylogs';
  static String daylogById(String id) => '/daylogs/$id';

  // 방
  static const String rooms = '/rooms';
  static String roomById(String id) => '/rooms/$id';
  static String roomInvite(String id) => '/rooms/$id/invite';
  static const String roomsJoin = '/rooms/join';
  static String roomLeave(String id) => '/rooms/$id/leave';

  // 공유 지도
  static String roomShare(String id) => '/rooms/$id/share';
  static String roomSharedMap(String id) => '/rooms/$id/shared-map';

  // 미디어
  static const String mediaUpload = '/media/upload';
}
