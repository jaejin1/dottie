import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// Dottie 앱 공통 타이포그래피 헬퍼.
/// 디자인 토큰을 한 곳에 모아 화면들이 같은 룩을 유지하게 한다.
///
/// 폰트 선택: **Jua** (Google Fonts) — 한글 + 영문 모두 자연스럽게 렌더되는
/// 둥글둥글한 트렌디 디스플레이 폰트. K-앱 메인 헤더에 자주 쓰임.
class AppTypography {
  AppTypography._();

  /// 홈 / 방 / 검색 / 캐릭터 / 설정 등 메인 탭의 좌상단 헤더 스타일.
  /// 모든 탭이 같은 크기 / 같은 폰트로 보이도록 한 곳에서 관리.
  static TextStyle tabHeader({Color? color}) => GoogleFonts.jua(
        fontSize: 26,
        color: color ?? DottieColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.0,
      );

  /// 스플래시 / 로그인 등 브랜드 노출이 메인인 hero 영역 스타일.
  /// 같은 폰트(Jua)로 톤 일관성 유지 + 사이즈만 크게.
  static TextStyle brandHero({Color? color, double fontSize = 38}) =>
      GoogleFonts.jua(
        fontSize: fontSize,
        color: color ?? DottieColors.primary,
        letterSpacing: -0.5,
        height: 1.0,
      );

  // ── 본문 영역 (Noto Sans KR) ─────────────────────────
  // feed/spot 톤을 기준으로 한 일반 텍스트 스케일.

  /// 카드 / 시트 / 다이얼로그 제목. 본문 첫 머리 강조.
  /// feed_card placeName / spot tile placeName 등이 사용.
  static TextStyle title({
    Color? color,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w700,
  }) =>
      GoogleFonts.notoSansKr(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: -0.15,
        color: color ?? DottieColors.textPrimary,
      );

  /// 카드 부제 / 메타 정보 — 카테고리, 시간, 작성자 등.
  static TextStyle subtitle({
    Color? color,
    double fontSize = 12.5,
    FontWeight fontWeight = FontWeight.w600,
  }) =>
      GoogleFonts.notoSansKr(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? DottieColors.textSecondary,
      );

  /// 본문 텍스트 — 메모, 설명 등 줄간격 있는 일반 내용.
  static TextStyle body({
    Color? color,
    double fontSize = 14,
    double height = 1.5,
    FontWeight fontWeight = FontWeight.w400,
  }) =>
      GoogleFonts.notoSansKr(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
        color: color ?? DottieColors.textPrimary,
      );

  /// 작은 보조 텍스트 — 챕 라벨, 메타, 카운트 등.
  static TextStyle caption({
    Color? color,
    double fontSize = 11.5,
    FontWeight fontWeight = FontWeight.w600,
  }) =>
      GoogleFonts.notoSansKr(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color ?? DottieColors.textSecondary,
      );

  /// 힌트 / placeholder / 빈 상태 안내 톤.
  static TextStyle hint({
    Color? color,
    double fontSize = 12,
    double height = 1.5,
  }) =>
      GoogleFonts.notoSansKr(
        fontSize: fontSize,
        height: height,
        color: color ?? DottieColors.textHint,
      );
}
