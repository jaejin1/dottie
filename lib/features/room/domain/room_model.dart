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
