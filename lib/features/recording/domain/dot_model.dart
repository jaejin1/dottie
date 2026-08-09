import 'package:freezed_annotation/freezed_annotation.dart';

import '../../cumulative_map/domain/place.dart';

part 'dot_model.freezed.dart';
part 'dot_model.g.dart';

@freezed
class Dot with _$Dot {
  const factory Dot({
    required String id,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    String? placeName,
    String? placeCategory,
    /// 업로드 직후 R2 원본 URL. **BE 응답에선 더 이상 안 옴** —
    /// (a) `POST /v1/dots` / `POST /v1/dots/batch` 요청 페이로드 (`photo_url`),
    /// (b) variant 생성 전 transient 로컬 캐시 ("처리 중" placeholder 트리거)
    /// 두 용도로만 쓰임. 표시는 [DotPhotoX.displayPhotoUrl] 사용.
    String? photoUrl,
    // BE 가 비동기로 생성하는 사진 variant.
    //   - photoThumbUrl: 160×160 center-crop JPEG (지도 핀, 리스트 미리보기)
    //   - photoPreviewUrl: 긴 변 720px JPEG (상세 / 본문)
    // 업로드 직후엔 둘 다 null — 수 초 내 BE 백그라운드 워커가 채움.
    @JsonKey(name: 'photo_thumb_url') String? photoThumbUrl,
    @JsonKey(name: 'photo_preview_url') String? photoPreviewUrl,
    String? memo,
    String? emotion,
    required String dayLogId,
    @Default(false) bool synced,
    // BE 응답에서 매핑되는 댓글 메타. 로컬 dot(drift) 또는 다른 엔드포인트에서
    // 가져온 dot 은 default 0/null 로 안전.
    @Default(0) int commentCount,
    DateTime? lastCommentedAt,
    // B8 — 사용자가 장소 선택 시 BE 가 매칭한 place_id + 응답 inline place.
    // 로컬 dot 이나 장소 미선택 dot 은 null.
    String? placeId,
    Place? place,
    // 메모에서 추출된 해시태그 (정규화: lowercase, 30자, 최대 10개).
    // BE 가 권위 — FE 는 입력 시 prefilter 만 하고, 응답을 신뢰.
    @Default(<String>[]) List<String> tags,
    // 이 dot 을 공유할/공유된 방 목록.
    //   - null      → 방 선택 안 함(생략). BE 가 auto_share 켜진 방들로 자동 공유.
    //   - []        → 개인 dot. 어느 방에도 안 올림.
    //   - [id, ...] → 지정한 방에만 공유 (auto_share 무시).
    // 요청(선택 의도)과 응답(실제 공유된 방)에 모두 쓰임 — 업로드 성공 후
    // BE 가 돌려준 실제 목록으로 갱신한다.
    @JsonKey(name: 'shared_room_ids') List<String>? sharedRoomIds,
  }) = _Dot;

  factory Dot.fromJson(Map<String, dynamic> json) => _$DotFromJson(json);
}

/// 사진 표시 / 판정 헬퍼.
///
/// BE 정책: 응답에서 `photo_url` 제거. variant 생성 후 `photo_thumb_url` /
/// `photo_preview_url` 만 채워짐. 업로드 직후 ~수초 동안은 셋 다 null 일 수 있고,
/// 그 사이 FE 가 막 만든 dot 의 [Dot.photoUrl] 만 살아있을 수 있음(R2 fetch 는
/// 못 하지만 "사진 첨부됨 + 처리 중" 시그널).
extension DotPhotoX on Dot {
  bool _nonEmpty(String? s) => s != null && s.isNotEmpty;

  /// 화면에 실제로 fetch 시도해도 되는 URL. preview > thumb 우선. 둘 다 없으면 null.
  /// `photoUrl` 은 R2 에서 이미 삭제됐을 수 있어 fetch 시도 대상에서 제외.
  String? get displayPhotoUrl {
    if (_nonEmpty(photoPreviewUrl)) return photoPreviewUrl;
    if (_nonEmpty(photoThumbUrl)) return photoThumbUrl;
    return null;
  }

  /// 지도 핀 / 리스트 썸네일 같은 작은 표시는 thumb 우선.
  String? get displayThumbUrl {
    if (_nonEmpty(photoThumbUrl)) return photoThumbUrl;
    if (_nonEmpty(photoPreviewUrl)) return photoPreviewUrl;
    return null;
  }

  /// 사진이 첨부돼 있는가 — display URL 또는 업로드 직후 임시 photoUrl 이 있으면 true.
  bool get hasPhotoData =>
      _nonEmpty(photoPreviewUrl) ||
      _nonEmpty(photoThumbUrl) ||
      _nonEmpty(photoUrl);

  /// variant 생성 진행 중 — 표시 가능한 URL 은 없고 photoUrl 만 있는 transient.
  bool get isPhotoProcessing =>
      !_nonEmpty(photoPreviewUrl) &&
      !_nonEmpty(photoThumbUrl) &&
      _nonEmpty(photoUrl);
}
