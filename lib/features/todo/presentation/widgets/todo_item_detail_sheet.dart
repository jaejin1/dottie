import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../shared/utils/error_messages.dart';
import '../../../auth/presentation/auth_provider.dart';
import '../../domain/todo_item_model.dart';
import '../../domain/todo_list_model.dart';
import '../todo_provider.dart';
import '_category_util.dart';
import 'check_in_button.dart';
import 'todo_item_input_sheet.dart';

/// 할일 항목 상세 시트 — 탭/long-press 진입.
///
/// 표시:
/// - 장소/카테고리/일자/시간/메모/감정
/// - 체크인 상태 (인증 시각 + 링크된 dot.id)
/// 액션:
/// - 도착 인증 (canCheckIn 시) — Step 1.9
/// - 수정 / 삭제
class TodoItemDetailSheet extends ConsumerWidget {
  const TodoItemDetailSheet({
    super.key,
    required this.todoList,
    required this.item,
  });

  final TodoList todoList;
  final TodoItem item;

  static Future<void> show(
    BuildContext context, {
    required TodoList todoList,
    required TodoItem item,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TodoItemDetailSheet(
        todoList: todoList,
        item: item,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    final plannedLocal = item.plannedAt?.toLocal();
    final uid = ref.watch(currentDottieUserProvider).valueOrNull?.uid;
    final canEdit = todoList.canEdit(uid);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: DottieColors.surface,
        borderRadius: BorderRadius.circular(Dimensions.radiusLg),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            Dimensions.md, Dimensions.md, Dimensions.md, Dimensions.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: DottieColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: Dimensions.md),

            // 상단 — 체크인 상태 + 액션 (수정/삭제)
            // 모음(collection)은 방문 개념 없는 저장용 — 상태 배지 대신 북마크 표시.
            Row(
              children: [
                if (!todoList.isTrip)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: DottieColors.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bookmark_rounded,
                            size: 13, color: DottieColors.primary),
                        const SizedBox(width: 4),
                        Text('저장됨',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color:
                                  DottieColors.primary.withValues(alpha: 0.9),
                            )),
                      ],
                    ),
                  )
                else if (item.isCheckedIn)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: DottieColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 14, color: DottieColors.primary),
                        SizedBox(width: 4),
                        Text('다녀옴',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: DottieColors.primary,
                            )),
                      ],
                    ),
                  )
                else
                  // 미체크인 — "예정". "안 가봄" 보다 부드러운 톤.
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color:
                          DottieColors.textPrimary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bookmark_border_rounded,
                            size: 13,
                            color: DottieColors.textPrimary
                                .withValues(alpha: 0.55)),
                        const SizedBox(width: 4),
                        Text('예정',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: DottieColors.textPrimary
                                  .withValues(alpha: 0.6),
                            )),
                      ],
                    ),
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.map_outlined,
                      size: 20, color: DottieColors.textSecondary),
                  onPressed: () => _onShowOnMap(context, ref),
                  tooltip: '지도에서 보기',
                ),
                if (canEdit) ...[
                  IconButton(
                    icon: const Icon(Icons.edit_outlined,
                        size: 20, color: DottieColors.textSecondary),
                    onPressed: () => _onEdit(context),
                    tooltip: '수정',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 20, color: DottieColors.textSecondary),
                    onPressed: () => _onDelete(context, ref),
                    tooltip: '삭제',
                  ),
                ],
              ],
            ),
            const SizedBox(height: Dimensions.md),

            // ── 위치 표시 영역 (dot detail 패턴 모방 — 일관성을 위해 위치만) ──
            //
            // 1) 작은 줄: 방문 시간(선택) + 카테고리
            Row(
              children: [
                if (plannedLocal != null) ...[
                  const Icon(Icons.schedule_outlined,
                      size: 14, color: DottieColors.textHint),
                  const SizedBox(width: 5),
                  Text(
                    '${plannedLocal.hour.toString().padLeft(2, '0')}:${plannedLocal.minute.toString().padLeft(2, '0')}',
                    style: GoogleFonts.notoSansKr(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: DottieColors.textSecondary,
                    ),
                  ),
                ],
                if (shortCategoryOf(item.placeCategory) != null) ...[
                  const SizedBox(width: 6),
                  const Text('·',
                      style: TextStyle(
                          color: DottieColors.textHint, fontSize: 13)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      shortCategoryOf(item.placeCategory)!,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 13,
                        color: DottieColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),

            // 2) 장소 카드 (dot 의 dot.place 카드와 동일 패턴) — 큰 강조.
            const SizedBox(height: Dimensions.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.sm, vertical: Dimensions.sm),
              decoration: BoxDecoration(
                color: DottieColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: DottieColors.primary.withAlpha(80), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: DottieColors.primary.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.place_rounded,
                            color: DottieColors.primary, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.placeName ?? '이름 없는 장소',
                              style: GoogleFonts.notoSansKr(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: DottieColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (shortCategoryOf(item.placeCategory) !=
                                null) ...[
                              const SizedBox(height: 2),
                              Text(
                                shortCategoryOf(item.placeCategory)!,
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 11,
                                  color: DottieColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      // 카카오맵 상세 페이지 (place 조인 시)
                      if (item.place?.placeUrl != null)
                        GestureDetector(
                          onTap: () => launchUrl(
                            Uri.parse(item.place!.placeUrl!),
                            mode: LaunchMode.externalApplication,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: DottieColors.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.open_in_new_rounded,
                                    size: 12, color: DottieColors.primary),
                                const SizedBox(width: 3),
                                Text(
                                  '카카오맵',
                                  style: GoogleFonts.notoSansKr(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: DottieColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  // 주소 — place 조인 데이터가 있을 때만. (전화는 표시 안 함)
                  if (_placeAddress != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 2, top: 1),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: DottieColors.textHint),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              _placeAddress!,
                              style: GoogleFonts.notoSansKr(
                                fontSize: 12,
                                color: DottieColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 감정 (있을 때만, 작은 칩)
            if (item.emotion != null && item.emotion!.isNotEmpty) ...[
              const SizedBox(height: Dimensions.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: DottieColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(item.emotion!,
                    style: const TextStyle(fontSize: 14)),
              ),
            ],

            // 메모
            if (item.notes != null && item.notes!.isNotEmpty) ...[
              const SizedBox(height: Dimensions.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.md),
                decoration: BoxDecoration(
                  color: DottieColors.background,
                  borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                ),
                child: Text(
                  item.notes!,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: DottieColors.textPrimary,
                  ),
                ),
              ),
            ],

            // 체크인 정보 — 모음에서는 미노출 (저장용)
            if (todoList.isTrip &&
                item.isCheckedIn &&
                item.checkedInAt != null) ...[
              const SizedBox(height: Dimensions.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.md),
                decoration: BoxDecoration(
                  color: DottieColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(Dimensions.radiusMd),
                  border: Border.all(
                    color: DottieColors.primary.withValues(alpha: 0.2),
                    width: 0.6,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_rounded,
                        size: 16, color: DottieColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '다녀온 시각: ${_formatCheckedIn(item.checkedInAt!.toLocal())}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DottieColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 도착 인증 버튼 + 안내문구 — 여행 코스 전용 (모음은 저장용)
            if (todoList.isTrip && canEdit && item.canCheckIn) ...[
              const SizedBox(height: Dimensions.lg),
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 13, color: DottieColors.textHint),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      '다녀왔다고 표시하면 dot 으로 기록돼요',
                      style: GoogleFonts.notoSansKr(
                        fontSize: 11,
                        color: DottieColors.textHint,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              CheckInButton(
                todoList: todoList,
                item: item,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 도로명 주소 우선, 없으면 지번.
  String? get _placeAddress {
    final p = item.place;
    if (p == null) return null;
    final road = p.roadAddress;
    if (road != null && road.isNotEmpty) return road;
    final addr = p.address;
    return (addr != null && addr.isNotEmpty) ? addr : null;
  }

  void _onShowOnMap(BuildContext context, WidgetRef ref) {
    ref.read(todoMapFocusProvider.notifier).request(item);
    Navigator.of(context).pop();
  }

  Future<void> _onEdit(BuildContext context) async {
    Navigator.of(context).pop();
    await TodoItemInputSheet.show(
      context,
      todoList: todoList,
      initialItem: item,
    );
  }

  Future<void> _onDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
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
            child:
                const Text('삭제', style: TextStyle(color: DottieColors.error)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(todoNotifierProvider.notifier).deleteItem(
            todoListId: todoList.id,
            itemId: item.id,
          );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userMessageFor(e))),
        );
      }
      return;
    }
    if (!context.mounted) return;
    Navigator.of(context).pop();
  }

  static String _formatCheckedIn(DateTime d) =>
      '${d.month}/${d.day} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

