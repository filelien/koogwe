import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/service_type_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceSelectionScreen extends ConsumerWidget {
  const ServiceSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedService = ref.watch(serviceTypeProvider).selectedService;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Services KOOGWE'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choisissez votre service',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ).animate().fadeIn().slideX(begin: -0.2, end: 0),
            const SizedBox(height: KoogweSpacing.md),
            Text(
              'KOOGWE propose plusieurs services pour répondre à tous vos besoins',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
              ),
            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
            const SizedBox(height: KoogweSpacing.xxxl),
            
            _ServiceCard(
              icon: Icons.directions_car,
              title: 'Transport de personnes',
              description: 'Courses VTC, covoiturage et transport classique',
              color: KoogweColors.primary,
              isSelected: selectedService == ServiceType.passengerTransport,
              onTap: () {
                ref.read(serviceTypeProvider.notifier).setServiceType(ServiceType.passengerTransport);
                context.pop();
              },
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: KoogweSpacing.lg),
            
            _ServiceCard(
              icon: Icons.local_shipping,
              title: 'Livraison de colis',
              description: 'Livrez et récupérez des colis rapidement',
              color: KoogweColors.secondary,
              isSelected: selectedService == ServiceType.packageDelivery,
              onTap: () {
                ref.read(serviceTypeProvider.notifier).setServiceType(ServiceType.packageDelivery);
                context.pop();
              },
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: KoogweSpacing.lg),
            
            _ServiceCard(
              icon: Icons.flash_on,
              title: 'Courses rapides',
              description: 'Livraison express de courses et achats',
              color: KoogweColors.accent,
              isSelected: selectedService == ServiceType.quickDelivery,
              onTap: () {
                ref.read(serviceTypeProvider.notifier).setServiceType(ServiceType.quickDelivery);
                context.pop();
              },
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: KoogweSpacing.lg),
            
            _ServiceCard(
              icon: Icons.business_center,
              title: 'Transport entreprise',
              description: 'Gestion des déplacements professionnels',
              color: KoogweColors.success,
              isSelected: selectedService == ServiceType.businessTransport,
              onTap: () {
                ref.read(serviceTypeProvider.notifier).setServiceType(ServiceType.businessTransport);
                context.pop();
              },
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: KoogweRadius.lgRadius,
      child: Container(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : (isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface),
          borderRadius: KoogweRadius.lgRadius,
          border: Border.all(
            color: isSelected ? color : (isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(KoogweSpacing.lg),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: KoogweSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 28),
          ],
        ),
      ),
    );
  }
}

