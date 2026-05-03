import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/auto_record_settings.dart';
import '../../../core/background/background_service.dart';

part 'auto_record_provider.g.dart';

@Riverpod(keepAlive: true)
class AutoRecordNotifier extends _$AutoRecordNotifier {
  static const _prefKey = 'auto_record_interval';

  @override
  Future<int> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefKey) ?? AutoRecordInterval.manual;
  }

  Future<void> setInterval(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, minutes);
    state = AsyncValue.data(minutes);
    await BackgroundService.scheduleAutoRecord(minutes);
  }
}
