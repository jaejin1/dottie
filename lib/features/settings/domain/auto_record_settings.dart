import 'dart:io';

class AutoRecordInterval {
  const AutoRecordInterval._();

  static const int manual = 0;
  static const int min30 = 30;
  static const int hour1 = 60;

  static const List<int> all = [manual, min30, hour1];

  static String label(int minutes) => switch (minutes) {
        0 => '수동',
        30 => '30분',
        60 => '1시간',
        _ => '$minutes분',
      };

  /// 플랫폼별 백그라운드 기록 메커니즘 선택.
  ///
  /// - Android: WorkManager periodic (>=15분 지원, 재부팅 후에도 OS 가 유지)
  /// - iOS: WorkManager 는 BGAppRefreshTask 라서 실행 시점을 OS 가 임의로
  ///   결정한다 (30분 힌트를 줘도 몇 시간씩 밀리거나 아예 실행 안 됨).
  ///   주기적 기록을 보장하려면 background location 스트림
  ///   (ContinuousLocationService + Always 권한) 을 써야 한다.
  static bool requiresForegroundService(int minutes) =>
      Platform.isIOS && minutes > 0;

  static bool hasBatteryWarning(int minutes) => false;
}
