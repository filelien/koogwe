import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:country_picker/country_picker.dart';

class LocaleState {
  final Locale locale;
  final String currency;
  final String countryCode;
  Country? selectedCountry;

  LocaleState({
    this.locale = const Locale('fr', 'GF'),
    this.currency = 'EUR',
    this.countryCode = 'GF',
    this.selectedCountry,
  });

  String get languageCode => locale.languageCode;

  LocaleState copyWith({
    Locale? locale,
    String? currency,
    String? countryCode,
    Country? selectedCountry,
  }) {
    return LocaleState(
      locale: locale ?? this.locale,
      currency: currency ?? this.currency,
      countryCode: countryCode ?? this.countryCode,
      selectedCountry: selectedCountry ?? this.selectedCountry,
    );
  }
}

class LocaleNotifier extends Notifier<LocaleState> {
  @override
  LocaleState build() {
    _loadLocalePreference();
    return LocaleState();
  }

  Future<void> _loadLocalePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'fr';
    final countryCode = prefs.getString('country_code') ?? 'GF';
    final currency = prefs.getString('currency') ?? 'EUR';

    state = LocaleState(
      locale: Locale(languageCode, countryCode),
      currency: currency,
      countryCode: countryCode,
    );
  }

  Future<void> setLocale(Locale locale, String currency, String countryCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setString('country_code', countryCode);
    await prefs.setString('currency', currency);

    state = LocaleState(
      locale: locale,
      currency: currency,
      countryCode: countryCode,
    );
  }

  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    
    state = state.copyWith(
      locale: Locale(languageCode, state.locale.countryCode),
    );
  }

  Future<void> setCurrency(String currency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
    state = state.copyWith(currency: currency);
  }

  Future<void> setCountry(Country country) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('country_code', country.countryCode);
    
    // Mettre à jour la devise selon le pays si nécessaire
    String currency = state.currency;
    switch (country.countryCode) {
      case 'FR':
      case 'GF':
        currency = 'EUR';
        break;
      case 'US':
        currency = 'USD';
        break;
      case 'BR':
        currency = 'BRL';
        break;
      // Ajouter d'autres pays selon les besoins
    }
    
    state = state.copyWith(
      countryCode: country.countryCode,
      selectedCountry: country,
      locale: Locale(state.locale.languageCode, country.countryCode),
      currency: currency,
    );
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, LocaleState>(LocaleNotifier.new);
