import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../room/data/room_repository.dart';
import '../domain/starred_place.dart';

part 'starred_places_provider.g.dart';

/// B9 — 룸 즐겨찾기 장소 list.
@riverpod
class StarredPlaces extends _$StarredPlaces {
  @override
  Future<List<StarredPlace>> build(String roomId) async {
    final repo = ref.watch(roomRepositoryProvider);
    final raw = await repo.getStarredPlaces(roomId);
    return raw.map(StarredPlace.fromJson).toList();
  }

  Future<void> toggle({
    required String placeId,
    required bool currentlyStarred,
  }) async {
    final repo = ref.read(roomRepositoryProvider);
    try {
      if (currentlyStarred) {
        await repo.unstarPlace(roomId, placeId);
      } else {
        await repo.starPlace(roomId, placeId);
      }
      ref.invalidateSelf();
    } catch (_) {
      // 실패 시 invalidate 만 — UI 가 다음 fetch 로 동기화
      ref.invalidateSelf();
    }
  }
}

/// 편의 — 특정 placeId 가 즐겨찾기인지 빠르게 확인.
@riverpod
bool isPlaceStarred(Ref ref, String roomId, String placeId) {
  final list =
      ref.watch(starredPlacesProvider(roomId)).valueOrNull ?? const [];
  return list.any((s) => s.id == placeId);
}
