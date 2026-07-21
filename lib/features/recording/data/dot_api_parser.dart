import '../../cumulative_map/domain/place.dart';
import '../domain/dot_model.dart';

/// BE 의 snake_case dot json → [Dot] 도메인 모델.
///
/// `Dot.fromJson` (freezed + JsonKey) 은 일부 필드만 snake_case 매핑 — 모든
/// dot-반환 endpoint 응답은 이 함수로 파싱한다.
///
/// 호출처 (top-level 로 두어 cross-feature 사용 가능):
///   - `/v1/dots`, `/v1/dots/cumulative`, `/v1/dots/search` (recording)
///   - `/v1/feed` (feed)
///   - `/v1/rooms/:id/cumulative-dots` (cumulative_map)
///
/// `synced=true` 로 세팅 — BE 응답은 항상 동기화된 상태.
Dot dotFromApi(Map<String, dynamic> d) {
  final lastCommentedRaw = d['last_commented_at'] as String?;
  final placeRaw = d['place'] as Map<String, dynamic>?;
  final rawTags = d['tags'];
  final tags = (rawTags is List)
      ? rawTags.whereType<String>().toList(growable: false)
      : const <String>[];
  return Dot(
    id: d['id'] as String,
    latitude: (d['latitude'] as num).toDouble(),
    longitude: (d['longitude'] as num).toDouble(),
    timestamp: DateTime.parse(d['timestamp'] as String),
    placeName: d['place_name'] as String?,
    placeCategory: d['place_category'] as String?,
    // photo_url 은 BE 응답에서 더 이상 안 옴 (variant 생성 후 원본 삭제).
    // photoUrl 은 요청 페이로드 / 로컬 임시 캐시 용도로만 유지.
    photoThumbUrl: d['photo_thumb_url'] as String?,
    photoPreviewUrl: d['photo_preview_url'] as String?,
    memo: d['memo'] as String?,
    emotion: d['emotion'] as String?,
    dayLogId: d['day_log_id'] as String,
    synced: true,
    placeId: d['place_id'] as String?,
    place: placeRaw != null ? Place.fromJson(placeRaw) : null,
    commentCount: (d['comment_count'] as num?)?.toInt() ?? 0,
    lastCommentedAt:
        lastCommentedRaw != null ? DateTime.parse(lastCommentedRaw) : null,
    tags: tags,
  );
}
