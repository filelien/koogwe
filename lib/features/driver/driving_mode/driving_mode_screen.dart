import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:google_fonts/google_fonts.dart';

class DrivingModeScreen extends StatefulWidget {
  const DrivingModeScreen({super.key});

  @override
  State<DrivingModeScreen> createState() => _DrivingModeScreenState();
}

class _DrivingModeScreenState extends State<DrivingModeScreen> {
  bool _isOnline = false;
  String _currentStatus = 'Hors ligne';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? KoogweColors.darkBackground : KoogweColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header simplifié
            Padding(
              padding: const EdgeInsets.all(KoogweSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 32),
                    onPressed: () => context.pop(),
                    color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                  ),
                  Text(
                    'Mode Conduite',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance
                ],
              ),
            ),
            
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Indicateur de statut
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: _isOnline
                            ? KoogweColors.success.withValues(alpha: 0.2)
                            : KoogweColors.darkTextTertiary.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isOnline ? Icons.directions_car : Icons.car_repair,
                        size: 64,
                        color: _isOnline ? KoogweColors.success : KoogweColors.darkTextTertiary,
                      ),
                    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                    
                    const SizedBox(height: KoogweSpacing.xxxl),
                    
                    Text(
                      _currentStatus,
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    
                    const SizedBox(height: KoogweSpacing.xl),
                    
                    // Informations importantes
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: KoogweSpacing.xxl),
                      padding: const EdgeInsets.all(KoogweSpacing.xl),
                      decoration: BoxDecoration(
                        color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                        borderRadius: KoogweRadius.lgRadius,
                      ),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.location_on,
                            label: 'Position',
                            value: 'Enregistrée',
                            color: KoogweColors.success,
                          ),
                          const SizedBox(height: KoogweSpacing.lg),
                          _InfoRow(
                            icon: Icons.battery_full,
                            label: 'Batterie',
                            value: '85%',
                            color: KoogweColors.success,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
                    
                    const SizedBox(height: KoogweSpacing.xxxl),
                    
                    // Bouton principal - GROS et SIMPLE
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            _isOnline = !_isOnline;
                            _currentStatus = _isOnline ? 'En ligne' : 'Hors ligne';
                          });
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: _isOnline ? KoogweColors.error : KoogweColors.success,
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isOnline ? Icons.stop : Icons.play_arrow,
                              size: 80,
                              color: Colors.white,
                            ),
                            const SizedBox(height: KoogweSpacing.md),
                            Text(
                              _isOnline ? 'Arrêter' : 'Démarrer',
                              style: GoogleFonts.inter(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().scale(delay: 600.ms, duration: 400.ms, curve: Curves.easeOutBack),
                  ],
                ),
              ),
            ),
            
            // Actions rapides
            Padding(
              padding: const EdgeInsets.all(KoogweSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _QuickActionButton(
                    icon: Icons.navigation,
                    label: 'Navigation',
                    onTap: () async {
                      // Simuler l'ouverture de l'application de navigation
                      // TODO: Intégrer avec Google Maps / Waze via url_launcher
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigation - Bientôt disponible')),
                      );
                    },
                  ),
                  _QuickActionButton(
                    icon: Icons.phone,
                    label: 'Appel',
                    onTap: () async {
                      // Simuler un appel
                      // TODO: Obtenir le numéro du passager depuis le provider de course
                      final phoneNumber = '+594694123456'; // Numéro de test
                      // TODO: Utiliser url_launcher pour l'appel réel
                      // final uri = Uri(scheme: 'tel', path: phoneNumber);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Appel vers $phoneNumber')),
                      );
                    },
                  ),
                  _QuickActionButton(
                    icon: Icons.message,
                    label: 'Message',
                    onTap: () async {
                      // Simuler l'envoi d'un message
                      // TODO: Obtenir le numéro du passager depuis le provider de course
                      final phoneNumber = '+594694123456'; // Numéro de test
                      // TODO: Utiliser url_launcher pour l'envoi réel
                      // final uri = Uri(scheme: 'sms', path: phoneNumber);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Message vers $phoneNumber')),
                      );
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: KoogweSpacing.md),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: KoogweRadius.fullRadius,
      child: Container(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: KoogweColors.primary),
            const SizedBox(height: KoogweSpacing.xs),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

