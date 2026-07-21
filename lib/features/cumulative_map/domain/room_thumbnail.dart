import 'package:freezed_annotation/freezed_annotation.dart';

part 'room_thumbnail.freezed.dart';
part 'room_thumbnail.g.dart';

/// B11 — 룸 누적 지도 썸네일 응답.
/// 응답은 Mapbox static API URL 한 개. dot 없는 룸은 서울 기본값.
@freezed
class RoomThumbnail with _$RoomThumbnail {
  const factory RoomThumbnail({
    required String url,
  }) = _RoomThumbnail;

  factory RoomThumbnail.fromJson(Map<String, dynamic> json) =>
      _$RoomThumbnailFromJson(json);
}
