import 'dart:math';

class LocationUtils {
  LocationUtils._();

  /// Haversine 공식으로 두 좌표 간 거리(km) 계산
  static double distanceInKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadius = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRad(double deg) => deg * pi / 180;

  /// 두 위치가 반경 meters 이내인지
  static bool isWithinRadius(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
    double meters,
  ) =>
      distanceInKm(lat1, lng1, lat2, lng2) * 1000 <= meters;
}
