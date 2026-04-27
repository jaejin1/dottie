import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: DottieColors.primary,
          brightness: Brightness.light,
          primary: DottieColors.primary,
          secondary: DottieColors.secondary,
          error: DottieColors.error,
          surface: DottieColors.surface,
        ),
        scaffoldBackgroundColor: DottieColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: DottieColors.surface,
          foregroundColor: DottieColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: DottieColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: DottieColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: DottieColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: DottieColors.textHint),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: DottieColors.surface,
          selectedItemColor: DottieColors.primary,
          unselectedItemColor: DottieColors.textHint,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        cardTheme: CardThemeData(
          color: DottieColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
}
