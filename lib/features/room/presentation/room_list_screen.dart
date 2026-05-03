import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/date_utils.dart';
import '../domain/room_model.dart';
import 'room_provider.dart';

class RoomListScreen extends ConsumerWidget {
  const RoomListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomsAsync = ref.watch(roomListProvider);

    return Scaffold(
      backgroundColor: DottieColors.background,
      appBar: AppBar(
        title: Text(
          '방',
          style: GoogleFonts.notoSansKr(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: DottieColors.textPrimary,
            letterSpacing: -1,
            height: 1,
          ),
        ),
        centerTitle: false,
        backgroundColor: DottieColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined,
                color: DottieColors.textSecondary, size: 22),
            onPressed: () => _showJoinDialog(context, ref),
            tooltip: '초대 코드로 참여',
          ),
        ],
      ),
      body: roomsAsync.when(
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
        error: (e, _) => Center(child: Text('오류: $e')),
        data: (rooms) => rooms.isEmpty
            ? _EmptyState(onCreateTap: () => _goCreate(context))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: rooms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _RoomCard(room: rooms[i])
                    .animate()
                    .fadeIn(duration: 300.ms, delay: (i * 40).ms)
                    .slideX(
                      begin: 0.05,
                      end: 0,
                      duration: 300.ms,
                      delay: (i * 40).ms,
                      curve: Curves.easeOutCubic,
                    ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _goCreate(context),
        backgroundColor: DottieColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add, size: 20),
        label: Text(
          '방 만들기',
          style: GoogleFonts.notoSansKr(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _goCreate(BuildContext context) => context.push(AppRoutes.createRoom);

  void _showJoinDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('초대 코드로 참여'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '초대 코드 8자리'),
          textCapitalization: TextCapitalization.characters,
          maxLength: 8,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('취소')),
          FilledButton(
            onPressed: () async {
              final code = controller.text.trim();
              if (code.length < 8) return;
              Navigator.pop(dialogContext);
              final room = await ref
                  .read(roomNotifierProvider.notifier)
                  .joinRoom(code);
              if (context.mounted && room != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${room.name}에 참여했어요!')),
                );
              }
            },
            style: FilledButton.styleFrom(
                backgroundColor: DottieColors.primary),
            child: const Text('참여'),
          ),
        ],
      ),
    );
  }
}

// ── 방 카드 ───────────────────────────────────────────────────

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room});
  final Room room;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DottieColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.push('/rooms/${room.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: DottieColors.border, width: 0.8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 왼쪽 컬러 바
                  Container(
                    width: 4,
                    color: DottieColors.secondary,
                  ),
                  // 콘텐츠
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                      child: Row(
                        children: [
                          _MemberAvatarStack(members: room.members),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room.name,
                                  style: GoogleFonts.notoSansKr(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: DottieColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _MemberCountBadge(
                                        count: room.members.length),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        DottieDateUtils.toKoreanDate(
                                            room.createdAt),
                                        style: GoogleFonts.notoSansKr(
                                          fontSize: 12,
                                          color: DottieColors.textHint,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              color: DottieColors.textHint, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberCountBadge extends StatelessWidget {
  const _MemberCountBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: DottieColors.surfaceVariant,
        borderRadius: BorderRadius.circular(Dimensions.radiusFull),
        border: Border.all(color: DottieColors.border, width: 0.8),
      ),
      child: Text(
        '$count명',
        style: GoogleFonts.notoSansKr(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: DottieColors.textSecondary,
        ),
      ),
    );
  }
}

class _MemberAvatarStack extends StatelessWidget {
  const _MemberAvatarStack({required this.members});
  final List<RoomMember> members;

  @override
  Widget build(BuildContext context) {
    final show = members.take(4).toList();
    return SizedBox(
      width: 18.0 * (show.length - 1) + 32,
      height: 32,
      child: Stack(
        children: List.generate(show.length, (i) {
          final color =
              characterColorMap[show[i].character.colorKey] ?? DottieColors.primary;
          return Positioned(
            left: i * 18.0,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: DottieColors.surface, width: 2),
              ),
              child: Center(
                child: Text(
                  show[i].nickname.characters.first,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── 빈 상태 ───────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreateTap});
  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    return Center(
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
              Icons.people_outline_rounded,
              size: 36,
              color: DottieColors.textHint,
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.8, 0.8),
                duration: 400.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(height: 16),
          Text(
            '아직 속한 방이 없어요',
            style: GoogleFonts.notoSansKr(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: DottieColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '친구와 함께할 방을 만들어보세요',
            style: GoogleFonts.notoSansKr(
              fontSize: 14,
              color: DottieColors.textHint,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onCreateTap,
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              '방 만들기',
              style: GoogleFonts.notoSansKr(fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: DottieColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }
}
