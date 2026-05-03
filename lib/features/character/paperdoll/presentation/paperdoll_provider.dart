import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../data/paperdoll_renderer.dart';
import '../domain/paperdoll_config.dart';

/// 단일 PaperdollRenderer 인스턴스. cache가 keepAlive 되어야 합성 비용 절감됨.
final paperdollRendererProvider = Provider<PaperdollRenderer>((ref) {
  final renderer = PaperdollRenderer();
  ref.onDispose(() => renderer.cache.clear());
  return renderer;
});

/// 캐릭터 구성 상태.
///
/// - 로드: GET /v1/users/me 의 `character_config` 필드 파싱
/// - 저장: PUT /v1/users/me/character (11개 필드 전체 전송)
/// - 인증 실패/오프라인 시 default로 fallback
final paperdollProvider =
    StateNotifierProvider<PaperdollNotifier, AsyncValue<PaperdollConfig>>(
  (ref) => PaperdollNotifier(),
);

/// 캐릭터 저장 시 발생할 수 있는 BE 에러.
class PaperdollSaveException implements Exception {
  const PaperdollSaveException(this.code, {this.part, this.value});

  /// BE 에러 코드 — 'INVALID_PART_ID' / 'VALIDATION_ERROR' / 'UNKNOWN_FIELD' /
  /// 'RATE_LIMIT_EXCEEDED' / 'NETWORK_ERROR' / 'UNKNOWN'
  final String code;

  /// INVALID_PART_ID 에러일 때 어느 부위인지 (예: 'hair')
  final String? part;

  /// INVALID_PART_ID 에러일 때 거절된 값
  final String? value;

  @override
  String toString() => switch (code) {
        'INVALID_PART_ID' => '이 ${part ?? '옵션'}을 사용할 수 없어요',
        'VALIDATION_ERROR' => '잘못된 형식이에요',
        'UNKNOWN_FIELD' => '지원하지 않는 항목이에요',
        'RATE_LIMIT_EXCEEDED' => '너무 자주 변경했어요. 잠시 후 다시 시도해 주세요',
        'NETWORK_ERROR' => '네트워크 오류예요. 잠시 후 다시 시도해 주세요',
        _ => '저장에 실패했어요',
      };
}

class PaperdollNotifier extends StateNotifier<AsyncValue<PaperdollConfig>> {
  PaperdollNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient.instance.get(ApiEndpoints.usersMe);
      final data = (res.data['data'] ?? res.data) as Map<String, dynamic>;
      final config = data['character_config'] as Map<String, dynamic>?;
      if (config != null) {
        state = AsyncValue.data(PaperdollConfig.fromJson(config));
      } else {
        state = const AsyncValue.data(PaperdollConfig.defaults);
      }
    } on DioException catch (e, st) {
      // 401은 인터셉터가 갱신 재시도 — 여기까지 오면 인증 실패.
      // 오프라인이거나 사용자 정보 없음 → default로 시작
      if (e.response == null) {
        state = const AsyncValue.data(PaperdollConfig.defaults);
      } else {
        state = AsyncValue.error(e, st);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 외부에서 새로고침 (예: 로그인 직후)
  Future<void> refresh() => _load();

  /// 에디터에서 미저장 변경 미리보기 — 저장은 별도 호출 필요.
  void update(PaperdollConfig config) {
    state = AsyncValue.data(config);
  }

  /// 저장. 성공 시 true.
  /// 실패 시 false 반환 + state는 이전 값 복원. 에러 정보는 [lastError]로 노출.
  Future<bool> save(PaperdollConfig config) async {
    // 주의: state를 AsyncValue.loading()으로 바꾸지 않는다.
    // 라우터가 loading 상태를 보고 에디터 화면을 spinner로 교체하면
    // 에디터의 스낵바/로컬 상태가 사라진다. 로딩 표시는 에디터의 _saving 플래그로 처리.
    debugPrint('[Paperdoll] save → PUT ${ApiEndpoints.usersMeCharacter}');
    try {
      await ApiClient.instance.put(
        ApiEndpoints.usersMeCharacter,
        data: config.toJson(),
      );
      debugPrint('[Paperdoll] save OK');
      state = AsyncValue.data(config);
      _lastError = null;
      return true;
    } on DioException catch (e) {
      _lastError = _interpret(e);
      debugPrint(
          '[Paperdoll] save failed: ${_lastError?.code} (${e.response?.statusCode})');
      return false;
    } catch (e) {
      _lastError = const PaperdollSaveException('UNKNOWN');
      debugPrint('[Paperdoll] save failed: ${e.runtimeType}');
      return false;
    }
  }

  /// 마지막 저장 에러 (UI에서 스낵바 등으로 노출용).
  PaperdollSaveException? get lastError => _lastError;
  PaperdollSaveException? _lastError;

  PaperdollSaveException _interpret(DioException e) {
    final res = e.response;
    if (res == null) return const PaperdollSaveException('NETWORK_ERROR');
    final body = res.data;
    if (body is Map && body['error'] is Map) {
      final err = body['error'] as Map;
      final code = err['code'] as String?;
      final part = err['part'] as String?;
      final value = err['value'] as String?;
      if (code == 'INVALID_PART_ID') {
        return PaperdollSaveException(code!, part: part, value: value);
      }
      if (code == 'VALIDATION_ERROR' ||
          code == 'UNKNOWN_FIELD' ||
          code == 'RATE_LIMIT_EXCEEDED') {
        return PaperdollSaveException(code!);
      }
    }
    return const PaperdollSaveException('UNKNOWN');
  }
}
