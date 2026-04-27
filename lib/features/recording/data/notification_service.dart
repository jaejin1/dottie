import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

part 'notification_service.g.dart';

const int _dotReminderBaseId = 1000;
const String _channelId = 'dottie_recording';
const String _channelName = 'Dottie 기록 알림';

final _plugin = FlutterLocalNotificationsPlugin();

const _messages = [
  '지금 어디? dot 찍어봐 🔵',
  '뭐하고 있어? 📍',
  '지금 이 순간을 기록해봐 ✨',
  '오늘 하루 어때? dot 하나 남겨봐 🗺️',
];

class NotificationService {
  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );
  }

  Future<void> requestPermission() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// 기록 시작 후 1시간 간격으로 알림 예약 (최대 8개, 8시간)
  Future<void> scheduleDotReminders() async {
    await cancelDotReminders();

    final now = tz.TZDateTime.now(tz.local);
    final rng = Random();

    for (int i = 1; i <= 8; i++) {
      final scheduledTime = now.add(Duration(hours: i));
      if (scheduledTime.hour < 6) break;

      final message = _messages[rng.nextInt(_messages.length)];

      await _plugin.zonedSchedule(
        _dotReminderBaseId + i,
        'Dottie',
        message,
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'dot_reminder',
      );
    }
  }

  Future<void> cancelDotReminders() async {
    for (int i = 1; i <= 8; i++) {
      await _plugin.cancel(_dotReminderBaseId + i);
    }
  }
}

@riverpod
NotificationService notificationService(Ref ref) => NotificationService();
