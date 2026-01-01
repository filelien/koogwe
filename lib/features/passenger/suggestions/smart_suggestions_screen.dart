import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SmartSuggestionsScreen extends StatefulWidget {
  const SmartSuggestionsScreen({super.key});

  @override
  State<SmartSuggestionsScreen> createState() => _SmartSuggestionsScreenState();
}

class _SmartSuggestionsScreenState extends State<SmartSuggestionsScreen> {
  final List<Suggestion> _suggestions = [
    Suggestion(
      id: '1',
      title: 'Retour au bureau',
      description: 'Basé sur vos trajets précédents',
      destination: '456 Avenue des Champs, Paris',
      icon: Icons.business,
      color: KoogweColors.primary,
      type: SuggestionType.work,
    ),
    Suggestion(
      id: '2',
      title: 'Aller à la maison',
      description: 'Vous y allez souvent à cette heure',
      destination: '123 Rue de la Paix, Paris',
      icon: Icons.home,
      color: KoogweColors.accent,
      type: SuggestionType.home,
    ),
    Suggestion(
      id: '3',
      title: 'Restaurant favori',
      description: 'Vous avez réservé ici 3 fois ce mois',
      destination: '789 Boulevard Saint-Michel, Paris',
      icon: Icons.restaurant,
      color: KoogweColors.secondary,
      type: SuggestionType.favorite,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientBackground(
      useDarkAurora: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Suggestions intelligentes',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(KoogweSpacing.lg),
            children: [
              // En-tête
              GlassCard(
                borderRadius: KoogweRadius.lgRadius,
                child: Padding(
                  padding: const EdgeInsets.all(KoogweSpacing.lg),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: KoogweColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lightbulb_outline,
                          color: KoogweColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: KoogweSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Suggestions basées sur vos habitudes',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Nous apprenons de vos trajets pour vous proposer les meilleures destinations',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),

              const SizedBox(height: KoogweSpacing.xl),

              // Liste des suggestions
              ..._suggestions.map((suggestion) {
                final index = _suggestions.indexOf(suggestion);
                return Padding(
                  padding: const EdgeInsets.only(bottom: KoogweSpacing.md),
                  child: GlassCard(
                    borderRadius: KoogweRadius.lgRadius,
                    onTap: () {
                      context.push('/passenger/ride-booking', extra: {
                        'dropoff': suggestion.destination,
                      });
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(KoogweSpacing.md),
                      leading: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: suggestion.color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          suggestion.icon,
                          color: suggestion.color,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        suggestion.title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            suggestion.description,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            suggestion.destination,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: suggestion.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0);
              }),
            ],
          ),
        ),
      ),
    );
  }
}

enum SuggestionType { home, work, favorite, recent }

class Suggestion {
  final String id;
  final String title;
  final String description;
  final String destination;
  final IconData icon;
  final Color color;
  final SuggestionType type;

  Suggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.destination,
    required this.icon,
    required this.color,
    required this.type,
  });
}

