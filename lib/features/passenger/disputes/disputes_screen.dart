import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/dispute_provider.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:koogwe/core/widgets/koogwe_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DisputesScreen extends ConsumerStatefulWidget {
  const DisputesScreen({super.key});

  @override
  ConsumerState<DisputesScreen> createState() => _DisputesScreenState();
}

class _DisputesScreenState extends ConsumerState<DisputesScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DisputeCategory _selectedCategory = DisputeCategory.price;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createDispute() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final success = await ref.read(disputeProvider.notifier).createDispute(
      category: _selectedCategory,
      title: _titleController.text,
      description: _descriptionController.text,
      rideId: 'ride_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (success && mounted) {
      _titleController.clear();
      _descriptionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Litige créé avec succès')),
      );
    }
  }

  Color _getStatusColor(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.pending:
        return KoogweColors.accent;
      case DisputeStatus.inReview:
        return KoogweColors.secondary;
      case DisputeStatus.resolved:
        return KoogweColors.success;
      case DisputeStatus.rejected:
        return KoogweColors.error;
    }
  }

  String _getStatusText(DisputeStatus status) {
    switch (status) {
      case DisputeStatus.pending:
        return 'En attente';
      case DisputeStatus.inReview:
        return 'En cours';
      case DisputeStatus.resolved:
        return 'Résolu';
      case DisputeStatus.rejected:
        return 'Rejeté';
    }
  }

  String _getCategoryText(DisputeCategory category) {
    switch (category) {
      case DisputeCategory.price:
        return 'Prix';
      case DisputeCategory.route:
        return 'Itinéraire';
      case DisputeCategory.driver:
        return 'Chauffeur';
      case DisputeCategory.vehicle:
        return 'Véhicule';
      case DisputeCategory.other:
        return 'Autre';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(disputeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Litiges & Support'),
        elevation: 0,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(KoogweSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Déclarer un problème',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                  const SizedBox(height: KoogweSpacing.md),
                  Text(
                    'Signalez un problème rencontré lors de votre trajet',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
                  const SizedBox(height: KoogweSpacing.xxxl),

                  // Catégorie
                  Text(
                    'Catégorie',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: KoogweSpacing.md),
                  Wrap(
                    spacing: KoogweSpacing.md,
                    runSpacing: KoogweSpacing.md,
                    children: DisputeCategory.values.map((category) {
                      final isSelected = _selectedCategory == category;
                      return FilterChip(
                        label: Text(_getCategoryText(category)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() => _selectedCategory = category);
                        },
                        selectedColor: KoogweColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: KoogweColors.primary,
                      );
                    }).toList(),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: KoogweSpacing.xl),

                  KoogweTextField(
                    controller: _titleController,
                    hint: 'Titre du litige',
                    prefixIcon: const Icon(Icons.title),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: KoogweSpacing.lg),

                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                      borderRadius: KoogweRadius.mdRadius,
                      border: Border.all(
                        color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                      ),
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Description détaillée du problème',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(KoogweSpacing.lg),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

                  const SizedBox(height: KoogweSpacing.xl),

                  KoogweButton(
                    text: 'Envoyer le litige',
                    icon: Icons.send,
                    onPressed: _createDispute,
                    isFullWidth: true,
                    size: ButtonSize.large,
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: KoogweSpacing.xxxl),

                  // Liste des litiges
                  if (state.disputes.isNotEmpty) ...[
                    Text(
                      'Mes litiges',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: KoogweSpacing.lg),
                    ...state.disputes.map((dispute) => _DisputeCard(
                          dispute: dispute,
                          statusColor: _getStatusColor(dispute.status),
                          statusText: _getStatusText(dispute.status),
                          categoryText: _getCategoryText(dispute.category),
                        )),
                  ],
                ],
              ),
            ),
    );
  }
}

class _DisputeCard extends StatelessWidget {
  final Dispute dispute;
  final Color statusColor;
  final String statusText;
  final String categoryText;

  const _DisputeCard({
    required this.dispute,
    required this.statusColor,
    required this.statusText,
    required this.categoryText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('d MMM yyyy', 'fr_FR');

    return Container(
      margin: const EdgeInsets.only(bottom: KoogweSpacing.md),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                categoryText,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.md),
          Text(
            dispute.title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: KoogweSpacing.sm),
          Text(
            dispute.description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: KoogweSpacing.md),
          Text(
            'Créé le ${dateFormat.format(dispute.createdAt)}',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
            ),
          ),
          if (dispute.resolution != null) ...[
            const SizedBox(height: KoogweSpacing.md),
            Container(
              padding: const EdgeInsets.all(KoogweSpacing.md),
              decoration: BoxDecoration(
                color: KoogweColors.success.withValues(alpha: 0.1),
                borderRadius: KoogweRadius.mdRadius,
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: KoogweColors.success, size: 20),
                  const SizedBox(width: KoogweSpacing.sm),
                  Expanded(
                    child: Text(
                      dispute.resolution!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: KoogweColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (dispute.refundAmount != null) ...[
            const SizedBox(height: KoogweSpacing.sm),
            Text(
              'Remboursement : ${dispute.refundAmount!.toStringAsFixed(2)}€',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: KoogweColors.success,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

