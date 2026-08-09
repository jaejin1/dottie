import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dottie/features/discover/data/discover_remote_source.dart';
import 'package:dottie/features/discover/domain/discover_course_model.dart';
import 'package:dottie/features/discover/presentation/discover_screen.dart';

/// 좋아요 흐름 격리용 fake — 실제 Dio 호출 없이 setLike 결과를 흉내.
class _FakeRemote extends DiscoverRemoteSource {
  _FakeRemote() : super(Dio());
  int likeCalls = 0;
  bool? lastLike;

  @override
  Future<DiscoverPage> fetch({
    String sort = 'trending',
    String? tag,
    String? type,
    String? cursor,
    int limit = 20,
  }) async {
    return (
      courses: <DiscoverCourse>[
        const DiscoverCourse(
          id: 'c1',
          name: '테스트 코스',
          coverEmoji: '☕',
          courseType: 'trip',
          tags: ['카페'],
          spotCount: 5,
          likeCount: 40,
          likedByMe: false,
          ownerNickname: '다정',
        ),
      ],
      nextCursor: null,
    );
  }

  @override
  Future<({int likeCount, bool likedByMe})> setLike(
      String courseId, bool like) async {
    likeCalls++;
    lastLike = like;
    return (likeCount: like ? 41 : 40, likedByMe: like);
  }
}

void main() {
  testWidgets('둘러보기 카드 하트 탭 → 좋아요 카운트/아이콘 갱신 + 카드 네비 미발동',
      (tester) async {
    // 폰 크기로 고정 — 넓은 기본 surface(800px)면 2열 카드가 커져 하트가
    // 뷰포트 밖으로 밀려 탭이 빗나간다(실기기와 무관한 테스트 아티팩트).
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final fake = _FakeRemote();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [discoverRemoteSourceProvider.overrideWithValue(fake)],
        child: const MaterialApp(home: DiscoverScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // 초기: 40 · 빈 하트
    expect(find.text('40'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsNothing);

    // 하트 탭 (카드 InkWell 로 버블링되면 context.push 가 GoRouter 부재로
    // 예외 → 테스트 실패로 드러남).
    await tester.tap(find.byIcon(Icons.favorite_border_rounded));
    await tester.pump(); // 낙관적 반영
    await tester.pump(); // setLike 완료 반영
    await tester.pumpAndSettle();

    expect(fake.likeCalls, 1);
    expect(fake.lastLike, true);
    expect(find.text('41'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border_rounded), findsNothing);
  });
}
