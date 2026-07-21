import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' hide User;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/config/app_config.dart';
import '../domain/linked_identity.dart';

part 'provider_token_service.g.dart';

/// 계정 "연결(link)"용 provider 토큰 취득 — Firebase 로그인은 하지 않고
/// provider SDK 로부터 토큰만 받아 `POST /identities` 에 전달한다.
/// (로그인 플로우는 auth_provider 가 담당 — 여기선 신원 증명용 토큰만.)
class ProviderTokenService {
  /// `(token, authorizationCode)` 반환. 사용자가 취소하면
  /// [ProviderTokenException] (cancelled) throw.
  Future<({String token, String? authorizationCode})> obtain(
      AuthProviderKind provider) async {
    switch (provider) {
      case AuthProviderKind.kakao:
        return (token: await _kakao(), authorizationCode: null);
      case AuthProviderKind.google:
        return (token: await _google(), authorizationCode: null);
      case AuthProviderKind.apple:
        return _apple();
      case AuthProviderKind.naver:
        // 네이버 SDK 미도입 — 이후 추가.
        throw const ProviderTokenException();
    }
  }

  Future<String> _kakao() async {
    try {
      final OAuthToken token = await isKakaoTalkInstalled()
          ? await UserApi.instance.loginWithKakaoTalk()
          : await UserApi.instance.loginWithKakaoAccount();
      return token.accessToken;
    } catch (_) {
      // 카카오톡 로그인 실패(미설치/취소) → 계정 로그인 폴백 1회 시도.
      try {
        final token = await UserApi.instance.loginWithKakaoAccount();
        return token.accessToken;
      } catch (_) {
        throw const ProviderTokenException(true);
      }
    }
  }

  Future<String> _google() async {
    final google = GoogleSignIn(serverClientId: AppConfig.googleServerClientId);
    // 다른 구글 계정을 연결할 수 있도록 계정 선택 UI 강제.
    await google.signOut();
    final user = await google.signIn();
    if (user == null) throw const ProviderTokenException(true);
    final auth = await user.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const ProviderTokenException();
    }
    return idToken;
  }

  Future<({String token, String? authorizationCode})> _apple() async {
    try {
      final c = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final idToken = c.identityToken;
      if (idToken == null || idToken.isEmpty) {
        throw const ProviderTokenException();
      }
      return (token: idToken, authorizationCode: c.authorizationCode);
    } on SignInWithAppleAuthorizationException {
      throw const ProviderTokenException(true);
    }
  }
}

@riverpod
ProviderTokenService providerTokenService(Ref ref) => ProviderTokenService();
