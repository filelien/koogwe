import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/providers/theme_provider.dart';
import 'package:koogwe/core/theme/koogwe_theme_data.dart';

/// Helper pour obtenir facilement les couleurs du thème actif
class ThemeHelper {
  /// Obtient les couleurs du thème depuis le contexte
  static KoogweThemeData colors(BuildContext context) {
    final container = ProviderScope.containerOf(context, listen: false);
    final themeState = container.read(themeProvider);
    return themeState.themeData;
  }

  /// Obtient le mode du thème (clair/sombre)
  static bool isDark(BuildContext context) {
    final container = ProviderScope.containerOf(context, listen: false);
    final themeState = container.read(themeProvider);
    return themeState.mode == KoogweThemeMode.dark;
  }
}

