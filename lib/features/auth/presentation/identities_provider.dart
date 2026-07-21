import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/identities_remote_source.dart';
import '../data/provider_token_service.dart';
import '../domain/linked_identity.dart';

part 'identities_provider.g.dart';

/// 연결된 소셜 계정 목록 + 연결/해제 액션.
@riverpod
class LinkedIdentitiesNotifier extends _$LinkedIdentitiesNotifier {
  @override
  Future<List<LinkedIdentity>> build() async {
    return ref.read(identitiesRemoteSourceProvider).fetch();
  }

  /// provider 연결. 대상이 이미 다른 계정(B)이면 [onConflict] 콜백으로
  /// 파괴적 확인을 받고, 승인 시 같은 토큰으로 `replace_existing` 재요청한다
  /// (재로그인 없이). 취소/비승인이면 아무 변화 없음.
  ///
  /// [OwnsSharedRoomException] / [ProviderAlreadyLinkedException] /
  /// [ProviderTokenException] 등은 호출자(UI)가 잡아 안내한다.
  Future<void> connect(
    AuthProviderKind provider, {
    required Future<bool> Function(IdentityAlreadyLinkedException conflict)
        onConflict,
  }) async {
    final creds = await ref.read(providerTokenServiceProvider).obtain(provider);
    final remote = ref.read(identitiesRemoteSourceProvider);
    try {
      final list = await remote.link(
        provider: provider,
        token: creds.token,
        authorizationCode: creds.authorizationCode,
      );
      state = AsyncData(list);
    } on IdentityAlreadyLinkedException catch (conflict) {
      final confirmed = await onConflict(conflict);
      if (!confirmed) return;
      final list = await remote.link(
        provider: provider,
        token: creds.token,
        authorizationCode: creds.authorizationCode,
        replaceExisting: true,
      );
      state = AsyncData(list);
    }
  }

  /// provider 연결 해제. 마지막 1개면 [LastIdentityException] throw(호출자 안내).
  Future<void> disconnect(AuthProviderKind provider) async {
    final list =
        await ref.read(identitiesRemoteSourceProvider).unlink(provider);
    state = AsyncData(list);
  }
}
