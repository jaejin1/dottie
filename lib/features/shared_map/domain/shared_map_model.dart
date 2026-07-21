import 'package:freezed_annotation/freezed_annotation.dart';
import '../../map_animation/domain/animation_frame.dart';

part 'shared_map_model.freezed.dart';

@freezed
class MemberTrack with _$MemberTrack {
  const factory MemberTrack({
    required String memberId,
    required String nickname,
    required String colorHex,
    required AnimationSequence sequence,
  }) = _MemberTrack;
}

@freezed
class CharacterPosition with _$CharacterPosition {
  const factory CharacterPosition({
    required String memberId,
    required String colorHex,
    required double lat,
    required double lng,
    required CharacterState state,
  }) = _CharacterPosition;
}

/// N명 그룹 인카운터. user_ids 와 dot_ids 는 같은 순서/길이 (i 번째 사용자의
/// 매칭 dot 이 dot_ids[i]). 최소 2명, 상한 없음.
/// 클라이언트 측 detectMeetings 가 만든 것은 startedAt/duration 등 메타가 null.
@freezed
class MeetingEvent with _$MeetingEvent {
  const factory MeetingEvent({
    required List<String> userIds,
    required double lat,
    required double lng,
    // BE 보강 필드 (클라이언트 detect 는 null/빈 list)
    DateTime? startedAt,
    int? durationMinutes,
    String? placeName,
    @Default([]) List<String> dotIds,
    double? maxDistanceM,
  }) = _MeetingEvent;
}
