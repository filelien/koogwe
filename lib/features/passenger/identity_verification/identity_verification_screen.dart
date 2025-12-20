import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/identity_verification_provider.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class IdentityVerificationScreen extends ConsumerWidget {
  const IdentityVerificationScreen({super.key});

  String _getStepName(VerificationStep step) {
    switch (step) {
      case VerificationStep.identity:
        return 'Identité';
      case VerificationStep.selfie:
        return 'Photo selfie';
      case VerificationStep.documents:
        return 'Documents';
      case VerificationStep.background:
        return 'Vérification de fond';
      case VerificationStep.completed:
        return 'Terminé';
    }
  }

  String _getStepDescription(VerificationStep step) {
    switch (step) {
      case VerificationStep.identity:
        return 'Carte d\'identité ou passeport';
      case VerificationStep.selfie:
        return 'Photo de votre visage pour vérification';
      case VerificationStep.documents:
        return 'Documents supplémentaires requis';
      case VerificationStep.background:
        return 'Vérification de vos antécédents';
      case VerificationStep.completed:
        return 'Vérification complète';
    }
  }

  IconData _getStepIcon(VerificationStep step) {
    switch (step) {
      case VerificationStep.identity:
        return Icons.badge;
      case VerificationStep.selfie:
        return Icons.face;
      case VerificationStep.documents:
        return Icons.description;
      case VerificationStep.background:
        return Icons.security;
      case VerificationStep.completed:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(identityVerificationProvider);
    final notifier = ref.read(identityVerificationProvider.notifier);

    if (state.verification == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Vérification d\'identité')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final verification = state.verification!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification d\'identité'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge de vérification
            if (verification.isVerified)
              Container(
                padding: const EdgeInsets.all(KoogweSpacing.xl),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [KoogweColors.success, KoogweColors.success.withValues(alpha: 0.8)],
                  ),
                  borderRadius: KoogweRadius.lgRadius,
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified, color: Colors.white, size: 48),
                    const SizedBox(width: KoogweSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profil Vérifié',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Votre identité a été vérifiée avec succès',
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
              ).animate().fadeIn().scale()
            else ...[
              // Indicateur de progression
              Container(
                padding: const EdgeInsets.all(KoogweSpacing.xl),
                decoration: BoxDecoration(
                  color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                  borderRadius: KoogweRadius.lgRadius,
                  border: Border.all(
                    color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Progression de vérification',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: KoogweSpacing.lg),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: verification.progress / 100,
                            strokeWidth: 12,
                            backgroundColor: isDark
                                ? KoogweColors.darkSurfaceVariant
                                : KoogweColors.lightSurfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(KoogweColors.primary),
                          ),
                        ),
                        Text(
                          '${verification.progress.toInt()}%',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: KoogweColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: KoogweSpacing.md),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(verification.status).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(verification.status),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: _getStatusColor(verification.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().scale(),
            ],

            const SizedBox(height: KoogweSpacing.xxxl),

            Text(
              'Étapes de vérification',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
            const SizedBox(height: KoogweSpacing.lg),

            ...verification.steps.map((stepData) {
              final index = verification.steps.indexOf(stepData);
              return _VerificationStepCard(
                step: stepData.step,
                stepName: _getStepName(stepData.step),
                stepDescription: _getStepDescription(stepData.step),
                stepIcon: _getStepIcon(stepData.step),
                isCompleted: stepData.isCompleted,
                onUpload: () => _uploadStep(context, ref, stepData.step),
              ).animate()
                  .fadeIn(delay: Duration(milliseconds: 300 + (index * 100)))
                  .slideY(begin: 0.1, end: 0);
            }),

            if (verification.progress == 100 && !verification.isVerified) ...[
              const SizedBox(height: KoogweSpacing.xxxl),
              KoogweButton(
                text: 'Finaliser la vérification',
                icon: Icons.check_circle,
                onPressed: () async {
                  await notifier.completeVerification();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vérification terminée ! Badge activé.')),
                    );
                  }
                },
                isFullWidth: true,
                size: ButtonSize.large,
                variant: ButtonVariant.gradient,
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _uploadStep(
    BuildContext context,
    WidgetRef ref,
    VerificationStep step,
  ) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      await ref.read(identityVerificationProvider.notifier).uploadDocument(step, image.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploadé avec succès')),
        );
      }
    }
  }

  Color _getStatusColor(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return KoogweColors.success;
      case VerificationStatus.rejected:
        return KoogweColors.error;
      case VerificationStatus.pending:
        return KoogweColors.accent;
      default:
        return KoogweColors.primary;
    }
  }

  String _getStatusText(VerificationStatus status) {
    switch (status) {
      case VerificationStatus.verified:
        return 'Vérifié';
      case VerificationStatus.rejected:
        return 'Refusé';
      case VerificationStatus.pending:
        return 'En attente de validation';
      case VerificationStatus.inProgress:
        return 'En cours';
      default:
        return 'Non commencé';
    }
  }
}

class _VerificationStepCard extends StatelessWidget {
  final VerificationStep step;
  final String stepName;
  final String stepDescription;
  final IconData stepIcon;
  final bool isCompleted;
  final VoidCallback onUpload;

  const _VerificationStepCard({
    required this.step,
    required this.stepName,
    required this.stepDescription,
    required this.stepIcon,
    required this.isCompleted,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: KoogweSpacing.md),
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      decoration: BoxDecoration(
        color: isCompleted
            ? KoogweColors.success.withValues(alpha: 0.1)
            : (isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface),
        borderRadius: KoogweRadius.lgRadius,
        border: Border.all(
          color: isCompleted
              ? KoogweColors.success
              : (isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(KoogweSpacing.md),
            decoration: BoxDecoration(
              color: isCompleted
                  ? KoogweColors.success.withValues(alpha: 0.2)
                  : KoogweColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check_circle : stepIcon,
              color: isCompleted ? KoogweColors.success : KoogweColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: KoogweSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stepName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                  ),
                ),
                Text(
                  stepDescription,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!isCompleted)
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: onUpload,
              color: KoogweColors.primary,
            )
          else
            Icon(Icons.check_circle, color: KoogweColors.success, size: 28),
        ],
      ),
    );
  }
}

