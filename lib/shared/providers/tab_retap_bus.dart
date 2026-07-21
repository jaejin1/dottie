import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tab_retap_bus.g.dart';

/// 같은 탭을 이미 활성화된 상태에서 다시 누른 이벤트의 broadcast bus.
///
/// family arg: 탭 root path (`AppRoutes.home`, `AppRoutes.rooms` 등).
/// 탭별로 별도 카운터.
///
/// **사용 패턴**:
/// - [MainShell] 의 `_onTap` 가 retap 감지 시 `.notify()` 호출
/// - 그 탭의 root screen (e.g. `_FeedView`) 가 `ref.listen` 으로 듣고 동작:
///   - 리스트 맨 위로 스크롤
///   - 데이터 invalidate
///
/// instagram / twitter / x 류 SNS 의 표준 UX 패턴 — "탭 더블탭으로 새로고침".
///
/// keepAlive — 카운터 state. listener (root screen) 가 dispose 돼도 카운터는
/// 살아있어 다음 listener 가 마지막 값을 기준으로 distinct 비교. 단 listener
/// mount 시점의 첫 build 에선 `ref.listen` 이 발화 안 함 — 의도된 동작.
@Riverpod(keepAlive: true)
class TabReTapBus extends _$TabReTapBus {
  @override
  int build(String path) => 0;

  /// 재탭 이벤트. listener 의 `ref.listen` 콜백 발화.
  void notify() {
    state = state + 1;
  }
}
