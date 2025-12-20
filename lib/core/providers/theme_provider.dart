import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:koogwe/core/theme/koogwe_theme_data.dart';

class ThemeState {
  final KoogweTheme currentTheme;
  final KoogweThemeMode mode;
  final bool isSystemMode;

  ThemeState({
    required this.currentTheme,
    required this.mode,
    this.isSystemMode = false,
  });

  ThemeState copyWith({
    KoogweTheme? currentTheme,
    KoogweThemeMode? mode,
    bool? isSystemMode,
  }) {
    return ThemeState(
      currentTheme: currentTheme ?? this.currentTheme,
      mode: mode ?? this.mode,
      isSystemMode: isSystemMode ?? this.isSystemMode,
    );
  }

  KoogweThemeData get themeData => KoogweThemeData.getTheme(currentTheme, mode);

  ThemeMode get flutterThemeMode {
    if (isSystemMode) return ThemeMode.system;
    return mode == KoogweThemeMode.dark ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeData get materialTheme {
    final data = themeData;
    return ThemeData(
      useMaterial3: true,
      brightness: mode == KoogweThemeMode.dark ? Brightness.dark : Brightness.light,
      primaryColor: data.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: data.primary,
        brightness: mode == KoogweThemeMode.dark ? Brightness.dark : Brightness.light,
        primary: data.primary,
        secondary: data.secondary,
        tertiary: data.accent,
        error: data.error,
        surface: data.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: data.textPrimary,
      ),
      scaffoldBackgroundColor: data.background,
      cardColor: data.surface,
      dividerColor: data.border,
      appBarTheme: AppBarTheme(
        backgroundColor: data.surface,
        foregroundColor: data.textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: data.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: data.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: data.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: data.textPrimary),
        displayMedium: TextStyle(color: data.textPrimary),
        displaySmall: TextStyle(color: data.textPrimary),
        headlineLarge: TextStyle(color: data.textPrimary),
        headlineMedium: TextStyle(color: data.textPrimary),
        headlineSmall: TextStyle(color: data.textPrimary),
        titleLarge: TextStyle(color: data.textPrimary),
        titleMedium: TextStyle(color: data.textPrimary),
        titleSmall: TextStyle(color: data.textPrimary),
        bodyLarge: TextStyle(color: data.textPrimary),
        bodyMedium: TextStyle(color: data.textPrimary),
        bodySmall: TextStyle(color: data.textSecondary),
        labelLarge: TextStyle(color: data.textPrimary),
        labelMedium: TextStyle(color: data.textSecondary),
        labelSmall: TextStyle(color: data.textTertiary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: data.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: data.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: data.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: data.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: data.error),
        ),
      ),
    );
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    _loadTheme();
    return ThemeState(
      currentTheme: KoogweTheme.defaultOrange,
      mode: KoogweThemeMode.light,
    );
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt('selected_theme') ?? 0;
      final modeIndex = prefs.getInt('theme_mode') ?? 0;
      final isSystemMode = prefs.getBool('is_system_mode') ?? false;

      if (themeIndex >= 0 && themeIndex < KoogweTheme.values.length) {
        final theme = KoogweTheme.values[themeIndex];
        final mode = modeIndex == 0 ? KoogweThemeMode.light : KoogweThemeMode.dark;

        state = ThemeState(
          currentTheme: theme,
          mode: mode,
          isSystemMode: isSystemMode,
        );
      }
    } catch (e) {
      // Utiliser le thème par défaut en cas d'erreur
      state = ThemeState(
        currentTheme: KoogweTheme.defaultOrange,
        mode: KoogweThemeMode.light,
      );
    }
  }

  Future<void> setTheme(KoogweTheme theme) async {
    state = state.copyWith(currentTheme: theme);
    await _saveTheme();
  }

  Future<void> setMode(KoogweThemeMode mode) async {
    state = state.copyWith(mode: mode, isSystemMode: false);
    await _saveTheme();
  }

  Future<void> setThemeMode(KoogweThemeMode mode) async {
    if (mode == KoogweThemeMode.system) {
      await setSystemMode(true);
    } else {
      state = state.copyWith(mode: mode, isSystemMode: false);
      await _saveTheme();
    }
  }

  Future<void> setSystemMode(bool useSystem) async {
    if (useSystem) {
      // Détecter le mode système
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final systemMode = brightness == Brightness.dark
          ? KoogweThemeMode.dark
          : KoogweThemeMode.light;
      state = state.copyWith(mode: systemMode, isSystemMode: true);
    } else {
      state = state.copyWith(isSystemMode: false);
    }
    await _saveTheme();
  }

  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('selected_theme', state.currentTheme.index);
      await prefs.setInt('theme_mode', state.mode.index);
      await prefs.setBool('is_system_mode', state.isSystemMode);
    } catch (e) {
      // Ignorer les erreurs de sauvegarde
    }
  }

  void listenToSystemMode() {
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      if (state.isSystemMode) {
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        final systemMode = brightness == Brightness.dark
            ? KoogweThemeMode.dark
            : KoogweThemeMode.light;
        state = state.copyWith(mode: systemMode);
      }
    };
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);
