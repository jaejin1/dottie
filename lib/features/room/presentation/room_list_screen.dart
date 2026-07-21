import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/typography.dart';
import '../../../../core/utils/color_hex.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/utils/error_messages.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../onboarding/domain/onboarding_step.dart';
import '../../onboarding/presentation/onboarding_tour_provider.dart';
import '../../onboarding/presentation/tour_content.dart';
import '../../cumulative_map/presentation/room_thumbnail_provider.dart';
import '../domain/room_model.dart';
import 'room_provider.dart';
import 'widgets/room_create_dialog.dart';
import 'widgets/room_join_dialog.dart';

class RoomListScreen extends ConsumerStatefulWidget {
  const RoomListScreen({super.key});

  @override
  ConsumerState<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends ConsumerState<RoomListScreen> {
  final _createRoomKey = GlobalKey();
  final _firstRoomCardKey = GlobalKey();
  bool _tourShown = false;
  bool _hintShown = false;
  TutorialCoachMark? _coachMark;
  TutorialCoachMark? _hintCoachMark;
  ProviderSubscription<OnboardingStep>? _tourSub;
  ProviderSubscription<AsyncValue<List<Room>>>? _roomsSub;

  /// 사용자가 첫 방을 가졌을 때 1회만 표시하는 hint 의 플래그 키.
  static String _hintKey(String uid) => 'room.first_card_hint_seen_v1.$uid';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowRoomCoachMark();
      _maybeShowFirstCardHint();
    });
    _tourSub = ref.listenManual(onboardingTourProvider, (prev, next) {
      if (next == OnboardingStep.idle || next == OnboardingStep.dotFab) {
        _tourShown = false;
      }
      if (next == OnboardingStep.room && !_tourShown) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _maybeShowRoomCoachMark();
        });
      }
    });
    // 방 목록 로딩 완료 시에도 재시도 — 데이터가 코치마크보다 늦게 도착할 때 대비
    _roomsSub = ref.listenManual(roomListProvider, (prev, next) {
      if (next.hasValue) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _maybeShowRoomCoachMark();
          _maybeShowFirstCardHint();
        });
      }
    });
  }

  @override
  void dispose() {
    _tourSub?.close();
    _roomsSub?.close();
    _coachMark?.finish();
    _hintCoachMark?.finish();
    super.dispose();
  }

  void _maybeShowRoomCoachMark() {
    if (!mounted || _tourShown) return;
    if (ref.read(onboardingTourProvider) != OnboardingStep.room) return;

    // 신규 사용자(방 0개)는 createRoom spotlight 건너뛰고 즉시 character step으로.
    // 첫 방 생성/join 시점에 _maybeShowFirstCardHint 가 별도로 안내함.
    final roomsAsync = ref.read(roomListProvider);
    final hasRooms = (roomsAsync.valueOrNull?.isNotEmpty) ?? false;
    if (!hasRooms) {
      _tourShown = true;
      ref.read(onboardingTourProvider.notifier).advance(); // room → character
      return;
    }

    _tourShown = true;
    _showRoomCoachMark();
  }

  /// tour 종료 후, 사용자가 처음 방을 가지는 시점에 1회만 표시하는 hint.
  ///
  /// 트리거: 방 목록이 비어있다가 1개 이상으로 변할 때 (또는 화면 진입 시 이미 방 있고
  /// 한 번도 본 적 없을 때). SharedPreferences 플래그로 중복 방지.
  Future<void> _maybeShowFirstCardHint() async {
    if (!mounted || _hintShown) return;
    // tour 진행 중이면 hint 표시 안 함 — _showRoomCoachMark 와 충돌 방지
    final tourStep = ref.read(onboardingTourProvider);
    if (tourStep != OnboardingStep.idle && tourStep != OnboardingStep.done) {
      return;
    }
    // 카드가 렌더되어야 spotlight 가능
    if (_firstRoomCardKey.currentContext == null) return;

    final uid = ref.read(currentDottieUserProvider).valueOrNull?.uid;
    if (uid == null) return;

    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_hintKey(uid)) ?? false;
    if (seen) {
      _hintShown = true;
      return;
    }

    if (!mounted || _firstRoomCardKey.currentContext == null) return;
    _hintShown = true;
    await prefs.setBool(_hintKey(uid), true);
    if (!mounted) return;
    _showFirstCardHint();
  }

  void _showFirstCardHint() {
    _hintCoachMark = TutorialCoachMark(
      targets: [
        TargetFocus(
          identify: 'firstRoomCardHint',
          keyTarget: _firstRoomCardKey,
          shape: ShapeLightFocus.RRect,
          radius: 16,
          paddingFocus: 6,
          enableOverlayTab: false,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (_, controller) => TourContent(
                message: '방을 탭해서\n함께하는 지도를 확인해보세요',
                description: '멤버들이 기록한 dot이 한 지도에 모여요',
                actionLabel: '확인',
                onAction: () => controller.next(),
                onSkip: controller.skip,
              ),
            ),
          ],
        ),
      ],
      colorShadow: const Color(0xFF0A0908),
      opacityShadow: 0.72,
      focusAnimationDuration: const Duration(milliseconds: 350),
      pulseAnimationDuration: const Duration(milliseconds: 900),
      unFocusAnimationDuration: const Duration(milliseconds: 200),
      skipWidget: tourSkipIcon,
      onFinish: () {},
      onSkip: () => true,
    );
    _hintCoachMark!.show(context: context, rootOverlay: true);
  }

  void _showRoomCoachMark() {
    final hasRoomCard = _firstRoomCardKey.currentContext != null;

    final targets = <TargetFocus>[
      TargetFocus(
        identify: 'createRoom',
        keyTarget: _createRoomKey,
        shape: ShapeLightFocus.Circle,
        radius: 28,
        paddingFocus: 10,
        enableOverlayTab: false,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (_, controller) => TourContent(
              message: '친구와 같은 지도를\n함께 볼 수 있어요',
              description: '방을 만들고 초대 코드로 친구를 불러보세요',
              actionLabel: '다음',
              onAction: () => controller.next(),
              stepCurrent: 4,
              stepTotal: 5,
              onSkip: controller.skip,
            ),
          ),
        ],
      ),
      if (hasRoomCard)
        TargetFocus(
          identify: 'firstRoomCard',
          keyTarget: _firstRoomCardKey,
          shape: ShapeLightFocus.RRect,
          radius: 16,
          paddingFocus: 6,
          enableOverlayTab: false,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (_, controller) => TourContent(
                message: '방을 탭해서\n함께하는 지도를 확인해보세요',
                description: '멤버들이 기록한 dot이 한 지도에 모여요',
                actionLabel: '확인',
                onAction: () => controller.next(),
                stepCurrent: 4,
                stepTotal: 5,
                onSkip: controller.skip,
              ),
            ),
          ],
        ),
    ];

    _coachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFF0A0908),
      opacityShadow: 0.78,
      focusAnimationDuration: const Duration(milliseconds: 350),
      pulseAnimationDuration: const Duration(milliseconds: 900),
      unFocusAnimationDuration: const Duration(milliseconds: 200),
      skipWidget: tourSkipIcon,
      onFinish: () {
        if (mounted) {
          ref.read(onboardingTourProvider.notifier).advance(); // room → character
        }
      },
      onSkip: () {
        ref.read(onboardingTourProvider.notifier).skip();
        return true;
      },
    );
    _coachMark!.show(context: context, rootOverlay: true);
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomListProvider);

    return Scaffold(
      backgroundColor: DottieColors.background,
      appBar: AppBar(
        title: Text('방', style: AppTypography.tabHeader()),
        centerTitle: false,
        backgroundColor: DottieColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          // 태그/메모 기반 dot 검색 — 메인 탭에서 옮겨옴.
          IconButton(
            icon: const Icon(Icons.search_rounded,
                color: DottieColors.textSecondary, size: 22),
            onPressed: () => context.push('/search'),
            tooltip: '검색',
          ),
          IconButton(
            icon: const Icon(Icons.add_home_outlined,
                color: DottieColors.textSecondary, size: 22),
            onPressed: () => RoomJoinDialog.show(context),
            tooltip: '초대 링크로 참여',
          ),
          IconButton(
            key: _createRoomKey,
            icon: const Icon(Icons.add_rounded,
                color: DottieColors.textSecondary, size: 22),
            onPressed: () => RoomCreateDialog.show(context),
            tooltip: '방 만들기',
          ),
          const SizedBox(width: 4),
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
        error: (e, _) => ErrorView(
          message: userMessageFor(e),
          onRetry: () => ref.invalidate(roomListProvider),
        ),
        data: (rooms) => rooms.isEmpty
            ? _EmptyState(onCreateTap: () => RoomCreateDialog.show(context))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                itemCount: rooms.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _RoomCard(
                      key: i == 0 ? _firstRoomCardKey : null,
                      room: rooms[i],
                    )
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
    );
  }

}

// ── 방 카드 ───────────────────────────────────────────────────

class _RoomCard extends StatelessWidget {
  const _RoomCard({super.key, required this.room});
  final Room room;

  @override
  Widget build(BuildContext context) {
    // 방 id 해시 기반 액센트 — 카드 전체에 살짝 tinted 톤만 적용.
    // 좌측 바 X. 방마다 다른 분위기로 식별 + 노이즈는 작게.
    final color = DottieColors.accentFor(room.id);
    return Material(
      color: color.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => context.push('/rooms/${room.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.18),
              width: 0.8,
            ),
          ),
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
                        _MemberCountBadge(count: room.members.length),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            DottieDateUtils.toKoreanDate(room.createdAt),
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
              const SizedBox(width: 8),
              // 누적 지도 mini — B11 thumbnail URL fetch.
              // 로딩/에러 시 placeholder.
              _RoomMiniMap(
                  roomId: room.id,
                  dotCount: room.sharedDates.length,
                  members: room.members),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  color: DottieColors.textHint, size: 20),
            ],
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
          final color = colorFromHex(show[i].character.colorHex,
              fallback: DottieColors.primary);
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

// ── 룸 누적 지도 mini — B11 ──────────────────────────────────
//
// `/v1/rooms/:id/thumbnail` URL fetch → Mapbox static 이미지.
// 로딩/에러/빈 응답이면 placeholder (멤버 컬러 점 + dot 일수).
class _RoomMiniMap extends ConsumerWidget {
  const _RoomMiniMap({
    required this.roomId,
    required this.dotCount,
    required this.members,
  });
  final String roomId;
  final int dotCount;
  final List<RoomMember> members;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlAsync = ref.watch(roomThumbnailUrlProvider(roomId));
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 64,
        height: 48,
        child: urlAsync.when(
          loading: () => _placeholder(),
          error: (_, __) => _placeholder(),
          data: (url) {
            if (url == null || url.isEmpty) return _placeholder();
            return CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, __) => _placeholder(),
              errorWidget: (_, __, ___) => _placeholder(),
            );
          },
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2620), Color(0xFF3A3530)],
        ),
        border: Border.all(color: DottieColors.border, width: 0.5),
      ),
      child: Stack(
        children: [
          for (var i = 0; i < members.take(5).length; i++)
            Positioned(
              left: 8.0 + (i * 11),
              top: 14.0 + ((i * 7) % 18),
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: colorFromHex(members[i].character.colorHex,
                      fallback: DottieColors.primary),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          if (dotCount > 0)
            Positioned(
              right: 4,
              bottom: 3,
              child: Text(
                '$dotCount일',
                style: GoogleFonts.notoSansKr(
                  fontSize: 9,
                  color: Colors.white.withAlpha(180),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
