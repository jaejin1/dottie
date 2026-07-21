import 'dart:math' as math;

import '../domain/place_group.dart';
import '../domain/room_dot.dart';

/// dot → PlaceGroup. 세 단계:
/// 1. **place_id 가 있는 dot**: 같은 place_id 끼리 묶음 (정확 — BE B8 매칭).
/// 2. **place_id 없는 dot 의 인접 합류**: place 그룹 centroid 50m 안이면
///    그 place 그룹에 흡수 (예전 주소 기반 dot 이 같은 장소 신규 dot 과 합쳐짐).
/// 3. **여전히 place_id 없는 dot**: 50m 좌표 union-find 폴백.
class PlaceGrouper {
  PlaceGrouper._();

  static const double _radiusM = 50.0;
  static const double _bucketSizeDeg = 0.001; // 약 100m at lat 37.5

  static List<PlaceGroup> group(List<RoomDot> dots) {
    if (dots.isEmpty) return const [];

    // 1. place_id 별 그룹화
    final byPlaceId = <String, List<RoomDot>>{};
    final withoutPlaceId = <RoomDot>[];
    for (final rd in dots) {
      final pid = rd.dot.placeId;
      if (pid != null && pid.isNotEmpty) {
        byPlaceId.putIfAbsent(pid, () => []).add(rd);
      } else {
        withoutPlaceId.add(rd);
      }
    }

    // 2. 각 place 그룹의 대표 좌표 (BE place 객체 우선, 없으면 평균)
    final placeCenters = <String, _LatLng>{};
    for (final entry in byPlaceId.entries) {
      final groupDots = entry.value;
      // BE place 객체에 정확한 place 좌표가 있으면 그것 사용
      final withPlace = groupDots.firstWhere(
        (rd) => rd.dot.place != null,
        orElse: () => groupDots.first,
      );
      double lat, lng;
      if (withPlace.dot.place != null) {
        lat = withPlace.dot.place!.latitude;
        lng = withPlace.dot.place!.longitude;
      } else {
        lat = groupDots
                .map((rd) => rd.dot.latitude)
                .reduce((a, b) => a + b) /
            groupDots.length;
        lng = groupDots
                .map((rd) => rd.dot.longitude)
                .reduce((a, b) => a + b) /
            groupDots.length;
      }
      placeCenters[entry.key] = _LatLng(lat, lng);
    }

    // 3. place_id 없는 dot 들 — 가장 가까운 place 그룹 centroid 50m 안이면 합류.
    //    (예전에 주소 기반으로 찍은 dot 이 같은 장소 신규 dot 과 자연 통합.)
    final stillOrphan = <RoomDot>[];
    for (final rd in withoutPlaceId) {
      String? bestPid;
      double bestDist = double.infinity;
      placeCenters.forEach((pid, center) {
        final d = _distanceM(
            rd.dot.latitude, rd.dot.longitude, center.lat, center.lng);
        if (d <= _radiusM && d < bestDist) {
          bestDist = d;
          bestPid = pid;
        }
      });
      if (bestPid != null) {
        byPlaceId[bestPid!]!.add(rd);
      } else {
        stillOrphan.add(rd);
      }
    }

    // 4. 결과 빌드
    final allMemberIds = dots.map((d) => d.memberId).toSet();
    final result = <PlaceGroup>[];
    for (final entry in byPlaceId.entries) {
      result.add(_buildGroup(
        id: 'place-${entry.key}',
        dots: entry.value,
        allMemberIds: allMemberIds,
      ));
    }
    if (stillOrphan.isNotEmpty) {
      result.addAll(_clusterByCoord(stillOrphan, allMemberIds));
    }

    return result;
  }

  static PlaceGroup _buildGroup({
    required String id,
    required List<RoomDot> dots,
    required Set<String> allMemberIds,
  }) {
    final sorted = [...dots]
      ..sort((a, b) => b.dot.timestamp.compareTo(a.dot.timestamp));
    final lats = sorted.map((rd) => rd.dot.latitude).toList();
    final lngs = sorted.map((rd) => rd.dot.longitude).toList();
    final centerLat = lats.reduce((a, b) => a + b) / lats.length;
    final centerLng = lngs.reduce((a, b) => a + b) / lngs.length;
    final memberIds = sorted.map((rd) => rd.memberId).toSet();
    // BE place 객체 우선, 없으면 dot.placeName
    final placeName = sorted
            .map((rd) => rd.dot.place?.name)
            .where((n) => n != null && n.isNotEmpty)
            .firstOrNull ??
        sorted
            .map((rd) => rd.dot.placeName)
            .where((n) => n != null && n.isNotEmpty)
            .firstOrNull ??
        '';
    final category = sorted
            .map((rd) => rd.dot.place?.category)
            .where((c) => c != null && c.isNotEmpty)
            .firstOrNull ??
        sorted
            .map((rd) => rd.dot.placeCategory)
            .where((c) => c != null && c.isNotEmpty)
            .firstOrNull;
    final firstVisitedAt = sorted.last.dot.timestamp;
    final isFirstTogether =
        memberIds.length == allMemberIds.length && allMemberIds.length >= 2;
    return PlaceGroup(
      id: id,
      dots: sorted,
      centerLat: centerLat,
      centerLng: centerLng,
      memberIds: memberIds,
      placeName: placeName,
      category: category,
      firstVisitedAt: firstVisitedAt,
      visitCount: sorted.length, // orphan group — dots 수가 곧 방문 수
      isFirstTogether: isFirstTogether,
    );
  }

  /// place_id 없는 dot 들에 대한 fallback — 좌표 union-find.
  static List<PlaceGroup> _clusterByCoord(
      List<RoomDot> dots, Set<String> allMemberIds) {
    if (dots.isEmpty) return const [];

    final buckets = <String, List<int>>{};
    String keyOf(double lat, double lng) {
      final bx = (lng / _bucketSizeDeg).floor();
      final by = (lat / _bucketSizeDeg).floor();
      return '$bx:$by';
    }

    for (var i = 0; i < dots.length; i++) {
      final d = dots[i].dot;
      buckets.putIfAbsent(keyOf(d.latitude, d.longitude), () => []).add(i);
    }

    final parent = List<int>.generate(dots.length, (i) => i);
    int find(int x) {
      while (parent[x] != x) {
        parent[x] = parent[parent[x]];
        x = parent[x];
      }
      return x;
    }

    void union(int a, int b) {
      final ra = find(a);
      final rb = find(b);
      if (ra != rb) parent[ra] = rb;
    }

    for (final entry in buckets.entries) {
      final parts = entry.key.split(':');
      final bx = int.parse(parts[0]);
      final by = int.parse(parts[1]);
      final neighborIndices = <int>[];
      for (var dx = -1; dx <= 1; dx++) {
        for (var dy = -1; dy <= 1; dy++) {
          final nb = buckets['${bx + dx}:${by + dy}'];
          if (nb != null) neighborIndices.addAll(nb);
        }
      }
      final selfIdxs = entry.value;
      for (final i in selfIdxs) {
        for (final j in neighborIndices) {
          if (j <= i) continue;
          final di = dots[i].dot;
          final dj = dots[j].dot;
          if (_distanceM(di.latitude, di.longitude, dj.latitude, dj.longitude) <=
              _radiusM) {
            union(i, j);
          }
        }
      }
    }

    final groups = <int, List<int>>{};
    for (var i = 0; i < dots.length; i++) {
      groups.putIfAbsent(find(i), () => []).add(i);
    }

    return groups.entries
        .map((entry) => _buildGroup(
              id: 'coord-${entry.key}',
              dots: entry.value.map((i) => dots[i]).toList(),
              allMemberIds: allMemberIds,
            ))
        .toList();
  }

  // Haversine — meters
  static double _distanceM(double lat1, double lng1, double lat2, double lng2) {
    const r = 6371000.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLng = _deg2rad(lng2 - lng1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _deg2rad(double d) => d * (math.pi / 180);
}

class _LatLng {
  const _LatLng(this.lat, this.lng);
  final double lat;
  final double lng;
}
