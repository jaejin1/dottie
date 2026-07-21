/// 피드 페이지네이션 / 무한 스크롤 / fallback 한도 등 튜닝 상수.
/// 한 곳에 모아 테스트 시 override / BE 정책 변경 시 일괄 수정.
class FeedConfig {
  FeedConfig._();

  /// BE `/v1/feed` 한 페이지 dot 수. spec 의 max=50 안에서 첫 페이지 응답 속도와
  /// "더 보기" 트리거 빈도의 균형. 카드 평균 높이 250~400px → 화면 ~3개 = 5~6
  /// 페이지 분량.
  static const int pageSize = 20;

  /// BE 미배포 fallback 모드에서 클라이언트 합치기 결과의 cap. 100 넘으면
  /// 메모리 부담 + 의미 적음.
  static const int fallbackCap = 100;

  /// 무한 스크롤 트리거 — 리스트 끝에서 이만큼 남았을 때 loadMore.
  /// 카드 1~2 개 전에 prefetch 가 시작되어 사용자 체감 끊김 없음.
  static const double infiniteScrollTriggerPx = 600;
}
