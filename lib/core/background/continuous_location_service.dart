import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'background_dot_task.dart';

/// 1·5·10분 간격을 위한 연속 위치 스트림 서비스.
///
/// Android는 [AndroidSettings.foregroundNotificationConfig]로 OS가 강제하는
/// 지속 알림을 띄워 Foreground Service로 동작 → 앱이 백그라운드여도 지속.
/// iOS는 [AppleSettings.allowBackgroundLocationUpdates]로 백그라운드 위치
/// 업데이트를 허용 (Always 권한 필요).
///
/// 위치는 매 업데이트마다 들어오지만, [_intervalMinutes] 경과 전이라면
/// dot은 저장하지 않고 throttle한다.
class ContinuousLocationService {
  ContinuousLocationService._();

  static StreamSubscription<Position>? _sub;
  static int _intervalMinutes = 0;
  static const _prefsLastTickTs = 'cls_last_tick_ts';

  static bool get isRunning => _sub != null;

  static Future<void> start(int intervalMinutes) async {
    if (intervalMinutes <= 0) {
      await stop();
      return;
    }
    if (_sub != null && _intervalMinutes == intervalMinutes) return;
    await stop();

    _intervalMinutes = intervalMinutes;

    _sub = Geolocator.getPositionStream(
      locationSettings: _platformSettings(intervalMinutes),
    ).listen(_onPosition, onError: (_) {});

    // 시작 즉시 첫 dot 1회 저장 (사용자가 자동기록을 켰을 때 즉시 피드백).
    unawaited(_tick(force: true));
  }

  static Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    _intervalMinutes = 0;
  }

  static void _onPosition(Position _) {
    unawaited(_tick());
  }

  static Future<void> _tick({bool force = false}) async {
    if (_intervalMinutes <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(_prefsLastTickTs) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final intervalMs = _intervalMinutes * 60 * 1000;
    if (!force && now - last < intervalMs) return;
    await prefs.setInt(_prefsLastTickTs, now);
    await captureAutoDot(reason: 'continuous');
  }

  static LocationSettings _platformSettings(int intervalMinutes) {
    if (Platform.isAndroid) {
      final intervalMs = intervalMinutes * 60 * 1000;
      return AndroidSettings(
        accuracy: LocationAccuracy.low,
        distanceFilter: 0,
        // OS 위치 갱신 주기 힌트 — 자주 깨우면 배터리 낭비.
        intervalDuration: Duration(milliseconds: intervalMs),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Dottie',
          notificationText: '백그라운드에서 위치를 기록하고 있어요',
          notificationIcon:
              AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
          enableWakeLock: true,
          setOngoing: true,
        ),
      );
    }
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.low,
        activityType: ActivityType.fitness,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.low,
      distanceFilter: 0,
    );
  }
}
