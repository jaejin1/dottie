import 'package:freezed_annotation/freezed_annotation.dart';

import '../../cumulative_map/domain/place.dart';

part 'todo_item_model.freezed.dart';
part 'todo_item_model.g.dart';

/// 할일 1건 — 가야 할 장소 1개.
///
/// 체크인되면 checkInDotId 에 정상 Dot.id 가 들어가 trail 에 자동 편입.
/// PlanItem 자체는 보존돼 회고 시 "계획 vs 실제" 비교 가능.
@freezed
class TodoItem with _$TodoItem {
  const factory TodoItem({
    required String id,
    @JsonKey(name: 'todo_list_id') required String todoListId,
    required double latitude,
    required double longitude,
    @JsonKey(name: 'place_name') String? placeName,
    @JsonKey(name: 'place_category') String? placeCategory,
    @JsonKey(name: 'place_id') String? placeId,

    /// 참고용 시간 — 미설정 시 null. 정렬에 영향 없음.
    @JsonKey(name: 'planned_at') DateTime? plannedAt,

    /// startDate 기준 0,1,2... 인덱스. plannedAt 으로 계산 가능하지만
    /// UI 그룹화 효율을 위해 비정규화 저장.
    @JsonKey(name: 'day_index') @Default(0) int dayIndex,

    /// 같은 일 내 정렬 순서 (드래그 재정렬).
    @JsonKey(name: 'order_in_day') @Default(0) int orderInDay,

    String? notes,
    String? emotion,

    /// 체크인 성공 시 생성된 Dot.id (약한 참조).
    @JsonKey(name: 'check_in_dot_id') String? checkInDotId,
    @JsonKey(name: 'checked_in_at') DateTime? checkedInAt,

    /// 즐겨찾기 고정 여부.
    @JsonKey(name: 'is_pinned') @Default(false) bool isPinned,

    /// 핀 고정 순서 (낮을수록 위에 표시).
    @JsonKey(name: 'pin_order') @Default(0) int pinOrder,

    /// 계획 시점 첨부 이미지 (선택).
    @JsonKey(name: 'photo_url') String? photoUrl,

    /// place_id 조인 장소 상세 (주소/전화/카카오맵 링크) — BE GetList 가 embed.
    Place? place,

    @Default(false) bool synced,
  }) = _TodoItem;

  factory TodoItem.fromJson(Map<String, dynamic> json) =>
      _$TodoItemFromJson(json);
}

extension TodoItemX on TodoItem {
  bool get isCheckedIn => checkInDotId != null;

  /// 체크인 가능 — 미체크인 상태면 언제든.
  ///
  /// "갈곳 모음" 으로 피벗되면서 *planned date 도래* 게이트 제거됨.
  /// 사용자는 등록한 갈곳에 *언제든* 도착 인증 가능. 기간 picker 다시 도입 시
  /// 이 조건 재검토.
  bool get canCheckIn => !isCheckedIn;

  /// 오늘 일정. (기간 picker 재도입 시 활용 — 현재 호출처 없음)
  bool get isToday {
    if (plannedAt == null) return false;
    final today = DateTime.now();
    final p = plannedAt!.toLocal();
    return today.year == p.year &&
        today.month == p.month &&
        today.day == p.day;
  }
}
