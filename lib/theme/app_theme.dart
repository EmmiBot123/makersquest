// MakerQuest Flutter Light Theme & Playful Design System for Students
import 'package:flutter/material.dart';

class AppColors {
  // Vibrant, cheerful, student-friendly Frosted Cloud Light Palette
  static const Color bgPrimary = Color(0xFFEEF4FF);     // Soft luminous sky canvas fallback
  static const Color bgSecondary = Color(0xCCFFFFFF);   // Frosted translucent white surface
  static const Color bgCard = Color(0xC2FFFFFF);        // Translucent elevated frosted card
  static const Color bgSurface = Color(0x99F1F5F9);     // Frosted soft pill/container fill
  static const Color border = Color(0xB3CBD5E1);        // Subtle frosted rim divider
  static const Color borderLight = Color(0xE6FFFFFF);   // Bright specular glass highlight rim
  static const Color glassStroke = Color(0xDDFFFFFF);   // Specular top-left glass edge stroke
  static const Color glassWhite = Color(0xB8FFFFFF);    // Standard frosted cloud glass fill

  static const Color primary = Color(0xFF4F46E5);        // Quest Indigo (Vibrant & Energetic)
  static const Color primaryLight = Color(0xFF4338CA);   // Deep readable indigo for light background
  static const Color primarySoft = Color(0xFFEEF2FF);    // Ultra-soft indigo tint
  static const Color amber = Color(0xFFD97706);          // Sunburst Gold / Amber
  static const Color amberGlow = Color(0xFFB45309);      // Warm Honey Gold
  static const Color amberSoft = Color(0xFFFEF3C7);      // Soft amber tint
  static const Color emerald = Color(0xFF059669);        // Fresh Spring Emerald
  static const Color emeraldSoft = Color(0xFFD1FAE5);    // Soft emerald tint
  static const Color cyan = Color(0xFF0284C7);           // Sky Blue
  static const Color cyanSoft = Color(0xFFE0F2FE);       // Soft cyan tint
  static const Color rose = Color(0xFFE11D48);           // Vivid Coral Rose
  static const Color roseSoft = Color(0xFFFFE4E6);       // Soft rose tint
  static const Color violet = Color(0xFF7C3AED);         // Royal Violet
  static const Color violetSoft = Color(0xFFF3E8FF);     // Soft violet tint

  static const Color textMain = Color(0xFF0F172A);       // Deep Slate Navy for high-contrast crisp reading
  static const Color textMuted = Color(0xFF475569);      // Medium Slate for descriptions
  static const Color textDim = Color(0xFF64748B);        // Subtle secondary caption grey
}

class AppTheme {
  static const List<String> kFontFallback = [
    'Apple Color Emoji',
    'Segoe UI Emoji',
    'Segoe UI Symbol',
    'Noto Color Emoji',
    'Android Emoji',
    'EmojiSymbols',
    '-apple-system',
    'BlinkMacSystemFont',
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamilyFallback: kFontFallback,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.amber,
        tertiary: AppColors.emerald,
        surface: AppColors.bgCard,
        error: AppColors.rose,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textMain,
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 2,
        shadowColor: AppColors.primary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.glassStroke, width: 1.3),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xBDFFFFFF),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textMain),
        titleTextStyle: TextStyle(
          color: AppColors.textMain,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.borderLight, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xEAFFFFFF),
        surfaceTintColor: Colors.transparent,
        elevation: 14,
        shadowColor: AppColors.primary.withValues(alpha: 0.14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.glassStroke, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgSurface,
        labelStyle: const TextStyle(color: AppColors.textMain, fontSize: 12, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  // Alias for backward compatibility
  static ThemeData get darkTheme => lightTheme;
}
