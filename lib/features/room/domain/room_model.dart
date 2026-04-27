import 'package:freezed_annotation/freezed_annotation.dart';
import '../../auth/domain/user_model.dart';

part 'room_model.freezed.dart';
part 'room_model.g.dart';

@freezed
class Room with _$Room {
  const factory Room({
    required String id,
    required String name,
    required String ownerId,
    @Default([]) List<RoomMember> members,
    required DateTime createdAt,
    String? inviteCode,
  }) = _Room;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}

@freezed
class RoomMember with _$RoomMember {
  const factory RoomMember({
    required String userId,
    required String nickname,
    required CharacterConfig character,
    required DateTime joinedAt,
  }) = _RoomMember;

  factory RoomMember.fromJson(Map<String, dynamic> json) =>
      _$RoomMemberFromJson(json);
}
