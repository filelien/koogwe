import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComfortPreferences {
  final bool silence;
  final bool music;
  final bool airConditioning;
  final bool gentleDriving;
  final bool conversation;
  final String? temperature;

  ComfortPreferences({
    this.silence = false,
    this.music = false,
    this.airConditioning = true,
    this.gentleDriving = false,
    this.conversation = false,
    this.temperature,
  });

  ComfortPreferences copyWith({
    bool? silence,
    bool? music,
    bool? airConditioning,
    bool? gentleDriving,
    bool? conversation,
    String? temperature,
  }) {
    return ComfortPreferences(
      silence: silence ?? this.silence,
      music: music ?? this.music,
      airConditioning: airConditioning ?? this.airConditioning,
      gentleDriving: gentleDriving ?? this.gentleDriving,
      conversation: conversation ?? this.conversation,
      temperature: temperature ?? this.temperature,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'silence': silence,
      'music': music,
      'airConditioning': airConditioning,
      'gentleDriving': gentleDriving,
      'conversation': conversation,
      'temperature': temperature,
    };
  }
}

class ComfortPreferencesNotifier extends Notifier<ComfortPreferences> {
  @override
  ComfortPreferences build() {
    _loadPreferences();
    return ComfortPreferences();
  }

  Future<void> _loadPreferences() async {
    // Simuler le chargement depuis le stockage
    await Future.delayed(const Duration(milliseconds: 300));
    // Pour la démo, on garde les valeurs par défaut
  }

  Future<void> updatePreferences(ComfortPreferences preferences) async {
    state = preferences;
    // Sauvegarder les préférences (simulé)
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> toggleSilence() async {
    state = state.copyWith(silence: !state.silence);
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> toggleMusic() async {
    state = state.copyWith(music: !state.music);
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> toggleAirConditioning() async {
    state = state.copyWith(airConditioning: !state.airConditioning);
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> toggleGentleDriving() async {
    state = state.copyWith(gentleDriving: !state.gentleDriving);
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> toggleConversation() async {
    state = state.copyWith(conversation: !state.conversation);
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> setTemperature(String temp) async {
    state = state.copyWith(temperature: temp);
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

final comfortPreferencesProvider = NotifierProvider<ComfortPreferencesNotifier, ComfortPreferences>(
  ComfortPreferencesNotifier.new,
);

