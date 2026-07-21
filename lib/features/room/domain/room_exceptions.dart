class ShareDayLogException implements Exception {
  const ShareDayLogException(this.code);
  final String code; // 'ALREADY_SHARED' | 'DAY_LOG_NOT_FOUND' | 'FORBIDDEN'

  @override
  String toString() => switch (code) {
        'ALREADY_SHARED' => '이미 이 방에 공유된 기록이에요.',
        'DAY_LOG_NOT_FOUND' => '기록을 찾을 수 없어요. 앱을 재시작 후 다시 시도해 주세요.',
        'FORBIDDEN' => '본인 기록만 공유할 수 있어요.',
        _ => '공유에 실패했어요.',
      };
}

class LeaveRoomException implements Exception {
  const LeaveRoomException(this.code);
  final String code; // 'OWNER_CANNOT_LEAVE'

  @override
  String toString() => switch (code) {
        'OWNER_CANNOT_LEAVE' => '방장은 나갈 수 없어요. 방을 삭제해 주세요.',
        _ => '방 나가기에 실패했어요.',
      };
}

class KickMemberException implements Exception {
  const KickMemberException(this.code);
  final String code;
  // 'FORBIDDEN' | 'CANNOT_KICK_SELF' | 'CANNOT_KICK_OWNER' |
  // 'ROOM_NOT_FOUND' | 'MEMBER_NOT_FOUND'

  @override
  String toString() => switch (code) {
        'FORBIDDEN' => '방장만 멤버를 내보낼 수 있어요.',
        'CANNOT_KICK_SELF' => '자기 자신은 내보낼 수 없어요. 방 나가기를 사용해 주세요.',
        'CANNOT_KICK_OWNER' => '방장은 내보낼 수 없어요.',
        'ROOM_NOT_FOUND' => '방을 찾을 수 없어요.',
        'MEMBER_NOT_FOUND' => '이미 방에 없는 멤버예요.',
        _ => '멤버 내보내기에 실패했어요.',
      };
}

class JoinRoomException implements Exception {
  const JoinRoomException(this.code);
  final String code;
  // 'ROOM_ALREADY_MEMBER' | 'ROOM_FULL' | 'INVALID_INVITE_CODE' | 'ROOM_NOT_FOUND'

  @override
  String toString() => switch (code) {
        'ROOM_ALREADY_MEMBER' => '이미 참여 중인 방이에요.',
        'ROOM_FULL' => '방 정원이 꽉 찼어요.',
        'INVALID_INVITE_CODE' => '초대 코드가 만료됐거나 올바르지 않아요.',
        'ROOM_NOT_FOUND' => '방을 찾을 수 없어요.',
        _ => '방 참여에 실패했어요.',
      };
}

/// 방 이름 변경 4xx 에러.
class RenameRoomException implements Exception {
  const RenameRoomException(this.code);
  final String code; // 'BAD_REQUEST' | 'FORBIDDEN' | 'ROOM_NOT_FOUND'

  @override
  String toString() => switch (code) {
        'BAD_REQUEST' => '방 이름은 1자 이상 50자 이하로 입력해 주세요.',
        'FORBIDDEN' => '방장만 이름을 바꿀 수 있어요.',
        'ROOM_NOT_FOUND' => '방을 찾을 수 없어요.',
        _ => '방 이름 변경에 실패했어요.',
      };
}
