import 'package:freezed_annotation/freezed_annotation.dart';
import '../../auth/domain/user_model.dart';

part 'room_model.freezed.dart';
part 'room_model.g.dart';

@freezed
class Room with _$Room {
  const factory Room({
    required String id,
    required String name,
    @JsonKey(name: 'owner_id') required String ownerId,
    @Default([]) List<RoomMember> members,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'invite_code') String? inviteCode,
    @JsonKey(name: 'shared_dates') @Default([]) List<String> sharedDates,

    /// 자동 공유 — 새로 찍은 dot 의 day_log 가 이 룸에 자동 share 되는지.
    /// 디폴트 false (프라이버시 우선 — 사용자가 명시적으로 켜야 자동 공유).
    /// 룸별 / 사용자별 독립 설정 — 다른 멤버에게 영향 없음.
    @JsonKey(name: 'auto_share') @Default(false) bool autoShare,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}

@freezed
class RoomMember with _$RoomMember {
  const factory RoomMember({
    @JsonKey(name: 'user_id') required String userId,
    required String nickname,
    @JsonKey(name: 'character_config') @Default(CharacterConfig()) CharacterConfig character,
    @JsonKey(name: 'joined_at') required DateTime joinedAt,
  }) = _RoomMember;

  factory RoomMember.fromJson(Map<String, dynamic> json) =>
      _$RoomMemberFromJson(json);
}
