import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/color_hex.dart';
import '../../domain/discover_course_model.dart';
import '../discover_provider.dart';

/// 디스커버리 그리드 카드 — 풀블리드 포토 카드.
///
/// 커버 사진(있으면) 또는 accent 그라디언트+이모지가 카드 전체를 채우고, 하단
/// 그라디언트 스크림 위에 이름·작성자·곳수를 흰 글씨로 오버레이. 유형 배지는
/// 좌상단, 좋아요는 우상단(탭 가능). 카드 탭 → 상세(`/todos/:id`, public read).
///
/// 좋아요 하트는 **카드 탭 레이어의 자식이 아니라 Stack 오버레이(형제)** 로 둔다
/// — 중첩 탭 충돌 방지(별도 레이어라 하트 onTap 확실히 발화).
class DiscoverCourseCard extends StatelessWidget {
  const DiscoverCourseCard({
    super.key,
    required this.course,
    this.interactiveLike = true,
  });
  final DiscoverCourse course;

  /// true(기본, 디스커버리 그리드): 우상단 하트 탭 → 좋아요 토글.
  /// false(홈 피드 레일): 정적 인기수 표시만 — 가로 스크롤 중 오발 방지 +
  /// discoverFeedProvider 미로딩 커플링 회피. 좋아요는 카드 탭 → 상세에서.
  final bool interactiveLike;

  @override
  Widget build(BuildContext context) {
    final accent = DottieColors.accentFor(course.id);
    final hasPhoto =
        course.coverImageUrl != null && course.coverImageUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── 배경(사진 또는 accent 그라디언트 + 이모지) ──
            _Background(course: course, accent: accent, hasPhoto: hasPhoto),
            // ── 하단 스크림(텍스트 가독성) ──
            const _BottomScrim(),
            // ── 카드 탭(상세 진입) — 하단 오버레이 콘텐츠 포함 ──
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push('/todos/${course.id}'),
                  child: Padding(
                    padding: const EdgeInsets.all(11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 유형 배지(좌상단)
                        Align(
                          alignment: Alignment.topLeft,
                          child: _TypeBadge(isTrip: course.isTrip),
                        ),
                        const Spacer(),
                        _Overlay(course: course, accent: accent),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // ── 좋아요(우상단, 별도 레이어) — 그리드는 탭 가능, 레일은 정적 ──
            Positioned(
              top: 6,
              right: 6,
              child: interactiveLike
                  ? _HeartButton(course: course)
                  : _LikePill(course: course),
            ),
          ],
        ),
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background({
    required this.course,
    required this.accent,
    required this.hasPhoto,
  });
  final DiscoverCourse course;
  final Color accent;
  final bool hasPhoto;

  @override
  Widget build(BuildContext context) {
    final gradient = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.95),
            accent.withValues(alpha: 0.6),
          ],
        ),
      ),
      // 사진 없을 때만 이모지를 배경 히어로로.
      child: hasPhoto
          ? null
          : Align(
              alignment: const Alignment(0, -0.35),
              child: Text(course.coverEmoji ?? '📍',
                  style: const TextStyle(fontSize: 46)),
            ),
    );
    if (!hasPhoto) return gradient;
    return Stack(
      fit: StackFit.expand,
      children: [
        gradient, // 로딩/에러 시 베이스
        Image.network(
          course.coverImageUrl!,
          fit: BoxFit.cover,
          cacheWidth: 720,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          frameBuilder: (_, child, frame, wasSync) =>
              wasSync || frame != null ? child : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _BottomScrim extends StatelessWidget {
  const _BottomScrim();
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.35, 0.7, 1.0],
          colors: [
            Colors.transparent,
            Color(0x59000000), // black 35%
            Color(0xB3000000), // black 70%
          ],
        ),
      ),
    );
  }
}

/// 하단 오버레이 — 이름 + 작성자 · 곳수(흰 글씨).
class _Overlay extends StatelessWidget {
  const _Overlay({required this.course, required this.accent});
  final DiscoverCourse course;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    const shadow = [Shadow(color: Color(0x8A000000), blurRadius: 4)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          course.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.notoSansKr(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            height: 1.2,
            letterSpacing: -0.2,
            color: Colors.white,
            shadows: shadow,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 15,
              height: 15,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                // BE 가 owner_color_hex(작성자 캐릭터 색)를 보내면 그 색, 없으면 accent.
                color: colorFromHex(course.ownerColorHex, fallback: accent),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white70, width: 1),
              ),
              child: Text(
                course.ownerNickname.isNotEmpty
                    ? course.ownerNickname.characters.first
                    : '?',
                style: const TextStyle(
                    color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                course.ownerNickname.isEmpty ? '익명' : course.ownerNickname,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.notoSansKr(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.9),
                  shadows: shadow,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.place, size: 12, color: Colors.white70),
            const SizedBox(width: 1),
            Text(
              '${course.spotCount}',
              style: GoogleFonts.notoSansKr(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.9),
                shadows: shadow,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.isTrip});
  final bool isTrip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isTrip ? '✈️ 여행' : '📌 모음',
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// 좋아요 버튼 — 흰 하트(비활성)/빨강(활성). 낙관적 토글, 카드 위 별도 레이어.
class _HeartButton extends ConsumerWidget {
  const _HeartButton({required this.course});
  final DiscoverCourse course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(discoverFeedProvider.notifier).toggleLike(course.id);
      },
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              course.likedByMe
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: 18,
              color: course.likedByMe ? DottieColors.error : Colors.white,
              shadows: const [Shadow(color: Color(0x73000000), blurRadius: 4)],
            ),
            if (course.likeCount > 0) ...[
              const SizedBox(width: 3),
              Text(
                '${course.likeCount}',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: [Shadow(color: Color(0x73000000), blurRadius: 4)],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 정적 인기수 — 홈 피드 레일용(탭 불가). likeCount 0 이면 아무것도 안 그림.
class _LikePill extends StatelessWidget {
  const _LikePill({required this.course});
  final DiscoverCourse course;

  @override
  Widget build(BuildContext context) {
    if (course.likeCount <= 0) return const SizedBox.shrink();
    const shadow = [Shadow(color: Color(0x73000000), blurRadius: 4)];
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_rounded,
            size: 15,
            // 내가 이미 좋아요한 코스면 빨강으로 살짝 구분(인기수는 그대로 표시).
            color: course.likedByMe ? DottieColors.error : Colors.white,
            shadows: shadow,
          ),
          const SizedBox(width: 3),
          Text(
            '${course.likeCount}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: shadow,
            ),
          ),
        ],
      ),
    );
  }
}
