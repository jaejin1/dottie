import 'package:flutter_test/flutter_test.dart';
import 'package:dottie/features/notification/domain/notification_model.dart';
import 'package:dottie/features/notification/presentation/notification_provider.dart';

AppNotification _dotCreated({
  required String id,
  required String actorId,
  required String roomId,
  String? dotDate,
  bool isRead = false,
  DateTime? createdAt,
}) {
  return AppNotification(
    id: id,
    type: NotificationType.dotCreated,
    actorId: actorId,
    actorNickname: 'actor-$actorId',
    dotId: 'dot-$id',
    roomId: roomId,
    dotDate: dotDate,
    isRead: isRead,
    createdAt: createdAt ?? DateTime(2026, 7, 5, 9),
  );
}

void main() {
  group('NotificationNotifier.collapseDuplicates', () {
    test('같은 actor+date, 다른 roomId 의 dotCreated 3건 → 1건 + collapsedIds 2개',
        () {
      final raw = [
        _dotCreated(id: '1', actorId: 'a1', roomId: 'r1', dotDate: '2026-07-05'),
        _dotCreated(id: '2', actorId: 'a1', roomId: 'r2', dotDate: '2026-07-05'),
        _dotCreated(id: '3', actorId: 'a1', roomId: 'r3', dotDate: '2026-07-05'),
      ];

      final result = NotificationNotifier.collapseDuplicates(raw);

      expect(result, hasLength(1));
      expect(result.first.collapsedIds, containsAll(['2', '3']));
      expect(result.first.collapsedIds, hasLength(2));
    });

    test('createdAt 오름차순 3건 연쇄 → 대표는 최신(id 3), collapsedIds 는 1,2 누적', () {
      final raw = [
        _dotCreated(
          id: '1',
          actorId: 'a1',
          roomId: 'r1',
          dotDate: '2026-07-05',
          createdAt: DateTime(2026, 7, 5, 9),
        ),
        _dotCreated(
          id: '2',
          actorId: 'a1',
          roomId: 'r2',
          dotDate: '2026-07-05',
          createdAt: DateTime(2026, 7, 5, 10),
        ),
        _dotCreated(
          id: '3',
          actorId: 'a1',
          roomId: 'r3',
          dotDate: '2026-07-05',
          createdAt: DateTime(2026, 7, 5, 11),
        ),
      ];

      final result = NotificationNotifier.collapseDuplicates(raw);

      expect(result, hasLength(1));
      expect(result.first.id, '3');
      expect(result.first.collapsedIds, containsAll(['1', '2']));
      expect(result.first.collapsedIds, hasLength(2));
    });

    test('comment/mention 은 접히지 않음', () {
      final raw = [
        AppNotification(
          id: 'c1',
          type: NotificationType.comment,
          actorId: 'a1',
          actorNickname: 'a1',
          roomId: 'r1',
          isRead: false,
          createdAt: DateTime(2026, 7, 5),
        ),
        AppNotification(
          id: 'c2',
          type: NotificationType.comment,
          actorId: 'a1',
          actorNickname: 'a1',
          roomId: 'r2',
          isRead: false,
          createdAt: DateTime(2026, 7, 5),
        ),
      ];

      final result = NotificationNotifier.collapseDuplicates(raw);

      expect(result, hasLength(2));
    });

    test('그룹 내 하나라도 unread 면 대표도 unread', () {
      final raw = [
        _dotCreated(
          id: '1',
          actorId: 'a1',
          roomId: 'r1',
          dotDate: '2026-07-05',
          isRead: true,
          createdAt: DateTime(2026, 7, 5, 9),
        ),
        _dotCreated(
          id: '2',
          actorId: 'a1',
          roomId: 'r2',
          dotDate: '2026-07-05',
          isRead: false,
          createdAt: DateTime(2026, 7, 5, 10),
        ),
      ];

      final result = NotificationNotifier.collapseDuplicates(raw);

      expect(result, hasLength(1));
      expect(result.first.isRead, isFalse);
      // 대표는 최신 createdAt(id=2) 이어야 함
      expect(result.first.id, '2');
      expect(result.first.collapsedIds, ['1']);
    });

    test('dotDate 가 null 이면 createdAt 의 로컬 날짜로 그룹핑', () {
      final raw = [
        _dotCreated(
          id: '1',
          actorId: 'a1',
          roomId: 'r1',
          dotDate: null,
          createdAt: DateTime(2026, 7, 5, 9),
        ),
        _dotCreated(
          id: '2',
          actorId: 'a1',
          roomId: 'r2',
          dotDate: null,
          createdAt: DateTime(2026, 7, 5, 20),
        ),
      ];

      final result = NotificationNotifier.collapseDuplicates(raw);

      expect(result, hasLength(1));
    });

    test('다른 actor 는 접히지 않음', () {
      final raw = [
        _dotCreated(id: '1', actorId: 'a1', roomId: 'r1', dotDate: '2026-07-05'),
        _dotCreated(id: '2', actorId: 'a2', roomId: 'r1', dotDate: '2026-07-05'),
      ];

      final result = NotificationNotifier.collapseDuplicates(raw);

      expect(result, hasLength(2));
    });

    test('다른 날짜는 접히지 않음', () {
      final raw = [
        _dotCreated(id: '1', actorId: 'a1', roomId: 'r1', dotDate: '2026-07-04'),
        _dotCreated(id: '2', actorId: 'a1', roomId: 'r1', dotDate: '2026-07-05'),
      ];

      final result = NotificationNotifier.collapseDuplicates(raw);

      expect(result, hasLength(2));
    });
  });
}
