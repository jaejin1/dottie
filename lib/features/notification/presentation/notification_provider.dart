import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/notification_remote_source.dart';
import '../domain/notification_model.dart';

final notificationProvider = StateNotifierProvider<NotificationNotifier,
    AsyncValue<List<AppNotification>>>(
  (ref) {
    final source = ref.watch(notificationRemoteSourceProvider);
    return NotificationNotifier(source);
  },
);

class NotificationNotifier
    extends StateNotifier<AsyncValue<List<AppNotification>>> {
  final NotificationRemoteSource _source;

  NotificationNotifier(this._source) : super(const AsyncLoading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncLoading();
    try {
      final notifications = await _source.getNotifications();
      state = AsyncData(notifications);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() => _load();

  Future<void> markRead(String id) async {
    final current = state.valueOrNull;
    if (current == null) return;
    // 이미 읽음 상태면 API 호출 생략 (호출부에서 미리 거를 수도 있음)
    final target = current.firstWhere(
      (n) => n.id == id,
      orElse: () => current.first,
    );
    if (target.isRead) return;
    state = AsyncData(
      current.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList(),
    );
    debugPrint('[Notification] markRead → POST /notifications/$id/read');
    try {
      await _source.markRead(id);
    } catch (e) {
      debugPrint('[Notification] markRead error: $e');
      state = AsyncData(current);
    }
  }

  Future<void> markAllRead() async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (!current.any((n) => !n.isRead)) return;
    state = AsyncData(current.map((n) => n.copyWith(isRead: true)).toList());
    debugPrint('[Notification] markAllRead → POST /notifications/read-all');
    try {
      await _source.markAllRead();
    } catch (e) {
      debugPrint('[Notification] markAllRead error: $e');
      state = AsyncData(current);
    }
  }

  int get unreadCount =>
      state.valueOrNull?.where((n) => !n.isRead).length ?? 0;
}
