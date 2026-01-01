import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientBackground(
      useDarkAurora: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Centre d\'aide',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(KoogweSpacing.lg),
            children: [
              // Options principales
              _HelpOption(
                icon: Icons.help_outline,
                title: 'Questions fréquentes',
                subtitle: 'Trouvez des réponses aux questions courantes',
                color: KoogweColors.primary,
                onTap: () => context.push('/passenger/faq'),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),

              const SizedBox(height: KoogweSpacing.md),

              _HelpOption(
                icon: Icons.chat_bubble_outline,
                title: 'Chat en direct',
                subtitle: 'Parlez avec notre équipe de support',
                color: KoogweColors.accent,
                onTap: () => context.push('/support/chatbot'),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: KoogweSpacing.md),

              _HelpOption(
                icon: Icons.phone_outlined,
                title: 'Appeler le support',
                subtitle: '+33 1 23 45 67 89',
                color: KoogweColors.success,
                onTap: () async {
                  final uri = Uri(scheme: 'tel', path: '+33123456789');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: KoogweSpacing.md),

              _HelpOption(
                icon: Icons.email_outlined,
                title: 'Envoyer un email',
                subtitle: 'support@koogwe.app',
                color: KoogweColors.secondary,
                onTap: () async {
                  final uri = Uri(
                    scheme: 'mailto',
                    path: 'support@koogwe.app',
                    queryParameters: {'subject': 'Demande d\'aide KOOGWE'},
                  );
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: KoogweSpacing.xl),

              // Section ressources
              Text(
                'Ressources',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: KoogweSpacing.md),

              _HelpOption(
                icon: Icons.video_library_outlined,
                title: 'Tutoriels vidéo',
                subtitle: 'Apprenez à utiliser KOOGWE',
                color: KoogweColors.primary,
                onTap: () {
                  // TODO: Ouvrir tutoriels
                },
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: KoogweSpacing.md),

              _HelpOption(
                icon: Icons.description_outlined,
                title: 'Guide d\'utilisation',
                subtitle: 'Documentation complète',
                color: KoogweColors.accent,
                onTap: () {
                  // TODO: Ouvrir guide
                },
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: KoogweSpacing.md),

              _HelpOption(
                icon: Icons.bug_report_outlined,
                title: 'Signaler un problème',
                subtitle: 'Aidez-nous à améliorer l\'application',
                color: KoogweColors.error,
                onTap: () {
                  // TODO: Ouvrir formulaire de signalement
                },
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _HelpOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      borderRadius: KoogweRadius.lgRadius,
      onTap: onTap,
      child: ListTile(
        contentPadding: const EdgeInsets.all(KoogweSpacing.md),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
        ),
      ),
    );
  }
}

