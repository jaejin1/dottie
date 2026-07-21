import 'package:flutter/material.dart';

class DottieColors {
  DottieColors._();

  // ── 브랜드 ──────────────────────────────────────────
  static const Color primary = Color(0xFFE8806A);     // 머스크 탠저린 — 따뜻하고 부드러운 산호
  static const Color primaryLight = Color(0xFFF5D5C8); // 연한 살구 (배지 등)
  static const Color secondary = Color(0xFF8B6F4E);   // 모카 브라운
  static const Color accent = Color(0xFFBF9E6F);      // 샌드 골드

  // ── 배경 ────────────────────────────────────────────
  static const Color background = Color(0xFFFAF8F4);  // 크림 아이보리
  static const Color surface = Color(0xFFFEFCFA);     // 카드 / 시트 (거의 흰색)
  static const Color surfaceVariant = Color(0xFFF2EEE7); // 인풋 / 구분 영역
  static const Color border = Color(0xFFE5E0D8);      // 구분선

  // ── 텍스트 ──────────────────────────────────────────
  static const Color textPrimary = Color(0xFF2A2620);  // 따뜻한 다크 브라운
  static const Color textSecondary = Color(0xFF7A7068); // 미드 웜 그레이
  static const Color textHint = Color(0xFFB5AFA5);    // 연한 웜 그레이

  // ── 상태 ────────────────────────────────────────────
  static const Color error = Color(0xFFD4604A);
  static const Color success = Color(0xFF6B9C6B);

  // ── 캐릭터 컬러 (5가지) ─────────────────────────────
  // 다크 맵(shared_map) 가독성 + 라이트 surface 가독성 둘 다 균형.
  // yellow 만 다크 위 OLED 번짐을 완화하기 위해 채도/명도 소폭 하향.
  static const Color charBlue = Color(0xFF7EB8F7);
  static const Color charMint = Color(0xFF7ED6C8);
  static const Color charCoral = Color(0xFFFF8FAB);
  static const Color charLavender = Color(0xFFB8A8F5);
  static const Color charYellow = Color(0xFFD9B83A);

  // ── 지도 오버레이 ────────────────────────────────────
  static const Color dotMarker = primary;
  static const Color trailLine = Color(0x80E8806A);

  // ── 다크 글래스 표면 (shared_map 등 다크 컨텍스트 전용) ──────
  // 일관성: 모든 떠 있는 글래스 컨테이너는 surfaceFloating + borderGlass 조합 사용.
  // BackdropFilter blur 와 함께 쓸 때 가장 자연스러움.
  static const Color surfaceFloating = Color(0x8C000000);   // black 55%
  static const Color surfaceFloatingStrong = Color(0xB3000000); // black 70% (시트 배경 등)
  static const Color surfaceModal = Color(0xFF1F2024);      // 모달 솔리드 배경
  static const Color borderGlass = Color(0x26FFFFFF);       // white 15% — 기본 테두리
  static const Color borderGlassStrong = Color(0x47FFFFFF); // white 28% — 강조 테두리

  // ── 그룹 액센트 팔레트 ───────────────────────────────
  // 컬렉션/방 같은 *사용자가 만든 그룹* 카드에 부여되는 컬러 테마. id 해시로
  // 결정 → 같은 그룹은 항상 같은 색, 다른 그룹은 서로 다른 색 (식별성 + 재미).
  // 부드러운 톤만 골라 카드 리스트에서 자연스럽게 어울리도록.
  static const List<Color> accentPalette = [
    primary,
    secondary,
    accent,
    charBlue,
    charMint,
    charCoral,
    charLavender,
    charYellow,
    success,
  ];

  /// 그룹 id 해시 기반 deterministic 색 — 같은 id 는 항상 같은 색.
  /// 컬렉션 카드 좌측 바, 방 카드 좌측 바 등에 동일 함수 사용 → 시각 일관성.
  static Color accentFor(String id) =>
      accentPalette[id.hashCode.abs() % accentPalette.length];
}

// 색상 picker 시스템은 hex 기반으로 전환됨.
// 프리셋은 `lib/core/utils/color_hex.dart`의 `kCharacterColorPresetsHex` 참고.
// 단일 hex → Color 변환은 `colorFromHex()` 사용.
