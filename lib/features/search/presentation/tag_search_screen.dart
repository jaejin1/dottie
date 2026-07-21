import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/typography.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/color_hex.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/utils/error_messages.dart';
import '../../../shared/widgets/dot_detail_sheet.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../feed/domain/feed_entry.dart';
import '../../feed/presentation/widgets/feed_card.dart';
import '../../recording/domain/tag_parser.dart';
import '../../room/domain/room_model.dart';
import '../../room/presentation/room_provider.dart';
import '../domain/tag_search_models.dart';
import 'tag_search_provider.dart';

/// 태그 기반 dot 검색 화면 (하단 네비 탭).
class TagSearchScreen extends ConsumerStatefulWidget {
  const TagSearchScreen({super.key});

  @override
  ConsumerState<TagSearchScreen> createState() => _TagSearchScreenState();
}

class _TagSearchScreenState extends ConsumerState<TagSearchScreen> {
  final _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(tagSearchProvider);
    final notifier = ref.read(tagSearchProvider.notifier);

    // BE 가 응답한 비즈니스 에러는 SnackBar 로 안내 (UI 자체는 이전 정상 상태 유지).
    // 비교는 인스턴스 동일성 대신 code 로 — 같은 종류 에러 반복 발생 시 listen 이
    // 매번 발화하지 않도록 (`copyWith` 가 latestException 인스턴스를 새로 만들 수 있음).
    ref.listen<TagSearchState>(tagSearchProvider, (prev, next) {
      final exc = next.latestException;
      if (exc == null) return;
      if (prev?.latestException?.code == exc.code &&
          prev?.latestException?.message == exc.message) {
        return;
      }
      if (!mounted) return;
      final msg = switch (exc.code) {
        'INVALID_TAG_FORMAT' => '태그 형식이 올바르지 않아요',
        'TAGS_TOO_MANY' => '태그는 최대 10개까지만 가능해요',
        'INVALID_DATE' => '날짜 형식이 올바르지 않아요',
        'INVALID_DATE_RANGE' => '시작 날짜가 종료 날짜보다 나중이에요',
        'INVALID_CURSOR' => '검색 결과가 만료돼서 처음부터 다시 불러올게요',
        _ => exc.message ?? '검색 중 오류가 발생했어요',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      // cursor 만료는 자동 복구 — 한 build 사이클당 1회만 시도 (notifier 측 가드).
      if (exc.code == 'INVALID_CURSOR') {
        ref.read(tagSearchProvider.notifier).tryRecoverFromCursorError();
      }
    });

    return Scaffold(
      backgroundColor: DottieColors.background,
      appBar: AppBar(
        title: Text('검색', style: AppTypography.tabHeader()),
        centerTitle: false,
        backgroundColor: DottieColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (searchState.tags.isNotEmpty)
            IconButton(
              tooltip: '초기화',
              icon: const Icon(Icons.refresh_rounded,
                  color: DottieColors.textSecondary),
              onPressed: notifier.clear,
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchBar(
            controller: _inputController,
            onSubmit: (raw) {
              final cleaned = raw.trim().replaceFirst('#', '');
              if (cleaned.isEmpty) return; // 빈 입력 — silent.
              final t = TagParser.normalize(cleaned);
              if (t == null) {
                // 입력 텍스트는 보존(사용자가 수정할 수 있도록) + 안내.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('태그는 한글/영문/숫자/_ 만 사용할 수 있어요 (최대 30자)'),
                  ),
                );
                return;
              }
              notifier.addTag(t);
              _inputController.clear();
            },
          ),
          if (searchState.tags.isNotEmpty)
            _ActiveTagChips(
              tags: searchState.tags,
              matchMode: searchState.matchMode,
              onRemove: notifier.removeTag,
              onToggleMatch: () => notifier.setMatchMode(
                searchState.matchMode == TagMatchMode.all
                    ? TagMatchMode.any
                    : TagMatchMode.all,
              ),
            ),
          const SizedBox(height: 4),
          Expanded(
            child: searchState.tags.isEmpty
                ? const _EmptyHero()
                : _ResultList(state: searchState),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onSubmit});
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          Dimensions.md, 4, Dimensions.md, Dimensions.sm),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: '#태그 입력 후 엔터',
          prefixIcon: const Icon(Icons.tag_rounded, size: 20),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusFull),
            borderSide:
                const BorderSide(color: DottieColors.border, width: 0.8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusFull),
            borderSide:
                const BorderSide(color: DottieColors.border, width: 0.8),
          ),
        ),
        onSubmitted: onSubmit,
      ),
    );
  }
}

class _ActiveTagChips extends StatelessWidget {
  const _ActiveTagChips({
    required this.tags,
    required this.matchMode,
    required this.onRemove,
    required this.onToggleMatch,
  });

  final List<String> tags;
  final TagMatchMode matchMode;
  final ValueChanged<String> onRemove;
  final VoidCallback onToggleMatch;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(Dimensions.md, 0, Dimensions.md, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags
                  .map((t) => _RemovableTagChip(tag: t, onRemove: onRemove))
                  .toList(),
            ),
          ),
          if (tags.length >= 2) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onToggleMatch,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: DottieColors.surfaceVariant,
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusFull),
                  border: Border.all(
                      color: DottieColors.border, width: 0.8),
                ),
                child: Text(
                  matchMode == TagMatchMode.all ? 'AND' : 'OR',
                  style: GoogleFonts.notoSansKr(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: DottieColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RemovableTagChip extends StatelessWidget {
  const _RemovableTagChip({required this.tag, required this.onRemove});
  final String tag;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DottieColors.primary.withAlpha(30),
      borderRadius: BorderRadius.circular(Dimensions.radiusFull),
      child: InkWell(
        borderRadius: BorderRadius.circular(Dimensions.radiusFull),
        onTap: () => onRemove(tag),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '#$tag',
                style: GoogleFonts.notoSansKr(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: DottieColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.close_rounded,
                size: 14,
                color: DottieColors.primary.withAlpha(180),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyHero extends ConsumerWidget {
  const _EmptyHero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomListProvider);
    final rooms = roomsAsync.valueOrNull ?? const [];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
          Dimensions.md, Dimensions.md, Dimensions.md, Dimensions.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // cross-room 검색 scope 안내.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: DottieColors.primary.withAlpha(14),
              borderRadius: BorderRadius.circular(Dimensions.radiusMd),
              border: Border.all(
                color: DottieColors.primary.withAlpha(40),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: DottieColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '내가 속한 모든 방의 #태그를 함께 검색해요',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: DottieColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 본인 인기 태그 (roomId 미지정).
          const _PopularTagsSection(title: '내 인기태그', roomId: null),

          // 방별 인기 태그 — 룸마다 섹션 추가. BE 호출은 룸 수만큼 N회.
          for (final room in rooms) ...[
            const SizedBox(height: 20),
            _PopularTagsSection(
              title: '${room.name} 인기태그',
              roomId: room.id,
            ),
          ],
        ],
      ),
    );
  }
}

/// 인기 태그 섹션 — 본인 또는 특정 방. [roomId] null = 본인.
class _PopularTagsSection extends ConsumerWidget {
  const _PopularTagsSection({required this.title, required this.roomId});
  final String title;
  final String? roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(popularTagsProvider(roomId: roomId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.notoSansKr(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: DottieColors.textSecondary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 12),
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (e, _) => Text(
            userMessageFor(e),
            style: GoogleFonts.notoSansKr(
                fontSize: 12, color: DottieColors.textHint),
          ),
          data: (list) {
            if (list.isEmpty) {
              // 본인 섹션이 비어있으면 큰 empty 상태, 룸 섹션이 비어있으면
              // 한 줄 안내 (방마다 큰 placeholder 가 반복되면 산만).
              if (roomId == null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.tag_rounded,
                          size: 40,
                          color: DottieColors.textHint.withAlpha(120),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '아직 태그가 없어요\ndot 메모에 #태그를 적어보세요',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSansKr(
                            fontSize: 13,
                            color: DottieColors.textHint,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Text(
                '아직 #태그가 없어요',
                style: GoogleFonts.notoSansKr(
                  fontSize: 12,
                  color: DottieColors.textHint,
                ),
              );
            }
            return Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  list.map((t) => _PopularTagChip(item: t)).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _PopularTagChip extends ConsumerWidget {
  const _PopularTagChip({required this.item});
  final TagWithCount item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () =>
          ref.read(tagSearchProvider.notifier).addTag(item.tag),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: DottieColors.surfaceVariant,
          borderRadius: BorderRadius.circular(Dimensions.radiusFull),
          border: Border.all(color: DottieColors.border, width: 0.8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '#${item.tag}',
              style: GoogleFonts.notoSansKr(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: DottieColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${item.count}',
              style: GoogleFonts.notoSansKr(
                fontSize: 11,
                color: DottieColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultList extends ConsumerStatefulWidget {
  const _ResultList({required this.state});
  final TagSearchState state;

  @override
  ConsumerState<_ResultList> createState() => _ResultListState();
}

class _ResultListState extends ConsumerState<_ResultList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    // 끝에서 200px 남으면 다음 페이지 로드.
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      ref.read(tagSearchProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    if (state.isLoading && state.page == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final results = state.page?.results ?? const <TagSearchResult>[];
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                size: 40,
                color: DottieColors.textHint.withAlpha(140)),
            const SizedBox(height: 8),
            Text(
              '결과가 없어요',
              style: GoogleFonts.notoSansKr(
                fontSize: 14,
                color: DottieColors.textHint,
              ),
            ),
          ],
        ),
      );
    }
    final hasMore = state.page?.hasMore ?? false;
    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.zero,
      itemCount: results.length + (hasMore ? 1 : 0),
      separatorBuilder: (_, i) {
        if (i == results.length - 1 && !hasMore) {
          return const SizedBox.shrink();
        }
        return const Divider(
          height: 1,
          thickness: 1,
          color: DottieColors.border,
        );
      },
      itemBuilder: (_, i) {
        if (i >= results.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        return _TagSearchResultCard(result: results[i])
            .animate()
            .fadeIn(duration: 280.ms, delay: (i * 30).ms)
            .slideY(begin: 0.05, end: 0, duration: 280.ms);
      },
    );
  }
}

/// 태그 검색 결과 카드 — timeline 의 [FeedCard] 와 동일 디자인.
///
/// 동작:
///   탭 → [DotDetailSheet] (사진/장소/메모/댓글 표시)
///   시트의 "지도에서 보기" → [AppRoutes.dotMap] 으로 push (fullscreen alias).
///   shell-nested `/rooms/:id/map` 을 shell 밖 `/search` 에서 직접 push 하면
///   navigator stack 충돌로 흰 화면 → fullscreen alias 우회.
class _TagSearchResultCard extends ConsumerWidget {
  const _TagSearchResultCard({required this.result});
  final TagSearchResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myUid = ref.watch(currentDottieUserProvider).valueOrNull?.uid;
    final rooms = ref.watch(roomListProvider).valueOrNull ?? const <Room>[];
    final roomById = {for (final r in rooms) r.id: r};

    final entry = FeedEntry(
      dot: result.dot,
      authorId: result.userId,
      authorNickname: result.userNickname,
      // 멤버 색이 누락된 경우 폴백 — FeedCard 의 헤더 아바타가 색 필요.
      authorColorHex: result.userColorHex ?? '#7EB8F7',
      isMine: result.isOwnedBy(myUid),
      sharedRoomIds:
          (result.roomId != null && result.roomId!.isNotEmpty)
              ? <String>{result.roomId!}
              : const <String>{},
    );

    return FeedCard(
      entry: entry,
      roomNameById: roomById,
      onTap: () => _openDetail(context, entry, roomById),
    );
  }

  void _openDetail(
    BuildContext context,
    FeedEntry entry,
    Map<String, Room> roomById,
  ) {
    final roomId = result.roomId;
    // 결과가 어느 룸에 공유된 dot 일 때만 "지도에서 보기" 노출.
    // viewer 가 그 방 멤버가 아닌 케이스(BE 가시성 누락) 는 방어적 가드.
    final actionable =
        (roomId != null && roomById.containsKey(roomId))
            ? <String>{roomId}
            : <String>{};
    final actionableNames = {
      for (final id in actionable) id: roomById[id]!.name,
    };

    DotDetailSheet.show(
      context,
      entry.dot,
      memberName: entry.isMine ? null : entry.authorNickname,
      memberColor: colorFromHex(entry.authorColorHex),
      roomId: roomId,
      ownerUserId: entry.authorId,
      openInMapRoomIds: actionable,
      openInMapRoomNames: actionableNames,
      onOpenInMap: (pickedRoomId) {
        final date =
            DottieDateUtils.toDateString(entry.dot.timestamp.toLocal());
        // fullscreen alias — shell 밖 search 화면에서 직접 push 가능.
        context.push(
          AppRoutes.dotMap,
          extra: {
            'roomId': pickedRoomId,
            'date': date,
            'dotId': entry.dot.id,
          },
        );
      },
    );
  }
}

