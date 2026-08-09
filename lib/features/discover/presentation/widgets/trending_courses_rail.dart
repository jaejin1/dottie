import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../feed_courses_provider.dart';
import 'discover_course_card.dart';

/// 홈 피드 상단 "지금 뜨는 코스" 가로 레일 — 숨은 둘러보기 진입점 겸 발견 채널.
///
/// `feedCoursesProvider`(top-N, 표시 전용) 구독. 로딩/빈/에러 시 완전히 숨어
/// 홈 피드를 방해하지 않는다. 카드는 정적 하트 변형(레일 오발 방지), 탭 → 상세.
/// 헤더의 "더보기" → 전체 둘러보기(`/todos/discover`).
class TrendingCoursesRail extends ConsumerWidget {
  const TrendingCoursesRail({super.key});

  // 카드 폭 고정 → 그리드와 동일 비율(0.72)로 높이 산출.
  static const double _cardWidth = 150;
  static const double _cardHeight = _cardWidth / 0.72; // ≈ 208

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courses = ref.watch(feedCoursesProvider).valueOrNull ?? const [];
    if (courses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 8, 8),
          child: Row(
            children: [
              Text(
                '🔥 지금 뜨는 코스',
                style: GoogleFonts.notoSansKr(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: DottieColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/todos/discover'),
                style: TextButton.styleFrom(
                  foregroundColor: DottieColors.textSecondary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '더보기',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: DottieColors.textSecondary,
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: _cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: courses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => SizedBox(
              width: _cardWidth,
              child: DiscoverCourseCard(
                course: courses[i],
                interactiveLike: false,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
