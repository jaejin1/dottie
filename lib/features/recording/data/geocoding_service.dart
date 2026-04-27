import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/config/app_config.dart';

part 'geocoding_service.g.dart';

class GeocodingResult {
  const GeocodingResult({
    required this.placeName,
    this.placeCategory,
  });
  final String placeName;
  final String? placeCategory; // cafe, restaurant, park 등
}

class GeocodingService {
  GeocodingService(this._dio);
  final Dio _dio;

  /// Mapbox Reverse Geocoding API로 좌표 → 장소명 변환
  Future<GeocodingResult?> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await _dio.get(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$longitude,$latitude.json',
        queryParameters: {
          'access_token': AppConfig.mapboxAccessToken,
          'language': 'ko',
          'types': 'poi,address',
          'limit': 1,
        },
      );

      final features = response.data['features'] as List?;
      if (features == null || features.isEmpty) return null;

      final feature = features.first as Map<String, dynamic>;
      final placeName = feature['place_name'] as String? ?? '';

      // POI category 추출 (maki 필드 활용)
      final properties = feature['properties'] as Map<String, dynamic>?;
      final maki = properties?['maki'] as String?;
      final category = _mapMakiToCategory(maki);

      // 장소명에서 간략한 이름만 추출 (첫 번째 쉼표 이전)
      final shortName = placeName.split(',').first.trim();

      return GeocodingResult(
        placeName: shortName.isNotEmpty ? shortName : placeName,
        placeCategory: category,
      );
    } catch (_) {
      return null;
    }
  }

  String? _mapMakiToCategory(String? maki) {
    if (maki == null) return null;
    const map = {
      'cafe': 'cafe',
      'coffee': 'cafe',
      'restaurant': 'restaurant',
      'fast-food': 'restaurant',
      'food': 'restaurant',
      'park': 'park',
      'hospital': 'hospital',
      'gym': 'gym',
      'shop': 'shop',
      'convenience': 'shop',
    };
    return map[maki];
  }
}

@riverpod
GeocodingService geocodingService(Ref ref) =>
    GeocodingService(Dio());
