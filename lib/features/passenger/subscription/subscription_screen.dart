import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/subscription_provider.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:google_fonts/google_fonts.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(subscriptionProvider);
    final notifier = ref.read(subscriptionProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Abonnements & Pass'),
        elevation: 0,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(KoogweSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.currentSubscription != null && state.currentSubscription!.isActive) ...[
                    _CurrentSubscriptionCard(
                      subscription: state.currentSubscription!,
                    ).animate().fadeIn().scale(),
                    const SizedBox(height: KoogweSpacing.xxxl),
                  ],
                  
                  Text(
                    'Plans disponibles',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
                  const SizedBox(height: KoogweSpacing.lg),
                  
                  ...state.availablePlans.map((plan) => _SubscriptionPlanCard(
                    plan: plan,
                    isCurrent: state.currentSubscription?.id == plan.id,
                    onSubscribe: () async {
                      await notifier.subscribe(plan.type);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Abonnement activé avec succès !')),
                        );
                      }
                    },
                  )),
                ],
              ),
            ),
    );
  }
}

class _CurrentSubscriptionCard extends StatelessWidget {
  final Subscription subscription;

  const _CurrentSubscriptionCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KoogweSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [KoogweColors.primary, KoogweColors.primaryDark],
        ),
        borderRadius: KoogweRadius.lgRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Votre Pass Actif',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  subscription.type == SubscriptionType.weekly
                      ? 'Hebdomadaire'
                      : subscription.type == SubscriptionType.monthly
                          ? 'Mensuel'
                          : 'Annuel',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.lg),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${subscription.ridesUsed} / ${subscription.ridesLimit}',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Trajets utilisés',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${subscription.daysRemaining} jours',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Restants',
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
          const SizedBox(height: KoogweSpacing.lg),
          Container(
            padding: const EdgeInsets.all(KoogweSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: KoogweRadius.mdRadius,
            ),
            child: Row(
              children: [
                Icon(Icons.savings, color: Colors.white, size: 20),
                const SizedBox(width: KoogweSpacing.sm),
                Text(
                  'Économies : ${subscription.savings.toStringAsFixed(2)}€',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionPlanCard extends StatelessWidget {
  final Subscription plan;
  final bool isCurrent;
  final VoidCallback onSubscribe;

  const _SubscriptionPlanCard({
    required this.plan,
    required this.isCurrent,
    required this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: KoogweSpacing.lg),
      padding: const EdgeInsets.all(KoogweSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
        borderRadius: KoogweRadius.lgRadius,
        border: Border.all(
          color: isCurrent
              ? KoogweColors.primary
              : (isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.type == SubscriptionType.weekly
                        ? 'Pass Hebdomadaire'
                        : plan.type == SubscriptionType.monthly
                            ? 'Pass Mensuel'
                            : 'Pass Annuel',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${plan.ridesLimit} trajets inclus',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: KoogweColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Actif',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: KoogweColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.lg),
          Row(
            children: [
              Text(
                '${plan.price.toStringAsFixed(2)}€',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: KoogweColors.primary,
                ),
              ),
              const SizedBox(width: KoogweSpacing.sm),
              Text(
                '/ ${plan.type == SubscriptionType.weekly ? "semaine" : plan.type == SubscriptionType.monthly ? "mois" : "an"}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.md),
          Container(
            padding: const EdgeInsets.all(KoogweSpacing.md),
            decoration: BoxDecoration(
              color: KoogweColors.primary.withValues(alpha: 0.1),
              borderRadius: KoogweRadius.mdRadius,
            ),
            child: Row(
              children: [
                Icon(Icons.local_offer, color: KoogweColors.primary, size: 20),
                const SizedBox(width: KoogweSpacing.sm),
                Text(
                  'Réduction ${plan.discountPercentage.toStringAsFixed(0)}% sur tous les trajets',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: KoogweColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: KoogweSpacing.lg),
          KoogweButton(
            text: isCurrent ? 'Abonnement actif' : 'S\'abonner',
            icon: isCurrent ? Icons.check_circle : Icons.arrow_forward,
            onPressed: isCurrent ? null : onSubscribe,
            isFullWidth: true,
            variant: isCurrent ? ButtonVariant.outline : ButtonVariant.gradient,
          ),
        ],
      ),
    );
  }
}

