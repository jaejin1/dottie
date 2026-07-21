import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/color_hex.dart';
import '../../domain/todo_list_model.dart';

class _SharedBadge extends StatelessWidget {
  const _SharedBadge({required this.memberCount});
  final int memberCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: DottieColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_outlined,
              size: 9, color: DottieColors.primary.withValues(alpha: 0.8)),
          const SizedBox(width: 2),
          Text(
            '$memberCount',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: DottieColors.primary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberAvatarRow extends StatelessWidget {
  const _MemberAvatarRow({required this.list});
  final TodoList list;

  @override
  Widget build(BuildContext context) {
    const maxShow = 5;
    final shown = list.members.take(maxShow).toList();
    final hasMore = list.members.length > maxShow;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 18,
          width: shown.length * 14.0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (int i = 0; i < shown.length; i++)
                Positioned(
                  left: i * 12.0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: colorFromHex(shown[i].character.colorHex,
                          fallback: DottieColors.primary),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: DottieColors.surface, width: 1.2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      shown[i].nickname.isNotEmpty ? shown[i].nickname.characters.first : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '···',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: DottieColors.textPrimary.withValues(alpha: 0.4),
                letterSpacing: 1,
              ),
            ),
          ),
      ],
    );
  }
}

class _ModeBadge extends StatelessWidget {
  const _ModeBadge({required this.isTrip, required this.color});
  final bool isTrip;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (isTrip ? color : DottieColors.textHint).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isTrip ? '✈️ 여행' : '📌 모음',
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: isTrip
              ? color.withValues(alpha: 0.85)
              : DottieColors.textHint,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

String _subtitle(TodoList list, int total) {
  if (total == 0) return '아직 비어있어요';
  if (!list.isTrip) return '$total곳 저장됨';
  final s = list.startDate;
  final e = list.endDate;
  return '${s.month}/${s.day}~${e.month}/${e.day} · $total곳';
}

/// 컬렉션 카드 — 스팟 메인 화면의 리스트 아이템.
class CollectionCard extends StatelessWidget {
  const CollectionCard({super.key, required this.list});

  final TodoList list;

  @override
  Widget build(BuildContext context) {
    final total = list.items.length;
    final color = DottieColors.accentFor(list.id);
    final isTrip = list.isTrip;

    // 카드 배경은 모두 흰 surface 로 통일 (피드 톤) — 컬렉션 색 정체성은
    // 좌측 emoji 배지의 tinted 배경에만 남김. 한 화면에 여러 카드가 있어도
    // 노이즈 없이 깔끔.
    return Container(
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
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => context.push('/todos/${list.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              children: [
                // 이모지 배지 — 컬렉션 색으로 살짝 tinted.
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    list.coverEmoji ?? '📍',
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              list.name,
                              style: GoogleFonts.notoSansKr(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.15,
                                color: DottieColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          _ModeBadge(isTrip: isTrip, color: color),
                          if (list.isShared) ...[
                            const SizedBox(width: 4),
                            _SharedBadge(memberCount: list.members.length),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (list.isShared && list.members.isNotEmpty) ...[
                            _MemberAvatarRow(list: list),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            _subtitle(list, total),
                            style: GoogleFonts.notoSansKr(
                              fontSize: 11.5,
                              color: DottieColors.textPrimary
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          if (list.description != null &&
                              list.description!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                list.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.notoSansKr(
                                  fontSize: 11.5,
                                  color: DottieColors.textPrimary
                                      .withValues(alpha: 0.38),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                if (list.isPinned)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.push_pin_rounded,
                      size: 13,
                      color: DottieColors.primary.withValues(alpha: 0.7),
                    ),
                  ),
                Icon(Icons.chevron_right_rounded,
                    color: DottieColors.textHint.withValues(alpha: 0.6),
                    size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
