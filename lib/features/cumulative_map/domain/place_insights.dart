import 'package:freezed_annotation/freezed_annotation.dart';

import '../../character/paperdoll/domain/paperdoll_config.dart';
import 'place.dart';

part 'place_insights.freezed.dart';
part 'place_insights.g.dart';

/// B10 — 장소 인사이트 응답.
@freezed
class PlaceInsights with _$PlaceInsights {
  const factory PlaceInsights({
    required Place place,
    @Default([]) List<PlaceVisitor> visitors,
  }) = _PlaceInsights;

  factory PlaceInsights.fromJson(Map<String, dynamic> json) =>
      _$PlaceInsightsFromJson(json);
}

/// 장소별 멤버 방문 통계.
@freezed
class PlaceVisitor with _$PlaceVisitor {
  const factory PlaceVisitor({
    @JsonKey(name: 'user_id') required String userId,
    required String nickname,
    @JsonKey(name: 'character_config')
    @Default(PaperdollConfig.defaults)
    PaperdollConfig characterConfig,
    @JsonKey(name: 'visit_count') required int visitCount,
    @JsonKey(name: 'first_visited_at') required DateTime firstVisitedAt,
    @JsonKey(name: 'last_visited_at') required DateTime lastVisitedAt,
  }) = _PlaceVisitor;

  factory PlaceVisitor.fromJson(Map<String, dynamic> json) =>
      _$PlaceVisitorFromJson(json);
}
