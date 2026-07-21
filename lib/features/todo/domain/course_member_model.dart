import 'package:freezed_annotation/freezed_annotation.dart';
import '../../auth/domain/user_model.dart';

part 'course_member_model.freezed.dart';
part 'course_member_model.g.dart';

@freezed
class CourseMember with _$CourseMember {
  const factory CourseMember({
    @JsonKey(name: 'user_id') required String userId,
    required String nickname,
    @JsonKey(name: 'character_config') @Default(CharacterConfig()) CharacterConfig character,
    @JsonKey(name: 'profile_image') String? profileImage,
    @JsonKey(name: 'joined_at') required DateTime joinedAt,
    @Default('member') String role,
  }) = _CourseMember;

  factory CourseMember.fromJson(Map<String, dynamic> json) =>
      _$CourseMemberFromJson(json);
}

extension CourseMemberX on CourseMember {
  bool get isOwner => role == 'owner';
  bool get isViewer => role == 'viewer';
}
