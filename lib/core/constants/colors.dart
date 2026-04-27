import 'package:flutter/material.dart';

class DottieColors {
  DottieColors._();

  // 브랜드 컬러
  static const Color primary = Color(0xFF5B8BF5);      // 블루 (메인)
  static const Color secondary = Color(0xFF7ED6C8);    // 민트
  static const Color accent = Color(0xFFFF8FAB);       // 코랄

  // 캐릭터 컬러 (5가지)
  static const Color charBlue = Color(0xFF5B8BF5);
  static const Color charMint = Color(0xFF7ED6C8);
  static const Color charCoral = Color(0xFFFF8FAB);
  static const Color charLavender = Color(0xFFB8A8F5);
  static const Color charYellow = Color(0xFFFFD166);

  // 배경
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2FF);

  // 텍스트
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0B7C3);

  // 상태
  static const Color error = Color(0xFFFF5252);
  static const Color success = Color(0xFF4CAF50);

  // 지도 오버레이
  static const Color dotMarker = primary;
  static const Color trailLine = Color(0x805B8BF5);
}

// 캐릭터 colorKey → Color 매핑
const Map<String, Color> characterColorMap = {
  'blue': DottieColors.charBlue,
  'mint': DottieColors.charMint,
  'coral': DottieColors.charCoral,
  'lavender': DottieColors.charLavender,
  'yellow': DottieColors.charYellow,
};
