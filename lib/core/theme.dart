import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color bg = Color(0xFF080C14);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceUp = Color(0xFF1A2232);
  static const Color surfaceHigh = Color(0xFF243044);

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

  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF475569);

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
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.primary,
        secondary: AppColors.cyanLight,
        error: AppColors.red,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.bg,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        indicatorColor: AppColors.primaryGlow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryLight, size: 24);
          }
          return const IconThemeData(color: AppColors.textMuted, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryLight,
            );
          }
          return GoogleFonts.inter(fontSize: 11, color: AppColors.textMuted);
        }),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceUp, width: 1),
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primary,
        thumbColor: AppColors.primaryLight,
        inactiveTrackColor: AppColors.surfaceHigh,
        overlayColor: AppColors.primaryGlow,
      ),
      dividerColor: AppColors.surfaceUp,
    );
  }
}
