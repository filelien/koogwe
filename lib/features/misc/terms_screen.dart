import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_spacing.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conditions & Confidentialité')),
      body: Padding(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        child: ListView(
          children: [
            Text('Conditions d’utilisation', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            const Text('1. Objet...\n2. Utilisation...\n3. Données...'),
            const SizedBox(height: 24),
            Text('Politique de confidentialité', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            const Text('Nous respectons votre vie privée...'),
          ],
        ),
      ),
    );
  }
}
