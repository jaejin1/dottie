import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../domain/linked_identity.dart';

part 'identities_remote_source.g.dart';

/// `/v1/users/me/identities` — 연결된 소셜 계정 조회/연결/해제.
///
/// 응답은 항상 갱신된 identities 목록(`{ data: [...] }`). 409 비즈니스 에러는
/// [linked_identity.dart] 의 typed exception 으로 변환해 상위에서 UI 분기.
class IdentitiesRemoteSource {
  IdentitiesRemoteSource(this._dio);
  final Dio _dio;

  Future<List<LinkedIdentity>> fetch() async {
    final res = await _dio.get(ApiEndpoints.usersMeIdentities);
    return _parseList(res.data);
  }

  /// 계정 연결. [replaceExisting] true 면 대상이 다른 계정(B)이어도 B 를 삭제하고 흡수.
  Future<List<LinkedIdentity>> link({
    required AuthProviderKind provider,
    required String token,
    String? authorizationCode,
    bool replaceExisting = false,
  }) async {
    try {
      final res = await _dio.post(
        ApiEndpoints.usersMeIdentities,
        data: {
          'provider': provider.wire,
          'token': token,
          if (authorizationCode != null) 'authorization_code': authorizationCode,
          'replace_existing': replaceExisting,
        },
      );
      return _parseList(res.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<List<LinkedIdentity>> unlink(AuthProviderKind provider) async {
    try {
      final res = await _dio.delete(ApiEndpoints.usersMeIdentity(provider.wire));
      return _parseList(res.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  List<LinkedIdentity> _parseList(dynamic raw) {
    final list = (raw is Map && raw['data'] is List)
        ? raw['data'] as List
        : (raw as List);
    return list
        .map((e) => LinkedIdentity.fromJson((e as Map).cast<String, dynamic>()))
        .whereType<LinkedIdentity>()
        .toList();
  }

  /// BE 에러 바디(`{ error: { code, target } }`) → typed exception.
  Object _mapError(DioException e) {
    final body = e.response?.data;
    final err = (body is Map && body['error'] is Map)
        ? (body['error'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final code = err['code'] as String?;
    switch (code) {
      case 'IDENTITY_ALREADY_LINKED':
        final target = (err['target'] is Map)
            ? (err['target'] as Map).cast<String, dynamic>()
            : const <String, dynamic>{};
        final summary = (target['summary'] is Map)
            ? (target['summary'] as Map).cast<String, dynamic>()
            : const <String, dynamic>{};
        return IdentityAlreadyLinkedException(
          dotCount: (summary['dot_count'] as num?)?.toInt() ?? 0,
          roomCount: (summary['room_count'] as num?)?.toInt() ?? 0,
        );
      case 'OWNS_SHARED_ROOM':
        return const OwnsSharedRoomException();
      case 'PROVIDER_ALREADY_LINKED':
        return const ProviderAlreadyLinkedException();
      case 'LAST_IDENTITY':
        return const LastIdentityException();
      default:
        return e; // 그 외는 원래 DioException 전파
    }
  }
}

@riverpod
IdentitiesRemoteSource identitiesRemoteSource(Ref ref) =>
    IdentitiesRemoteSource(ApiClient.instance);
