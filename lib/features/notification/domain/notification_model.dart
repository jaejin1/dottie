import 'package:flutter/foundation.dart';
import '../../../core/utils/date_utils.dart';

enum NotificationType {
  comment,
  mention,
  /// 같은 룸의 다른 사용자가 오늘 첫 dot 을 남겼고, 수신자는 아직 오늘 dot 이
  /// 없을 때 — "회원님도 남겨보세요" 톤의 활동 환기 알림.
  dotCreated,
}

@immutable
class AppNotification {
  final String id;
  final NotificationType type;
  final String actorId;
  final String actorNickname;
  /// 알림 액터(댓글/멘션 작성자)의 정체성 색 hex. BE `actor_color_hex`.
  /// 미설정/탈퇴 시 BE가 default(`#7EB8F7`) 폴백.
  final String actorColorHex;
  final String? dotId;
  final String? roomId;
  /// dot이 속한 day_log의 날짜 (`YYYY-MM-DD`).
  /// dot이 없는 알림(room_invite 등)은 null.
  final String? dotDate;
  final String? commentPreview;
  final bool isRead;
  final DateTime createdAt;
  /// FE 합성 필드 — 같은 dedupKey 로 접힌 다른 알림 row 의 id 목록.
  /// BE 응답에는 없으며 [markRead] 시 함께 읽음 처리하기 위해 쓰인다.
  final List<String> collapsedIds;

  const AppNotification({
    required this.id,
    required this.type,
    required this.actorId,
    required this.actorNickname,
    this.actorColorHex = '#7EB8F7',
    this.dotId,
    this.roomId,
    this.dotDate,
    this.commentPreview,
    required this.isRead,
    required this.createdAt,
    this.collapsedIds = const [],
  });

  /// 같은 사용자가 여러 room 을 공유할 때 BE 가 room 마다 만드는 중복
  /// `dotCreated` 알림을 접기 위한 key. roomId 는 의도적으로 제외 —
  /// actor 가 같은 날 남긴 첫 dot 은 어느 room 에서 왔든 동일 알림으로 취급.
  String get dedupKey =>
      '${type.name}|$actorId|${dotDate ?? DottieDateUtils.toDateString(createdAt)}';

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final type = switch (typeStr) {
      'mention' => NotificationType.mention,
      'dot_created' => NotificationType.dotCreated,
      _ => NotificationType.comment,
    };

    return AppNotification(
      id: json['id'] as String,
      type: type,
      actorId: json['actor_id'] as String,
      actorNickname: json['actor_nickname'] as String,
      actorColorHex: (json['actor_color_hex'] as String?) ?? '#7EB8F7',
      dotId: json['dot_id'] as String?,
      roomId: json['room_id'] as String?,
      dotDate: json['dot_date'] as String?,
      commentPreview: json['comment_preview'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  AppNotification copyWith({bool? isRead, List<String>? collapsedIds}) {
    return AppNotification(
      id: id,
      type: type,
      actorId: actorId,
      actorNickname: actorNickname,
      actorColorHex: actorColorHex,
      dotId: dotId,
      roomId: roomId,
      dotDate: dotDate,
      commentPreview: commentPreview,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      collapsedIds: collapsedIds ?? this.collapsedIds,
    );
  }
}
