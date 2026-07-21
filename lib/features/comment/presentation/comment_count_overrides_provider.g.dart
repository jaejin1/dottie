// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_count_overrides_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$commentCountOverridesHash() =>
    r'aca333d9a581cdf530306ca940d6951ce3725928';

/// BE 응답의 `comment_count` 가 stale 인 dot 에 대한 클라이언트 측 정정 store.
///
/// **왜 필요한가**: `/v1/feed` 응답의 `dot.comment_count` 가 (a) BE
/// eventual-consistency 로 댓글 추가 직후 0 이거나 (b) BE 가 그 필드를 안
/// 채워 보내는 케이스가 관찰됨. invalidate 해도 BE 가 stale 값을 주면 사용자가
/// 회복 불가.
///
/// **해결**: `CommentListNotifier` 가 BE 댓글 응답 받을 때마다 그 카운트로
/// 여기 dotId 를 override. `FeedCard` 는 override 가 있으면 그 값 우선 표시.
///
/// 동작:
/// - 시트 진입 → `_load` → override.set → 카드 카운트 즉시 정확
/// - 댓글 추가/삭제 → override.set + feed invalidate → 카드 갱신
/// - 시트 안 들어가도 BE 응답이 정상이면 dot.commentCount 그대로 노출
///
/// keepAlive — 메모리 작음 (활성 dot 만), 앱 평생 유지.
///
/// Copied from [CommentCountOverrides].
@ProviderFor(CommentCountOverrides)
final commentCountOverridesProvider =
    NotifierProvider<CommentCountOverrides, Map<String, int>>.internal(
      CommentCountOverrides.new,
      name: r'commentCountOverridesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$commentCountOverridesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CommentCountOverrides = Notifier<Map<String, int>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
