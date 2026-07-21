import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/place.dart';

/// B8 — `/v1/places/search` 호출 client.
class PlacesRemoteSource {
  PlacesRemoteSource(this._dio);
  final Dio _dio;

  /// 키워드 기반 장소 검색. 좌표는 옵셔널.
  ///
  /// BE 카카오 Local Search 동작:
  ///   - 좌표 전달 → x/y/radius=500 — *현재 위치 500m 반경* (dot 기록 인증용)
  ///   - 좌표 미전달 → x/y/radius 생략 — *국내 전국* 키워드 검색 (갈곳 모음용)
  ///
  /// 해외 검색은 현재 backend 한계로 0/빈약 결과. 호출자가 UI 안내 처리.
  ///
  /// DioException (네트워크 오류 + BE 4xx/5xx) 은 **모두 그대로 전파** — 호출자가
  /// 사용자에게 의미 있는 메시지를 표시해야 함 (빈 결과 vs 검색 실패 구분).
  Future<List<Place>> search({
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    if (query.trim().isEmpty) return [];
    // lat/lng 가 동시에 있어야만 유효 (한쪽만 있으면 BE 가 무시할 수 있어 안전하게 둘 다 생략).
    final hasCoord = latitude != null && longitude != null;
    final res = await _dio.get(
      ApiEndpoints.placesSearch,
      queryParameters: {
        'q': query.trim(),
        if (hasCoord) 'latitude': latitude,
        if (hasCoord) 'longitude': longitude,
      },
    );
    final list = (res.data['data'] as List?) ?? const [];
    return list
        .cast<Map<String, dynamic>>()
        .map(Place.fromJson)
        .toList();
  }
}

final placesRemoteSourceProvider = Provider<PlacesRemoteSource>((ref) {
  return PlacesRemoteSource(ApiClient.instance);
});
