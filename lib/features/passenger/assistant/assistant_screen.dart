import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:google_fonts/google_fonts.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final List<AssistantSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  void _loadSuggestions() {
    // Suggestions simulées intelligentes
    final suggestions = [
      AssistantSuggestion(
        icon: Icons.access_time,
        title: 'Heure idéale pour voyager',
        description: 'Le trafic est généralement plus faible entre 10h et 14h. Économisez jusqu\'à 15% sur vos trajets.',
        action: 'Réserver maintenant',
        color: KoogweColors.primary,
      ),
      AssistantSuggestion(
        icon: Icons.location_on,
        title: 'Zone moins chère',
        description: 'Les trajets depuis le centre-ville sont 20% moins chers que depuis l\'aéroport actuellement.',
        action: 'Voir les zones',
        color: KoogweColors.secondary,
      ),
      AssistantSuggestion(
        icon: Icons.trending_down,
        title: 'Trafic faible maintenant',
        description: 'Le trafic est actuellement optimal. Temps de trajet réduit de 30% par rapport à la moyenne.',
        action: 'Réserver un trajet',
        color: KoogweColors.success,
      ),
      AssistantSuggestion(
        icon: Icons.local_offer,
        title: 'Offre spéciale disponible',
        description: 'Réduction de 10% sur tous les trajets vers Kourou jusqu\'à demain soir.',
        action: 'Profiter de l\'offre',
        color: KoogweColors.accent,
      ),
    ];
    
    setState(() {
      _suggestions.addAll(suggestions);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant intelligent'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(KoogweSpacing.xl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [KoogweColors.primary, KoogweColors.primaryDark],
                ),
                borderRadius: KoogweRadius.lgRadius,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(KoogweSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.smart_toy, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: KoogweSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Votre assistant KOOGWE',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Suggestions personnalisées pour optimiser vos trajets',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().scale(duration: 500.ms, curve: Curves.easeOutBack),
            
            const SizedBox(height: KoogweSpacing.xxxl),
            
            Text(
              'Suggestions pour vous',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
            const SizedBox(height: KoogweSpacing.lg),
            
            ..._suggestions.asMap().entries.map((entry) {
              final index = entry.key;
              final suggestion = entry.value;
              return _SuggestionCard(
                suggestion: suggestion,
                onAction: () {
                  // Action selon le type de suggestion
                  context.push('/passenger/ride-booking');
                },
              ).animate()
                  .fadeIn(delay: Duration(milliseconds: 300 + (index * 100)))
                  .slideY(begin: 0.1, end: 0);
            }),
          ],
        ),
      ),
    );
  }
}

class AssistantSuggestion {
  final IconData icon;
  final String title;
  final String description;
  final String action;
  final Color color;

  AssistantSuggestion({
    required this.icon,
    required this.title,
    required this.description,
    required this.action,
    required this.color,
  });
}

class _SuggestionCard extends StatelessWidget {
  final AssistantSuggestion suggestion;
  final VoidCallback onAction;

  const _SuggestionCard({
    required this.suggestion,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: KoogweSpacing.lg),
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
        borderRadius: KoogweRadius.lgRadius,
        border: Border.all(
          color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KoogweSpacing.md),
                decoration: BoxDecoration(
                  color: suggestion.color.withValues(alpha: 0.2),
                  borderRadius: KoogweRadius.mdRadius,
                ),
                child: Icon(suggestion.icon, color: suggestion.color, size: 24),
              ),
              const SizedBox(width: KoogweSpacing.md),
              Expanded(
                child: Text(
                  suggestion.title,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.md),
          Text(
            suggestion.description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: KoogweSpacing.md),
          TextButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: Text(suggestion.action),
            style: TextButton.styleFrom(
              foregroundColor: suggestion.color,
            ),
          ),
        ],
      ),
    );
  }
}

