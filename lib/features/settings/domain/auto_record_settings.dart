class AutoRecordInterval {
  const AutoRecordInterval._();

  static const int manual = 0;
  static const int min1 = 1;
  static const int min5 = 5;
  static const int min10 = 10;
  static const int min30 = 30;
  static const int hour1 = 60;

  static const List<int> all = [manual, min1, min5, min10, min30, hour1];

  static String label(int minutes) => switch (minutes) {
        0 => '수동',
        1 => '1분',
        5 => '5분',
        10 => '10분',
        30 => '30분',
        60 => '1시간',
        _ => '$minutes분',
      };

  /// 1·5·10분 — Foreground Service(연속 위치 스트림) 필요.
  /// WorkManager periodic은 OS 강제 최소 15분 때문에 사용 불가.
  static bool requiresForegroundService(int minutes) =>
      minutes > 0 && minutes < 15;

  /// 짧은 간격은 위치 스트림이 항시 돌아 배터리 소모가 큼.
  static bool hasBatteryWarning(int minutes) =>
      minutes > 0 && minutes <= 10;
}
