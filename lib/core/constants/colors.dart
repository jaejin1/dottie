import 'package:flutter/material.dart';

class DottieColors {
  DottieColors._();

  // ── 브랜드 ──────────────────────────────────────────
  static const Color primary = Color(0xFFC07B5A);     // 클레이 테라코타
  static const Color primaryLight = Color(0xFFEDD5C8); // 연한 테라코타 (배지 등)
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
  static const Color charBlue = Color(0xFF7EB8F7);
  static const Color charMint = Color(0xFF7ED6C8);
  static const Color charCoral = Color(0xFFFF8FAB);
  static const Color charLavender = Color(0xFFB8A8F5);
  static const Color charYellow = Color(0xFFE8C547);

  // ── 지도 오버레이 ────────────────────────────────────
  static const Color dotMarker = primary;
  static const Color trailLine = Color(0x80C07B5A);
}

// 캐릭터 colorKey → Color 매핑
const Map<String, Color> characterColorMap = {
  'blue': DottieColors.charBlue,
  'mint': DottieColors.charMint,
  'coral': DottieColors.charCoral,
  'lavender': DottieColors.charLavender,
  'yellow': DottieColors.charYellow,
};

/// 사용자 정체성 색 프리셋 화이트리스트. 변경 시 BE validation도 동기화.
const List<String> kCharacterColorKeys = [
  'blue', 'mint', 'coral', 'lavender', 'yellow',
];

const String kCharacterColorKeyDefault = 'blue';
