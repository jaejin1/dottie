import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../auth/domain/user_model.dart';

part 'character_provider.g.dart';

@riverpod
class CharacterNotifier extends _$CharacterNotifier {
  @override
  CharacterConfig build() {
    _loadFromServer();
    return const CharacterConfig();
  }

  Future<void> _loadFromServer() async {
    try {
      final res = await ApiClient.instance.get(ApiEndpoints.usersMe);
      final data = res.data['data'] as Map<String, dynamic>;
      final config = data['character_config'] as Map<String, dynamic>?;
      if (config != null) {
        state = CharacterConfig(
          colorKey: config['color'] as String? ?? state.colorKey,
          accessoryKey: config['accessory'] as String? ?? state.accessoryKey,
          expressionKey: config['expression'] as String? ?? state.expressionKey,
        );
      }
    } catch (_) {}
  }

  void setColor(String colorKey) {
    state = state.copyWith(colorKey: colorKey);
  }

  void setAccessory(String accessoryKey) {
    state = state.copyWith(accessoryKey: accessoryKey);
  }

  void setExpression(String expressionKey) {
    state = state.copyWith(expressionKey: expressionKey);
  }

  Future<bool> save() async {
    try {
      await ApiClient.instance.put(
        ApiEndpoints.usersMeCharacter,
        data: {
          'color': state.colorKey,
          'accessory': state.accessoryKey,
          'expression': state.expressionKey,
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
