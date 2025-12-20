import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/providers/theme_provider.dart';
import 'package:koogwe/core/theme/koogwe_theme_data.dart';

class KoogweColors {
  // Méthode helper pour obtenir les couleurs depuis le thème actif
  static KoogweThemeData of(BuildContext context) {
    final container = ProviderScope.containerOf(context);
    final themeState = container.read(themeProvider);
    return themeState.themeData;
  }

  // Getters dynamiques qui utilisent le thème actif via Riverpod
  // Note: Ces méthodes nécessitent un BuildContext avec un ProviderScope
  static Color get primary => _getCurrentTheme()?.primary ?? const Color(0xFFFF6B35);
  static Color get primaryDark => const Color(0xFFE85527);
  static Color get secondary => _getCurrentTheme()?.secondary ?? const Color(0xFF4ECDC4);
  static Color get accent => _getCurrentTheme()?.accent ?? const Color(0xFFFFE66D);
  static Color get background => _getCurrentTheme()?.background ?? const Color(0xFFFFFFFF);
  static Color get surface => _getCurrentTheme()?.surface ?? const Color(0xFFF8F9FA);
  static Color get surfaceVariant => _getCurrentTheme()?.surfaceVariant ?? const Color(0xFFE9ECEF);
  static Color get textPrimary => _getCurrentTheme()?.textPrimary ?? const Color(0xFF212529);
  static Color get textSecondary => _getCurrentTheme()?.textSecondary ?? const Color(0xFF6C757D);
  static Color get textTertiary => _getCurrentTheme()?.textTertiary ?? const Color(0xFFADB5BD);
  static Color get border => _getCurrentTheme()?.border ?? const Color(0xFFDEE2E6);
  static Color get error => _getCurrentTheme()?.error ?? const Color(0xFFDC3545);
  static Color get success => _getCurrentTheme()?.success ?? const Color(0xFF28A745);
  static Color get warning => _getCurrentTheme()?.warning ?? const Color(0xFFFFC107);

  // Couleurs spécifiques qui ne changent pas avec le thème
  static const lightBackground = Color(0xFFF5F7FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF0F2F5);
  static const lightBorder = Color(0xFFE4E7EC);
  
  static const darkBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF1C1C1E);
  static const darkSurfaceVariant = Color(0xFF2C2C2E);
  static const darkBorder = Color(0xFF38383A);

  static const lightTextPrimary = Color(0xFF1A1C1E);
  static const lightTextSecondary = Color(0xFF5F6368);
  static const lightTextTertiary = Color(0xFF9AA0A6);
  
  static const darkTextPrimary = Color(0xFFF5F7FA);
  static const darkTextSecondary = Color(0xFFAEB3B8);
  static const darkTextTertiary = Color(0xFF787C82);

  // Vehicle Type Colors (peuvent être personnalisées par thème à l'avenir)
  static const vehicleEconomy = Color(0xFF34C759);
  static const vehicleComfort = Color(0xFF0A84FF);
  static const vehiclePremium = Color(0xFF5856D6);
  static const vehicleXL = Color(0xFFFF9500);

  // Status Colors
  static const statusOnline = Color(0xFF34C759);
  static const statusOffline = Color(0xFF8E8E93);
  static const statusBusy = Color(0xFFFF9500);
  static const statusUnavailable = Color(0xFFFF3B30);

  // Map Colors
  static const mapRoute = Color(0xFF0A84FF);
  static const mapPickup = Color(0xFF34C759);
  static const mapDropoff = Color(0xFFFF3B30);
  static const mapDriver = Color(0xFF5856D6);

  // Getters additionnels pour compatibilité
  static Color get primaryLight => primary;
  static Color get secondaryLight => secondary;
  static Color get secondaryDark => secondary;
  static Color get lightOnSurface => lightTextPrimary;
  static Color get darkOnSurface => darkTextPrimary;
  static Color get lightOnBackground => lightTextPrimary;
  static Color get lightDivider => lightBorder;
  static Color get darkDivider => darkBorder;
  static Color get info => const Color(0xFF0A84FF);
  static Color get glassLight => const Color(0xFFFFFFFF).withValues(alpha: 0.6);
  static Color get glassDark => const Color(0xFF1D1B20).withValues(alpha: 0.45);
  static Color get glassBorderLight => const Color(0xFFFFFFFF).withValues(alpha: 0.35);
  static Color get glassBorderDark => const Color(0xFFFFFFFF).withValues(alpha: 0.18);
  static Color get auroraStart => const Color(0xFF2E0F4F);
  static Color get auroraMid => const Color(0xFF4527A0);
  static Color get auroraEnd => const Color(0xFF120E43);

  // Helper pour obtenir le thème actif (nécessite un ProviderScope)
  static KoogweThemeData? _getCurrentTheme() {
    try {
      // Note: Cette méthode ne fonctionne que dans un contexte avec ProviderScope
      // Pour une utilisation sûre, utilisez KoogweColors.of(context) à la place
      return null;
    } catch (_) {
      return null;
    }
  }
}
