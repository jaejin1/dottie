import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/constants/typography.dart';
import '../domain/todo_list_model.dart';
import 'todo_provider.dart';
import 'widgets/collection_card.dart';

/// 스팟 탭 메인 — 단일 리스트 + 타입 필터 칩 (전체 / ✈️ 여행 / 📌 모음).
class TodoCollectionListScreen extends ConsumerStatefulWidget {
  const TodoCollectionListScreen({super.key});

  @override
  ConsumerState<TodoCollectionListScreen> createState() =>
      _TodoCollectionListScreenState();
}

class _TodoCollectionListScreenState
    extends ConsumerState<TodoCollectionListScreen> {
  String? _typeFilter; // null=전체, 'trip'=여행, 'collection'=모음

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(myTodoListsProvider);
    final allLists = allAsync.valueOrNull ?? const <TodoList>[];

    // 필터 적용
    final filtered = _typeFilter == null
        ? allLists
        : allLists.where((l) {
            if (_typeFilter == 'trip') return l.isTrip;
            return !l.isTrip; // 'collection'
          }).toList();

    // 고정 컬렉션(pinOrder 순) → 일반 컬렉션(createdAt 최신순)
    final pinned = filtered.where((l) => l.isPinned).toList()
      ..sort((a, b) => a.pinOrder.compareTo(b.pinOrder));
    final rest = filtered.where((l) => !l.isPinned).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final sorted = [...pinned, ...rest];

    return Scaffold(
      backgroundColor: DottieColors.background,
      appBar: AppBar(
        title: Text('스팟', style: AppTypography.tabHeader()),
        centerTitle: false,
        backgroundColor: DottieColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded,
                color: DottieColors.textSecondary, size: 22),
            tooltip: '새 코스',
            onPressed: () => context.push('/todos/new'),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: _FilterChipBar(
            selected: _typeFilter,
            onChanged: (v) => setState(() => _typeFilter = v),
          ),
        ),
      ),
      body: allAsync.when(
        loading: () => const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              strokeCap: StrokeCap.round,
              color: DottieColors.primary,
            ),
          ),
        ),
        error: (e, st) {
          debugPrint('[TodoCollectionList] load error: $e\n$st');
          return _LoadFailedView(
            error: e,
            onRetry: () => ref.refresh(myTodoListsProvider),
          );
        },
        data: (_) {
          if (allLists.isEmpty) {
            return _EmptyView(
              onCreateTap: () => context.push('/todos/new'),
            );
          }
          if (sorted.isEmpty) {
            return _FilterEmptyView(filter: _typeFilter!);
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final list = sorted[i];
              return GestureDetector(
                onLongPress: () => _onLongPress(context, ref, list),
                child: CollectionCard(list: list),
              )
                  .animate()
                  .fadeIn(duration: 300.ms, delay: (i * 40).ms)
                  .slideX(
                    begin: 0.05,
                    end: 0,
                    duration: 300.ms,
                    delay: (i * 40).ms,
                    curve: Curves.easeOutCubic,
                  );
            },
          );
        },
      ),
    );
  }
}

void _onLongPress(BuildContext context, WidgetRef ref, TodoList list) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) => SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: DottieColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: DottieColors.textHint.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () async {
                Navigator.pop(sheetCtx);
                try {
                  await ref.read(todoNotifierProvider.notifier).togglePinCollection(list);
                  HapticFeedback.lightImpact();
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('오류가 발생했어요. 잠시 후 다시 시도해 주세요.')),
                    );
                  }
                }
              },
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: list.isPinned
                            ? DottieColors.primary.withValues(alpha: 0.12)
                            : DottieColors.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.push_pin_rounded,
                        size: 18,
                        color: list.isPinned
                            ? DottieColors.primary
                            : DottieColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      list.isPinned ? '상단 고정 해제' : '상단 고정',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: list.isPinned
                            ? DottieColors.primary
                            : DottieColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (list.isPinned)
                      Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: DottieColors.primary.withValues(alpha: 0.7),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    ),
  );
}

class _FilterChipBar extends StatelessWidget {
  const _FilterChipBar({required this.selected, required this.onChanged});
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DottieColors.background,
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _Chip(label: '전체', value: null, selected: selected, onTap: onChanged),
          const SizedBox(width: 8),
          _Chip(label: '✈️ 여행', value: 'trip', selected: selected, onTap: onChanged),
          const SizedBox(width: 8),
          _Chip(label: '📌 모음', value: 'collection', selected: selected, onTap: onChanged),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final String? value;
  final String? selected;
  final ValueChanged<String?> onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? DottieColors.primary.withValues(alpha: 0.12)
              : DottieColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? DottieColors.primary.withValues(alpha: 0.4)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? DottieColors.primary
                : DottieColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _FilterEmptyView extends StatelessWidget {
  const _FilterEmptyView({required this.filter});
  final String filter;

  @override
  Widget build(BuildContext context) {
    final label = filter == 'trip' ? '여행 코스' : '모음 코스';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filter == 'trip' ? '✈️' : '📌',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(
              '$label가 없어요',
              style: GoogleFonts.notoSansKr(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: DottieColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '새 코스를 만들어 스팟을 추가해보세요',
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
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.onCreateTap});
  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: DottieColors.surfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(color: DottieColors.border, width: 0.8),
              ),
              child: const Icon(
                Icons.bookmark_border_rounded,
                size: 36,
                color: DottieColors.textHint,
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                    curve: Curves.easeOutCubic),
            const SizedBox(height: 16),
            Text(
              '아직 만든 코스가 없어요',
              style: GoogleFonts.notoSansKr(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: DottieColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '여행이나 동네 산책처럼\n가고 싶은 스팟을 모아보세요',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSansKr(
                fontSize: 14,
                color: DottieColors.textHint,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onCreateTap,
              icon: const Icon(Icons.add, size: 18),
              label: Text(
                '첫 코스 만들기',
                style: GoogleFonts.notoSansKr(fontWeight: FontWeight.w600),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: DottieColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadFailedView extends StatelessWidget {
  const _LoadFailedView({required this.error, required this.onRetry});
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    String message = '잠시 후 다시 시도해 주세요.';
    final e = error;
    if (e is DioException) {
      if (e.response == null) {
        message = '네트워크 연결을 확인해 주세요.';
      } else if (e.response?.statusCode == 401) {
        message = '로그인이 필요해요.';
      } else {
        message = '서버 응답이 올바르지 않아요. (${e.response?.statusCode})';
      }
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined,
                size: 48,
                color: DottieColors.textPrimary.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text(
              '불러오지 못했어요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: DottieColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: DottieColors.textPrimary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: DottieColors.primary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
