import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/notification_remote_source.dart';
import '../domain/notification_model.dart';

final notificationProvider = StateNotifierProvider<NotificationNotifier,
    AsyncValue<List<AppNotification>>>(
  (ref) {
    final source = ref.watch(notificationRemoteSourceProvider);
    return NotificationNotifier(source, ref);
  },
);

class NotificationNotifier
    extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final NotificationRemoteSource _source;
  final Ref _ref;

  NotificationNotifier(this._source, this._ref)
      : super(const AsyncData([])) {
    // 인증 상태에 따라 자동 로드/리셋. 미인증일 때는 호출 자체가 나가지 않아
    // 라우터 redirect 와의 race(/home 진입 직후 stale token 으로 401) 를 회피.
    _ref.listen<bool>(
      isAuthenticatedProvider,
      (prev, next) {
        if (next) {
          _load();
        } else if (prev == true) {
          state = const AsyncData([]);
        }
      },
      fireImmediately: true,
    );
  }

  Future<void> _load() async {
    if (!_ref.read(isAuthenticatedProvider)) return;
    state = const AsyncLoading();
    try {
      final notifications = await _source.getNotifications();
      state = AsyncData(collapseDuplicates(notifications));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() => _load();

  /// BE 가 같은 사용자와 여러 room 을 공유할 때 room 마다 만드는 중복
  /// `dotCreated` 알림을 하나로 접는다. comment/mention 은 그대로 통과.
  /// 대표 row = 그룹 중 최신 createdAt. 그룹 내 하나라도 unread 면 대표도
  /// unread 로 취급해 배지 카운트가 실제 unread 존재 여부와 어긋나지 않게 한다.
  @visibleForTesting
  static List<AppNotification> collapseDuplicates(
      List<AppNotification> raw) {
    final result = <AppNotification>[];
    final groupIndexByKey = <String, int>{};

    for (final n in raw) {
      if (n.type != NotificationType.dotCreated) {
        result.add(n);
        continue;
      }
      final key = n.dedupKey;
      final existingIdx = groupIndexByKey[key];
      if (existingIdx == null) {
        groupIndexByKey[key] = result.length;
        result.add(n);
        continue;
      }
      final existing = result[existingIdx];
      final representative =
          n.createdAt.isAfter(existing.createdAt) ? n : existing;
      final collapsed = n.createdAt.isAfter(existing.createdAt) ? existing : n;
      result[existingIdx] = representative.copyWith(
        isRead: existing.isRead && n.isRead,
        collapsedIds: [
          ...existing.collapsedIds,
          ...n.collapsedIds,
          collapsed.id,
        ],
      );
    }
    return result;
  }

  Future<void> markRead(String id) async {
    final current = state.valueOrNull;
    if (current == null) return;
    // 대표 row 로 매치되면 그 그룹 전체(collapsedIds 포함)를 읽음 처리 대상으로.
    // 대표로 못 찾으면 이미 다른 그룹의 collapsedIds 안에 접혀 있을 수 있음
    // (탭과 _load() 재로드 경합 시) — 그 경우 해당 그룹을 찾아 처리한다.
    // 둘 다 아니면 목록에 없는 id 이므로 서버에는 단건만 그대로 전달한다.
    // 과거에 `orElse: () => current.first` 로 폴백했었는데, 매치 실패 시
    // 무관한 첫 그룹을 읽음 처리해버리는 버그가 있어 제거했다.
    AppNotification? target;
    for (final n in current) {
      if (n.id == id || n.collapsedIds.contains(id)) {
        target = n;
        break;
      }
    }
    if (target != null && target.isRead) return;

    if (target != null) {
      state = AsyncData(
        current
            .map((n) => n.id == target!.id ? n.copyWith(isRead: true) : n)
            .toList(),
      );
    }
    // 접힌 중복 row(다른 room 의 같은 dotCreated 알림)도 함께 읽음 처리 —
    // 그렇지 않으면 리스트엔 안 보이는 unread row 때문에 배지 숫자만 남는다.
    // 각 호출을 독립적으로 catch 해 하나의 row 실패가 나머지 낙관적
    // 갱신 전체를 되돌리지 않도록 한다.
    final idsToMark = target != null ? [target.id, ...target.collapsedIds] : [id];
    assert(() {
      debugPrint(
          '[Notification] markRead → POST /notifications/{$idsToMark}/read');
      return true;
    }());
    await Future.wait(idsToMark.map((i) async {
      try {
        await _source.markRead(i);
      } catch (e) {
        assert(() {
          debugPrint('[Notification] markRead error for $i: $e');
          return true;
        }());
      }
    }));
  }

  // markAllRead 는 실패 시 전체 롤백(단일 batch 요청이라 부분 성공 개념이
  // 없음), markRead 는 row 별 개별 요청이라 부분 실패를 허용하고 다음
  // _load() 에서 서버 상태로 자연 수렴한다 — 의도된 비대칭.
  Future<void> markAllRead() async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (!current.any((n) => !n.isRead)) return;
    state = AsyncData(current.map((n) => n.copyWith(isRead: true)).toList());
    assert(() {
      debugPrint('[Notification] markAllRead → POST /notifications/read-all');
      return true;
    }());
    try {
      await _source.markAllRead();
    } catch (e) {
      assert(() {
        debugPrint('[Notification] markAllRead error: $e');
        return true;
      }());
      state = AsyncData(current);
    }
  }

  int get unreadCount =>
      state.valueOrNull?.where((n) => !n.isRead).length ?? 0;
}
