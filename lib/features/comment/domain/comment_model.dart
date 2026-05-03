import 'package:flutter/foundation.dart';

@immutable
class MentionSpan {
  final String userId;
  final String nickname;
  final String colorKey; // 5색 프리셋 키 — 색 미설정/탈퇴 사용자는 'blue' 폴백
  final int start;
  final int end;

  const MentionSpan({
    required this.userId,
    required this.nickname,
    this.colorKey = 'blue',
    required this.start,
    required this.end,
  });

  factory MentionSpan.fromJson(Map<String, dynamic> json) {
    return MentionSpan(
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      colorKey: (json['color'] as String?) ?? 'blue',
      start: json['start'] as int,
      end: json['end'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'nickname': nickname,
      'color': colorKey,
      'start': start,
      'end': end,
    };
  }
}

@immutable
class DotComment {
  final String id;
  final String dotId;
  final String authorId;
  final String authorNickname;
  final String authorColorKey; // BE author_color — 정체성 색, 'blue' 폴백
  final String content;
  final List<MentionSpan> mentions;
  final DateTime createdAt;

  const DotComment({
    required this.id,
    required this.dotId,
    required this.authorId,
    required this.authorNickname,
    this.authorColorKey = 'blue',
    required this.content,
    required this.mentions,
    required this.createdAt,
  });

  factory DotComment.fromJson(Map<String, dynamic> json) {
    final mentionsList = (json['mentions'] as List<dynamic>? ?? [])
        .map((e) => MentionSpan.fromJson(e as Map<String, dynamic>))
        .toList();
    return DotComment(
      id: json['id'] as String,
      dotId: json['dot_id'] as String,
      authorId: json['author_id'] as String,
      authorNickname: json['author_nickname'] as String,
      authorColorKey: (json['author_color'] as String?) ?? 'blue',
      content: json['content'] as String,
      mentions: mentionsList,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
