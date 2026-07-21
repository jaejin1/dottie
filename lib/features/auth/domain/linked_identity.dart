import 'package:flutter/foundation.dart';

/// 지원 소셜 로그인 provider.
enum AuthProviderKind { kakao, naver, apple, google }

extension AuthProviderKindX on AuthProviderKind {
  String get wire => name; // 'kakao' | 'naver' | 'apple' | 'google'

  String get label => switch (this) {
        AuthProviderKind.kakao => '카카오',
        AuthProviderKind.naver => '네이버',
        AuthProviderKind.apple => 'Apple',
        AuthProviderKind.google => 'Google',
      };

  static AuthProviderKind? fromWire(String s) {
    for (final p in AuthProviderKind.values) {
      if (p.name == s) return p;
    }
    return null;
  }
}

/// `GET /users/me/identities` 항목 — 현재 계정에 연결된 로그인 수단 1개.
@immutable
class LinkedIdentity {
  const LinkedIdentity({
    required this.provider,
    this.email,
    required this.connectedAt,
  });

  final AuthProviderKind provider;
  final String? email;
  final DateTime connectedAt;

  static LinkedIdentity? fromJson(Map<String, dynamic> json) {
    final kind = AuthProviderKindX.fromWire(json['provider'] as String? ?? '');
    if (kind == null) return null; // 알 수 없는 provider 는 스킵
    final raw = json['connected_at'] as String?;
    return LinkedIdentity(
      provider: kind,
      email: json['email'] as String?,
      connectedAt:
          raw != null ? DateTime.parse(raw) : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// 409 `IDENTITY_ALREADY_LINKED` — 그 소셜 계정이 이미 다른 계정(B)에 연결됨.
/// FE 는 [summary] 로 "기록 N개 삭제" 파괴적 확인 다이얼로그를 띄운 뒤,
/// 사용자 확인 시 `replace_existing: true` 로 재요청한다.
class IdentityAlreadyLinkedException implements Exception {
  const IdentityAlreadyLinkedException({this.dotCount = 0, this.roomCount = 0});
  final int dotCount;
  final int roomCount;
}

/// 409 `OWNS_SHARED_ROOM` — 그 계정(B)이 다른 멤버 있는 공유 방의 방장이라
/// 흡수 불가. 재요청 없음(사용자가 방 정리 후 재시도).
class OwnsSharedRoomException implements Exception {
  const OwnsSharedRoomException();
}

/// 409 `PROVIDER_ALREADY_LINKED` — 이 로그인 방식에 이미 다른 계정이 연결됨
/// (한 user 에 provider 당 1개).
class ProviderAlreadyLinkedException implements Exception {
  const ProviderAlreadyLinkedException();
}

/// 409 `LAST_IDENTITY` — 마지막 남은 로그인 수단이라 해제 불가.
class LastIdentityException implements Exception {
  const LastIdentityException();
}

/// provider 토큰 취득 실패(사용자 취소 포함).
class ProviderTokenException implements Exception {
  const ProviderTokenException([this.cancelled = false]);
  final bool cancelled;
}
