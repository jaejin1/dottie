import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_endpoints.dart';

/// 스팟 순서대로 실제 도로를 따라가는 경로 geometry.
///
/// BE `/todo-lists/:id/route?day_index=N` 호출 — 서버가 Mapbox Directions 를
/// 계산하고 (todo_list_id, day_index) 단위로 캐시한다. 같은 코스를 보는
/// 멤버들이 계산 결과를 공유하므로 FE 는 캐시를 신경 쓸 필요 없음.
class RouteRemoteSource {
  RouteRemoteSource(this._dio);

  final Dio _dio;

  /// day 별 도로 경로 조회.
  /// 스팟 2개 미만 / 서버측 Mapbox 실패 / 네트워크 오류 → null (직선 폴백).
  Future<DayRoute?> fetchDayRoute(String todoListId, int dayIndex) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.todoListRoute(todoListId),
        queryParameters: {'day_index': dayIndex},
      );
      final data = res.data['data'];
      if (data == null) return null; // 스팟 부족 or 서버측 경로 계산 실패
      final map = data as Map<String, dynamic>;
      final geometry = map['geometry'] as Map<String, dynamic>;
      final coords = (geometry['coordinates'] as List)
          .map((c) => [
                ((c as List)[0] as num).toDouble(),
                (c[1] as num).toDouble(),
              ])
          .toList();
      return DayRoute(
        coordinates: coords,
        distanceM: ((map['distance_m'] as num?) ?? 0).round(),
        durationS: ((map['duration_s'] as num?) ?? 0).round(),
        profile: (map['profile'] as String?) ?? 'walking',
      );
    } catch (e) {
      // 4xx(403/404 포함)/네트워크 오류 — 라인은 직선 폴백으로 항상 그려지므로
      // 사용자에게 노출하지 않고 조용히 skip.
      debugPrint('[RouteSource] route fetch failed: $e');
      return null;
    }
  }
}

class DayRoute {
  const DayRoute({
    required this.coordinates,
    required this.distanceM,
    required this.durationS,
    required this.profile,
  });

  /// [[lng, lat], ...] — GeoJSON LineString 좌표.
  final List<List<double>> coordinates;
  final int distanceM;
  final int durationS;
  final String profile; // 'walking' | 'driving'
}
