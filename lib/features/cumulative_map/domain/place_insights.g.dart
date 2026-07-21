// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_insights.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlaceInsightsImpl _$$PlaceInsightsImplFromJson(Map<String, dynamic> json) =>
    _$PlaceInsightsImpl(
      place: Place.fromJson(json['place'] as Map<String, dynamic>),
      visitors:
          (json['visitors'] as List<dynamic>?)
              ?.map((e) => PlaceVisitor.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$PlaceInsightsImplToJson(_$PlaceInsightsImpl instance) =>
    <String, dynamic>{'place': instance.place, 'visitors': instance.visitors};

_$PlaceVisitorImpl _$$PlaceVisitorImplFromJson(Map<String, dynamic> json) =>
    _$PlaceVisitorImpl(
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      characterConfig: json['character_config'] == null
          ? PaperdollConfig.defaults
          : PaperdollConfig.fromJson(
              json['character_config'] as Map<String, dynamic>,
            ),
      visitCount: (json['visit_count'] as num).toInt(),
      firstVisitedAt: DateTime.parse(json['first_visited_at'] as String),
      lastVisitedAt: DateTime.parse(json['last_visited_at'] as String),
    );

Map<String, dynamic> _$$PlaceVisitorImplToJson(_$PlaceVisitorImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'nickname': instance.nickname,
      'character_config': instance.characterConfig,
      'visit_count': instance.visitCount,
      'first_visited_at': instance.firstVisitedAt.toIso8601String(),
      'last_visited_at': instance.lastVisitedAt.toIso8601String(),
    };
