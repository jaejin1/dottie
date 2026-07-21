import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/date_utils.dart';
import 'notification_preferences.dart';
import 'push_token_remote_source.dart';

part 'push_notification_service.g.dart';

/// 백그라운드 메시지 핸들러 — **반드시 top-level / static 함수**.
/// 앱이 terminated/background 일 때 OS 가 별도 isolate 에서 호출하므로
/// instance 멤버 의존 X. Firebase.initializeApp 은 다른 isolate 에서 다시 호출.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 백그라운드 isolate — Firebase 자동 초기화는 OS 가 처리.
  // OS 가 알림 자체는 자동 표시 (notification payload). 별도 작업 불필요.
  // message.data 에 room_id/dot_id/내용이 담겨 있고, 이 isolate 는 main()
  // 의 전역 debugPrint 차단을 거치지 않으므로 assert() 로 개별 가드한다.
  assert(() {
    debugPrint('[FCM-bg] received id=${message.messageId} '
        'data=${message.data}');
    return true;
  }());
}

/// FCM (Firebase Cloud Messaging) 초기화 + 메시지 핸들링.
///
/// - 앱 시작 시 [initialize] 호출 (Firebase init 이후)
/// - 사용자 로그인 시 [registerTokenForCurrentUser] — 토큰 BE 등록
/// - 로그아웃 시 [unregisterToken] — 토큰 BE 삭제 + 로컬 캐시 정리
///
/// 메시지 흐름:
/// - **terminated**: OS 가 알림 표시. 사용자 탭 → 앱 시작 → [getInitialMessage]
///   로 한 번 페이로드 받아 라우팅.
/// - **background**: OS 가 알림 표시. 탭 → [onMessageOpenedApp] 발화.
/// - **foreground**: notification payload 가 있어도 OS 가 자동 표시 안 함 →
///   [flutter_local_notifications] 으로 직접 in-app banner 표시.
class PushNotificationService {
  PushNotificationService(this._tokenRemote, this._prefs);
  final PushTokenRemoteSource _tokenRemote;

  /// foreground 알림 type 별 on/off — null 이면 prefs 미로드 (초기) → 표시 허용.
  /// 토글이 바뀌면 [updatePreferences] 로 교체.
  NotificationPreferences? _prefs;

  void updatePreferences(NotificationPreferences prefs) {
    _prefs = prefs;
  }

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  /// foreground 메시지를 표시할 채널 — `flutter_local_notifications` 으로 직접
  /// 표시하므로 채널 ID 가 manifest 에 등록돼야 안 흐릿함.
  static const _foregroundChannel = AndroidNotificationChannel(
    'dottie_messages',
    'Dottie 메시지',
    description: '댓글 / 멘션 등 실시간 알림',
    importance: Importance.high,
  );

  bool _initialized = false;
  String? _lastRegisteredToken;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // (1) Android 채널 등록 — foreground 알림용.
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_foregroundChannel);

    // (2) local notification 초기화 + 탭 콜백 (foreground 표시 후 사용자 탭).
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // (3) iOS foreground presentation — notification payload 가 있을 때 시스템
    //     배너 표시 옵션. 우리는 local_notifications 으로 직접 표시할 거라 false.
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );
    }

    // (4) terminated 진입 케이스 — initial message.
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      debugPrint('[FCM] initial message id=${initial.messageId}');
      // 라우터가 mount 된 다음 frame 에 처리.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationTap(initial.data);
      });
    }

    // (5) background 에서 앱 깨움 — onMessageOpenedApp.
    _openedSub = FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      debugPrint('[FCM] opened from background id=${msg.messageId}');
      _handleNotificationTap(msg.data);
    });

    // (6) foreground 메시지 — local_notifications 으로 직접 표시.
    _foregroundSub = FirebaseMessaging.onMessage.listen(_handleForeground);
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _foregroundSub?.cancel();
    await _openedSub?.cancel();
    _tokenRefreshSub = null;
    _foregroundSub = null;
    _openedSub = null;
    _initialized = false;
  }

  // ── 권한 + 토큰 ────────────────────────────────────────

  /// 권한 요청 + 현재 토큰을 BE 에 등록. 로그인 직후 호출.
  Future<void> registerTokenForCurrentUser() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[FCM] permission=${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return;
    }
    final token = await _messaging.getToken();
    if (token == null) {
      debugPrint('[FCM] getToken returned null');
      return;
    }
    // 디버그 빌드에서만 전체 토큰 출력 (Firebase Console 직접 발송 테스트용).
    // release 빌드에선 절대 출력 X — debugPrint 도 system log 로 새므로
    // kDebugMode 가드 명시적.
    assert(() {
      debugPrint('[FCM] dev token: $token');
      return true;
    }());
    await _registerIfChanged(token);

    // 토큰 갱신 listen — 한 번만 등록 (initialize 이후 한 번이면 충분).
    _tokenRefreshSub ??=
        _messaging.onTokenRefresh.listen(_registerIfChanged);
  }

  Future<void> _registerIfChanged(String token) async {
    if (token == _lastRegisteredToken) return;
    _lastRegisteredToken = token;
    await _tokenRemote.registerToken(token);
  }

  /// 로그아웃 시 호출 — BE 에 토큰 삭제 + 로컬 캐시 정리.
  Future<void> unregisterToken() async {
    final token = _lastRegisteredToken ?? await _messaging.getToken();
    if (token != null) {
      await _tokenRemote.unregisterToken(token);
    }
    _lastRegisteredToken = null;
    // FCM 토큰 자체 무효화 — 다른 user 가 같은 디바이스에 로그인해도 새 토큰 발급.
    try {
      await _messaging.deleteToken();
    } catch (e) {
      debugPrint('[FCM] deleteToken error: $e');
    }
  }

  // ── foreground 메시지 처리 ─────────────────────────────

  Future<void> _handleForeground(RemoteMessage msg) async {
    // FCM data payload (title/body/room_id/dot_id 포함) 노출 차단 — debug only.
    assert(() {
      debugPrint('[FCM-fg] received id=${msg.messageId} data=${msg.data}');
      return true;
    }());
    // 사용자 토글 — type 별 차단. background/terminated 는 OS 가 이미 표시 후라
    // 막을 수 없음 (Phase 2 BE preferences 동기화로 해결).
    final type = msg.data['type'] as String?;
    if (_prefs != null && !_prefs!.shouldShowForType(type)) {
      debugPrint('[FCM-fg] suppressed by user preference (type=$type)');
      return;
    }
    final notification = msg.notification;
    final title = notification?.title ?? msg.data['title'] as String?;
    // body 는 프라이버시 정책상 BE 가 비워서 보낼 수 있음. 빈 문자열은
    // local_notifications 가 빈 줄로 표시해 어색하므로 null 로 정규화.
    final rawBody = notification?.body ?? msg.data['body'] as String?;
    final body = (rawBody != null && rawBody.trim().isNotEmpty) ? rawBody : null;
    if (title == null && body == null) return;
    // local_notifications 으로 직접 표시 — payload 에 data 를 직렬화해
    // 사용자 탭 시 라우팅 가능.
    final payload = _encodeData(msg.data);
    // 같은 사용자와 여러 room 을 공유하면 BE 가 room 마다 push 를 보내
    // room 개수만큼 중복 배너가 뜬다. dot 단위 결정적 id 를 사용해 같은
    // dot 의 후속 push 가 새 배너를 쌓지 않고 기존 배너를 교체하게 한다.
    // _handleNotificationTap 과 동일하게 UUID 검증 통과한 값만 사용 —
    // 검증 없이 임의 문자열을 해시에 넣지 않아 두 경로의 신뢰 경계
    // 처리를 일치시킨다 (payload 는 BE 서명 없는 외부 입력으로 취급).
    final rawDotId = msg.data['dot_id'] as String?;
    final dotId = (rawDotId != null && _uuidRe.hasMatch(rawDotId))
        ? rawDotId
        : null;
    final notifId = dotId != null
        ? ('${msg.data['type']}:$dotId'.hashCode & 0x7fffffff)
        : msg.hashCode;
    await _localNotifications.show(
      notifId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _foregroundChannel.id,
          _foregroundChannel.name,
          channelDescription: _foregroundChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          // notifId 재사용으로 배너를 교체할 때 소리/진동이 매번 재발생하지
          // 않도록 억제 — 중복 push 가 여러 번 알림음을 울리는 것을 방지.
          // Android 전용 플래그. iOS(DarwinNotificationDetails)는 같은 id 로
          // 배너를 교체하긴 하지만 교체마다 알림음이 다시 울릴 수 있다.
          onlyAlertOnce: true,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    final data = _decodeData(payload);
    _handleNotificationTap(data);
  }

  // ── 라우팅 ────────────────────────────────────────────

  /// FCM data payload 기반 라우팅. payload 형식:
  ///   { type: 'comment'|'mention', room_id, dot_id?, dot_date? }
  ///
  /// dot_id 있으면 `/rooms/:id/map?dotId=...` (shared map + 시트 자동),
  /// 없으면 `/rooms/:id` (룸 메인).
  ///
  /// **보안 가드**: 외부에서 들어오는 신뢰 경계(payload) — 모든 id 가
  /// UUID 형식, date 는 YYYY-MM-DD 형식인지 정규식 검증. 잘못된 형식은
  /// 조용히 무시 (라우터 경로 인젝션 / GoRouter assertion 크래시 차단).
  static final _uuidRe =
      RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-'
          r'[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
  static final _dateRe = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  void _handleNotificationTap(Map<String, dynamic> data) {
    final roomId = data['room_id'] as String?;
    if (roomId == null || !_uuidRe.hasMatch(roomId)) {
      debugPrint('[FCM] tap — invalid/missing room_id, skip');
      return;
    }
    final rawDate = data['dot_date'] as String?;
    final dateStr = (rawDate != null && _dateRe.hasMatch(rawDate))
        ? rawDate
        : DottieDateUtils.toDateString(DateTime.now());
    final dotId = data['dot_id'] as String?;
    final validDotId =
        (dotId != null && dotId.isNotEmpty && _uuidRe.hasMatch(dotId))
            ? dotId
            : null;

    assert(() {
      debugPrint(
          '[FCM] tap → /dot-map (roomId=$roomId, date=$dateStr, dotId=$validDotId)');
      return true;
    }());

    // /rooms/:id/map 은 StatefulShellRoute 내부 중첩 경로 — shell 밖(알림 핸들러)에서
    // push 하면 navigator stack 이 어긋나 반복 네비게이션이 발생함.
    // /dot-map 은 shell-external fullscreen alias 로 이 문제가 없음.
    appRouter.push(
      AppRoutes.dotMap,
      extra: {
        'roomId': roomId,
        'date': dateStr,
        if (validDotId != null) 'dotId': validDotId,
      },
    );
  }

  // ── 페이로드 직렬화 ─────────────────────────────────────
  // local_notifications 의 payload 는 String 한 개라 data Map 을 query-string
  // 형태로 인코딩. JSON 도 가능하지만 dependency 최소화.

  static String _encodeData(Map<String, dynamic> data) {
    return data.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');
  }

  static Map<String, dynamic> _decodeData(String payload) {
    final result = <String, dynamic>{};
    for (final pair in payload.split('&')) {
      final idx = pair.indexOf('=');
      if (idx <= 0) continue;
      final k = Uri.decodeComponent(pair.substring(0, idx));
      final v = Uri.decodeComponent(pair.substring(idx + 1));
      result[k] = v;
    }
    return result;
  }
}

/// 앱 평생 유지되는 singleton — keepAlive.
///
/// prefs 는 watch 가 아닌 listen — 토글 변경 시 service 에 push 만 하고
/// 새 인스턴스 생성은 안 함 (Firebase listener 가 끊겨버리는 것 방지).
@Riverpod(keepAlive: true)
PushNotificationService pushNotificationService(Ref ref) {
  final service =
      PushNotificationService(ref.watch(pushTokenRemoteSourceProvider), null);
  // prefs 로딩 완료 시 / 토글 변경 시 service 에 주입.
  ref.listen<AsyncValue<NotificationPreferences>>(
    notificationPreferencesNotifierProvider,
    (_, next) {
      final prefs = next.valueOrNull;
      if (prefs != null) service.updatePreferences(prefs);
    },
    fireImmediately: true,
  );
  ref.onDispose(service.dispose);
  return service;
}
