import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ── Durum ───────────────────────────────────────────────────
  static bool isDark = true;

  static void setBrightness(Brightness b) {
    isDark = (b == Brightness.dark);
  }

  // ── Nötr renkler — getter (tema duyarlı) ────────────────────
  static const Color bgDark = Color(0xFF080C14);
  static const Color bgLight = Color(0xFFF4F6FB);

  static const Color surfaceDark = Color(0xFF111827);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  static const Color surfaceUpDark = Color(0xFF1A2232);
  static const Color surfaceUpLight = Color(0xFFE2E8F0);

  static const Color surfaceHighDark = Color(0xFF243044);
  static const Color surfaceHighLight = Color(0xFFCBD5E1);

  static const Color textPrimaryDark = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);

  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textSecondaryLight = Color(0xFF475569);

  static const Color textMutedDark = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  static Color get bg => isDark ? bgDark : bgLight;
  static Color get surface => isDark ? surfaceDark : surfaceLight;
  static Color get surfaceUp => isDark ? surfaceUpDark : surfaceUpLight;
  static Color get surfaceHigh => isDark ? surfaceHighDark : surfaceHighLight;
  static Color get textPrimary => isDark ? textPrimaryDark : textPrimaryLight;
  static Color get textSecondary => isDark ? textSecondaryDark : textSecondaryLight;
  static Color get textMuted => isDark ? textMutedDark : textMutedLight;

  // ── Aksan renkleri — const (her iki temada ortak) ────────────
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryGlow = Color(0x447C3AED);

  static const Color cyan = Color(0xFF06B6D4);
  static const Color cyanLight = Color(0xFF22D3EE);

  static const Color pink = Color(0xFFDB2777);
  static const Color pinkLight = Color(0xFFF472B6);

  static const Color green = Color(0xFF059669);
  static const Color greenLight = Color(0xFF34D399);

  static const Color amber = Color(0xFFD97706);
  static const Color amberLight = Color(0xFFFBBF24);

  static const Color red = Color(0xFFDC2626);
  static const Color redLight = Color(0xFFF87171);

  static const List<Color> graphPalette = [
    Color(0xFFA78BFA),
    Color(0xFF22D3EE),
    Color(0xFFF472B6),
    Color(0xFF34D399),
    Color(0xFFFBBF24),
    Color(0xFFF87171),
  ];
}

class AppTheme {
  // Dark tema: açıkça Dark sabitlerinden kurulur
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surfaceDark,
        primary: AppColors.primary,
        secondary: AppColors.cyanLight,
        error: AppColors.red,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimaryDark,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimaryDark,
        displayColor: AppColors.textPrimaryDark,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        shadowColor: Colors.transparent,
        indicatorColor: AppColors.primaryGlow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryLight, size: 24);
          }
          return IconThemeData(color: AppColors.textMutedDark, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryLight,
            );
          }
          return GoogleFonts.inter(fontSize: 11, color: AppColors.textMutedDark);
        }),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.surfaceUpDark, width: 1),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primary,
        thumbColor: AppColors.primaryLight,
        inactiveTrackColor: AppColors.surfaceHighDark,
        overlayColor: AppColors.primaryGlow,
      ),
      dividerColor: AppColors.surfaceUpDark,
    );
  }

  // Light tema: açıkça Light sabitlerinden kurulur
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.light(
        surface: AppColors.surfaceLight,
        primary: AppColors.primary,
        secondary: AppColors.cyan,
        error: AppColors.red,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimaryLight,
        displayColor: AppColors.textPrimaryLight,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        elevation: 0,
        shadowColor: Colors.transparent,
        indicatorColor: AppColors.primaryGlow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return IconThemeData(color: AppColors.textMutedLight, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            );
          }
          return GoogleFonts.inter(fontSize: 11, color: AppColors.textMutedLight);
        }),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.surfaceUpLight, width: 1),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primary,
        thumbColor: AppColors.primaryLight,
        inactiveTrackColor: AppColors.surfaceHighLight,
        overlayColor: AppColors.primaryGlow,
      ),
      dividerColor: AppColors.surfaceUpLight,
    );
  }
}
