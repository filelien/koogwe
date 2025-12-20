import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';

class KoogweTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    splashFactory: NoSplash.splashFactory,
    primaryColor: KoogweColors.primary,
    scaffoldBackgroundColor: KoogweColors.lightBackground,
    colorScheme: ColorScheme.light(
      primary: KoogweColors.primary,
      secondary: KoogweColors.secondary,
      tertiary: KoogweColors.accent,
      error: KoogweColors.error,
      surface: KoogweColors.lightSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: KoogweColors.lightOnSurface,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: KoogweColors.lightTextPrimary),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: KoogweColors.lightTextPrimary,
      ),
    ),
    textTheme: _buildTextTheme(Brightness.light),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: KoogweColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: KoogweSpacing.xl, vertical: KoogweSpacing.lg),
        shape: RoundedRectangleBorder(borderRadius: KoogweRadius.lgRadius),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: KoogweColors.primary,
        side: BorderSide(color: KoogweColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: KoogweSpacing.xl, vertical: KoogweSpacing.lg),
        shape: RoundedRectangleBorder(borderRadius: KoogweRadius.lgRadius),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: KoogweColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: KoogweSpacing.lg, vertical: KoogweSpacing.md),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: KoogweColors.lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: KoogweSpacing.lg, vertical: KoogweSpacing.lg),
      border: OutlineInputBorder(
        borderRadius: KoogweRadius.mdRadius,
        borderSide: BorderSide(color: KoogweColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: KoogweRadius.mdRadius,
        borderSide: BorderSide(color: KoogweColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: KoogweRadius.mdRadius,
        borderSide: BorderSide(color: KoogweColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: KoogweColors.error),
        borderRadius: BorderRadius.circular(KoogweRadius.md),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: KoogweColors.error, width: 2),
        borderRadius: BorderRadius.circular(KoogweRadius.md),
      ),
      hintStyle: GoogleFonts.inter(
        color: KoogweColors.lightTextTertiary,
        fontSize: 14,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: KoogweColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: KoogweRadius.lgRadius,
        side: BorderSide(color: KoogweColors.lightBorder, width: 1),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: KoogweColors.lightDivider,
      thickness: 1,
      space: 1,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: KoogweColors.lightSurface,
      selectedItemColor: KoogweColors.primary,
      unselectedItemColor: KoogweColors.lightTextTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    splashFactory: NoSplash.splashFactory,
    primaryColor: KoogweColors.primary,
    scaffoldBackgroundColor: KoogweColors.darkBackground,
    colorScheme: ColorScheme.dark(
      primary: KoogweColors.primary,
      secondary: KoogweColors.secondary,
      tertiary: KoogweColors.accent,
      error: KoogweColors.error,
      surface: KoogweColors.darkSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: KoogweColors.darkOnSurface,
      onError: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: KoogweColors.darkTextPrimary),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: KoogweColors.darkTextPrimary,
      ),
    ),
    textTheme: _buildTextTheme(Brightness.dark),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: KoogweColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: KoogweSpacing.xl, vertical: KoogweSpacing.lg),
        shape: RoundedRectangleBorder(borderRadius: KoogweRadius.lgRadius),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: KoogweColors.primary,
        side: BorderSide(color: KoogweColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: KoogweSpacing.xl, vertical: KoogweSpacing.lg),
        shape: RoundedRectangleBorder(borderRadius: KoogweRadius.lgRadius),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: KoogweColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: KoogweSpacing.lg, vertical: KoogweSpacing.md),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: KoogweColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: KoogweSpacing.lg, vertical: KoogweSpacing.lg),
      border: OutlineInputBorder(
        borderRadius: KoogweRadius.mdRadius,
        borderSide: BorderSide(color: KoogweColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: KoogweRadius.mdRadius,
        borderSide: BorderSide(color: KoogweColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: KoogweRadius.mdRadius,
        borderSide: BorderSide(color: KoogweColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: KoogweColors.error),
        borderRadius: BorderRadius.circular(KoogweRadius.md),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: KoogweColors.error, width: 2),
        borderRadius: BorderRadius.circular(KoogweRadius.md),
      ),
      hintStyle: GoogleFonts.inter(
        color: KoogweColors.darkTextTertiary,
        fontSize: 14,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: KoogweColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: KoogweRadius.lgRadius,
        side: BorderSide(color: KoogweColors.darkBorder, width: 1),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: KoogweColors.darkDivider,
      thickness: 1,
      space: 1,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: KoogweColors.darkSurface,
      selectedItemColor: KoogweColors.primary,
      unselectedItemColor: KoogweColors.darkTextTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );

  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.light
        ? KoogweColors.lightTextPrimary
        : KoogweColors.darkTextPrimary;

    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: -0.25,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: baseColor,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: baseColor,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
    );
  }
}
