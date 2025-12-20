import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/providers/ride_provider.dart';
import 'package:koogwe/core/widgets/floating_sheet.dart';
import 'package:koogwe/core/constants/app_assets.dart';

class RideTrackingScreen extends ConsumerStatefulWidget {
  const RideTrackingScreen({super.key});

  @override
  ConsumerState<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends ConsumerState<RideTrackingScreen> {
  bool _sosActive = false;

  Future<void> _triggerSOS() async {
    // Confirmation avant d'activer le SOS
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => _SOSConfirmDialog(),
    );

    if (confirm == true && mounted) {
      setState(() => _sosActive = true);
      // TODO: Implémenter l'appel d'urgence réel
      // - Envoyer position GPS en temps réel
      // - Notifier les contacts d'urgence
      // - Contacter les services de secours
      // - Envoyer notification au chauffeur
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Alerte SOS activée. Vos contacts d\'urgence ont été notifiés.'),
          backgroundColor: KoogweColors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ride = ref.watch(rideProvider).current;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? KoogweColors.darkSurfaceVariant : KoogweColors.lightSurfaceVariant,
            ),
            child: const Center(child: Icon(Icons.map, size: 64)),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(KoogweSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    // Bouton SOS
                    Container(
                      decoration: BoxDecoration(
                        color: _sosActive ? KoogweColors.error : KoogweColors.error.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: _sosActive
                            ? [
                                BoxShadow(
                                  color: KoogweColors.error.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ]
                            : null,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _sosActive ? Icons.warning : Icons.emergency,
                          color: Colors.white,
                        ),
                        onPressed: _triggerSOS,
                        tooltip: 'Alerte SOS',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (ride != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: FloatingSheet(
                  padding: const EdgeInsets.all(KoogweSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: KoogweColors.primary.withValues(alpha: 0.1),
                            child: ClipOval(
                              child: Image.asset(
                                AppAssets.appLogo,
                                width: 56,
                                height: 56,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => Icon(Icons.person, size: 32, color: KoogweColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: KoogweSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ride.vehicleType,
                                  style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                                  ),
                                ),
                                Text(
                                  '${ride.pickup} → ${ride.dropoff}',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.star, size: 16, color: KoogweColors.accent),
                                    Text(' 4.9 (234 courses)', style: GoogleFonts.inter(fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              // TODO: Obtenir le numéro du chauffeur depuis le provider de course
                              final phoneNumber = '+594694123456'; // Numéro de test
                              // TODO: Utiliser url_launcher pour l'appel réel
                              // final uri = Uri(scheme: 'tel', path: phoneNumber);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Appel vers $phoneNumber')),
                              );
                            },
                            icon: Icon(Icons.phone, color: KoogweColors.primary),
                          ),
                          IconButton(
                            onPressed: () async {
                              // TODO: Obtenir le numéro du chauffeur depuis le provider de course
                              final phoneNumber = '+594694123456'; // Numéro de test
                              // TODO: Utiliser url_launcher pour l'envoi réel
                              // final uri = Uri(scheme: 'sms', path: phoneNumber);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Message vers $phoneNumber')),
                              );
                            },
                            icon: Icon(Icons.message, color: KoogweColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: KoogweSpacing.xl),
                      Container(
                        padding: const EdgeInsets.all(KoogweSpacing.lg),
                        decoration: BoxDecoration(
                          color: isDark ? KoogweColors.darkSurfaceVariant : KoogweColors.lightSurfaceVariant,
                          borderRadius: KoogweRadius.lgRadius,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(children: [
                              Text('5 min', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: KoogweColors.primary)),
                              Text('Arrivée', style: GoogleFonts.inter(fontSize: 12)),
                            ]),
                            Container(width: 1, height: 32, color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
                            Column(children: [
                              Text('3.2 km', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: KoogweColors.primary)),
                              Text('Distance', style: GoogleFonts.inter(fontSize: 12)),
                            ]),
                          ],
                        ),
                      ),
                      const SizedBox(height: KoogweSpacing.lg),
                      KoogweButton(
                        text: 'Annuler la course',
                        onPressed: () async {
                          await ref.read(rideProvider.notifier).cancelCurrentRide();
                          if (context.mounted) context.pop();
                        },
                        isFullWidth: true,
                        variant: ButtonVariant.outline,
                        customColor: KoogweColors.error,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Dialogue de confirmation pour le bouton SOS
class _SOSConfirmDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: KoogweRadius.lgRadius),
      title: Row(
        children: [
          Icon(Icons.emergency, color: KoogweColors.error, size: 28),
          const SizedBox(width: KoogweSpacing.md),
          Text(
            'Alerte SOS',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: KoogweColors.error,
            ),
          ),
        ],
      ),
      content: Text(
        'Voulez-vous activer l\'alerte SOS ? Vos contacts d\'urgence et les services de secours seront notifiés de votre position.',
        style: GoogleFonts.inter(
          fontSize: 14,
          color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Annuler',
            style: GoogleFonts.inter(color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: KoogweColors.error,
          ),
          child: const Text('Activer SOS'),
        ),
      ],
    );
  }
}
