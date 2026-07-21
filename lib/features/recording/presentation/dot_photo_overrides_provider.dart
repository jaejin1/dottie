import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dot_photo_overrides_provider.g.dart';

/// BE 사진 variant 워커가 thumb/preview URL 을 늦게 발급하는 상황을 보완하는
/// override store.
///
/// **왜 필요한가**: dot 등록 시 photoUrl 만 응답에 있고 thumb/preview 는 worker
/// 처리 후 채워짐. `activeRecordingProvider._pollPhotoVariants` 가 today daylog
/// 를 refetch 해서 갱신하지만, dot 등록 직후 시트가 닫히고 사용자가 다른 화면
/// (feed/timeline) 으로 이동하면 polling 결과가 그 화면의 dot 객체에는 반영
/// 안 됨 — feed 카드 사진이 영구 미로드.
///
/// **해결**: polling 으로 받은 thumb/preview URL 을 여기에 set. FeedCard /
/// dot_content_block 이 displayThumbUrl 우선 lookup. override 없으면 기존
/// dot.photoThumbUrl 사용.
///
/// 동작:
/// - `_pollPhotoVariants` 가 매 시도마다 새 thumb/preview URL set
/// - feed/timeline 의 카드들이 select 로 watch — set 즉시 rebuild
/// - 같은 dotId 재set 은 값 동일 시 skip (불필요 rebuild 방지)
///
/// keepAlive — 메모리 작음 (사진 dot 만), 앱 평생 유지.
@Riverpod(keepAlive: true)
class DotPhotoOverrides extends _$DotPhotoOverrides {
  @override
  Map<String, DotPhotoOverride> build() => const {};

  /// thumb/preview URL 둘 다 변경 없으면 skip.
  void set(String dotId, {String? thumbUrl, String? previewUrl}) {
    final existing = state[dotId];
    if (existing != null &&
        existing.thumbUrl == thumbUrl &&
        existing.previewUrl == previewUrl) {
      return;
    }
    state = {
      ...state,
      dotId: DotPhotoOverride(thumbUrl: thumbUrl, previewUrl: previewUrl),
    };
  }

  DotPhotoOverride? operator [](String dotId) => state[dotId];
}

class DotPhotoOverride {
  const DotPhotoOverride({this.thumbUrl, this.previewUrl});
  final String? thumbUrl;
  final String? previewUrl;

  bool get isEmpty =>
      (thumbUrl == null || thumbUrl!.isEmpty) &&
      (previewUrl == null || previewUrl!.isEmpty);
}
