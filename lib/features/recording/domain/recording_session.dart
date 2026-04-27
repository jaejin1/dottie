import 'package:freezed_annotation/freezed_annotation.dart';
import 'dot_model.dart';

part 'recording_session.freezed.dart';

@freezed
class RecordingSession with _$RecordingSession {
  const factory RecordingSession({
    required String dayLogId,
    required DateTime startedAt,
    @Default([]) List<Dot> dots,
    @Default(false) bool isCapturingLocation,
    String? error,
  }) = _RecordingSession;
}
