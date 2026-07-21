import 'package:freezed_annotation/freezed_annotation.dart';

part 'place.freezed.dart';
part 'place.g.dart';

/// BE 의 places 테이블 응답. dot 에 inline 으로 들어오기도 함.
/// (B8 — `/v1/places/search` + dot 응답 inline.)
///
/// 카카오 API 출처 필드:
///   - `category` (풀패스, 예: "음식점 > 카페 > 커피전문점")
///   - `category_group_code` (예: CE7=카페, FD6=음식점, AT4=관광명소) — UI 아이콘/필터
///   - `category_group_name` (짧은 이름, 예: "카페")
///   - `place_url` (카카오맵 딥링크)
///   - `distance` (좌표 기반 검색 시 거리 m. 좌표 미전달 시 null)
@freezed
class Place with _$Place {
  const factory Place({
    required String id,
    required String name,
    String? category,
    @JsonKey(name: 'category_group_code') String? categoryGroupCode,
    @JsonKey(name: 'category_group_name') String? categoryGroupName,
    String? address,
    @JsonKey(name: 'road_address') String? roadAddress,
    String? telephone,
    @JsonKey(name: 'place_url') String? placeUrl,
    int? distance,
    required double latitude,
    required double longitude,
  }) = _Place;

  factory Place.fromJson(Map<String, dynamic> json) => _$PlaceFromJson(json);
}
