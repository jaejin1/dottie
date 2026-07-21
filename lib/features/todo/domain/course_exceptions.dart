class JoinCourseException implements Exception {
  const JoinCourseException(this.code);
  final String code;

  @override
  String toString() => switch (code) {
        'COURSE_ALREADY_MEMBER' => '이미 참여 중인 코스예요.',
        'COURSE_FULL' => '코스 정원이 꽉 찼어요.',
        'INVALID_INVITE_CODE' => '초대 코드가 만료됐거나 올바르지 않아요.',
        'INVITE_EXPIRED' => '초대 코드가 만료됐어요.',
        'COURSE_NOT_FOUND' => '코스를 찾을 수 없어요.',
        _ => '코스 참여에 실패했어요.',
      };
}

class LeaveCourseException implements Exception {
  const LeaveCourseException(this.code);
  final String code;

  @override
  String toString() => switch (code) {
        'OWNER_CANNOT_LEAVE' => '코스 소유자는 나갈 수 없어요. 코스를 삭제해 주세요.',
        _ => '코스 나가기에 실패했어요.',
      };
}

class KickCourseMemberException implements Exception {
  const KickCourseMemberException(this.code);
  final String code;

  @override
  String toString() => switch (code) {
        'FORBIDDEN' => '소유자만 멤버를 내보낼 수 있어요.',
        'CANNOT_KICK_SELF' => '자기 자신은 내보낼 수 없어요.',
        'CANNOT_KICK_OWNER' => '소유자는 강퇴할 수 없어요.',
        'MEMBER_NOT_FOUND' => '이미 코스에 없는 멤버예요.',
        'COURSE_NOT_FOUND' => '코스를 찾을 수 없어요.',
        _ => '멤버 내보내기에 실패했어요.',
      };
}

class GenerateCourseInviteException implements Exception {
  const GenerateCourseInviteException(this.code);
  final String code;

  @override
  String toString() => switch (code) {
        'FORBIDDEN' => '소유자만 초대 코드를 만들 수 있어요.',
        'COURSE_NOT_FOUND' => '코스를 찾을 수 없어요.',
        _ => '초대 코드 생성에 실패했어요.',
      };
}
