import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

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
              Icon(Icons.build_circle, size: 64, color: KoogweColors.primary),
              const SizedBox(height: 16),
              Text('Maintenance en cours', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('KOOGWE revient très vite. Merci de votre patience.', textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
