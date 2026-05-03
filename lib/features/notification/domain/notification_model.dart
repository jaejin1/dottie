import 'package:flutter/foundation.dart';

enum NotificationType { comment, mention }

@immutable
class AppNotification {
  final String id;
  final NotificationType type;
  final String actorId;
  final String actorNickname;
  /// 알림 액터(댓글/멘션 작성자)의 정체성 색 키. BE `actor_color`.
  /// 5색 프리셋. 미설정/탈퇴 시 BE가 'blue' 폴백.
  final String actorColorKey;
  final String? dotId;
  final String? roomId;
  /// dot이 속한 day_log의 날짜 (`YYYY-MM-DD`).
  /// dot이 없는 알림(room_invite 등)은 null.
  final String? dotDate;
  final String? commentPreview;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.actorId,
    required this.actorNickname,
    this.actorColorKey = 'blue',
    this.dotId,
    this.roomId,
    this.dotDate,
    this.commentPreview,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final type = typeStr == 'mention'
        ? NotificationType.mention
        : NotificationType.comment;

    return AppNotification(
      id: json['id'] as String,
      type: type,
      actorId: json['actor_id'] as String,
      actorNickname: json['actor_nickname'] as String,
      actorColorKey: (json['actor_color'] as String?) ?? 'blue',
      dotId: json['dot_id'] as String?,
      roomId: json['room_id'] as String?,
      dotDate: json['dot_date'] as String?,
      commentPreview: json['comment_preview'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      actorId: actorId,
      actorNickname: actorNickname,
      actorColorKey: actorColorKey,
      dotId: dotId,
      roomId: roomId,
      dotDate: dotDate,
      commentPreview: commentPreview,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
