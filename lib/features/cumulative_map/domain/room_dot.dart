import 'package:freezed_annotation/freezed_annotation.dart';

import '../../character/paperdoll/domain/paperdoll_config.dart';
import '../../recording/domain/dot_model.dart';

part 'room_dot.freezed.dart';

/// 누적 지도 표시용 — Dot 에 멤버 메타(닉네임/색/paperdoll) 를 묶음.
/// shared-map 응답을 N 일치 fetch 후 합산해 만든다.
@freezed
class RoomDot with _$RoomDot {
  const factory RoomDot({
    required Dot dot,
    required String memberId,
    required String nickname,
    required String colorHex,
    PaperdollConfig? paperdoll,
  }) = _RoomDot;
}
