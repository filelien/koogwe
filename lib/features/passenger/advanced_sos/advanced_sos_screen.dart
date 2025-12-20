import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AdvancedSOSScreen extends StatefulWidget {
  const AdvancedSOSScreen({super.key});

  @override
  State<AdvancedSOSScreen> createState() => _AdvancedSOSScreenState();
}

class _AdvancedSOSScreenState extends State<AdvancedSOSScreen> {
  bool _sosActive = false;
  int _quickPressCount = 0;
  DateTime? _lastPressTime;

  void _handleQuickPress() {
    final now = DateTime.now();
    if (_lastPressTime == null || now.difference(_lastPressTime!) < const Duration(seconds: 2)) {
      _quickPressCount++;
      if (_quickPressCount >= 3) {
        _activateSOS();
        _quickPressCount = 0;
      }
    } else {
      _quickPressCount = 1;
    }
    _lastPressTime = now;
  }

  Future<void> _activateSOS() async {
    // Vibrer pour feedback haptique
    HapticFeedback.heavyImpact();
    
    // Confirmation silencieuse
    final confirm = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => _SOSConfirmationDialog(),
    );

    if (confirm == true) {
      setState(() => _sosActive = true);
      
      // Actions automatiques
      await _callEmergency();
      await _shareLocation();
      
      // Notification visuelle minimale
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Alerte SOS activée'),
              ],
            ),
            backgroundColor: KoogweColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _callEmergency() async {
    final phoneNumber = '112'; // Numéro d'urgence Guyane
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _shareLocation() async {
    // TODO: Partager la position GPS avec les contacts d'urgence
    // Envoyer notification push
    // Envoyer SMS aux contacts
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? KoogweColors.darkBackground : KoogweColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Bouton SOS discret (3 appuis rapides pour activer)
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: _handleQuickPress,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: _sosActive
                          ? KoogweColors.error.withValues(alpha: 0.2)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: _sosActive
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.emergency,
                                size: 64,
                                color: KoogweColors.error,
                              ),
                              const SizedBox(height: KoogweSpacing.md),
                              Text(
                                'SOS ACTIF',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: KoogweColors.error,
                                ),
                              ),
                            ],
                          )
                        : Icon(
                            Icons.circle_outlined,
                            size: 200,
                            color: isDark
                                ? KoogweColors.darkTextTertiary.withValues(alpha: 0.3)
                                : KoogweColors.lightTextTertiary.withValues(alpha: 0.3),
                          ),
                  ),
                ),
              ),
            ),

            // Actions rapides (visibles uniquement si SOS actif)
            if (_sosActive)
              Padding(
                padding: const EdgeInsets.all(KoogweSpacing.xl),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _QuickActionButton(
                          icon: Icons.phone,
                          label: 'Appel',
                          color: KoogweColors.error,
                          onTap: _callEmergency,
                        ),
                        _QuickActionButton(
                          icon: Icons.share_location,
                          label: 'Position',
                          color: KoogweColors.primary,
                          onTap: _shareLocation,
                        ),
                        _QuickActionButton(
                          icon: Icons.stop,
                          label: 'Arrêter',
                          color: KoogweColors.darkTextSecondary,
                          onTap: () {
                            setState(() => _sosActive = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('SOS désactivé')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SOSConfirmationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        decoration: BoxDecoration(
          color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
          borderRadius: KoogweRadius.lgRadius,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(KoogweSpacing.lg),
              decoration: BoxDecoration(
                color: KoogweColors.error.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.emergency,
                color: KoogweColors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: KoogweSpacing.lg),
            Text(
              'Activer l\'alerte SOS ?',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: KoogweSpacing.md),
            Text(
              'Les services d\'urgence et vos contacts seront notifiés',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: KoogweSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: KoogweSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: KoogweColors.error,
                    ),
                    child: const Text('Activer SOS'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
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
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: KoogweSpacing.xs),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

