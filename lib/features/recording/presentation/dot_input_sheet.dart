import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/dimensions.dart';
import '../../../shared/widgets/dottie_button.dart';
import '../../cumulative_map/domain/place.dart';
import '../../cumulative_map/presentation/cumulative_map_provider.dart';
import '../../cumulative_map/presentation/room_places_provider.dart';
import '../../cumulative_map/presentation/room_thumbnail_provider.dart';
import '../../cumulative_map/presentation/widgets/place_search_sheet.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../character/paperdoll/presentation/paperdoll_provider.dart';
import '../../feed/domain/feed_entry.dart';
import '../../feed/presentation/feed_provider.dart';
import '../../feed/presentation/feed_local_photo_store.dart';
import '../../room/domain/room_model.dart';
import '../../room/presentation/room_provider.dart';
import '../../timeline/presentation/timeline_provider.dart';
import '../../search/presentation/tag_search_provider.dart';
import '../data/dot_remote_source.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../onboarding/domain/onboarding_step.dart';
import '../../onboarding/presentation/onboarding_tour_provider.dart';
import '../data/location_service.dart';
import '../domain/dot_model.dart';
import '../domain/tag_parser.dart';
import 'dot_rate_limit_provider.dart';
import 'recording_provider.dart';
import 'widgets/emotion_picker.dart';
import 'widgets/memo_with_tags_field.dart';

class DotInputSheet extends ConsumerStatefulWidget {
  const DotInputSheet({super.key});

  /// 저장 성공 후 오늘 첫 dot이면 true 반환
  static Future<bool> show(BuildContext context) async {
    return await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const DotInputSheet(),
        ) ??
        false;
  }

  @override
  ConsumerState<DotInputSheet> createState() => _DotInputSheetState();
}

class _DotInputSheetState extends ConsumerState<DotInputSheet> {
  final _memoController = HashtagAwareController();
  String? _selectedEmotion;
  String? _photoPath;
  Place? _selectedPlace; // B8 — 사용자가 검색해서 선택한 장소
  bool _isSaving = false;

  /// 공유할 방 선택. null = 아직 사용자가 안 건드림(= auto_share 기본값 사용).
  /// 사용자가 칩을 처음 탭하면 그 시점 effective 집합으로 초기화 후 토글한다.
  Set<String>? _selectedRoomIds;

  /// auto_share 켜진 방 id — 기본 pre-check 대상.
  Set<String> _autoShareRoomIds(List<Room> rooms) =>
      {for (final r in rooms) if (r.autoShare) r.id};

  /// 현재 실효 선택 집합 (사용자 미변경 시 auto_share 기본값).
  Set<String> _effectiveRoomIds(List<Room> rooms) =>
      _selectedRoomIds ?? _autoShareRoomIds(rooms);

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeRecordingProvider).valueOrNull;
    final isCapturing = session?.isCapturingLocation ?? false;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    // 시트 최대 높이 — 화면의 92% 까지. 키보드가 올라와도 본문이 잘리지 않도록
    // 본문은 ListView 로 스크롤 가능하게 두고, padding 으로 키보드 위까지 띄움.
    final maxHeight = MediaQuery.of(context).size.height * 0.75;

    // 저장 중일 때 시트 dismiss 차단 — 사용자가 swipe-down 또는 뒤로가기로
    // 닫으면 dot 은 저장됐는데 UI 가 "안 됐다" 고 보여 중복 등록 위험. PopScope
    // 가 dismiss 시도를 가로채 안내 메시지 표시.
    return PopScope(
      canPop: !_isSaving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isSaving) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('저장 중이에요. 잠시만 기다려주세요')),
          );
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        constraints: BoxConstraints(maxHeight: maxHeight),
        decoration: BoxDecoration(
          color: DottieColors.surface,
          borderRadius: BorderRadius.circular(Dimensions.radiusLg),
        ),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.fromLTRB(
              Dimensions.md,
              Dimensions.md,
              Dimensions.md,
              Dimensions.md + bottomPadding),
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
          ).animate().fadeIn(duration: 200.ms),
          const SizedBox(height: Dimensions.md),

          // 온보딩 투어 중일 때 힌트 배너
          if (ref.watch(onboardingTourProvider) == OnboardingStep.dotSheet)
            _TourHintBanner(),

          // 제목
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: DottieColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'dot 찍기',
                style: GoogleFonts.notoSansKr(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: DottieColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 280.ms, delay: 60.ms)
              .slideY(begin: 0.1, end: 0, duration: 280.ms, delay: 60.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: Dimensions.sm),

          // 현재 위치 상태
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isCapturing
                ? Row(
                    key: const ValueKey('capturing'),
                    children: [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: DottieColors.primary,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('위치 수집 중...',
                          style: GoogleFonts.notoSansKr(
                              fontSize: 13, color: DottieColors.textSecondary)),
                    ],
                  )
                : Row(
                    key: const ValueKey('idle'),
                    children: [
                      const Icon(Icons.location_on_rounded,
                          color: DottieColors.primary, size: 15),
                      const SizedBox(width: 4),
                      Text('현재 위치 자동 수집',
                          style: GoogleFonts.notoSansKr(
                              fontSize: 13, color: DottieColors.textSecondary)),
                    ],
                  ),
          )
              .animate()
              .fadeIn(duration: 280.ms, delay: 100.ms),
          const SizedBox(height: Dimensions.md),

          // 감정 이모지
          Text('지금 기분은?',
              style: GoogleFonts.notoSansKr(
                  fontWeight: FontWeight.w700, fontSize: 14, color: DottieColors.textPrimary))
              .animate()
              .fadeIn(duration: 280.ms, delay: 140.ms),
          const SizedBox(height: Dimensions.sm),
          EmotionPicker(
            selected: _selectedEmotion,
            onChanged: (e) => setState(() => _selectedEmotion = e),
          ),
          const SizedBox(height: Dimensions.md),

          // 메모 + 해시태그 강조 + 자동완성
          MemoWithTagsField(
            controller: _memoController,
            suggestionFetcher: (prefix) =>
                ref.read(tagAutocompleteProvider(prefix).future),
          )
              .animate()
              .fadeIn(duration: 280.ms, delay: 280.ms)
              .slideY(begin: 0.06, end: 0, duration: 280.ms, delay: 280.ms),
          const SizedBox(height: Dimensions.sm),

          // 장소 + 사진 — 가로 2분할 (양옆으로 동일 너비).
          Row(
            children: [
              Expanded(
                child: _PickerButton(
                  icon: Icons.place_outlined,
                  label: _selectedPlace?.name ?? '장소',
                  isSelected: _selectedPlace != null,
                  onTap: _pickPlace,
                  onClear: _selectedPlace != null
                      ? () => setState(() => _selectedPlace = null)
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PickerButton(
                  icon: Icons.add_a_photo_outlined,
                  label: _photoPath != null ? '사진 선택됨' : '사진',
                  isSelected: _photoPath != null,
                  onTap: _pickImage,
                  onClear: _photoPath != null
                      ? () => setState(() => _photoPath = null)
                      : null,
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 280.ms, delay: 300.ms),

          // 공유할 방 선택 — 방에 소속돼 있을 때만 노출. 미선택(전부 해제) = 개인 dot.
          _buildRoomSelector(),

          const SizedBox(height: Dimensions.lg),

          // 저장 버튼 — 60초 rate limit 안에 있으면 disable + countdown.
          Consumer(
            builder: (context, ref, _) {
              final asyncState = ref.watch(dotRateLimitProvider);
              final remaining =
                  asyncState.valueOrNull?.remainingSeconds ?? 0;
              final limited = remaining > 0;
              final isTourStep =
                  ref.watch(onboardingTourProvider) == OnboardingStep.dotSheet;
              if (!isTourStep) {
                return DottieButton(
                  label: limited ? '$remaining초 후 다시' : 'dot 찍기',
                  isLoading: _isSaving,
                  onTap: limited ? null : _saveDot,
                );
              }
              // 투어 중: StatefulWidget으로 분리해 Consumer rebuild마다 재시작 방지
              return _PulsingDotButton(
                label: limited ? '$remaining초 후 다시' : 'dot 찍기',
                isLoading: _isSaving,
                onTap: limited ? null : _saveDot,
              );
            },
          )
              .animate()
              .fadeIn(duration: 280.ms, delay: 360.ms)
              .slideY(begin: 0.08, end: 0, duration: 280.ms, delay: 360.ms, curve: Curves.easeOutCubic),
        ],
      ),
      ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('카메라로 찍기'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('앨범에서 선택'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source);
    if (file != null) setState(() => _photoPath = file.path);
  }

  Future<void> _pickPlace() async {
    // BE B8 — /places/search 는 latitude/longitude 필수.
    // 현재 위치를 미리 받아 시트에 전달 → 좌표 기반 정확한 검색.
    double? lat;
    double? lng;
    try {
      final pos = await ref
          .read(locationServiceProvider)
          .getCurrentPosition();
      lat = pos.latitude;
      lng = pos.longitude;
    } catch (e) {
      if (!mounted) return;
      _showLocationError(e);
      return;
    }
    if (!mounted) return;
    final picked = await PlaceSearchSheet.show(
      context,
      latitude: lat,
      longitude: lng,
      initialQuery: _selectedPlace?.name,
    );
    if (picked != null && mounted) {
      setState(() => _selectedPlace = picked);
    }
  }

  /// 공유할 방 선택 UI. 방 미소속이면 숨김. auto_share 방이 기본 선택.
  Widget _buildRoomSelector() {
    final rooms = ref.watch(roomListProvider).valueOrNull ?? const <Room>[];
    if (rooms.isEmpty) return const SizedBox.shrink();
    final effective = _effectiveRoomIds(rooms);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: Dimensions.md),
        Row(
          children: [
            Text('어디에 올릴까요?',
                style: GoogleFonts.notoSansKr(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: DottieColors.textPrimary)),
            const SizedBox(width: 6),
            Text(effective.isEmpty ? '나만 보기' : '${effective.length}개 방',
                style: GoogleFonts.notoSansKr(
                    fontSize: 12, color: DottieColors.textHint)),
          ],
        ),
        const SizedBox(height: Dimensions.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final r in rooms)
              _RoomChip(
                label: r.name,
                selected: effective.contains(r.id),
                onTap: () => _toggleRoom(rooms, r.id),
              ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 280.ms, delay: 320.ms);
  }

  void _toggleRoom(List<Room> rooms, String roomId) {
    setState(() {
      final next = {..._effectiveRoomIds(rooms)};
      if (!next.remove(roomId)) next.add(roomId);
      _selectedRoomIds = next;
    });
  }

  Future<void> _saveDot() async {
    // pop 후에도 SnackBar 가 안전히 뜨도록 root ScaffoldMessenger 를 미리 확보.
    // (시트 dismiss 후 시트 context 는 deactivated.)
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _isSaving = true);
    var result = await _runCapture();
    if (!mounted) return;
    // 거리 초과 → 사용자 확인 후 override 재호출
    if (result == null) {
      setState(() => _isSaving = false);
      return;
    }
    if (result.uploadError != null) {
      setState(() => _isSaving = false);
      _handleUploadError(messenger, result.uploadError!);
      return;
    }
    if (result.tooFar != null) {
      setState(() => _isSaving = false);
      final confirm = await _confirmFarPlace(result.tooFar!);
      if (!mounted || !confirm) return;
      setState(() => _isSaving = true);
      result = await _runCapture(overrideDistance: true);
      if (!mounted) return;
      if (result == null || result.tooFar != null) {
        setState(() => _isSaving = false);
        return;
      }
      if (result.uploadError != null) {
        setState(() => _isSaving = false);
        _handleUploadError(messenger, result.uploadError!);
        return;
      }
    }
    final captured = result.captured!;

    // 사진 로컬 경로 등록 (BE variant 생성 전 피드 카드 즉시 표시용)
    final photoUploadFailed = _photoPath != null &&
        captured.dot != null &&
        (captured.dot!.photoUrl == null || captured.dot!.photoUrl!.isEmpty);
    if (_photoPath != null && captured.dot != null) {
      ref
          .read(feedLocalPhotoStoreProvider.notifier)
          .set(captured.dot!.id, _photoPath!);
    }

    // 피드 낙관적 삽입 — 서버 refresh 없이 새 dot 즉시 피드 상단 표시.
    if (captured.dot != null) {
      final me = ref.read(currentDottieUserProvider).valueOrNull;
      if (me != null) {
        final colorHex = ref.read(paperdollProvider).valueOrNull?.colorHex
            ?? me.character.colorHex;
        final optimisticEntry = FeedEntry(
          dot: captured.dot!,
          authorId: me.uid,
          authorNickname: me.nickname,
          authorColorHex: colorHex,
          isMine: true,
          // 서버가 돌려준 실제 공유 방(없으면 빈 집합 = 개인).
          sharedRoomIds: captured.dot!.sharedRoomIds?.toSet() ?? const {},
        );
        // 전체 피드(null) 인스턴스에 즉시 삽입. room 필터 인스턴스는 서버 refresh 시 반영.
        ref
            .read(feedNotifierProvider(null).notifier)
            .prependEntry(optimisticEntry);
      }
    }
    // 새 dot 이 저장됐으니 rate limit 카운트다운을 즉시 60초로 리셋.
    ref.read(dotRateLimitProvider.notifier).onDotSaved();
    // D — BE B14 자동 share: auto_share=true 룸들에 dot 의 day_log 가
    // 자동 share 됐을 수 있음. FE 측 룸 관련 캐시 모두 invalidate해
    // 다음 룸 진입 시 새 dot 이 즉시 누적 지도/하루 지도에 반영되도록.
    ref.invalidate(roomListProvider);
    // 모든 cumulative / places / thumbnail provider 무효화 — family 단위라
    // 어떤 roomId 가 auto_share 인지 클라이언트는 모름. 무차별 invalidate.
    ref.invalidate(cumulativeRoomDotsProvider);
    ref.invalidate(roomPlacesProvider);
    ref.invalidate(roomThumbnailUrlProvider);
    // allDayLogs / todayDayLog: today_map / timeline 이 watch 중이라 keepAlive
    // 상태. 명시 invalidate 없으면 feed rebuild 시 stale 캐시를 반환해 새 dot 누락.
    ref.invalidate(allDayLogsProvider);
    ref.invalidate(todayDayLogProvider);
    ref.invalidate(timelineDayLogsProvider);
    // feedNotifierProvider 는 여기서 invalidate 하지 않음.
    // prependEntry 로 낙관적 삽입한 직후 invalidate 하면 family 전체가 rebuild 되고
    // 서버 응답이 optimistic state 를 덮어써서 새 dot/사진이 즉시 사라지는 버그 발생.
    // 피드는 사용자의 pull-to-refresh 또는 다음 진입 시 서버 데이터로 갱신됨.
    Navigator.pop(context, captured.isFirst && captured.dot != null);
    // pop 직후 시트 context 는 deactivated — root messenger 사용.
    final String successMsg;
    if (captured.dot == null) {
      successMsg = '위치 수집에 실패했습니다.';
    } else if (photoUploadFailed) {
      // dot 자체는 저장. 사진만 실패 — 사용자에게 명시. 로컬 path 가 보존돼
      // 다음에 다시 시도 가능 (현재는 수동 — 향후 background sync).
      successMsg = '사진 업로드에 실패했어요. dot 은 저장됐어요.';
    } else {
      successMsg = 'dot을 찍었어요! ${captured.dot!.placeName ?? ''} 📍';
    }
    messenger.showSnackBar(SnackBar(content: Text(successMsg)));
  }

  /// captureDot 실행 wrapper — PlaceTooFarException / DotUploadException 을 결과로 변환.
  Future<_CaptureOutcome?> _runCapture({bool overrideDistance = false}) async {
    try {
      final memo = _memoController.text.trim();
      // 태그는 메모 본문에서 #토큰 정규식 추출 후 정규화. 메모 원문은 그대로 보존.
      final tags = TagParser.extractFromText(memo);
      // 방 선택 — **사용자가 칩을 실제로 건드렸을 때만** 명시 전송.
      //   - 미소속 / 미변경 → null(생략) → BE 기본(auto_share + 날짜공유) 유지
      //     (하위호환: 안 건드리면 지금 동작 그대로. 날짜공유 B13 도 안 깨짐).
      //   - 변경 → 실효 선택 명시([]=개인, [ids]=특정 방, auto_share 무시).
      final rooms = ref.read(roomListProvider).valueOrNull ?? const <Room>[];
      final roomIds = (rooms.isEmpty || _selectedRoomIds == null)
          ? null
          : _selectedRoomIds!.toList();
      final res =
          await ref.read(activeRecordingProvider.notifier).captureDot(
                memo: memo.isEmpty ? null : memo,
                emotion: _selectedEmotion,
                photoLocalPath: _photoPath,
                placeId: _selectedPlace?.id,
                placeLat: _selectedPlace?.latitude,
                placeLng: _selectedPlace?.longitude,
                placeOverride: _selectedPlace,
                overrideDistanceCheck: overrideDistance,
                tags: tags,
                roomIds: roomIds,
              );
      return _CaptureOutcome.captured(res);
    } on LocationException catch (e) {
      // 권한 거부 / 서비스 OFF / GPS 타임아웃 → "설정 열기" 안내 SnackBar
      if (mounted) _showLocationError(e);
      return null;
    } on PlaceTooFarException catch (e) {
      return _CaptureOutcome.tooFar(e);
    } on DotUploadException catch (e) {
      return _CaptureOutcome.uploadError(e);
    }
  }

  /// 위치 권한/서비스 에러 SnackBar. 영구 거부 / 서비스 OFF 시 *설정 열기* 액션
  /// 노출 — 사용자가 시스템 설정 앱을 찾지 못하는 친구 회피.
  void _showLocationError(Object e) {
    final messenger = ScaffoldMessenger.of(context);
    if (e is LocationException && e.shouldOpenSettings) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(e.message),
          action: SnackBarAction(
            label: '설정 열기',
            onPressed: () => openAppSettings(),
          ),
          duration: const Duration(seconds: 6),
        ),
      );
      return;
    }
    final msg = e is LocationException ? e.message : '위치를 가져오지 못했어요';
    messenger.showSnackBar(SnackBar(content: Text(msg)));
  }

  /// BE 4xx 응답 분기 — 메시지 + 사이드 이펙트 (RATE_LIMITED 의 경우 카운트다운 갱신).
  void _handleUploadError(
      ScaffoldMessengerState messenger, DotUploadException e) {
    if (e.isRateLimited) {
      // BE 가 알려준 정확한 retry 시점으로 카운트다운 동기화.
      final retry = e.retryAfterSeconds ?? 60;
      ref.read(dotRateLimitProvider.notifier).bumpFromServer(retry);
      messenger.showSnackBar(
        SnackBar(content: Text('$retry초 후에 다시 시도할 수 있어요')),
      );
      return;
    }
    final msg = switch (e.code) {
      'INVALID_TAG_FORMAT' => '태그 형식이 올바르지 않아요',
      'TAGS_TOO_MANY' => '태그는 최대 10개까지만 가능해요',
      'INVALID_TIMESTAMP' => '시간 정보가 잘못됐어요. 다시 시도해 주세요',
      // 비멤버 방은 BE 가 조용히 제외(드롭)하므로 NOT_ROOM_MEMBER 는 오지 않음.
      // INVALID_ROOM_ID(형식 오류, 클라 버그)만 400 으로 옴.
      'INVALID_ROOM_ID' => '방 정보가 올바르지 않아요. 다시 시도해 주세요',
      _ => e.message ?? 'dot 저장에 실패했어요',
    };
    messenger.showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<bool> _confirmFarPlace(PlaceTooFarException e) async {
    final placeName = _selectedPlace?.name ?? '선택한 장소';
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('장소가 멀어요',
            style: GoogleFonts.notoSansKr(fontWeight: FontWeight.w700)),
        content: Text(
          '"$placeName" 은(는) 현재 위치에서 ${e.distanceM.toStringAsFixed(0)}m 떨어져 있어요.\n그래도 등록할까요?',
          style: GoogleFonts.notoSansKr(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('취소',
                style: GoogleFonts.notoSansKr(
                    color: DottieColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('등록',
                style: GoogleFonts.notoSansKr(
                    color: DottieColors.primary,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

/// 장소/사진 가로 2분할 picker 버튼.
/// - 미선택: outline 만, primary 색.
/// - 선택됨: 살짝 fill + 우측에 X 아이콘 (탭 시 onClear).
/// 방 선택 토글 칩 — 선택 시 primary 채움 + 체크.
class _RoomChip extends StatelessWidget {
  const _RoomChip({
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
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? DottieColors.primary.withValues(alpha: 0.12)
              : DottieColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? DottieColors.primary : DottieColors.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              size: 16,
              color: selected ? DottieColors.primary : DottieColors.textHint,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.notoSansKr(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? DottieColors.primary
                    : DottieColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  const _PickerButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  /// null 이면 X 아이콘 미노출 (= 미선택 상태). 탭 시 선택 해제 콜백.
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: DottieColors.primary,
        side: BorderSide(
          color: isSelected
              ? DottieColors.primary
              : DottieColors.primary.withAlpha(140),
          width: isSelected ? 1.4 : 1.0,
        ),
        backgroundColor:
            isSelected ? DottieColors.primary.withAlpha(20) : null,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusMd),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.notoSansKr(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onClear != null) ...[
            const SizedBox(width: 4),
            // child 의 InkResponse onTap 이 parent OutlinedButton 보다 우선
            // hit-test 되므로 X 탭은 선택 해제만 수행 (picker 다시 안 열림).
            InkResponse(
              onTap: onClear,
              radius: 14,
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.close_rounded, size: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── 온보딩 투어 Pulsing 저장 버튼 ──────────────────────────────────────
//
// Consumer rebuild (dotRateLimitProvider 1초마다 갱신)마다 flutter_animate가
// 재시작되는 문제를 방지하기 위해 AnimationController를 직접 관리하는 위젯으로 분리.

class _PulsingDotButton extends StatefulWidget {
  const _PulsingDotButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  State<_PulsingDotButton> createState() => _PulsingDotButtonState();
}

class _PulsingDotButtonState extends State<_PulsingDotButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: DottieColors.primary.withValues(alpha: _pulse.value * 0.55),
              blurRadius: _pulse.value * 22,
              spreadRadius: _pulse.value * 2,
            ),
          ],
        ),
        child: child,
      ),
      child: DottieButton(
        label: widget.label,
        isLoading: widget.isLoading,
        onTap: widget.onTap,
      ),
    );
  }
}

// ── 온보딩 투어 힌트 배너 ──────────────────────────────────────

class _TourHintBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: DottieColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DottieColors.primary.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.tips_and_updates_outlined,
              color: DottieColors.primary, size: 17),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '메모나 사진은 선택사항이에요.\n저장만 눌러도 지금 위치가 기록돼요!',
              style: GoogleFonts.notoSansKr(
                color: DottieColors.primary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 150.ms)
        .slideY(begin: -0.1, end: 0, duration: 300.ms, delay: 150.ms, curve: Curves.easeOutCubic);
  }
}

/// captureDot 결과 — 정상 / 거리 초과 / BE 업로드 거부 분기.
class _CaptureOutcome {
  const _CaptureOutcome._({this.captured, this.tooFar, this.uploadError});
  factory _CaptureOutcome.captured(({Dot? dot, bool isFirst}) r) =>
      _CaptureOutcome._(captured: r);
  factory _CaptureOutcome.tooFar(PlaceTooFarException e) =>
      _CaptureOutcome._(tooFar: e);
  factory _CaptureOutcome.uploadError(DotUploadException e) =>
      _CaptureOutcome._(uploadError: e);
  final ({Dot? dot, bool isFirst})? captured;
  final PlaceTooFarException? tooFar;
  final DotUploadException? uploadError;
}
