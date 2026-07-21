import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' hide User;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../core/config/app_config.dart';
import '../../../core/utils/color_hex.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../character/paperdoll/presentation/paperdoll_provider.dart';
import '../../notification/data/notification_preferences.dart';
import '../../recording/data/dot_local_source.dart' show appDatabaseProvider;
import '../../../core/storage/secure_storage.dart';
import '../domain/user_model.dart';

part 'auth_provider.g.dart';

const _storage = kSecureStorage;
const _prefsBeUserId = 'be_user_id';

@riverpod
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@riverpod
Stream<User?> authStateChanges(Ref ref) =>
    ref.watch(firebaseAuthProvider).authStateChanges();

@riverpod
User? currentUser(Ref ref) {
  // 인증 상태 변화(login/logout/token revoke) 마다 재계산되도록 stream 을 watch.
  // 값은 동기적으로 SDK 인스턴스에서 읽어, 첫 build (splash → home redirect) 시
  // stream 의 비동기 emit 을 기다리지 않고 즉시 정확한 결과를 낸다.
  ref.watch(authStateChangesProvider);
  return ref.read(firebaseAuthProvider).currentUser;
}

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
  } catch (e, st) {
    // 첫 SSO 로그인 시 token race 등으로 실패하면 dependent 가 0 결과를 내므로
    // 원인 추적을 위해 반드시 로깅. null 반환은 유지(keepAlive + throw 시
    // 에러가 영구 캐시되어 전체 화면이 망가지는 것을 회피).
    debugPrint('[currentDottieUser] /users/me failed: $e\n$st');
    return null;
  }
}

/// 현재 사용자의 정체성 색.
///
/// 우선순위: `paperdollProvider.colorHex` > `currentDottieUser.character.colorHex`
/// (paperdollProvider가 picker 즉시 반영을 위한 단일 source of truth — 저장 후
/// `currentDottieUser` 재요청 없이 색이 즉시 갱신됨).
///
/// 자유 hex 형식. 잘못된 값이면 default(`#7EB8F7`)로 폴백.
@riverpod
Color currentUserColor(Ref ref) {
  final paperdoll = ref.watch(paperdollProvider).valueOrNull;
  if (paperdoll != null) {
    return colorFromHex(paperdoll.colorHex);
  }
  final user = ref.watch(currentDottieUserProvider).valueOrNull;
  return colorFromHex(user?.character.colorHex);
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
      // provider 토큰(identity token)을 BE 로 보내 신원 매핑 + custom token 발급.
      // (native signInWithCredential 대신 — BE 가 canonical UID 를 소유해야
      //  카카오/네이버/애플/구글이 일관된 세션으로 통합·연결된다.)
      // nonce 불필요: BE 가 identity token JWT 를 Apple 공개키로 검증.
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        throw Exception('apple identityToken missing');
      }
      final res = await ApiClient.instance.post(ApiEndpoints.authLogin, data: {
        'provider': 'apple',
        'token': identityToken,
        'authorization_code': credential.authorizationCode,
      });
      await _signInWithBackendToken(res);
      await _saveIdToken();
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
      final googleUser = await GoogleSignIn(
        serverClientId: AppConfig.googleServerClientId,
      ).signIn();
      if (googleUser == null) {
        state = const AsyncData(null);
        return false;
      }
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception('google idToken missing');
      }
      final res = await ApiClient.instance.post(ApiEndpoints.authLogin, data: {
        'provider': 'google',
        'token': idToken,
      });
      await _signInWithBackendToken(res);
      await _saveIdToken();
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      debugPrint('[AuthNotifier] login error: $e\n$st');
      state = AsyncError(e, st);
      return false;
    }
  }

  /// `/auth/login` 응답의 `firebase_custom_token` 으로 Firebase 로그인.
  /// provider 토큰을 보냈으므로 항상 non-empty custom token 이 온다.
  Future<void> _signInWithBackendToken(Response res) async {
    final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
    final customToken = data['firebase_custom_token'] as String? ?? '';
    if (customToken.isEmpty) {
      throw Exception('empty firebase_custom_token');
    }
    await FirebaseAuth.instance.signInWithCustomToken(customToken);
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    await _storage.delete(key: 'firebase_id_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsBeUserId);
    // 사용자별 알림 토글 정리 — 다음 user 로그인 시 default(ON) 부터 시작.
    await NotificationPreferencesNotifier.clearLocal(prefs);
    // 보안: 로컬 DB(위치 dot / 할일)는 user 격리가 없어 잔존 시 다음
    // 로그인 사용자에게 노출될 수 있다. 전체 삭제.
    await _wipeLocalDatabase();
    ref.invalidate(notificationPreferencesNotifierProvider);
    // 이전 사용자의 캐릭터 config 를 메모리에서 즉시 제거 (다음 로그인 시 재로딩).
    ref.invalidate(paperdollProvider);
    state = const AsyncData(null);
  }

  /// 로컬 drift DB 전체 삭제. 계정 정리(로그아웃/탈퇴) 시 호출.
  /// 삭제 실패가 세션 정리 전체를 막지 않도록 예외를 삼킨다(로그만).
  Future<void> _wipeLocalDatabase() async {
    try {
      await ref.read(appDatabaseProvider).wipeAll();
    } catch (e) {
      debugPrint('[AuthNotifier] local DB wipe failed: $e');
    }
  }

  Future<void> _saveIdToken() async {
    // 로그인 직후 force refresh 로 신선한 토큰 보장 — 이전 세션의 storage 잔존
    // 토큰이나 expired 토큰이 BG isolate / 첫 API 호출에 흘러가는 것을 차단.
    final idToken =
        await FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (idToken != null) {
      await _storage.write(key: 'firebase_id_token', value: idToken);
    }
    // 이전 세션(다른 SSO 계정)의 캐릭터가 지도/입력 시트에 남지 않도록
    // 사용자 스코프 상태를 새 계정 기준으로 재로딩한다. paperdollProvider 는
    // long-lived StateNotifier 라 authStateChanges 를 watch 하지 않아
    // 명시적 invalidate 가 없으면 A 로그아웃 → B 로그인 시 A 의 캐릭터가 보인다.
    ref.invalidate(paperdollProvider);
  }

  /// 회원 탈퇴 — BE 에서 모든 데이터 영구 삭제 후 Firebase 세션도 정리.
  ///
  /// BE: `DELETE /v1/users/me`
  /// - 204: 정상 삭제
  /// - 404 USER_NOT_FOUND: 이미 삭제됨 — 멱등 처리 (signOut 그대로 진행)
  /// - 그 외 4xx/5xx: [AccountDeleteException] throw — caller 가 UI 안내
  /// - 네트워크 오류: [AccountDeleteException(networkError: true)] — 재시도 가능
  ///
  /// 성공/멱등 시 Firebase signOut + 로컬 자격증명 정리. 호출자는 로그인 화면으로 이동.
  Future<void> deleteAccount() async {
    try {
      await ApiClient.instance.delete('/users/me');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 404) {
        // 이미 BE 측에서 삭제된 사용자 — Firebase 세션만 남은 상태. 정상 종료로 처리.
        debugPrint('[AuthNotifier] deleteAccount 404 — already gone, treat as success');
      } else if (e.response == null) {
        // 네트워크 오류 — Firebase 세션 보존 (재시도 가능).
        throw const AccountDeleteException(networkError: true);
      } else {
        final body = e.response?.data;
        String? code;
        String? message;
        if (body is Map<String, dynamic>) {
          final err = body['error'];
          if (err is Map<String, dynamic>) {
            code = err['code'] as String?;
            message = err['message'] as String?;
          }
        }
        throw AccountDeleteException(
          statusCode: status,
          code: code,
          message: message,
        );
      }
    } catch (e, st) {
      debugPrint('[AuthNotifier] deleteAccount unexpected: $e\n$st');
      throw const AccountDeleteException();
    }
    // BE 측 삭제 성공 또는 멱등 — Firebase 세션 + 로컬 자격증명 정리.
    await FirebaseAuth.instance.signOut();
    await _storage.delete(key: 'firebase_id_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsBeUserId);
    await NotificationPreferencesNotifier.clearLocal(prefs);
    // 탈퇴 — BE 에서 원격 데이터 삭제됐으므로 로컬 잔존분도 완전 제거.
    await _wipeLocalDatabase();
    ref.invalidate(notificationPreferencesNotifierProvider);
    // 이전 사용자의 캐릭터 config 를 메모리에서 즉시 제거 (다음 로그인 시 재로딩).
    ref.invalidate(paperdollProvider);
    state = const AsyncData(null);
  }
}

/// 회원 탈퇴 BE 호출이 거절/실패한 경우. 화면 단에서 사용자 안내 분기.
class AccountDeleteException implements Exception {
  const AccountDeleteException({
    this.statusCode,
    this.code,
    this.message,
    this.networkError = false,
  });
  final int? statusCode;
  final String? code;
  final String? message;
  final bool networkError;

  @override
  String toString() =>
      'AccountDeleteException(status=$statusCode, code=$code, msg=$message, network=$networkError)';
}
