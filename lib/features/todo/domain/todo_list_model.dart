import 'package:freezed_annotation/freezed_annotation.dart';

import 'course_member_model.dart';
import 'todo_item_model.dart';

part 'todo_list_model.freezed.dart';
part 'todo_list_model.g.dart';

List<String> _tagsFromJson(dynamic v) {
  if (v == null) return <String>[];
  if (v is List) return v.whereType<String>().toList();
  return <String>[];
}

List<String> _tagsToJson(List<String> v) => v;

/// 할일 묶음 — "코스" (여행 일정 or 상시 모음).
///
/// courseType:
///   'trip'       — 기간 있는 여행 코스. startDate/endDate 유효.
///   'collection' — 상시 모음. startDate/endDate 는 sentinel(now~now+50yr).
@freezed
class TodoList with _$TodoList {
  const factory TodoList({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    required String name,
    @JsonKey(name: 'cover_emoji') String? coverEmoji,
    @JsonKey(name: 'start_date') required DateTime startDate,
    @JsonKey(name: 'end_date') required DateTime endDate,
    @Default(<TodoItem>[]) List<TodoItem> items,
    @JsonKey(name: 'share_token') String? shareToken,
    @JsonKey(name: 'share_token_expires_at') DateTime? shareTokenExpiresAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @Default(false) bool synced,
    // 코스 유형 — BE 저장/반환 (course_type, 000021). 기본값 'trip'.
    @JsonKey(name: 'course_type', defaultValue: 'trip')
    @Default('trip')
    String courseType,
    // Phase 2 메타 (BE 동기화 예정)
    String? description,
    @JsonKey(fromJson: _tagsFromJson, toJson: _tagsToJson)
    @Default(<String>[])
    List<String> tags,
    @JsonKey(name: 'cover_image_url') String? coverImageUrl,
    @JsonKey(name: 'visibility', defaultValue: 'private')
    @Default('private')
    String visibility,
    // 다른 사람의 공유 코스를 import 한 경우 true (BE: is_imported). 하위호환 유지.
    @JsonKey(name: 'is_imported') @Default(false) bool isImported,
    // 협업 멤버 목록 — 소유자 포함. BE: members[].
    @JsonKey(name: 'members') @Default(<CourseMember>[]) List<CourseMember> members,
    // 현재 유효 초대 코드 — owner 에게만 값 있음. BE: invite_code.
    @JsonKey(name: 'invite_code') String? inviteCode,
    // 초대 코드 만료 시각. BE: invite_code_expires_at.
    @JsonKey(name: 'invite_code_expires_at') DateTime? inviteCodeExpiresAt,
    // 연결된 룸 ID — null이면 독립 스팟 리스트. BE: room_id.
    @JsonKey(name: 'room_id') String? roomId,
    // 스팟 탭 상단 고정. BE: is_pinned / pin_order.
    @JsonKey(name: 'is_pinned') @Default(false) bool isPinned,
    @JsonKey(name: 'pin_order') @Default(0) int pinOrder,
  }) = _TodoList;

  factory TodoList.fromJson(Map<String, dynamic> json) =>
      _$TodoListFromJson(json);
}

extension TodoListX on TodoList {
  bool get isTrip => courseType == 'trip';

  /// 공유 코스 여부 — 멤버가 2명 이상(소유자 + 1명).
  bool get isShared => members.length > 1;

  /// 현재 사용자의 role. 'owner' | 'member' | 'viewer'.
  String myRole(String? uid) {
    if (uid == null) return 'viewer';
    if (uid == ownerId) return 'owner';
    for (final m in members) {
      if (m.userId == uid) return m.role;
    }
    // 멤버 목록 미수신(오프라인) 시 과차단 방지 — 기본 member로.
    return 'member';
  }

  /// 편집 가능 여부 — viewer는 false.
  bool canEdit(String? uid) => myRole(uid) != 'viewer';

  /// startDate 기준 0,1,2... 인덱스에 해당하는 날짜. isTrip 일 때만 유효.
  DateTime dateForDayIndex(int dayIndex) {
    return DateTime(startDate.year, startDate.month, startDate.day)
        .add(Duration(days: dayIndex));
  }

  /// 전체 일자 수 (start, end 포함). isTrip 일 때만 유의미.
  int get totalDays {
    if (!isTrip) return 0;
    final s = DateTime(startDate.year, startDate.month, startDate.day);
    final e = DateTime(endDate.year, endDate.month, endDate.day);
    return e.difference(s).inDays + 1;
  }

  /// 오늘이 todo 기간 안에 들어와 있는가.
  bool get isActive {
    if (!isTrip) return true;
    final today = DateTime.now();
    final t = DateTime(today.year, today.month, today.day);
    final s = DateTime(startDate.year, startDate.month, startDate.day);
    final e = DateTime(endDate.year, endDate.month, endDate.day);
    return !t.isBefore(s) && !t.isAfter(e);
  }

  /// 종료 이후.
  bool get isPast {
    if (!isTrip) return false;
    final today = DateTime.now();
    final t = DateTime(today.year, today.month, today.day);
    final e = DateTime(endDate.year, endDate.month, endDate.day);
    return t.isAfter(e);
  }

  /// 아직 시작 안 함.
  bool get isFuture {
    if (!isTrip) return false;
    final today = DateTime.now();
    final t = DateTime(today.year, today.month, today.day);
    final s = DateTime(startDate.year, startDate.month, startDate.day);
    return t.isBefore(s);
  }

  /// 체크인 비율 (체크인 / 전체) — 진행상태 UI 표시용.
  double get checkInProgress {
    if (items.isEmpty) return 0.0;
    final checked = items.where((i) => i.isCheckedIn).length;
    return checked / items.length;
  }
}
