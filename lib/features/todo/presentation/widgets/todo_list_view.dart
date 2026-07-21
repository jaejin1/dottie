import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../shared/utils/error_messages.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../auth/presentation/auth_provider.dart';
import '../../domain/todo_item_model.dart';
import '../../domain/todo_list_model.dart';
import '../todo_provider.dart';
import '_category_util.dart';
import '_day_palette.dart';
import 'todo_item_detail_sheet.dart';

/// 갈곳 컬렉션 리스트 뷰 — 단일 list.
///
/// filterDayIndex: -1 = 전체, ≥0 = 해당 dayIndex 만.
class TodoListView extends ConsumerWidget {
  const TodoListView({
    super.key,
    required this.todoListId,
    this.filterDayIndex = -1,
  });
  final String todoListId;
  final int filterDayIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(todoListByIdProvider(todoListId));

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(
        message: userMessageFor(e),
        onRetry: () => ref.invalidate(todoListByIdProvider(todoListId)),
      ),
      data: (list) {
        if (list == null) {
          return const Center(child: Text('이 컬렉션을 찾을 수 없어요'));
        }
        if (list.items.isEmpty) {
          return const EmptyState(
            icon: Icons.place_rounded,
            title: '가고 싶은 곳을 모아 보세요',
            description: '오른쪽 아래 + 버튼으로 스팟을 추가할 수 있어요',
          );
        }
        // 일자 필터 적용 후 정렬.
        final filtered = filterDayIndex >= 0
            ? list.items.where((i) => i.dayIndex == filterDayIndex).toList()
            : [...list.items];
        filtered.sort((a, b) {
          final dc = a.dayIndex.compareTo(b.dayIndex);
          if (dc != 0) return dc;
          return a.orderInDay.compareTo(b.orderInDay);
        });
        if (filtered.isEmpty) {
          return const EmptyState(
            icon: Icons.place_rounded,
            title: '이 날에는 아직 스팟이 없어요',
            description: '+ 버튼으로 스팟을 추가해 보세요',
          );
        }
        return _Content(list: list, items: filtered, filterDayIndex: filterDayIndex);
      },
    );
  }
}

// ── drag row 모델 ─────────────────────────────────────────────────────────────

sealed class _DragRow {
  const _DragRow();
}

final class _ItemDragRow extends _DragRow {
  final TodoItem item;
  const _ItemDragRow(this.item);
}

final class _HeaderDragRow extends _DragRow {
  final int dayIndex;
  const _HeaderDragRow(this.dayIndex);
}

// ── _Content ──────────────────────────────────────────────────────────────────

class _Content extends ConsumerWidget {
  const _Content({required this.list, required this.items, required this.filterDayIndex});
  final TodoList list;
  final List<TodoItem> items;
  final int filterDayIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentDottieUserProvider).valueOrNull?.uid;
    final canEdit = list.canEdit(uid);

    final pinned = items.where((i) => i.isPinned).toList()
      ..sort((a, b) => a.pinOrder.compareTo(b.pinOrder));
    final rest = items.where((i) => !i.isPinned).toList();

    // 여행 + 편집 권한 → 드래그 재정렬 모드 (전체 / Day 필터 모두 지원)
    if (list.isTrip && canEdit) {
      return _DraggableContent(
        list: list,
        pinned: pinned,
        rest: rest,
        filterDayIndex: filterDayIndex,
      );
    }

    // 모음(collection) 또는 읽기 전용 — 기존 ListView
    final showDayHeaders = list.isTrip && filterDayIndex < 0;
    final rows = <Widget>[];
    int tileIndex = 0;

    if (pinned.isNotEmpty) {
      rows.add(const _PinnedHeader());
      for (final item in pinned) {
        rows.add(_ItemTile(
          key: ValueKey(item.id),
          list: list,
          item: item,
          animationIndex: tileIndex++,
        ));
      }
      if (rest.isNotEmpty) rows.add(const _SectionDivider());
    }

    int? lastDay;
    for (final item in rest) {
      if (showDayHeaders && item.dayIndex != lastDay) {
        lastDay = item.dayIndex;
        rows.add(_DayHeader(list: list, dayIndex: item.dayIndex));
      }
      rows.add(_ItemTile(
        key: ValueKey(item.id),
        list: list,
        item: item,
        animationIndex: tileIndex++,
      ));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
          Dimensions.md, Dimensions.sm, Dimensions.md, 100),
      itemCount: rows.length,
      itemBuilder: (_, i) => rows[i],
    );
  }
}

// ── _DraggableContent ─────────────────────────────────────────────────────────

/// 드래그 재정렬 — trip + canEdit 시 전체/Day 필터 모두 지원.
///
/// 로컬 [_rows] 상태로 낙관적 업데이트: 드래그 완료 즉시 화면 반영,
/// 서버 동기화는 [TodoNotifier.reorderItemsSilently]로 백그라운드 처리.
class _DraggableContent extends ConsumerStatefulWidget {
  const _DraggableContent({
    required this.list,
    required this.pinned,
    required this.rest,
    required this.filterDayIndex,
  });
  final TodoList list;
  final List<TodoItem> pinned;
  final List<TodoItem> rest;
  final int filterDayIndex;

  @override
  ConsumerState<_DraggableContent> createState() => _DraggableContentState();
}

class _DraggableContentState extends ConsumerState<_DraggableContent> {
  late List<_DragRow> _rows;

  bool get _isAllView => widget.filterDayIndex < 0;

  @override
  void initState() {
    super.initState();
    _rows = _buildRows(widget.rest);
  }

  @override
  void didUpdateWidget(_DraggableContent old) {
    super.didUpdateWidget(old);
    // 아이템 추가/삭제/수정이 외부(서버 sync 등)에서 오면 로컬 rows 갱신.
    // reorderItemsSilently는 _invalidate를 호출하지 않으므로 드래그 후엔 이 분기 미실행.
    if (!listEquals(widget.rest, old.rest) ||
        widget.filterDayIndex != old.filterDayIndex) {
      _rows = _buildRows(widget.rest);
    }
  }

  /// 아이템 목록 → 표시용 flat rows 구성.
  /// 전체 뷰에서는 dayIndex 순으로 정렬 후 Day 헤더 삽입.
  List<_DragRow> _buildRows(List<TodoItem> items) {
    if (!_isAllView) {
      // 단일 날 필터: 헤더 없이 orderInDay 순으로만.
      return items.map((i) => _ItemDragRow(i)).toList();
    }
    // 전체 뷰: dayIndex → orderInDay 정렬 후 Day 헤더 삽입.
    final sorted = List<TodoItem>.from(items)
      ..sort((a, b) {
        final dc = a.dayIndex.compareTo(b.dayIndex);
        if (dc != 0) return dc;
        return a.orderInDay.compareTo(b.orderInDay);
      });
    final rows = <_DragRow>[];
    int lastDay = -99;
    for (final item in sorted) {
      if (item.dayIndex != lastDay) {
        lastDay = item.dayIndex;
        rows.add(_HeaderDragRow(lastDay));
      }
      rows.add(_ItemDragRow(item));
    }
    return rows;
  }

  /// 드래그 후 rows → 아이템(dayIndex·orderInDay 재계산).
  List<TodoItem> _recalcDays(List<_DragRow> rows) {
    int currentDay = 0;
    int order = 0;
    final result = <TodoItem>[];
    for (final row in rows) {
      switch (row) {
        case _HeaderDragRow(:final dayIndex):
          currentDay = dayIndex;
          order = 0;
        case _ItemDragRow(:final item):
          result.add(item.copyWith(dayIndex: currentDay, orderInDay: order++));
      }
    }
    return result;
  }

  /// 단일 날 드래그: orderInDay만 재계산.
  List<TodoItem> _recalcSameDay(List<_DragRow> rows) {
    int order = 0;
    return rows
        .whereType<_ItemDragRow>()
        .map((r) => r.item.copyWith(orderInDay: order++))
        .toList();
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final row = _rows[oldIndex];
    if (row is _HeaderDragRow) return; // 헤더는 드래그 불가

    final newRows = List<_DragRow>.from(_rows)
      ..removeAt(oldIndex)
      ..insert(newIndex, row);

    final originalItems =
        _rows.whereType<_ItemDragRow>().map((r) => r.item).toList();

    final updatedItems =
        _isAllView ? _recalcDays(newRows) : _recalcSameDay(newRows);

    setState(() {
      // 전체 뷰: 재계산 후 rows 재구성 (헤더 위치를 day 기반으로 정규화).
      // 단일 날 뷰: newRows 직접 사용.
      _rows = _isAllView ? _buildRows(updatedItems) : newRows;
    });

    // 낙관적 업데이트 완료 — 서버 동기화는 백그라운드 (invalidate 없음).
    ref.read(todoNotifierProvider.notifier).reorderItemsSilently(
      todoListId: widget.list.id,
      originalItems: originalItems,
      updatedItems: updatedItems,
      filterDayIndex: widget.filterDayIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // 핀 항목 (드래그 불가)
        if (widget.pinned.isNotEmpty) ...[
          const SliverToBoxAdapter(child: _PinnedHeader()),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.md),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _ItemTile(
                  key: ValueKey(widget.pinned[i].id),
                  list: widget.list,
                  item: widget.pinned[i],
                  animationIndex: i,
                ),
                childCount: widget.pinned.length,
              ),
            ),
          ),
          if (_rows.isNotEmpty)
            const SliverToBoxAdapter(child: _SectionDivider()),
        ],
        // 드래그 가능 rows (아이템 + Day 헤더 혼합)
        SliverPadding(
          padding: EdgeInsets.only(
            left: Dimensions.md,
            right: Dimensions.md,
            top: widget.pinned.isEmpty ? Dimensions.sm : 0,
            bottom: 100,
          ),
          sliver: SliverReorderableList(
            itemCount: _rows.length,
            onReorderStart: (_) => HapticFeedback.mediumImpact(),
            onReorder: _onReorder,
            itemBuilder: (_, i) {
              final row = _rows[i];
              return switch (row) {
                _HeaderDragRow(:final dayIndex) => _DayHeader(
                    key: ValueKey('header-$dayIndex'),
                    list: widget.list,
                    dayIndex: dayIndex,
                  ),
                _ItemDragRow(:final item) => _ItemTile(
                    key: ValueKey(item.id),
                    list: widget.list,
                    item: item,
                    animationIndex: i,
                    showDragHandle: true,
                  ),
              };
            },
          ),
        ),
      ],
    );
  }
}

class _PinnedHeader extends StatelessWidget {
  const _PinnedHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 4),
      child: Row(
        children: [
          const Icon(Icons.push_pin_rounded, size: 13, color: DottieColors.primary),
          const SizedBox(width: 6),
          Text(
            '고정된 스팟',
            style: GoogleFonts.notoSansKr(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: DottieColors.primary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              color: DottieColors.primary.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(height: 1, color: DottieColors.surfaceVariant),
    );
  }
}

/// day 섹션 헤더 — "● Day 1 · 7/17" (색 = day 팔레트, 지도와 동일).
class _DayHeader extends StatelessWidget {
  const _DayHeader({super.key, required this.list, required this.dayIndex});
  final TodoList list;
  final int dayIndex;

  @override
  Widget build(BuildContext context) {
    final color = dayColorOf(dayIndex);
    final date = list.dateForDayIndex(dayIndex);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            'Day ${dayIndex + 1}',
            style: GoogleFonts.notoSansKr(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: DottieColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${date.month}/${date.day}',
            style: GoogleFonts.notoSansKr(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DottieColors.textSecondary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(height: 1, color: color.withValues(alpha: 0.25)),
          ),
        ],
      ),
    );
  }
}

class _ItemTile extends ConsumerWidget {
  const _ItemTile({
    super.key,
    required this.list,
    required this.item,
    required this.animationIndex,
    this.showDragHandle = false,
  });

  final TodoList list;
  final TodoItem item;
  final int animationIndex;
  final bool showDragHandle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCheckedIn = item.isCheckedIn;
    final uid = ref.watch(currentDottieUserProvider).valueOrNull?.uid;
    final canEdit = list.canEdit(uid);
    // 긴 목록에서 뒤쪽 타일이 수 초간 안 보이지 않게 delay 상한.
    final delay = (80 + animationIndex.clamp(0, 15) * 40).ms;

    final card = _buildCard(
      context, ref, canEdit, isCheckedIn,
      dragIndex: showDragHandle ? animationIndex : null,
    );

    if (!canEdit || showDragHandle) {
      // 드래그 모드 — Dismissible 비활성 (가로 제스처 충돌 방지).
      // 재정렬 후 재애니메이션 방지: delay=0.
      // 드래그 핸들은 카드 내부 아이콘에만 적용 (카드 전체 X → 스크롤 가능).
      return card
          .animate()
          .fadeIn(duration: showDragHandle ? 0.ms : 240.ms, delay: showDragHandle ? 0.ms : delay)
          .slideY(begin: showDragHandle ? 0 : 0.06, end: 0, duration: showDragHandle ? 0.ms : 240.ms);
    }

    return Dismissible(
      key: ValueKey('dismiss-${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: DottieColors.error.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 22),
      ),
      confirmDismiss: (_) async {
        final confirmed = await showDialog<bool>(
              context: context,
              builder: (dc) => AlertDialog(
                title: const Text('삭제'),
                content: Text(
                    "'${item.placeName ?? "이 스팟"}'을 삭제할까요?\n다녀온 dot 은 그대로 남아요."),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dc, false),
                      child: const Text('취소')),
                  TextButton(
                    onPressed: () => Navigator.pop(dc, true),
                    child: const Text('삭제',
                        style: TextStyle(color: DottieColors.error)),
                  ),
                ],
              ),
            ) ??
            false;
        if (!confirmed) return false;
        try {
          await ref.read(todoNotifierProvider.notifier).deleteItem(
                todoListId: list.id,
                itemId: item.id,
              );
          return true;
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(userMessageFor(e))),
            );
          }
          return false;
        }
      },
      child: card,
    )
        .animate()
        .fadeIn(duration: 240.ms, delay: delay)
        .slideY(begin: 0.06, end: 0, duration: 240.ms, delay: delay);
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, bool canEdit, bool isCheckedIn, {int? dragIndex}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: DottieColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => TodoItemDetailSheet.show(
            context,
            todoList: list,
            item: item,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 모음은 방문 체크 개념 없이 저장용 — 체크링 미노출.
                if (list.isTrip) ...[
                  _CheckRing(
                    isCheckedIn: isCheckedIn,
                    canEdit: canEdit,
                    onToggle: () => _onToggleCheckIn(context, ref, canEdit),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (item.emotion != null && item.emotion!.isNotEmpty) ...[
                            Text(item.emotion!, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              item.placeName ?? '이름 없는 장소',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                color: DottieColors.textPrimary.withValues(
                                    alpha: list.isTrip && isCheckedIn
                                        ? 0.5
                                        : 1.0),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // 시간은 여행(trip) 타입에서만 표시 — 모음은 시간 개념 없음.
                          if (list.isTrip && item.plannedAt != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${item.plannedAt!.toLocal().hour.toString().padLeft(2, '0')}:${item.plannedAt!.toLocal().minute.toString().padLeft(2, '0')}',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: DottieColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (shortCategoryOf(item.placeCategory) != null ||
                          (item.notes != null && item.notes!.isNotEmpty)) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            if (shortCategoryOf(item.placeCategory) != null) ...[
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: DottieColors.primary.withValues(alpha: 0.55),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                shortCategoryOf(item.placeCategory)!,
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: DottieColors.textPrimary.withValues(alpha: 0.55),
                                ),
                              ),
                              if (item.notes != null && item.notes!.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Text('·', style: GoogleFonts.notoSansKr(
                                  fontSize: 11,
                                  color: DottieColors.textPrimary.withValues(alpha: 0.3),
                                )),
                                const SizedBox(width: 6),
                              ],
                            ],
                            if (item.notes != null && item.notes!.isNotEmpty)
                              Flexible(
                                child: Text(
                                  item.notes!,
                                  style: GoogleFonts.notoSansKr(
                                    fontSize: 12,
                                    color: DottieColors.textPrimary.withValues(alpha: 0.45),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                if (item.isPinned)
                  Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: Icon(
                      Icons.push_pin_rounded,
                      size: 14,
                      color: DottieColors.primary.withValues(alpha: 0.7),
                    ),
                  ),
                if (dragIndex != null)
                  // 드래그 핸들 — 이 아이콘만 드래그 트리거.
                  // GestureDetector(onTap)로 탭이 카드 InkWell까지 전달되지 않게 차단.
                  GestureDetector(
                    onTap: () {},
                    child: ReorderableDragStartListener(
                      index: dragIndex,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 12, 4, 12),
                        child: Icon(
                          Icons.drag_handle_rounded,
                          size: 22,
                          color: DottieColors.textHint.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: DottieColors.textHint.withValues(alpha: 0.6),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 체크 토글 — 다녀왔어요 / 취소. captureDot 없이 mark/unmark 만 호출하는
  /// 빠른 토글. (도착 인증 흐름 = detail sheet 의 CheckInButton 은 그대로.)
  Future<void> _onToggleCheckIn(BuildContext context, WidgetRef ref, bool canEdit) async {
    if (!canEdit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('보기 전용 코스예요')),
      );
      return;
    }
    // 미체크 상태에서 list 토글로 빠르게 표시 — 인증/dot 생성 X.
    // 인증과 함께 dot 생성하려면 카드 본체 탭 → detail sheet 의 "다녀왔어요" 버튼.
    // (체크 토글은 사용자가 *간편 표시* 목적일 때.)
    final isCheckedIn = item.isCheckedIn;
    final notifier = ref.read(todoNotifierProvider.notifier);
    try {
      if (isCheckedIn) {
        await notifier.unmarkCheckedIn(
          todoListId: list.id,
          itemId: item.id,
        );
      } else {
        // dot 없이 그냥 표시만. checkInDotId = '' 또는 별도 sentinel.
        // BE 가 dot_id 필수면 detail sheet 의 CheckInButton 사용을 안내.
        TodoItemDetailSheet.show(
          context,
          todoList: list,
          item: item,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userMessageFor(e))),
        );
      }
    }
  }
}

/// 큰 체크 ring — 미체크는 outline 만, 체크 시 fill + white ✓.
class _CheckRing extends StatelessWidget {
  const _CheckRing({
    required this.isCheckedIn,
    required this.canEdit,
    required this.onToggle,
  });

  final bool isCheckedIn;
  final bool canEdit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color:
              isCheckedIn ? DottieColors.primary : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isCheckedIn
                ? DottieColors.primary
                : DottieColors.textPrimary.withValues(alpha: 0.2),
            width: 1.6,
          ),
        ),
        alignment: Alignment.center,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: isCheckedIn
              ? const Icon(
                  Icons.check_rounded,
                  key: ValueKey('checked'),
                  size: 14,
                  color: Colors.white,
                )
              : const SizedBox.shrink(key: ValueKey('unchecked')),
        ),
      ),
    );
  }
}
