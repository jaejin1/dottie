import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
// ignore: unused_import
import 'api_endpoints.dart';

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
      requestBody: AppConfig.isDev,
      responseBody: AppConfig.isDev,
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
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // TODO: 토큰 갱신 로직
    }
    handler.next(err);
  }
}
