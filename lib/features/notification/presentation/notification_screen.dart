import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../core/utils/date_utils.dart';
import '../domain/notification_model.dart';
import 'notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: DottieColors.background,
      appBar: AppBar(
        backgroundColor: DottieColors.surface,
        elevation: 0,
        title: Text(
          '알림',
          style: GoogleFonts.notoSansKr(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DottieColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final list = notificationState.valueOrNull ?? [];
              final hasUnread = list.any((n) => !n.isRead);
              if (!hasUnread) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('이미 모두 읽었어요'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              ref.read(notificationProvider.notifier).markAllRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('알림을 모두 읽음으로 표시했어요'),
                  duration: Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              '모두 읽음',
              style: GoogleFonts.notoSansKr(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: DottieColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: notificationState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: DottieColors.primary,
          ),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '알림을 불러오지 못했어요',
                style: GoogleFonts.notoSansKr(
                  fontSize: 16,
                  color: DottieColors.textSecondary,
                ),
              ),
              const SizedBox(height: Dimensions.md),
              ElevatedButton(
                onPressed: () =>
                    ref.read(notificationProvider.notifier).refresh(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DottieColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusMd),
                  ),
                ),
                child: Text(
                  '다시 시도',
                  style: GoogleFonts.notoSansKr(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        data: (notifications) {
          return RefreshIndicator(
            color: DottieColors.primary,
            onRefresh: () =>
                ref.read(notificationProvider.notifier).refresh(),
            child: notifications.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 200),
                      Center(
                        child: Text(
                          '아직 알림이 없어요',
                          style: GoogleFonts.notoSansKr(
                            fontSize: 16,
                            color: DottieColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return _NotificationTile(notification: n);
                    },
                  ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = notification;
    final initial =
        n.actorNickname.isNotEmpty ? n.actorNickname[0].toUpperCase() : '?';

    final description = n.type == NotificationType.comment
        ? '님이 dot에 댓글을 달았어요'
        : '님이 dot에서 멘션했어요';

    // 액터 정체성 색 (댓글/멘션 작성자) — BE `actor_color` 기반, 'blue' 폴백
    final actorColor =
        characterColorMap[n.actorColorKey] ?? DottieColors.primary;

    return InkWell(
      onTap: () {
        ref.read(notificationProvider.notifier).markRead(n.id);
        debugPrint(
            '[Notification] tapped id=${n.id} roomId=${n.roomId} dotId=${n.dotId}');

        final roomId = n.roomId;
        if (roomId == null || roomId.isEmpty) {
          debugPrint('[Notification] no roomId — skip navigation');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('연결된 방 정보가 없어요'),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        final dotId = n.dotId;
        if (dotId != null && dotId.isNotEmpty) {
          // BE가 제공하는 dot_date 우선 사용 (정확). 누락 시 알림 생성 시각으로 폴백.
          final dateStr =
              n.dotDate ?? DottieDateUtils.toDateString(n.createdAt);
          debugPrint(
              '[Notification] → push /rooms/$roomId/map (date=$dateStr, dotId=$dotId)');
          context.push(
            '/rooms/$roomId/map',
            extra: {'date': dateStr, 'dotId': dotId},
          );
        } else {
          debugPrint('[Notification] → push /rooms/$roomId (no dotId)');
          context.push('/rooms/$roomId');
        }
      },
      child: Container(
        color: n.isRead
            ? Colors.transparent
            : DottieColors.primaryLight.withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.md,
          vertical: Dimensions.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: actorColor.withAlpha(45),
                shape: BoxShape.circle,
                border: Border.all(
                    color: actorColor.withAlpha(120), width: 1),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: GoogleFonts.notoSansKr(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: actorColor,
                ),
              ),
            ),
            const SizedBox(width: Dimensions.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: n.actorNickname,
                          style: GoogleFonts.notoSansKr(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: actorColor,
                          ),
                        ),
                        TextSpan(
                          text: description,
                          style: GoogleFonts.notoSansKr(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: DottieColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (n.commentPreview != null) ...[
                    const SizedBox(height: Dimensions.xs),
                    Text(
                      n.commentPreview!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 13,
                        color: DottieColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: Dimensions.xs),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      DottieDateUtils.toTimeString(n.createdAt),
                      style: GoogleFonts.notoSansKr(
                        fontSize: 12,
                        color: DottieColors.textHint,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!n.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6, left: Dimensions.xs),
                decoration: const BoxDecoration(
                  color: DottieColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

