import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _expandedIndex;

  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'Comment réserver un trajet ?',
      answer: 'Pour réserver un trajet, allez sur la page d\'accueil, entrez votre destination, choisissez votre type de véhicule et confirmez votre réservation.',
      category: 'Réservation',
    ),
    FAQItem(
      question: 'Quels sont les moyens de paiement acceptés ?',
      answer: 'KOOGWE accepte les paiements par carte bancaire, mobile money (Orange Money, MTN Mobile Money) et espèces.',
      category: 'Paiement',
    ),
    FAQItem(
      question: 'Puis-je annuler un trajet ?',
      answer: 'Oui, vous pouvez annuler un trajet jusqu\'à 5 minutes après la réservation sans frais. Après ce délai, des frais d\'annulation peuvent s\'appliquer.',
      category: 'Annulation',
    ),
    FAQItem(
      question: 'Comment fonctionne le système de notation ?',
      answer: 'Après chaque trajet, vous pouvez noter votre chauffeur sur 5 étoiles et laisser un commentaire. Votre note aide à améliorer la qualité du service.',
      category: 'Évaluation',
    ),
    FAQItem(
      question: 'Que faire en cas de problème pendant le trajet ?',
      answer: 'Utilisez le bouton SOS dans l\'application pour signaler une urgence. Vous pouvez également contacter le support 24/7 via le chat ou le téléphone.',
      category: 'Sécurité',
    ),
    FAQItem(
      question: 'Comment utiliser un code promo ?',
      answer: 'Allez dans la section "Promotions" de votre profil, entrez votre code promo ou sélectionnez-en un dans la liste, puis appliquez-le lors de votre prochaine réservation.',
      category: 'Promotions',
    ),
    FAQItem(
      question: 'Puis-je partager mon trajet avec quelqu\'un ?',
      answer: 'Oui, depuis l\'écran de suivi de trajet, vous pouvez partager votre position et votre ETA avec vos contacts via SMS ou d\'autres applications.',
      category: 'Partage',
    ),
    FAQItem(
      question: 'Comment recharger mon portefeuille ?',
      answer: 'Allez dans "Portefeuille", cliquez sur "Recharger" et choisissez votre moyen de paiement (carte bancaire ou mobile money).',
      category: 'Portefeuille',
    ),
  ];

  List<FAQItem> get _filteredFAQs {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _faqs;
    return _faqs.where((faq) {
      return faq.question.toLowerCase().contains(query) ||
          faq.answer.toLowerCase().contains(query) ||
          faq.category.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
            'Questions fréquentes',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Barre de recherche
              Padding(
                padding: const EdgeInsets.all(KoogweSpacing.lg),
                child: GlassCard(
                  borderRadius: KoogweRadius.mdRadius,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher une question...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
              ).animate().fadeIn().slideY(begin: -0.1, end: 0),

              // Liste des FAQ
              Expanded(
                child: _filteredFAQs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
                            ),
                            const SizedBox(height: KoogweSpacing.md),
                            Text(
                              'Aucun résultat',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: KoogweSpacing.lg),
                        itemCount: _filteredFAQs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: KoogweSpacing.sm),
                        itemBuilder: (context, index) {
                          final faq = _filteredFAQs[index];
                          final isExpanded = _expandedIndex == index;

                          return GlassCard(
                            borderRadius: KoogweRadius.lgRadius,
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ExpansionTile(
                                initiallyExpanded: isExpanded,
                                onExpansionChanged: (expanded) {
                                  setState(() {
                                    _expandedIndex = expanded ? index : null;
                                  });
                                },
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: KoogweColors.primary.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.help_outline,
                                    color: KoogweColors.primary,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  faq.question,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    faq.category,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: KoogweColors.primary,
                                    ),
                                  ),
                                ),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      KoogweSpacing.xl,
                                      0,
                                      KoogweSpacing.xl,
                                      KoogweSpacing.lg,
                                    ),
                                    child: Text(
                                      faq.answer,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: -0.1, end: 0);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  final String category;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}

