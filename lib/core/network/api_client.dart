import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

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
    ..interceptors.add(LogInterceptor(
      requestHeader: false, // Authorization 헤더 로깅 제외
      requestBody: AppConfig.isDev,
      responseBody: AppConfig.isDev,
      error: true,
    ));

  static Dio get instance => _dio;
}

class _AuthInterceptor extends Interceptor {
  final _storage = const FlutterSecureStorage();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'firebase_id_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // _retried 플래그로 무한 재시도 방지
    if (err.response?.statusCode == 401 &&
        err.requestOptions.extra['_retried'] != true) {
      try {
        final newToken =
            await FirebaseAuth.instance.currentUser?.getIdToken(true);
        if (newToken != null) {
          await _storage.write(key: 'firebase_id_token', value: newToken);

          final opts = err.requestOptions
            ..headers['Authorization'] = 'Bearer $newToken'
            ..extra['_retried'] = true;
          // 기존 싱글턴 인스턴스로 재시도 (인터셉터 유지)
          final response = await ApiClient.instance.fetch(opts);
          return handler.resolve(response);
        }
      } catch (_) {
        // 갱신 실패 시 원래 에러 그대로 전달
      }
    }
    handler.next(err);
  }
}
