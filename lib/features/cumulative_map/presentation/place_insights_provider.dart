import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../room/data/room_repository.dart';
import '../domain/place_insights.dart';

part 'place_insights_provider.g.dart';

/// B10 — `/v1/rooms/:id/places/:place_id/insights` 응답.
/// place_id 가 BE 매칭된 ID 일 때만 호출 (placeId null 인 polkit-find 그룹은 호출 X).
@riverpod
Future<PlaceInsights?> placeInsights(
  Ref ref,
  String roomId,
  String placeId,
) async {
  final repo = ref.watch(roomRepositoryProvider);
  final data = await repo.getPlaceInsights(roomId, placeId);
  if (data == null) return null;
  return PlaceInsights.fromJson(data);
}
