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

  static bool get isDev => env == 'dev';
  static bool get isProd => env == 'prod';
}
