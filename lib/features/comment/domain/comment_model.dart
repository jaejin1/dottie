import 'package:flutter/foundation.dart';

@immutable
class MentionSpan {
  final String userId;
  final String nickname;
  /// 멘션 대상 사용자의 정체성 색 hex (BE `color_hex`).
  /// 색 미설정/탈퇴 사용자는 default(`#7EB8F7`).
  final String colorHex;
  final int start;
  final int end;

  const MentionSpan({
    required this.userId,
    required this.nickname,
    this.colorHex = '#7EB8F7',
    required this.start,
    required this.end,
  });

  factory MentionSpan.fromJson(Map<String, dynamic> json) {
    return MentionSpan(
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      colorHex: (json['color_hex'] as String?) ?? '#7EB8F7',
      start: json['start'] as int,
      end: json['end'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'nickname': nickname,
      'color_hex': colorHex,
      'start': start,
      'end': end,
    };
  }
}

@immutable
class DotComment {
  final String id;
  final String dotId;
  /// 댓글이 공유된 룸 ID 목록. 하나의 댓글이 여러 룸에 동시 귀속 가능.
  final List<String> roomIds;
  final String authorId;
  final String authorNickname;
  /// 작성자 정체성 색 hex (BE `author_color_hex`). default `#7EB8F7`.
  final String authorColorHex;
  final String content;
  final List<MentionSpan> mentions;
  final DateTime createdAt;

  const DotComment({
    required this.id,
    required this.dotId,
    this.roomIds = const [],
    required this.authorId,
    required this.authorNickname,
    this.authorColorHex = '#7EB8F7',
    required this.content,
    required this.mentions,
    required this.createdAt,
  });

  factory DotComment.fromJson(Map<String, dynamic> json) {
    final mentionsList = (json['mentions'] as List<dynamic>? ?? [])
        .map((e) => MentionSpan.fromJson(e as Map<String, dynamic>))
        .toList();
    // room_ids 배열 우선, 없으면 legacy room_id 단일값 폴백.
    final roomIds = json['room_ids'] != null
        ? (json['room_ids'] as List).cast<String>()
        : (json['room_id'] != null ? [json['room_id'] as String] : <String>[]);
    return DotComment(
      id: json['id'] as String,
      dotId: json['dot_id'] as String,
      roomIds: roomIds,
      authorId: json['author_id'] as String,
      authorNickname: json['author_nickname'] as String,
      authorColorHex: (json['author_color_hex'] as String?) ?? '#7EB8F7',
      content: json['content'] as String,
      mentions: mentionsList,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
