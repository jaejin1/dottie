import '../../../core/utils/location_utils.dart';
import '../../map_animation/data/animation_builder.dart';
import '../../recording/domain/dot_model.dart';
import '../../room/domain/room_model.dart';
import '../domain/shared_map_model.dart';

class SharedMapBuilder {
  SharedMapBuilder._();

  /// 멤버별 dots → MemberTrack 목록 빌드
  static List<MemberTrack> build({
    required List<RoomMember> members,
    required Map<String, List<Dot>> dotsByMember,
    Map<String, String> colorByUserId = const {},
  }) {
    return members
        .where((m) => dotsByMember.containsKey(m.userId))
        .map((m) {
          final dots = dotsByMember[m.userId]!;
          final colorKey = colorByUserId[m.userId] ?? m.colorKey;
          return MemberTrack(
            memberId: m.userId,
            nickname: m.nickname,
            colorKey: colorKey,
            sequence: AnimationBuilder.build(dots),
          );
        })
        .toList();
  }

  /// 전체 progress(0~1)에서 모든 멤버의 현재 위치 반환
  static List<CharacterPosition> interpolateAll(
    List<MemberTrack> tracks,
    double progress,
  ) {
    return tracks.map((t) {
      final interp = AnimationBuilder.interpolate(t.sequence, progress);
      return CharacterPosition(
        memberId: t.memberId,
        colorKey: t.colorKey,
        lat: interp.lat,
        lng: interp.lng,
        state: interp.state,
      );
    }).toList();
  }

  /// 현재 progress에서 100m 이내 만남 이벤트 감지
  static List<MeetingEvent> detectMeetings(List<CharacterPosition> positions) {
    final meetings = <MeetingEvent>[];
    for (int i = 0; i < positions.length; i++) {
      for (int j = i + 1; j < positions.length; j++) {
        final a = positions[i];
        final b = positions[j];
        if (LocationUtils.isWithinRadius(
            a.lat, a.lng, b.lat, b.lng, 100)) {
          meetings.add(MeetingEvent(
            memberIdA: a.memberId,
            memberIdB: b.memberId,
            lat: (a.lat + b.lat) / 2,
            lng: (a.lng + b.lng) / 2,
          ));
        }
      }
    }
    return meetings;
  }

}

extension on RoomMember {
  String get colorKey => character.colorKey;
}
