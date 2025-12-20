import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/locale_provider.dart';
import 'package:koogwe/core/widgets/koogwe_logo.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends ConsumerState<LanguageSelectionScreen> {
  String? _selectedLanguageCode;

  @override
  void initState() {
    super.initState();
    // Initialiser avec la langue actuelle
    final localeState = ref.read(localeProvider);
    _selectedLanguageCode = localeState.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeState = ref.watch(localeProvider);
    final currentLanguageCode = _selectedLanguageCode ?? localeState.languageCode;
    
    // Liste des langues supportées
    final languages = [
      {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷', 'native': 'Français'},
      {'code': 'en', 'name': 'English', 'flag': '🇬🇧', 'native': 'English'},
      {'code': 'es', 'name': 'Español', 'flag': '🇪🇸', 'native': 'Español'},
      {'code': 'pt', 'name': 'Português', 'flag': '🇵🇹', 'native': 'Português'},
      {'code': 'ht', 'name': 'Kreyòl', 'flag': '🇭🇹', 'native': 'Kreyòl ayisyen'},
    ];
    
    return Scaffold(
      backgroundColor: isDark ? KoogweColors.darkBackground : KoogweColors.lightBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: KoogweSpacing.xl,
                    right: KoogweSpacing.xl,
                    top: KoogweSpacing.xl,
                    bottom: MediaQuery.of(context).viewInsets.bottom + KoogweSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header avec logo
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/country-selection');
                              }
                            },
                            icon: Icon(
                              Icons.arrow_back,
                              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                            ),
                          ),
                          const Spacer(),
                          KoogweLogo(size: 48, showWordmark: false),
                        ],
                      ),
                      const SizedBox(height: KoogweSpacing.xxl),
                      
                      // Titre
                      Text(
                        'Choisissez votre langue',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                        ),
                      ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.md),
                      Text(
                        'Sélectionnez votre langue préférée pour l\'application',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                        ),
                      ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.xxl),
                      
                      // Liste des langues avec aperçu en temps réel
                      ...languages.asMap().entries.map((entry) {
                        final index = entry.key;
                        final lang = entry.value;
                        final isSelected = lang['code'] == currentLanguageCode;
                        final isRTL = lang['code'] == 'ar' || lang['code'] == 'he'; // Support RTL
                        
                        return _buildLanguageCard(
                          context: context,
                          isDark: isDark,
                          language: lang,
                          isSelected: isSelected,
                          isRTL: isRTL,
                          index: index,
                        ).animate()
                            .fadeIn(delay: (150 + index * 50).ms)
                            .slideX(begin: -0.1, end: 0);
                      }),
                      
                      const SizedBox(height: KoogweSpacing.xxl),
                      
                      // Bouton Continuer
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_selectedLanguageCode != null) {
                              final locale = Locale(_selectedLanguageCode!);
                              context.setLocale(locale);
                              ref.read(localeProvider.notifier).setLanguage(_selectedLanguageCode!);
                            }
                            context.go('/role-selection');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KoogweColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: KoogweSpacing.lg),
                            shape: RoundedRectangleBorder(
                              borderRadius: KoogweRadius.fullRadius,
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            'Continuer',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2, end: 0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLanguageCard({
    required BuildContext context,
    required bool isDark,
    required Map<String, String> language,
    required bool isSelected,
    required bool isRTL,
    required int index,
  }) {
    // Aperçu de texte dans la langue sélectionnée
    final previewText = {
      'fr': 'Bienvenue sur KOOGWE',
      'en': 'Welcome to KOOGWE',
      'es': 'Bienvenido a KOOGWE',
      'pt': 'Bem-vindo ao KOOGWE',
      'ht': 'Byenveni nan KOOGWE',
    };
    
    return Padding(
      padding: const EdgeInsets.only(bottom: KoogweSpacing.md),
      child: InkWell(
        onTap: () {
          setState(() => _selectedLanguageCode = language['code']);
          final locale = Locale(language['code']!);
          context.setLocale(locale);
          ref.read(localeProvider.notifier).setLanguage(language['code']!);
        },
        borderRadius: KoogweRadius.lgRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(KoogweSpacing.lg),
          decoration: BoxDecoration(
            color: isSelected
                ? KoogweColors.primary.withValues(alpha: 0.1)
                : (isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface),
            borderRadius: KoogweRadius.lgRadius,
            border: Border.all(
              color: isSelected
                  ? KoogweColors.primary
                  : (isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: KoogweColors.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Drapeau
              Text(
                language['flag']!,
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(width: KoogweSpacing.lg),
              // Informations de langue
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      language['name']!,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: KoogweSpacing.xs),
                    Text(
                      language['native']!,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: KoogweSpacing.sm),
                    // Aperçu en temps réel du texte
                    Container(
                      padding: const EdgeInsets.all(KoogweSpacing.sm),
                      decoration: BoxDecoration(
                        color: isDark
                            ? KoogweColors.darkBackground
                            : KoogweColors.lightBackground,
                        borderRadius: KoogweRadius.smRadius,
                      ),
                      child: Text(
                        previewText[language['code']] ?? previewText['en']!,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: KoogweColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Indicateur de sélection
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: KoogweColors.primary,
                  size: 32,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

