import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_provider.dart';
import '../data/dot_local_source.dart';

part 'dot_rate_limit_provider.g.dart';

/// dot 생성 rate limit (BE: 같은 user 의 dot 은 timestamp 기준 60초 간격).
///
/// FE 의 1차 가드 — 마지막 dot timestamp 기준 60초 안이면 저장 버튼을 disable
/// 시키고 카운트다운 표시. BE 가 권위이긴 하지만 사용자 입장에선 시도하기 전에
/// 알려주는 게 친절.
///
/// BE 가 `RATE_LIMITED` 응답한 경우 [DotRateLimit.bumpFromServer] 로 BE 가
/// 알려준 retryAfterSeconds 까지 lock 연장 가능 (clock skew 흡수).
class RateLimitState {
  const RateLimitState({required this.remainingSeconds});
  final int remainingSeconds;

  bool get isLimited => remainingSeconds > 0;
}

const Duration _kRateLimitWindow = Duration(seconds: 60);

@riverpod
class DotRateLimit extends _$DotRateLimit {
  /// 매 1초 stream — UI 가 watch 하면 자동으로 카운트다운.
  StreamController<RateLimitState>? _controller;
  Timer? _timer;

  /// 서버가 알려준 retry deadline 으로 override (BE 가 우리 로컬 last 보다 더
  /// 먼 시점을 알려주는 케이스 — clock skew, 다른 디바이스 동기 등).
  /// 서버 응답이 없으면 null.
  DateTime? _serverOverrideUntil;

  @override
  Stream<RateLimitState> build() {
    final controller = StreamController<RateLimitState>();
    _controller = controller;
    ref.onDispose(() {
      _timer?.cancel();
      controller.close();
    });

    // 즉시 한 번 emit + 1초 주기로 갱신.
    _emit();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _emit());

    return controller.stream;
  }

  Future<void> _emit() async {
    final controller = _controller;
    if (controller == null || controller.isClosed) return;
    final remaining = await _computeRemaining();
    if (controller.isClosed) return;
    controller.add(RateLimitState(remainingSeconds: remaining));
  }

  Future<int> _computeRemaining() async {
    final now = DateTime.now().toUtc();
    // 1) 서버 override 가 더 먼 시점이면 그쪽을 따름.
    final override = _serverOverrideUntil;
    final overrideRemaining = override != null
        ? override.difference(now).inSeconds
        : 0;
    // 2) 로컬 last dot timestamp 기준 잔여.
    final userId = ref.read(currentDottieUserProvider).valueOrNull?.uid ??
        ref.read(currentUserProvider)?.uid;
    var localRemaining = 0;
    if (userId != null) {
      final last = await ref
          .read(dotLocalSourceProvider)
          .getLastDotTimestampForUser(userId);
      if (last != null) {
        final lastUtc = last.toUtc();
        final elapsed = now.difference(lastUtc);
        final left = _kRateLimitWindow - elapsed;
        if (left.inSeconds > 0) localRemaining = left.inSeconds;
      }
    }
    final r = overrideRemaining > localRemaining
        ? overrideRemaining
        : localRemaining;
    return r > 0 ? r : 0;
  }

  /// BE 가 RATE_LIMITED 응답으로 알려준 retryAfterSeconds 를 반영.
  /// 즉시 stream 한 번 emit 해 UI 가 새 잔여 시간을 노출.
  ///
  /// **+1초 safety margin** — BE 의 retry_after 정확히 끝나는 시점에 사용자가
  /// 재시도하면 네트워크 RTT 때문에 또 429 발생 가능. 약간 보수적으로 잡아
  /// 카운트다운 0 도달 직후 즉시 시도해도 통과하도록.
  void bumpFromServer(int retryAfterSeconds) {
    if (retryAfterSeconds <= 0) return;
    const safetyMargin = Duration(seconds: 1);
    final until = DateTime.now().toUtc().add(
          Duration(seconds: retryAfterSeconds) + safetyMargin,
        );
    if (_serverOverrideUntil == null ||
        until.isAfter(_serverOverrideUntil!)) {
      _serverOverrideUntil = until;
      _emit();
    }
  }

  /// dot 저장 직후 호출 — 새 last timestamp 가 DB 에 반영됐으니
  /// 다음 _emit 이 60초 카운트다운 시작.
  void onDotSaved() {
    _serverOverrideUntil = null; // 우리 last 와 일치
    _emit();
  }
}
