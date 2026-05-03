import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' hide User;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../core/constants/colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../character/paperdoll/presentation/paperdoll_provider.dart';
import '../domain/user_model.dart';

part 'auth_provider.g.dart';

const _storage = FlutterSecureStorage();
const _prefsBeUserId = 'be_user_id';

@riverpod
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@riverpod
Stream<User?> authStateChanges(Ref ref) =>
    ref.watch(firebaseAuthProvider).authStateChanges();

@riverpod
User? currentUser(Ref ref) =>
    ref.watch(firebaseAuthProvider).currentUser;

@riverpod
bool isAuthenticated(Ref ref) =>
    ref.watch(currentUserProvider) != null;

/// BE /users/me 로부터 현재 사용자 정보를 가져옴. uid는 BE UUID(room.ownerId와 비교 가능).
@Riverpod(keepAlive: true)
Future<DottieUser?> currentDottieUser(Ref ref) async {
  // 인증 상태 변경 시 재조회
  ref.watch(authStateChangesProvider);
  final firebaseUser = ref.read(currentUserProvider);
  if (firebaseUser == null) return null;
  try {
    final res = await ApiClient.instance.get(ApiEndpoints.usersMe);
    final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
    final user = DottieUser.fromJson(data);
    // BG isolate가 로컬 DB에 dot을 저장할 때 user_id FK가 필요.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsBeUserId, user.uid);
    return user;
  } catch (_) {
    return null;
  }
}

/// 현재 사용자의 정체성 색.
///
/// 우선순위: `paperdollProvider.colorKey` > `currentDottieUser.character.colorKey`
/// (paperdollProvider가 picker 즉시 반영을 위한 단일 source of truth — 저장 후
/// `currentDottieUser` 재요청 없이 색이 즉시 갱신됨).
///
/// 5색 프리셋(`blue/mint/coral/lavender/yellow`) 기준. 모두 미로드/잘못된 값이면
/// `DottieColors.primary` 폴백.
@riverpod
Color currentUserColor(Ref ref) {
  final paperdoll = ref.watch(paperdollProvider).valueOrNull;
  if (paperdoll != null) {
    return characterColorMap[paperdoll.colorKey] ?? DottieColors.primary;
  }
  final user = ref.watch(currentDottieUserProvider).valueOrNull;
  return characterColorMap[user?.character.colorKey] ?? DottieColors.primary;
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> loginWithKakao() async {
    state = const AsyncLoading();
    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      final res = await ApiClient.instance.post(ApiEndpoints.authLogin, data: {
        'provider': 'kakao',
        'token': token.accessToken,
      });
      final customToken = res.data['data']['firebase_custom_token'] as String;
      await FirebaseAuth.instance.signInWithCustomToken(customToken);
      await _saveIdToken();
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      debugPrint('[AuthNotifier] login error: $e\n$st');
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> loginWithApple() async {
    state = const AsyncLoading();
    try {
      // PKCE nonce — replay attack 방지
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: credential.identityToken,
        rawNonce: rawNonce,
      );
      await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken != null) {
        await ApiClient.instance.post(ApiEndpoints.authLogin, data: {
          'provider': 'apple',
          'token': idToken,
        });
        await _storage.write(key: 'firebase_id_token', value: idToken);
      }
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      debugPrint('[AuthNotifier] login error: $e\n$st');
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    state = const AsyncLoading();
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        state = const AsyncData(null);
        return false;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken != null) {
        await ApiClient.instance.post(ApiEndpoints.authLogin, data: {
          'provider': 'google',
          'token': idToken,
        });
        await _storage.write(key: 'firebase_id_token', value: idToken);
      }
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      debugPrint('[AuthNotifier] login error: $e\n$st');
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await _storage.delete(key: 'firebase_id_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsBeUserId);
    state = const AsyncData(null);
  }

  Future<void> _saveIdToken() async {
    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (idToken != null) {
      await _storage.write(key: 'firebase_id_token', value: idToken);
    }
  }

  static String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
        length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  static String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
