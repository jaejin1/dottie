import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../auth/domain/user_model.dart';
import '../../auth/presentation/auth_provider.dart';

part 'character_provider.g.dart';

/// 캐릭터 관련 사용자 액션. 현재는 닉네임 변경 전용.
///
/// 캐릭터 외형(피부/머리/옷 등)은 `paperdollProvider`가 담당한다.
/// 이 notifier는 외형과 무관한 사용자 정보 변경에만 쓰인다.
@riverpod
class CharacterNotifier extends _$CharacterNotifier {
  @override
  CharacterConfig build() => const CharacterConfig();

  /// 닉네임을 서버에 저장하고 currentDottieUser 캐시를 무효화한다.
  Future<void> updateNickname(String nickname) async {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty || trimmed.runes.length > 30) {
      throw ArgumentError('닉네임은 1자 이상 30자 이하여야 합니다');
    }
    await ApiClient.instance.put(
      ApiEndpoints.usersMe,
      data: {'nickname': trimmed},
    );
    ref.invalidate(currentDottieUserProvider);
  }
}
