import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/typography.dart';
import '../../../core/utils/color_hex.dart';
import '../../../core/constants/dimensions.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../core/router/app_router.dart';
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
        backgroundColor: DottieColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('알림', style: AppTypography.tabHeader()),
        centerTitle: false,
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
                    children: const [
                      SizedBox(height: 80),
                      EmptyState(
                        icon: Icons.notifications_none_rounded,
                        title: '아직 알림이 없어요',
                        description: '댓글이나 새 dot 알림이 여기에 표시돼요',
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

    final description = switch (n.type) {
      NotificationType.comment => '님이 회원님 dot에 댓글을 남겼어요',
      NotificationType.mention => '님이 회원님을 멘션했어요',
      NotificationType.dotCreated => '님이 오늘 dot을 남겼어요 · 회원님도 남겨보세요',
    };

    // 액터 정체성 색 (댓글/멘션 작성자) — BE `actor_color_hex` 기반, default 폴백
    final actorColor =
        colorFromHex(n.actorColorHex, fallback: DottieColors.primary);

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

        final router = GoRouter.of(context);
        final dotId = n.dotId;

        if (dotId != null && dotId.isNotEmpty) {
          // shell 안의 nested route(`/rooms/:id/map`) 를 shell 밖(알림 화면)에서
          // push 하면 navigator stack 이 어긋나 반복 네비게이션이 발생함
          // (FCM 탭 핸들러와 동일한 문제). shell-external fullscreen alias 인
          // `/dot-map` 을 사용 — 뒤로가기 시 알림 목록으로 자연 복귀.
          // BE가 제공하는 dot_date 우선 (정확). 누락 시 알림 생성 시각으로 폴백.
          final dateStr =
              n.dotDate ?? DottieDateUtils.toDateString(n.createdAt);
          debugPrint(
              '[Notification] → push /dot-map (roomId=$roomId, date=$dateStr, dotId=$dotId)');
          router.push(
            AppRoutes.dotMap,
            extra: {'roomId': roomId, 'date': dateStr, 'dotId': dotId},
          );
        } else {
          // 룸 메인은 shell 내부 경로 — 알림 화면을 먼저 pop 한 뒤 다음 frame 에
          // shell 위에서 push (shell 미mount 상태 push 로 인한 흰 화면 회피).
          debugPrint('[Notification] → push /rooms/$roomId (no dotId)');
          Navigator.of(context).pop();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            router.push('/rooms/$roomId');
          });
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

