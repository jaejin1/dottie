import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class AppTheme {
  AppTheme._();

  // ── 타이포그래피 ─────────────────────────────────────
  static TextTheme get _textTheme {
    final base = GoogleFonts.notoSansKrTextTheme();
    return base.copyWith(
      titleLarge: GoogleFonts.notoSansKr(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: DottieColors.textPrimary,
        letterSpacing: -0.5,
      ),
      titleMedium: GoogleFonts.notoSansKr(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: DottieColors.textPrimary,
        letterSpacing: -0.3,
      ),
      titleSmall: GoogleFonts.notoSansKr(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: DottieColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.notoSansKr(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: DottieColors.textPrimary,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.notoSansKr(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: DottieColors.textSecondary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.notoSansKr(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: DottieColors.textHint,
      ),
      labelLarge: GoogleFonts.notoSansKr(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: DottieColors.textPrimary,
      ),
      labelMedium: GoogleFonts.notoSansKr(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: DottieColors.textSecondary,
      ),
      labelSmall: GoogleFonts.notoSansKr(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: DottieColors.textHint,
        letterSpacing: 0.2,
      ),
    );
  }

  // ── 크림 라이트 테마 ─────────────────────────────────
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: DottieColors.primary,
        onPrimary: Color(0xFFFEFCFA),
        primaryContainer: DottieColors.primaryLight,
        onPrimaryContainer: DottieColors.secondary,
        secondary: DottieColors.secondary,
        onSecondary: Color(0xFFFEFCFA),
        error: DottieColors.error,
        onError: Color(0xFFFEFCFA),
        surface: DottieColors.surface,
        onSurface: DottieColors.textPrimary,
        surfaceContainerHighest: DottieColors.surfaceVariant,
        outline: DottieColors.border,
        outlineVariant: DottieColors.border,
      ),
      scaffoldBackgroundColor: DottieColors.background,
      textTheme: _textTheme,

      // ── 앱바 ──────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: DottieColors.background,
        foregroundColor: DottieColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: GoogleFonts.notoSansKr(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: DottieColors.textPrimary,
          letterSpacing: -0.5,
        ),
        iconTheme:
            const IconThemeData(color: DottieColors.textPrimary, size: 22),
      ),

      // ── 버튼 ──────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DottieColors.primary,
          foregroundColor: const Color(0xFFFEFCFA),
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.notoSansKr(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DottieColors.primary,
          textStyle: GoogleFonts.notoSansKr(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DottieColors.textPrimary,
          side: const BorderSide(color: DottieColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ── 인풋 ──────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DottieColors.surfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: DottieColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: DottieColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.notoSansKr(
            color: DottieColors.textHint, fontSize: 14),
        labelStyle: GoogleFonts.notoSansKr(
            color: DottieColors.textSecondary, fontSize: 14),
      ),

      // ── 카드 ──────────────────────────────────────────
      cardTheme: CardThemeData(
        color: DottieColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: DottieColors.border, width: 0.8),
        ),
        shadowColor: const Color(0x14C07B5A), // 테라코타 틴트 그림자
      ),

      // ── 바텀시트 ──────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: DottieColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
        dragHandleColor: DottieColors.border,
      ),

      // ── 다이얼로그 ────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: DottieColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.notoSansKr(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: DottieColors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.notoSansKr(
          fontSize: 14,
          color: DottieColors.textSecondary,
          height: 1.5,
        ),
      ),

      // ── 스낵바 ────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DottieColors.textPrimary,
        contentTextStyle: GoogleFonts.notoSansKr(
          color: DottieColors.background,
          fontSize: 13,
        ),
        actionTextColor: DottieColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),

      // ── 칩 ────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: DottieColors.surfaceVariant,
        selectedColor: DottieColors.primary,
        disabledColor: DottieColors.surfaceVariant,
        labelStyle: GoogleFonts.notoSansKr(
          fontSize: 13,
          color: DottieColors.textSecondary,
        ),
        secondaryLabelStyle: GoogleFonts.notoSansKr(
          fontSize: 13,
          color: const Color(0xFFFEFCFA),
          fontWeight: FontWeight.w600,
        ),
        side: const BorderSide(color: DottieColors.border, width: 0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── 분리선 ────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: DottieColors.border,
        thickness: 0.8,
        space: 0,
      ),

      // ── ListTile ──────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: DottieColors.surface,
        iconColor: DottieColors.textSecondary,
        titleTextStyle: GoogleFonts.notoSansKr(
          fontSize: 15,
          color: DottieColors.textPrimary,
        ),
        subtitleTextStyle: GoogleFonts.notoSansKr(
          fontSize: 12,
          color: DottieColors.textHint,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // ── Switch ────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? const Color(0xFFFEFCFA)
                : DottieColors.border),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? DottieColors.primary
                : DottieColors.surfaceVariant),
        trackOutlineColor:
            WidgetStateProperty.resolveWith((states) =>
                states.contains(WidgetState.selected)
                    ? Colors.transparent
                    : DottieColors.border),
      ),

      // ── NavigationBar (salomon 교체 전 fallback) ──────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: DottieColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: DottieColors.primaryLight,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) =>
            GoogleFonts.notoSansKr(
              fontSize: 11,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w600
                  : FontWeight.w400,
              color: states.contains(WidgetState.selected)
                  ? DottieColors.primary
                  : DottieColors.textHint,
            )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? DottieColors.primary
                  : DottieColors.textHint,
              size: 22,
            )),
      ),
    );
  }
}
