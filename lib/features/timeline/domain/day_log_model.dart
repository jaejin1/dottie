import 'package:freezed_annotation/freezed_annotation.dart';
import '../../recording/domain/dot_model.dart';

part 'day_log_model.freezed.dart';
part 'day_log_model.g.dart';

@freezed
class DayLog with _$DayLog {
  const factory DayLog({
    required String id,
    required String userId,
    required DateTime date,
    @Default([]) List<Dot> dots,
    required DateTime startedAt,
    DateTime? endedAt,
    double? totalDistanceKm,
    int? placeCount,
    @Default(false) bool isRecording,
    @Default(false) bool synced,
  }) = _DayLog;

  factory DayLog.fromJson(Map<String, dynamic> json) =>
      _$DayLogFromJson(json);
}
