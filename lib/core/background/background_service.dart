import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/settings/domain/auto_record_settings.dart';
import 'background_dot_task.dart';
import 'continuous_location_service.dart';

class BackgroundService {
  BackgroundService._();

  static const _taskUniqueName = 'com.dottie.autorecord';
  static const _taskName = 'autoRecordDot';
  static const _prefsInterval = 'auto_record_interval';

  static Future<void> initialize() async {
    await Workmanager().initialize(backgroundCallbackDispatcher);
  }

  /// 앱 시작 시 저장된 간격을 복원해 적절한 메커니즘 재가동.
  /// 짧은 간격(<15분)은 ContinuousLocationService를 다시 띄워야 한다.
  /// WorkManager 작업은 OS가 영속화하므로 재등록이 필수는 아니지만 안전하게 재예약.
  static Future<void> restoreOnLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_prefsInterval) ?? AutoRecordInterval.manual;
    if (saved == AutoRecordInterval.manual) return;
    await scheduleAutoRecord(saved);
  }

  /// intervalMinutes == 0 이면 모든 자동기록 취소.
  /// < 15 → 연속 위치 스트림 (Foreground Service)
  /// >= 15 → WorkManager 주기 작업
  static Future<void> scheduleAutoRecord(int intervalMinutes) async {
    // 항상 양쪽 다 취소 후 재설정 (간격 변경 시 메커니즘이 바뀔 수 있음)
    await Workmanager().cancelByUniqueName(_taskUniqueName);
    await ContinuousLocationService.stop();

    if (intervalMinutes <= 0) return;

    if (AutoRecordInterval.requiresForegroundService(intervalMinutes)) {
      await ContinuousLocationService.start(intervalMinutes);
      return;
    }

    await Workmanager().registerPeriodicTask(
      _taskUniqueName,
      _taskName,
      frequency: Duration(minutes: intervalMinutes),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 5),
    );
  }

  static Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(_taskUniqueName);
    await ContinuousLocationService.stop();
  }
}
