import 'app_config.dart';

class MapboxConfig {
  MapboxConfig._();

  static String get accessToken => AppConfig.mapboxAccessToken;

  // Mapbox Studio에서 생성한 커스텀 스타일 URL (추후 교체)
  static const String styleUrl =
      'mapbox://styles/mapbox/light-v11';

  // 한국 기본 중심 좌표 (서울)
  static const double defaultLat = 37.5665;
  static const double defaultLng = 126.9780;
  static const double defaultZoom = 12.0;
}
