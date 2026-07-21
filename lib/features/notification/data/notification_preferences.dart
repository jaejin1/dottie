import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'notification_preferences_remote_source.dart';

part 'notification_preferences.g.dart';

/// 푸시 알림 타입별 on/off 상태 — immutable snapshot.
///
/// 토글은 [NotificationPreferencesNotifier] 가 담당. 이 클래스는 단순 값 + 표시
/// 허용 판정 메서드만 가짐.
class NotificationPreferences {
  const NotificationPreferences({
    required this.commentOnMyDot,
    required this.newDotInMyRoom,
  });

  final bool commentOnMyDot;
  final bool newDotInMyRoom;

  static const defaults = NotificationPreferences(
    commentOnMyDot: true,
    newDotInMyRoom: true,
  );

  /// FCM data payload 의 `type` 으로 표시 허용 여부 판정.
  /// BE spec (notification-preferences API):
  ///   - 'comment' / 'mention' → commentOnMyDot (MVP 묶음)
  ///   - 'dot_created' → newDotInMyRoom
  ///   - 기타 / null → 항상 허용 (안전망 — fail-open)
  bool shouldShowForType(String? type) {
    switch (type) {
      case 'comment':
      case 'mention':
        return commentOnMyDot;
      case 'dot_created':
        return newDotInMyRoom;
      default:
        return true;
    }
  }
}

/// 푸시 알림 환경설정 — BE 우선 + SharedPreferences 캐시 폴백.
///
/// **소스 우선순위**:
/// 1. 앱 시작 시 BE `/v1/users/me/notification-preferences` GET 시도
/// 2. 성공 → 응답값을 SharedPreferences 에 캐시 후 사용
/// 3. 실패 (BE 미배포 404/501, 네트워크 오류) → SharedPreferences 캐시값 사용
///
/// **토글 동작** ([setCommentOnMyDot] / [setNewDotInMyRoom]):
/// - BE PATCH → 응답 echo 로 state + 캐시 갱신
/// - BE 미배포 (404/501) / 네트워크 오류 → remote source 가 흡수해 `null` 반환
///   → 로컬만 갱신 (오프라인-friendly)
/// - 그 외 4xx (400/401 등) → throw — 호출자가 snackbar + UI 롤백
///
/// **2차 방어**: BE 가 차단 누락한 경우에도
/// [push_notification_service._handleForeground] 가 [shouldShowForType] 로
/// foreground in-app banner 만 차단 — race condition / 오프라인 안전망.
@Riverpod(keepAlive: true)
class NotificationPreferencesNotifier
    extends _$NotificationPreferencesNotifier {
  // SharedPreferences 키. clearLocal 에서 같이 사용하므로 public.
  static const keyComment = 'notif.comment_on_my_dot';
  static const keyNewDot = 'notif.new_dot_in_my_room';

  // 호환 — 기존 코드 안 깨지게 alias.
  static const _keyComment = keyComment;
  static const _keyNewDot = keyNewDot;

  /// 로그아웃 / 회원 탈퇴 시 호출 — 사용자 간 toggle 누출 방지.
  /// SharedPreferences 키 제거 + 다음 watch 가 default 부터 시작하도록.
  /// caller (auth_provider) 가 호출 후 provider invalidate 도 같이 해야 즉시
  /// state 가 default 로 리셋됨.
  static Future<void> clearLocal(SharedPreferences prefs) async {
    await prefs.remove(keyComment);
    await prefs.remove(keyNewDot);
  }

  @override
  Future<NotificationPreferences> build() async {
    final prefs = await SharedPreferences.getInstance();
    final remote = ref.watch(notificationPreferencesRemoteSourceProvider);

    final dto = await remote.fetch();
    if (dto != null) {
      // BE 성공 — 캐시 갱신 (다음 부팅 시 첫 프레임 노출용)
      await prefs.setBool(_keyComment, dto.commentOnMyDot);
      await prefs.setBool(_keyNewDot, dto.newDotInMyRoom);
      return NotificationPreferences(
        commentOnMyDot: dto.commentOnMyDot,
        newDotInMyRoom: dto.newDotInMyRoom,
      );
    }

    // BE 실패 — 캐시 사용 (없으면 default true)
    return NotificationPreferences(
      commentOnMyDot: prefs.getBool(_keyComment) ?? true,
      newDotInMyRoom: prefs.getBool(_keyNewDot) ?? true,
    );
  }

  Future<void> setCommentOnMyDot(bool value) =>
      _patch(commentOnMyDot: value);

  Future<void> setNewDotInMyRoom(bool value) =>
      _patch(newDotInMyRoom: value);

  /// in-flight 가드 — 더블탭 / 연속 토글 시 PATCH 응답 순서가 뒤집혀
  /// 마지막 응답이 사용자의 의도와 반대로 state 를 덮어쓰는 race 방지.
  /// 두 번째 호출은 즉시 return (Switch 가 watch 한 state 따라가므로 UI 변화 X).
  bool _patchInFlight = false;

  Future<void> _patch({bool? commentOnMyDot, bool? newDotInMyRoom}) async {
    if (_patchInFlight) {
      debugPrint('[notif-prefs] patch already in flight — ignoring');
      return;
    }
    _patchInFlight = true;
    try {
      final current = await future;
      final remote = ref.read(notificationPreferencesRemoteSourceProvider);

      // BE PATCH 시도. 404/501/네트워크 오류는 dto=null 로 흡수됨.
      // 400/401 같은 진짜 에러는 throw 되어 호출자가 처리.
      final dto = await remote.patch(
        commentOnMyDot: commentOnMyDot,
        newDotInMyRoom: newDotInMyRoom,
      );

      final newComment =
          dto?.commentOnMyDot ?? commentOnMyDot ?? current.commentOnMyDot;
      final newNewDot =
          dto?.newDotInMyRoom ?? newDotInMyRoom ?? current.newDotInMyRoom;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyComment, newComment);
      await prefs.setBool(_keyNewDot, newNewDot);

      state = AsyncData(NotificationPreferences(
        commentOnMyDot: newComment,
        newDotInMyRoom: newNewDot,
      ));
    } finally {
      _patchInFlight = false;
    }
  }

  /// 로그인 / push token 등록 직후 BE 와 강제 동기화.
  /// 실패는 무시 — 캐시 그대로 사용.
  Future<void> syncFromServer() async {
    try {
      ref.invalidateSelf();
      await future;
    } catch (e, st) {
      assert(() {
        debugPrint('[notif-prefs] sync failed: $e\n$st');
        return true;
      }());
    }
  }
}
