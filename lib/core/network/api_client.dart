import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/app_config.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  ApiClient._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  )
    ..interceptors.add(_AuthInterceptor())
    ..interceptors.addAll(
      AppConfig.isDev
          ? [
              LogInterceptor(
                requestHeader: false,
                requestBody: true,
                responseBody: true,
                error: true,
              ),
            ]
          : const [],
    );

  static Dio get instance => _dio;
}

class _AuthInterceptor extends Interceptor {
  // Firebase SDK 가 만료 5분 이내일 때 자동으로 토큰을 refresh 한다 — 따라서
  // storage 캐시를 사용할 때 발생하던 stale-token 401 race 가 사라진다.
  // storage 에는 BG isolate (background_dot_task) 가 직접 읽기 위해 best-effort
  // 로 미러링한다.
  final _storage = kSecureStorage;

  /// 비로그인으로 접근 가능한 path. AuthInterceptor 가 이 경로엔
  /// Bearer 토큰을 안 붙이고, 401 재시도도 안 한다.
  ///
  /// **명시 화이트리스트**(prefix `startsWith`) — `contains` 매칭은 임의 위치에
  /// `/public/` 가 끼면 silent auth bypass 가 발생할 위험이 있어 사용 금지.
  /// 신규 비인증 endpoint 추가 시 반드시 이 리스트에 명시.
  static const List<String> _publicPathPrefixes = <String>[
    '/public/',
    '/todo-lists/invite/', // 초대 코드 미리보기 — 인증 불필요 (GET만)
    '/rooms/invite/',      // 룸 초대 미리보기 — 인증 불필요 (GET만)
  ];

  static bool _isPublicPath(String path) {
    // Dio 의 RequestOptions.path 는 baseUrl 이후의 path. 보통 '/...' 로 시작하지만
    // 호출자가 절대 URL 을 넘기는 경우 path 가 'https://...' 인 케이스도 있으므로
    // Uri parse 로 정규화.
    final normalized = Uri.tryParse(path)?.path ?? path;
    final withSlash =
        normalized.startsWith('/') ? normalized : '/$normalized';
    return _publicPathPrefixes.any(withSlash.startsWith);
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 공개 경로엔 인증 헤더 안 붙임.
    if (_isPublicPath(options.path)) {
      return handler.next(options);
    }
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? token;
      try {
        token = await user.getIdToken();
        // 로그인 직후 순간엔 user 는 있지만 토큰이 아직 안 데워져 null/빈값이
        // 반환될 수 있다. 그대로 두면 첫 요청이 헤더 없이 나가 BE 가 401 을
        // 찍고(재시도로 200 되지만) 에러 로그가 오염된다 — force refresh 로
        // 첫 요청부터 토큰을 확보한다. 정상 상태에선 위 캐시 토큰이 즉시
        // 반환되므로 이 경로는 안 탐(오버헤드 없음).
        if (token == null || token.isEmpty) {
          token = await user.getIdToken(true);
        }
      } catch (_) {
        // getIdToken() 예외 — force refresh 로 1회 재시도.
        try {
          token = await user.getIdToken(true);
        } catch (_) {
          // 그래도 실패면 헤더 없이 진행. 보호 라우트면 BE 가 401 응답.
        }
      }
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        unawaited(
          _storage.write(key: 'firebase_id_token', value: token),
        );
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // 공개 경로의 401 은 의미가 다름 (rate limit / 토큰 만료 등) — refresh 안 함.
    if (_isPublicPath(err.requestOptions.path)) {
      return handler.next(err);
    }
    // SDK 자동 refresh 가 실패한 케이스(시계 오차, 서버 측 revoke 등) 안전망.
    if (err.response?.statusCode == 401 &&
        err.requestOptions.extra['_retried'] != true) {
      try {
        final newToken =
            await FirebaseAuth.instance.currentUser?.getIdToken(true);
        if (newToken != null && newToken.isNotEmpty) {
          unawaited(
            _storage.write(key: 'firebase_id_token', value: newToken),
          );
          final opts = err.requestOptions
            ..headers['Authorization'] = 'Bearer $newToken'
            ..extra['_retried'] = true;
          final response = await ApiClient.instance.fetch(opts);
          return handler.resolve(response);
        }
      } catch (_) {
        // 갱신 실패 — 원래 에러 그대로 전달.
      }
    }
    handler.next(err);
  }
}
