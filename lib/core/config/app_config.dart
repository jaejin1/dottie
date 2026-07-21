// ignore_for_file: do_not_use_environment

class AppConfig {
  AppConfig._();

  // --dart-define 으로 주입
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8080/v1',
  );

  static const String mapboxAccessToken = String.fromEnvironment(
    'MAPBOX_ACCESS_TOKEN',
    defaultValue: '',
  );

  static const String env = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  static const String kakaoNativeAppKey = String.fromEnvironment(
    'KAKAO_NATIVE_APP_KEY',
    defaultValue: '',
  );

  /// 구글 OAuth **웹(서버) 클라이언트 ID**. GoogleSignIn 에 지정해야 Android 에서
  /// idToken 이 나오고, iOS·Android 양쪽 토큰 aud 가 이 값으로 일관된다.
  /// (공개 클라이언트 ID — 비밀 아님. BE GOOGLE_CLIENT_IDS 에 이 값 포함 필요.)
  static const String googleServerClientId =
      '417852363208-4dd4r7ro3u1mb1u2q8irmjjrfliss542.apps.googleusercontent.com';

  static bool get isDev => env == 'dev';
  static bool get isProd => env == 'prod';

  /// 앱 웹 호스트 — 초대 링크 등 외부 공유용.
  static const String webHost = 'https://app.dottie.today';

  /// prod 빌드는 반드시 https 로만 통신해야 한다. 빌드 설정 실수로
  /// `--dart-define=API_URL` 가 http(평문)로 주입되면 Firebase ID 토큰·dot
  /// 좌표가 평문 전송되므로, 시작 시점에 즉시 실패시켜 배포를 차단한다.
  /// (assert 는 release 에서 제거되므로 일반 throw 로 fail-fast.)
  static void assertSecureConfig() {
    if (isProd && !apiUrl.startsWith('https://')) {
      final scheme =
          apiUrl.contains('://') ? apiUrl.split('://').first : '(none)';
      throw StateError(
          'SECURITY: prod 빌드는 https API_URL 이 필요합니다 (scheme=$scheme).');
    }
  }
}
