// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_local_photo_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedLocalPhotoStoreHash() =>
    r'73fda85f72a83e41e4e98fe4c6747b4b22b9983c';

/// dot 저장 직후 BE 사진 variant 생성 완료 전까지 로컬 원본 경로를 임시 보관.
///
/// **흐름**:
/// 1. dot 저장 성공 → `set(dotId, localPath)` 등록
/// 2. FeedCard 가 이 경로로 `Image.file` 표시 (즉시 보임)
/// 3. 피드 새로고침 후 BE variant(`photo_thumb_url`) 가 채워지면
///    FeedCard 가 `remove(dotId)` 를 호출 → 맵 entry + 디스크 파일 모두 삭제
///
/// keepAlive — 피드 invalidate 이후에도 유지돼야 카드에서 조회 가능.
///
/// Copied from [FeedLocalPhotoStore].
@ProviderFor(FeedLocalPhotoStore)
final feedLocalPhotoStoreProvider =
    NotifierProvider<FeedLocalPhotoStore, Map<String, String>>.internal(
      FeedLocalPhotoStore.new,
      name: r'feedLocalPhotoStoreProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$feedLocalPhotoStoreHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FeedLocalPhotoStore = Notifier<Map<String, String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
