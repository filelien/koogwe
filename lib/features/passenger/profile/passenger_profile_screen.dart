import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/auth_provider.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:koogwe/core/router/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_assets.dart';

class PassengerProfileScreen extends ConsumerWidget {
  const PassengerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        children: [
          // Section Nouvelles fonctionnalités
          _ProfileSection(
            title: 'Fonctionnalités Premium',
            children: [
              ListTile(
                leading: Icon(Icons.schedule, color: KoogweColors.primary),
                title: const Text('Trajets planifiés'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push(AppRoutes.scheduledRide),
              ),
              ListTile(
                leading: Icon(Icons.handshake, color: KoogweColors.secondary),
                title: const Text('Prix transparent'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push(AppRoutes.priceNegotiation),
              ),
              ListTile(
                leading: Icon(Icons.air, color: KoogweColors.accent),
                title: const Text('Préférences confort'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push(AppRoutes.comfortPreferences),
              ),
              ListTile(
                leading: Icon(Icons.share_location, color: KoogweColors.success),
                title: const Text('Partage de position'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push(AppRoutes.shareLocation),
              ),
              ListTile(
                leading: Icon(Icons.star, color: KoogweColors.accent),
                title: const Text('Score & Réputation'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push(AppRoutes.reputation),
              ),
              ListTile(
                leading: Icon(Icons.support_agent, color: KoogweColors.error),
                title: const Text('Litiges & Support'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push(AppRoutes.disputes),
              ),
              ListTile(
                leading: Icon(Icons.card_membership, color: KoogweColors.primary),
                title: const Text('Abonnements & Pass'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push(AppRoutes.subscription),
              ),
              ListTile(
                leading: Icon(Icons.trending_up, color: KoogweColors.accent),
                title: const Text('Prix prédictif'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push(AppRoutes.predictivePricing),
              ),
              ListTile(
                leading: Icon(Icons.family_restroom, color: KoogweColors.primary),
                title: const Text('Mode Famille'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push(AppRoutes.familyMode),
              ),
              ListTile(
                leading: Icon(Icons.verified_user, color: KoogweColors.success),
                title: const Text('Vérification d\'identité'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push(AppRoutes.identityVerification),
              ),
              ListTile(
                leading: Icon(Icons.analytics, color: KoogweColors.secondary),
                title: const Text('Analyse de mobilité'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push(AppRoutes.mobilityAnalytics),
              ),
              ListTile(
                leading: Icon(Icons.eco, color: KoogweColors.success),
                title: const Text('Mode Éco-Trajet'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push(AppRoutes.ecoTrip),
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.lg),
          Container(
            decoration: BoxDecoration(
              color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
              borderRadius: KoogweRadius.lgRadius,
              border: Border.all(color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Notifications'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(AppRoutes.notifications),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Historique des trajets'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(AppRoutes.rideHistory),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: const Text('Destinations favorites'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(AppRoutes.favoritesDestinations),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.local_offer),
                  title: const Text('Promotions & Codes'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(AppRoutes.promotions),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('FAQ & Aide'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(AppRoutes.faq),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.add_location),
                  title: const Text('Trajet avec arrêts multiples'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(AppRoutes.multiStop),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.compare_arrows),
                  title: const Text('Comparaison de prix'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push('${AppRoutes.priceComparison}?pickup=&dropoff='),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Historique de recherche'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(AppRoutes.searchHistory),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.lightbulb_outline),
                  title: const Text('Suggestions intelligentes'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(AppRoutes.smartSuggestions),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.support_agent),
                  title: const Text('Centre d\'aide'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(AppRoutes.helpCenter),
                ),
              ],
            ),
          ),
          const SizedBox(height: KoogweSpacing.lg),
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: KoogweColors.primary.withValues(alpha: 0.15),
                child: ClipOval(
                  child: Image.asset(
                    AppAssets.appLogo,
                    width: 58,
                    height: 58,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.person, color: KoogweColors.primary, size: 32),
                  ),
                ),
              ),
              const SizedBox(width: KoogweSpacing.lg),
              Expanded(
                child: Builder(builder: (context) {
                  final auth = ref.watch(authProvider);
                  final name = auth.user?.fullName.isNotEmpty == true ? auth.user!.fullName : 'KOOGWE';
                  final email = auth.user?.email ?? '';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                      if (email.isNotEmpty)
                        Text(email, style: GoogleFonts.inter(color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary)),
                    ],
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.xxl),
          Container(
            decoration: BoxDecoration(
              color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
              borderRadius: KoogweRadius.lgRadius,
              border: Border.all(color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
            ),
          ),
          const SizedBox(height: KoogweSpacing.xxxl),
          KoogweButton(
            text: 'Se déconnecter',
            icon: Icons.logout,
            customColor: Colors.redAccent,
            isFullWidth: true,
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.homeHero);
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KoogweSpacing.md, vertical: KoogweSpacing.sm),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
            borderRadius: KoogweRadius.lgRadius,
            border: Border.all(color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) const Divider(height: 0),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
