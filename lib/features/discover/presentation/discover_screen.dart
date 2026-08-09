import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../shared/utils/error_messages.dart';
import 'discover_provider.dart';
import 'widgets/discover_course_card.dart';

/// 공개 코스 둘러보기 — 인기/최신 정렬 + 태그 필터 + 그리드 무한 스크롤.
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _scrollController = ScrollController();

  // 편집 화면 taxonomy 와 동일.
  static const List<String> _tags = [
    '데이트', '맛집', '카페', '가족여행', '당일치기', '액티비티', '야경', '여행',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      ref.read(discoverFeedProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(discoverFeedProvider);
    final state = async.valueOrNull;

    return Scaffold(
      backgroundColor: DottieColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '둘러보기',
              style: GoogleFonts.jua(
                fontSize: 22,
                color: DottieColors.textPrimary,
                letterSpacing: -0.5,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '요즘 뜨는 스팟 코스',
              style: GoogleFonts.notoSansKr(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: DottieColors.textHint,
              ),
            ),
          ],
        ),
        centerTitle: false,
        toolbarHeight: 62,
        backgroundColor: DottieColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: Column(
            children: [
              // 정렬 — 언더라인 탭 (좌측 정렬, 이모지/알약 제거)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      Dimensions.md, 2, Dimensions.md, 10),
                  child: _SortTabs(
                    sort: state?.sort ?? 'trending',
                    onChanged: (s) =>
                        ref.read(discoverFeedProvider.notifier).setSort(s),
                  ),
                ),
              ),
              // 태그 필터
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.md),
                  children: [
                    for (final t in _tags) ...[
                      _TagChip(
                        label: t,
                        selected: state?.tag == t,
                        onTap: () =>
                            ref.read(discoverFeedProvider.notifier).setTag(t),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(discoverFeedProvider.notifier).refresh(),
        color: DottieColors.primary,
        child: async.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorView(
            message: userMessageFor(e),
            onRetry: () => ref.read(discoverFeedProvider.notifier).refresh(),
          ),
          data: (s) => _Grid(state: s, scrollController: _scrollController),
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.state, required this.scrollController});
  final DiscoverFeedState state;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    if (state.courses.isEmpty) {
      return const _EmptyView();
    }
    return GridView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
          Dimensions.md, Dimensions.sm, Dimensions.md, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: state.courses.length + (state.loadingMore ? 2 : 0),
      itemBuilder: (context, i) {
        if (i >= state.courses.length) {
          return const _CardSkeleton();
        }
        return DiscoverCourseCard(course: state.courses[i]);
      },
    );
  }
}

/// 정렬 — 언더라인 텍스트 탭. 선택 시 굵게 + 코랄 밑줄 바가 슬라이드.
class _SortTabs extends StatelessWidget {
  const _SortTabs({required this.sort, required this.onChanged});
  final String sort;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _tab('인기', 'trending'),
        const SizedBox(width: 20),
        _tab('최신', 'new'),
      ],
    );
  }

  Widget _tab(String label, String value) {
    final selected = sort == value;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(value),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.notoSansKr(
              fontSize: 15,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color:
                  selected ? DottieColors.textPrimary : DottieColors.textHint,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 5),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: 2.5,
            width: selected ? 16 : 0,
            decoration: BoxDecoration(
              color: DottieColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected
              ? DottieColors.primary
              : DottieColors.surfaceVariant,
          borderRadius: BorderRadius.circular(19),
        ),
        child: Text(
          '#$label',
          style: GoogleFonts.notoSansKr(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : DottieColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: DottieColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
      );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) {
    // RefreshIndicator 안에서 당겨 새로고침 가능하도록 스크롤 가능한 빈 상태.
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.28),
        Center(
          child: Column(
            children: [
              const Text('🧭', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text(
                '아직 공개된 코스가 없어요',
                style: GoogleFonts.notoSansKr(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: DottieColors.textPrimary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '조건을 바꾸거나 잠시 후 다시 확인해 보세요',
                style: GoogleFonts.notoSansKr(
                  fontSize: 12,
                  color: DottieColors.textPrimary.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.28),
        Center(
          child: Column(
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansKr(
                  fontSize: 13,
                  color: DottieColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRetry,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
