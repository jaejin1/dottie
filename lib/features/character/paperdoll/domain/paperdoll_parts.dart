/// 도트(픽셀 아트) 캐릭터 부위 정의.
///
/// z-order: 인덱스가 작을수록 먼저(뒤에) 그려진다.
/// 신발 → 하의 → 몸 → 상의 → 헤어뒤 → 얼굴 → 액세서리 → 헤어앞
enum PartType {
  skin,
  bottom,
  shoes,
  top,
  hairBack,
  face,
  accessory,
  hairFront,
}

/// 모든 부위를 z-order 순으로 반환 (렌더 순서 = 이 순서)
const List<PartType> kPartRenderOrder = [
  PartType.skin,
  PartType.bottom,
  PartType.shoes,
  PartType.top,
  PartType.hairBack,
  PartType.face,
  PartType.accessory,
  PartType.hairFront,
];

/// 에디터에서 사용자가 선택할 수 있는 부위 (hairBack/hairFront는 hair 1개로 묶어 노출)
enum EditableSlot {
  skin,
  hair,
  face,
  top,
  bottom,
  shoes,
  accessory,
}

extension EditableSlotLabel on EditableSlot {
  String get koLabel => switch (this) {
        EditableSlot.skin => '피부',
        EditableSlot.hair => '머리',
        EditableSlot.face => '얼굴',
        EditableSlot.top => '상의',
        EditableSlot.bottom => '하의',
        EditableSlot.shoes => '신발',
        EditableSlot.accessory => '액세서리',
      };
}

/// face_expression 화이트리스트 (BE 스펙과 동일).
///
/// FE는 BE에 없는 값을 보내지 않도록 sanitize. 추가/변경 시 BE에도 반영 필요.
const String kFaceExpressionDefault = 'default';
const List<String> kFaceExpressionWhitelist = [
  'default',
  'smile',
  'wink',
  'sad',
  'angry',
  'laugh',
];

const Map<String, String> kFaceExpressionLabel = {
  'default': '기본',
  'smile': '미소',
  'wink': '윙크',
  'sad': '슬픔',
  'angry': '화남',
  'laugh': '웃음',
};

/// manifest.json의 한 부위 옵션 항목.
class PartItem {
  const PartItem({
    required this.id,
    required this.name,
    required this.assetPath,
    this.tintable = false,
    this.expressions = const [],
    this.thumbnailPath,
  });

  /// 화이트리스트 검증된 ID (예: 'hair_03')
  final String id;

  /// 사람이 읽는 이름 (예: '갈색 단발')
  final String name;

  /// 앱 번들 내 에셋 경로 (예: 'assets/character/hair/hair_03.png').
  /// **manifest.json에서만 도출**, 외부 입력으로 받지 않는다.
  final String assetPath;

  /// 색상 입힘 가능 여부 (흰/회색 텍스처에 ColorFilter.modulate 적용)
  final bool tintable;

  /// face 부위에서만 사용. 표정별 별도 에셋 키.
  final List<String> expressions;

  /// 에디터 그리드용 썸네일 (없으면 assetPath 사용)
  final String? thumbnailPath;

  String thumbnail() => thumbnailPath ?? assetPath;
}

/// manifest.json 전체.
class PaperdollManifestData {
  const PaperdollManifestData({
    required this.version,
    required this.frameWidth,
    required this.frameHeight,
    required this.frameCount,
    required this.parts,
  });

  final int version;
  final int frameWidth;
  final int frameHeight;
  final int frameCount;

  /// PartType별 옵션 목록.
  final Map<PartType, List<PartItem>> parts;

  PartItem? findById(PartType type, String id) {
    final list = parts[type];
    if (list == null) return null;
    for (final item in list) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// 해당 부위의 첫 번째 옵션 (default fallback용)
  PartItem? defaultOf(PartType type) {
    final list = parts[type];
    if (list == null || list.isEmpty) return null;
    return list.first;
  }
}
