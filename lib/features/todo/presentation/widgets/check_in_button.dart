import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/utils/location_utils.dart';
import '../../../cumulative_map/domain/place.dart';
import '../../../recording/data/dot_remote_source.dart';
import '../../../recording/data/location_service.dart';
import '../../../recording/presentation/dot_rate_limit_provider.dart';
import '../../../recording/presentation/recording_provider.dart';
import '../../domain/todo_item_model.dart';
import '../../domain/todo_list_model.dart';
import '../todo_provider.dart';
import 'stamp_animation.dart';

/// 도착 인증 (체크인) 버튼.
///
/// 흐름:
///   1) 현재 GPS 가져오기
///   2) item 좌표와 거리 계산
///   3) **500m 초과 시 인증 불가** — "근처로 가야 인증할 수 있어요" 안내. override 없음.
///   4) captureDot() 으로 정상 Dot 1건 생성. item 의 placeName/category 명시 전달 →
///      GPS reverse geocoding 으로 "강남대로 ..." 가 덮어쓰지 않음 ("강남역" 유지)
///   5) markCheckedIn() 으로 TodoItem 에 dot.id 링크
///   6) StampAnimation 풀스크린 오버레이 → 시트 자동 닫힘
class CheckInButton extends ConsumerStatefulWidget {
  const CheckInButton({
    super.key,
    required this.todoList,
    required this.item,
  });

  final TodoList todoList;
  final TodoItem item;

  @override
  ConsumerState<CheckInButton> createState() => _CheckInButtonState();
}

class _CheckInButtonState extends ConsumerState<CheckInButton> {
  bool _processing = false;

  /// 체크인 허용 반경. 사용자 결정: dot 인증과 동일한 *근처* 개념이되 500m
  /// (GPS 정확도 + 도심 빌딩 등 신호 흔들림 감안 — 200m 보다 관대).
  /// 초과 시 인증 불가 (override 없음).
  static const double _maxDistanceM = 500.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: _processing ? null : _onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: DottieColors.primary,
          disabledBackgroundColor:
              DottieColors.primary.withValues(alpha: 0.4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        icon: _processing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.4,
                ),
              )
            : const Icon(Icons.where_to_vote_rounded, size: 22),
        label: Text(
          _processing ? '기록 중...' : '다녀왔어요',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(
        begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutCubic);
  }

  Future<void> _onPressed() async {
    setState(() => _processing = true);
    try {
      // 1) 현재 GPS
      final pos = await ref
          .read(locationServiceProvider)
          .getCurrentPosition();
      if (!mounted) return;

      // 2) 거리 검증 — 500m 초과 시 즉시 거부.
      final distM = LocationUtils.distanceM(
        pos.latitude,
        pos.longitude,
        widget.item.latitude,
        widget.item.longitude,
      );
      if (distM > _maxDistanceM) {
        _showFarAway(distM);
        return;
      }

      // 3) Dot 생성 — 일반 dot 입력과 동일한 흐름.
      //    placeName/category 는 GPS 기준 reverse geocoding 결과 (도로명 주소).
      //    dot.place 는 todo item 정보로 client-side 구성해 inline — BE 응답
      //    timing 과 무관하게 dot detail 의 장소 카드가 즉시 보임.
      //    (BE 가 응답에 place 채워주면 polling 후 더 풍부한 정보로 보강;
      //     안 채워줘도 client 가 만든 부분 정보가 유지됨.)
      final placeOverride = widget.item.placeId != null
          ? Place(
              id: widget.item.placeId!,
              name: widget.item.placeName ?? '이름 없는 장소',
              category: widget.item.placeCategory,
              latitude: widget.item.latitude,
              longitude: widget.item.longitude,
            )
          : null;
      final result =
          await ref.read(activeRecordingProvider.notifier).captureDot(
                memo: widget.item.notes,
                emotion: widget.item.emotion,
                placeId: widget.item.placeId,
                placeLat: widget.item.placeId != null
                    ? widget.item.latitude
                    : null,
                placeLng: widget.item.placeId != null
                    ? widget.item.longitude
                    : null,
                placeOverride: placeOverride,
                // 위에서 이미 500m 검증했고 captureDot 의 200m 검증은
                // 의도와 다르므로 override 로 skip.
                overrideDistanceCheck: true,
                tags: const [],
              );
      if (!mounted) return;
      final dot = result.dot;
      if (dot == null) {
        setState(() => _processing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기록에 실패했어요. 잠시 후 다시 시도해 주세요.')),
        );
        return;
      }

      // 4) TodoItem 에 dot.id 링크
      final marked = await ref
          .read(todoNotifierProvider.notifier)
          .markCheckedIn(
            todoListId: widget.todoList.id,
            itemId: widget.item.id,
            checkInDotId: dot.id,
          );
      if (!mounted) return;
      if (!marked) {
        setState(() => _processing = false);
        return;
      }

      // 5) 스탬프 애니메이션
      await StampAnimation.show(context, placeName: widget.item.placeName);
      if (!mounted) return;
      // 시트 자동 닫힘
      Navigator.of(context).pop();
    } on DotUploadException catch (e) {
      // BE 4xx 비즈니스 에러 — 사용자에게 친절한 메시지로 변환.
      if (!mounted) return;
      setState(() => _processing = false);
      _handleUploadError(e);
    } on LocationException catch (e) {
      // 위치 권한/서비스 거부 — 시스템 설정 안내.
      if (!mounted) return;
      setState(() => _processing = false);
      _showLocationError(e);
    } catch (e) {
      if (!mounted) return;
      setState(() => _processing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('기록에 실패했어요. 잠시 후 다시 시도해 주세요.')),
      );
    }
  }

  void _showLocationError(LocationException e) {
    final messenger = ScaffoldMessenger.of(context);
    if (e.shouldOpenSettings) {
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
    messenger.showSnackBar(SnackBar(content: Text(e.message)));
  }

  /// BE 의 4xx 응답을 사용자 친화 메시지로 분기. RATE_LIMITED 는 dot 입력
  /// 시트의 카운트다운(`dotRateLimitProvider`) 도 함께 동기화 — FAB 측이 같은
  /// 시계로 갱신됨. dot_input_sheet._handleUploadError 와 동일 패턴.
  void _handleUploadError(DotUploadException e) {
    final messenger = ScaffoldMessenger.of(context);
    if (e.isRateLimited) {
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
      _ => e.message ?? '기록에 실패했어요',
    };
    messenger.showSnackBar(SnackBar(content: Text(msg)));
  }

  /// 500m 초과 안내 — override 없음. 사용자가 *실제로 그 위치까지 가야* 다녀온 표시 가능.
  void _showFarAway(double distM) {
    if (!mounted) return;
    setState(() => _processing = false);
    final distKm = (distM / 1000).toStringAsFixed(1);
    final distMRound = distM.toStringAsFixed(0);
    final dist = distM > 1000 ? '${distKm}km' : '${distMRound}m';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('이 스팟에서 $dist 떨어져 있어요. 500m 안에서만 다녀왔다고 표시할 수 있어요.'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
