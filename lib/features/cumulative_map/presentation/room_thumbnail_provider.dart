import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../room/data/room_repository.dart';

part 'room_thumbnail_provider.g.dart';

/// B11 — `/v1/rooms/:id/thumbnail` URL 단건. dot 분포 기반 Mapbox static URL.
/// 응답 비어 있으면 null. UI 측에서 null 시 placeholder 표시.
@riverpod
Future<String?> roomThumbnailUrl(Ref ref, String roomId) async {
  final repo = ref.watch(roomRepositoryProvider);
  return repo.getRoomThumbnail(roomId);
}
