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
          final colorHex = colorByUserId[m.userId] ?? m.colorHex;
          return MemberTrack(
            memberId: m.userId,
            nickname: m.nickname,
            colorHex: colorHex,
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
        colorHex: t.colorHex,
        lat: interp.lat,
        lng: interp.lng,
        state: interp.state,
      );
    }).toList();
  }

  /// 모든 멤버를 **하나의 실제 시각 [t]** 에 동기화해 위치를 구한다.
  /// [interpolateAll] 은 각 멤버 시퀀스를 독립적으로 0~1 정규화하지만,
  /// 이 메서드는 공통 벽시계를 써서 "같은 시각에 각자 어디 있었나"를
  /// 정확히 재현한다. (재생 타이밍 정확화용)
  static List<CharacterPosition> interpolateAllAtTime(
    List<MemberTrack> tracks,
    DateTime t,
  ) {
    return tracks.map((track) {
      final interp = AnimationBuilder.interpolateAtTime(track.sequence, t);
      return CharacterPosition(
        memberId: track.memberId,
        colorHex: track.colorHex,
        lat: interp.lat,
        lng: interp.lng,
        state: interp.state,
      );
    }).toList();
  }

  /// 현재 progress에서 100m 이내 만남 이벤트 감지 (클라이언트 측, runtime).
  /// 단순 페어링 기반 — 그룹 인카운터는 BE encounters 응답이 담당.
  static List<MeetingEvent> detectMeetings(List<CharacterPosition> positions) {
    final meetings = <MeetingEvent>[];
    for (int i = 0; i < positions.length; i++) {
      for (int j = i + 1; j < positions.length; j++) {
        final a = positions[i];
        final b = positions[j];
        if (LocationUtils.isWithinRadius(
            a.lat, a.lng, b.lat, b.lng, 100)) {
          meetings.add(MeetingEvent(
            userIds: [a.memberId, b.memberId],
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
  String get colorHex => character.colorHex;
}
