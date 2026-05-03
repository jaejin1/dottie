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
