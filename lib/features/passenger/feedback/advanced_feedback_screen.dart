import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class AdvancedFeedbackScreen extends StatefulWidget {
  final String rideId;
  final String driverName;
  final double ridePrice;

  const AdvancedFeedbackScreen({
    super.key,
    required this.rideId,
    required this.driverName,
    required this.ridePrice,
  });

  @override
  State<AdvancedFeedbackScreen> createState() => _AdvancedFeedbackScreenState();
}

class _AdvancedFeedbackScreenState extends State<AdvancedFeedbackScreen> {
  double _overallRating = 5.0;
  double _cleanlinessRating = 5.0;
  double _safetyRating = 5.0;
  double _punctualityRating = 5.0;
  double _courtesyRating = 5.0;
  final Map<String, bool> _quickFeedback = {};
  final _commentController = TextEditingController();
  bool _isSatisfied = true;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    // Détecter l'insatisfaction
    if (_overallRating < 3 || _isSatisfied == false) {
      // Afficher lien support direct
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Besoin d\'aide ?'),
            content: const Text('Nous sommes désolés pour cette expérience. Notre équipe va vous contacter rapidement.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/passenger/disputes');
                },
                child: const Text('Contacter le support'),
              ),
            ],
          ),
        );
      }
    }

    // TODO: Envoyer le feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci pour votre évaluation !')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Évaluer votre trajet'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(KoogweSpacing.xl),
                    decoration: BoxDecoration(
                      color: KoogweColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star,
                      size: 48,
                      color: KoogweColors.primary,
                    ),
                  ),
                  const SizedBox(height: KoogweSpacing.lg),
                  Text(
                    'Comment s\'est passé votre trajet ?',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: KoogweSpacing.sm),
                  Text(
                    'Avec ${widget.driverName}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().scale(),

            const SizedBox(height: KoogweSpacing.xxxl),

            // Évaluation globale
            _RatingSection(
              title: 'Note globale',
              rating: _overallRating,
              onRatingChanged: (rating) => setState(() => _overallRating = rating),
              icon: Icons.star,
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: KoogweSpacing.xl),

            // Évaluations détaillées
            Text(
              'Détails de l\'expérience',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: KoogweSpacing.lg),

            _RatingSection(
              title: 'Propreté',
              rating: _cleanlinessRating,
              onRatingChanged: (rating) => setState(() => _cleanlinessRating = rating),
              icon: Icons.cleaning_services,
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: KoogweSpacing.md),

            _RatingSection(
              title: 'Sécurité',
              rating: _safetyRating,
              onRatingChanged: (rating) => setState(() => _safetyRating = rating),
              icon: Icons.security,
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: KoogweSpacing.md),

            _RatingSection(
              title: 'Ponctualité',
              rating: _punctualityRating,
              onRatingChanged: (rating) => setState(() => _punctualityRating = rating),
              icon: Icons.schedule,
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: KoogweSpacing.md),

            _RatingSection(
              title: 'Courtoisie',
              rating: _courtesyRating,
              onRatingChanged: (rating) => setState(() => _courtesyRating = rating),
              icon: Icons.people,
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: KoogweSpacing.xxxl),

            // Feedback rapide
            Text(
              'Feedback rapide',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: KoogweSpacing.md),
            Wrap(
              spacing: KoogweSpacing.sm,
              runSpacing: KoogweSpacing.sm,
              children: [
                'Conduite douce',
                'Véhicule propre',
                'Bonne conversation',
                'Wi-Fi fonctionnel',
                'Climatisation parfaite',
              ].map((option) {
                final isSelected = _quickFeedback[option] ?? false;
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _quickFeedback[option] = selected);
                  },
                  selectedColor: KoogweColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: KoogweColors.primary,
                );
              }).toList(),
            ).animate().fadeIn(delay: 700.ms),

            const SizedBox(height: KoogweSpacing.xl),

            // Commentaire
            Text(
              'Commentaire (optionnel)',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: KoogweSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                borderRadius: KoogweRadius.mdRadius,
                border: Border.all(
                  color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                ),
              ),
              child: TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Partagez votre expérience...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(KoogweSpacing.lg),
                ),
              ),
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: KoogweSpacing.xxxl),

            // Satisfaction globale
            Row(
              children: [
                Expanded(
                  child: _SatisfactionButton(
                    label: 'Satisfait',
                    icon: Icons.thumb_up,
                    isSelected: _isSatisfied,
                    color: KoogweColors.success,
                    onTap: () => setState(() => _isSatisfied = true),
                  ),
                ),
                const SizedBox(width: KoogweSpacing.md),
                Expanded(
                  child: _SatisfactionButton(
                    label: 'Insatisfait',
                    icon: Icons.thumb_down,
                    isSelected: !_isSatisfied,
                    color: KoogweColors.error,
                    onTap: () => setState(() => _isSatisfied = false),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: KoogweSpacing.xxxl),

            KoogweButton(
              text: 'Envoyer l\'évaluation',
              icon: Icons.send,
              onPressed: _submitFeedback,
              isFullWidth: true,
              size: ButtonSize.large,
              variant: ButtonVariant.gradient,
            ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  final String title;
  final double rating;
  final Function(double) onRatingChanged;
  final IconData icon;

  const _RatingSection({
    required this.title,
    required this.rating,
    required this.onRatingChanged,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
        borderRadius: KoogweRadius.mdRadius,
        border: Border.all(
          color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: KoogweColors.primary, size: 24),
          const SizedBox(width: KoogweSpacing.md),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ),
          ),
          RatingBar.builder(
            initialRating: rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 28,
            itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: KoogweColors.accent,
            ),
            onRatingUpdate: onRatingChanged,
          ),
        ],
      ),
    );
  }
}

class _SatisfactionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _SatisfactionButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: KoogweRadius.mdRadius,
      child: Container(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : (isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface),
          borderRadius: KoogweRadius.mdRadius,
          border: Border.all(
            color: isSelected ? color : (isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : KoogweColors.darkTextSecondary, size: 24),
            const SizedBox(width: KoogweSpacing.sm),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : (isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

