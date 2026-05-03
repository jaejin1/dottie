import 'package:freezed_annotation/freezed_annotation.dart';
import '../../map_animation/domain/animation_frame.dart';

part 'shared_map_model.freezed.dart';

@freezed
class MemberTrack with _$MemberTrack {
  const factory MemberTrack({
    required String memberId,
    required String nickname,
    required String colorKey,
    required AnimationSequence sequence,
  }) = _MemberTrack;
}

@freezed
class CharacterPosition with _$CharacterPosition {
  const factory CharacterPosition({
    required String memberId,
    required String colorKey,
    required double lat,
    required double lng,
    required CharacterState state,
  }) = _CharacterPosition;
}

@freezed
class MeetingEvent with _$MeetingEvent {
  const factory MeetingEvent({
    required String memberIdA,
    required String memberIdB,
    required double lat,
    required double lng,
  }) = _MeetingEvent;
}
