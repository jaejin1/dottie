import 'package:freezed_annotation/freezed_annotation.dart';

part 'dot_model.freezed.dart';
part 'dot_model.g.dart';

@freezed
class Dot with _$Dot {
  const factory Dot({
    required String id,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    String? placeName,
    String? placeCategory,
    String? photoUrl,
    String? memo,
    String? emotion,
    required String dayLogId,
    @Default(false) bool synced,
  }) = _Dot;

  factory Dot.fromJson(Map<String, dynamic> json) => _$DotFromJson(json);
}
