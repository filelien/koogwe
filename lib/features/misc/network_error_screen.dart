import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';

class NetworkErrorScreen extends StatelessWidget {
  const NetworkErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(KoogweSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 64, color: KoogweColors.accent),
              const SizedBox(height: 16),
              Text('Problème de réseau', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Vérifiez votre connexion et réessayez.', textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  // Retourner à la page précédente ou rafraîchir
                  Navigator.of(context).pop();
                },
                child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
