/// kakao 의 `placeCategory` ("음식점 > 카페 > 커피전문점 > 메가MGC커피") 같은
/// full path 를 UI 에 보여줄 수 있는 짧은 형태로 축약.
///
/// 규칙:
///   - 3 단계 이상: **마지막에서 두 번째** segment (broader 카테고리 — placeName
///     과 중복 안 됨).  예: `커피전문점`, `지하철,전철`.
///   - 2 단계: 마지막 segment.
///   - 1 단계: 그대로.
///   - null/empty: null.
String? shortCategoryOf(String? full) {
  if (full == null || full.isEmpty) return null;
  final segs = full
      .split(' > ')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  if (segs.isEmpty) return null;
  if (segs.length >= 3) return segs[segs.length - 2];
  return segs.last;
}

/// 카테고리 그룹별 지도 핀 스타일 (모음 코스 지도의 이모지 핀).
class CategoryStyle {
  const CategoryStyle(this.key, this.emoji, this.colorHex);

  /// 스타일 이미지 id 조합용 안정 키.
  final String key;
  final String emoji;

  /// 핀 원 배경색 (#RRGGBB).
  final String colorHex;
}

/// 전체 카테고리 스타일 목록 — 지도 이미지 사전 등록용.
const kCategoryStyles = [
  CategoryStyle('cafe', '☕', '#A9745B'),
  CategoryStyle('food', '🍜', '#F0883E'),
  CategoryStyle('bar', '🍺', '#D9A03A'),
  CategoryStyle('sight', '🏞', '#4CAF82'),
  CategoryStyle('stay', '🛏', '#9B7EDE'),
  CategoryStyle('culture', '🎨', '#5B8DEF'),
  CategoryStyle('shop', '🛍', '#E86B9A'),
  CategoryStyle('etc', '📍', '#E8806A'), // 기본 — primary 톤
];

/// kakao category full path → 카테고리 스타일.
/// 세그먼트 키워드 스캔 — 구체 카테고리(카페/술집)를 상위(음식점)보다 먼저 판정.
CategoryStyle categoryStyleOf(String? full) {
  if (full == null || full.isEmpty) return kCategoryStyles.last;
  bool has(List<String> keywords) => keywords.any((k) => full.contains(k));

  if (has(['카페', '디저트', '베이커리', '제과', '커피'])) {
    return kCategoryStyles[0];
  }
  if (has(['술집', '호프', '주점', '와인', '포차'])) {
    return kCategoryStyles[2];
  }
  if (has(['음식점', '식당', '맛집'])) return kCategoryStyles[1];
  if (has(['관광', '명소', '공원', '해수욕장', '테마파크', '캠핑'])) {
    return kCategoryStyles[3];
  }
  if (has(['숙박', '호텔', '모텔', '펜션', '리조트', '게스트하우스'])) {
    return kCategoryStyles[4];
  }
  if (has(['문화시설', '공연', '전시', '영화', '미술관', '박물관'])) {
    return kCategoryStyles[5];
  }
  if (has(['쇼핑', '마트', '백화점', '시장', '아울렛', '편의점'])) {
    return kCategoryStyles[6];
  }
  return kCategoryStyles.last;
}
