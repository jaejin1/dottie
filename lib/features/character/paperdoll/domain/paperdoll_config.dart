import '../../../../core/constants/colors.dart';
import 'paperdoll_parts.dart';
import 'paperdoll_validators.dart';

/// 사용자 캐릭터 구성. BE v2 스키마와 1:1 매핑.
///
/// 백엔드 직렬화 키 (snake_case):
/// - skin / hair / hair_color / face / face_expression
/// - top / top_color / bottom / bottom_color / shoes / accessory
/// - color  ← 정체성 색 (5색 프리셋, 지도/댓글 등에서 사용자 식별 색)
///
/// BE는 12개 필드 모두 필수 (부분 업데이트 불가, 색상 null 불가).
/// `schema_version`은 GET 응답에만 포함되며 PUT 요청에 보내면 거절됨.
class PaperdollConfig {
  const PaperdollConfig({
    this.skinId = 'skin_01',
    this.hairId = 'hair_basic',
    this.hairColor = '#3a2a1f',
    this.faceId = 'face_round',
    this.faceExpression = kFaceExpressionDefault,
    this.topId = 'top_tee',
    this.topColor = '#ffffff',
    this.bottomId = 'bottom_jeans',
    this.bottomColor = '#2a3a5f',
    this.shoesId = 'shoes_sneaker',
    this.accessoryId = 'none',
    this.colorKey = kCharacterColorKeyDefault,
  });

  final String skinId;
  final String hairId;
  final String hairColor;
  final String faceId;
  final String faceExpression;
  final String topId;
  final String topColor;
  final String bottomId;
  final String bottomColor;
  final String shoesId;
  final String accessoryId;

  /// 정체성 색 (지도 trail/마커, 댓글 아바타 등 식별용).
  /// `kCharacterColorKeys` 중 하나. 잘못된 값은 default('blue')로 치환.
  final String colorKey;

  static const PaperdollConfig defaults = PaperdollConfig();

  /// BE 응답 또는 임의 데이터를 안전하게 파싱.
  /// 잘못된 값은 default로 치환 — 다른 사용자 데이터에 의한 크래시 방지.
  /// `schema_version`은 무시 (read-only 정보).
  factory PaperdollConfig.fromJson(Map<String, dynamic> json) {
    return PaperdollConfig(
      skinId: sanitizePartId(json['skin'] as String?,
          defaultId: defaults.skinId),
      hairId: sanitizePartId(json['hair'] as String?,
          defaultId: defaults.hairId),
      hairColor: sanitizeHexColor(json['hair_color'] as String?,
          defaultHex: defaults.hairColor),
      faceId: sanitizePartId(json['face'] as String?,
          defaultId: defaults.faceId),
      faceExpression: sanitizeFaceExpression(
          json['face_expression'] as String?, kFaceExpressionWhitelist),
      topId:
          sanitizePartId(json['top'] as String?, defaultId: defaults.topId),
      topColor: sanitizeHexColor(json['top_color'] as String?,
          defaultHex: defaults.topColor),
      bottomId: sanitizePartId(json['bottom'] as String?,
          defaultId: defaults.bottomId),
      bottomColor: sanitizeHexColor(json['bottom_color'] as String?,
          defaultHex: defaults.bottomColor),
      shoesId: sanitizePartId(json['shoes'] as String?,
          defaultId: defaults.shoesId),
      accessoryId: sanitizePartId(json['accessory'] as String?,
          defaultId: defaults.accessoryId),
      colorKey: sanitizeColorKey(
        json['color_key'] as String?,
        kCharacterColorKeys,
        defaultKey: defaults.colorKey,
      ),
    );
  }

  /// PUT /v1/users/me/character body — 12개 필드 모두 포함.
  /// `schema_version`은 보내지 않는다 (보내면 UNKNOWN_FIELD 400).
  Map<String, dynamic> toJson() => {
        'skin': skinId,
        'hair': hairId,
        'hair_color': hairColor,
        'face': faceId,
        'face_expression': faceExpression,
        'top': topId,
        'top_color': topColor,
        'bottom': bottomId,
        'bottom_color': bottomColor,
        'shoes': shoesId,
        'accessory': accessoryId,
        'color_key': colorKey,
      };

  /// 슬롯의 ID를 변경한 사본.
  PaperdollConfig withSlot(EditableSlot slot, String id) {
    return switch (slot) {
      EditableSlot.skin => copyWith(skinId: id),
      EditableSlot.hair => copyWith(hairId: id),
      EditableSlot.face => copyWith(faceId: id),
      EditableSlot.top => copyWith(topId: id),
      EditableSlot.bottom => copyWith(bottomId: id),
      EditableSlot.shoes => copyWith(shoesId: id),
      EditableSlot.accessory => copyWith(accessoryId: id),
    };
  }

  /// 슬롯의 tint 색상 변경 (tintable 슬롯만).
  /// BE는 hex가 항상 필요하므로 default로 되돌리려면 default hex를 직접 전달.
  PaperdollConfig withSlotColor(EditableSlot slot, String hex) {
    return switch (slot) {
      EditableSlot.hair => copyWith(hairColor: hex),
      EditableSlot.top => copyWith(topColor: hex),
      EditableSlot.bottom => copyWith(bottomColor: hex),
      _ => this,
    };
  }

  String currentIdFor(EditableSlot slot) => switch (slot) {
        EditableSlot.skin => skinId,
        EditableSlot.hair => hairId,
        EditableSlot.face => faceId,
        EditableSlot.top => topId,
        EditableSlot.bottom => bottomId,
        EditableSlot.shoes => shoesId,
        EditableSlot.accessory => accessoryId,
      };

  String? currentColorFor(EditableSlot slot) => switch (slot) {
        EditableSlot.hair => hairColor,
        EditableSlot.top => topColor,
        EditableSlot.bottom => bottomColor,
        _ => null,
      };

  /// 슬롯의 default 색상 반환 (팔레트에서 "원래대로" 옵션용).
  static String defaultColorFor(EditableSlot slot) => switch (slot) {
        EditableSlot.hair => defaults.hairColor,
        EditableSlot.top => defaults.topColor,
        EditableSlot.bottom => defaults.bottomColor,
        _ => '#ffffff',
      };

  PaperdollConfig copyWith({
    String? skinId,
    String? hairId,
    String? hairColor,
    String? faceId,
    String? faceExpression,
    String? topId,
    String? topColor,
    String? bottomId,
    String? bottomColor,
    String? shoesId,
    String? accessoryId,
    String? colorKey,
  }) {
    return PaperdollConfig(
      skinId: skinId ?? this.skinId,
      hairId: hairId ?? this.hairId,
      hairColor: hairColor ?? this.hairColor,
      faceId: faceId ?? this.faceId,
      faceExpression: faceExpression ?? this.faceExpression,
      topId: topId ?? this.topId,
      topColor: topColor ?? this.topColor,
      bottomId: bottomId ?? this.bottomId,
      bottomColor: bottomColor ?? this.bottomColor,
      shoesId: shoesId ?? this.shoesId,
      accessoryId: accessoryId ?? this.accessoryId,
      colorKey: colorKey ?? this.colorKey,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaperdollConfig &&
          runtimeType == other.runtimeType &&
          skinId == other.skinId &&
          hairId == other.hairId &&
          hairColor == other.hairColor &&
          faceId == other.faceId &&
          faceExpression == other.faceExpression &&
          topId == other.topId &&
          topColor == other.topColor &&
          bottomId == other.bottomId &&
          bottomColor == other.bottomColor &&
          shoesId == other.shoesId &&
          accessoryId == other.accessoryId &&
          colorKey == other.colorKey;

  @override
  int get hashCode => Object.hash(
        skinId,
        hairId,
        hairColor,
        faceId,
        faceExpression,
        topId,
        topColor,
        bottomId,
        bottomColor,
        shoesId,
        accessoryId,
        colorKey,
      );
}
