import '../domain/paperdoll_config.dart';

/// 기존 시스템(`color/accessory/expression`)을 새 PaperdollConfig로 변환.
///
/// BE가 새 스키마를 응답하기 전까지의 임시 어댑터.
/// 멤버별로 다른 캐릭터로 구분되도록 colorKey를 상의(top) 색상에 매핑.
PaperdollConfig paperdollFromLegacyColorKey(String? colorKey) {
  return PaperdollConfig.defaults.copyWith(
    topColor: _legacyColorMap[colorKey] ?? _legacyColorMap['blue'],
  );
}

/// 기존 캐릭터 키 → 새 PaperdollConfig.
/// `accessory`가 안경/모자였다면 새 액세서리 ID로 매핑.
PaperdollConfig paperdollFromLegacyConfig({
  String? colorKey,
  String? accessoryKey,
  String? expressionKey,
}) {
  return PaperdollConfig.defaults.copyWith(
    topColor: _legacyColorMap[colorKey] ?? _legacyColorMap['blue'],
    accessoryId: _legacyAccessoryMap[accessoryKey] ?? 'none',
  );
}

/// 백엔드가 새/구 스키마 둘 다 줄 수 있을 때 안전하게 파싱.
///
/// - `skin`/`hair`/`top` 등 새 키가 있으면 새 스키마로 간주 → PaperdollConfig.fromJson
/// - 그 외엔 구 스키마(`color`/`accessory`/`expression`)로 간주 → 어댑터 사용
PaperdollConfig paperdollFromMixedJson(Map<String, dynamic>? json) {
  if (json == null) return PaperdollConfig.defaults;
  final hasNewSchema = json.containsKey('skin') ||
      json.containsKey('hair') ||
      json.containsKey('top');
  if (hasNewSchema) return PaperdollConfig.fromJson(json);
  return paperdollFromLegacyConfig(
    colorKey: json['color'] as String?,
    accessoryKey: json['accessory'] as String?,
    expressionKey: json['expression'] as String?,
  );
}

/// 레거시 색상 키 → hex.
/// BE의 v1→v2 마이그레이션 매핑과 동일 (color → top_color).
const Map<String, String> _legacyColorMap = {
  'blue': '#4a7ac8',
  'red': '#c84a4a',
  'green': '#4ac86a',
  'yellow': '#e8c84a',
  'purple': '#9a4ac8',
  'pink': '#e87aa8',
  // 기존 dottie 코드의 추가 키 (BE에는 매핑 없으니 default로)
  'mint': '#7ED6C8',
  'coral': '#FF8FAB',
  'lavender': '#B8A8F5',
};

/// 레거시 액세서리 키 → 새 BE 화이트리스트 ID.
/// BE v2 마이그레이션 후 화이트리스트가 'none' 단 1개로 축소됨.
/// 옛 'glasses'/'hat' 값이 들어와도 안전하게 'none'으로 매핑.
const Map<String, String> _legacyAccessoryMap = {
  'none': 'none',
  'glasses': 'none',
  'hat': 'none',
};
