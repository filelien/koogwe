import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/share_location_provider.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class ShareLocationScreen extends ConsumerWidget {
  const ShareLocationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(shareLocationProvider);
    final notifier = ref.read(shareLocationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partage de position'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Partagez votre trajet en temps réel',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ).animate().fadeIn().slideX(begin: -0.2, end: 0),
            const SizedBox(height: KoogweSpacing.md),
            Text(
              'Vos proches pourront suivre votre position en temps réel',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
              ),
            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
            const SizedBox(height: KoogweSpacing.xxxl),
            
            // Indicateur de partage
            Container(
              padding: const EdgeInsets.all(KoogweSpacing.xl),
              decoration: BoxDecoration(
                color: state.isSharing
                    ? KoogweColors.success.withValues(alpha: 0.1)
                    : (isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface),
                borderRadius: KoogweRadius.lgRadius,
                border: Border.all(
                  color: state.isSharing
                      ? KoogweColors.success
                      : (isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
                  width: state.isSharing ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    state.isSharing ? Icons.location_on : Icons.location_off,
                    size: 48,
                    color: state.isSharing ? KoogweColors.success : KoogweColors.darkTextTertiary,
                  ),
                  const SizedBox(height: KoogweSpacing.md),
                  Text(
                    state.isSharing ? 'Partage actif' : 'Partage inactif',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  if (state.isSharing && state.shareLink != null) ...[
                    const SizedBox(height: KoogweSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(KoogweSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark ? KoogweColors.darkBackground : KoogweColors.lightBackground,
                        borderRadius: KoogweRadius.mdRadius,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              state.shareLink!,
                              style: GoogleFonts.inter(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 20),
                            onPressed: () {
                              if (state.shareLink != null) {
                                Clipboard.setData(ClipboardData(text: state.shareLink!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Lien copié dans le presse-papiers')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).scale(),
            
            const SizedBox(height: KoogweSpacing.xl),
            
            // Bouton de contrôle
            KoogweButton(
              text: state.isSharing ? 'Arrêter le partage' : 'Démarrer le partage',
              icon: state.isSharing ? Icons.stop : Icons.share_location,
              onPressed: state.isLoading
                  ? null
                  : () async {
                      if (state.isSharing) {
                        await notifier.stopSharing();
                      } else {
                        final link = await notifier.startSharing();
                        // Partager le lien
                        await SharePlus.instance.share(
                          ShareParams(
                            text: 'Suivez ma position en temps réel sur KOOGWE : $link',
                          ),
                        );
                      }
                    },
              isFullWidth: true,
              size: ButtonSize.large,
              isLoading: state.isLoading,
              variant: state.isSharing ? ButtonVariant.outline : ButtonVariant.gradient,
              customColor: state.isSharing ? KoogweColors.error : null,
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: KoogweSpacing.xxxl),
            
            // Liste des contacts
            Text(
              'Contacts',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: KoogweSpacing.lg),
            ...state.contacts.map((contact) => _ContactCard(
              contact: contact,
              onShare: () => notifier.shareWithContact(contact.id),
              onRemove: () => notifier.removeContact(contact.id),
            )),
            
            const SizedBox(height: KoogweSpacing.xl),
            
            KoogweButton(
              text: 'Ajouter un contact',
              icon: Icons.person_add,
              onPressed: () {
                // TODO: Ouvrir dialogue d'ajout de contact
              },
              isFullWidth: true,
              variant: ButtonVariant.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final SharedContact contact;
  final VoidCallback onShare;
  final VoidCallback onRemove;

  const _ContactCard({
    required this.contact,
    required this.onShare,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: KoogweSpacing.md),
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
        borderRadius: KoogweRadius.lgRadius,
        border: Border.all(
          color: contact.isActive
              ? KoogweColors.success
              : (isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
          width: contact.isActive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: KoogweColors.primary.withValues(alpha: 0.1),
            child: Text(
              contact.name[0].toUpperCase(),
              style: GoogleFonts.inter(
                color: KoogweColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: KoogweSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                  ),
                ),
                Text(
                  contact.phone,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                  ),
                ),
                if (contact.isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: KoogweColors.success.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Suivi actif',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: KoogweColors.success,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!contact.isActive)
            IconButton(
              icon: Icon(Icons.share, color: KoogweColors.primary),
              onPressed: onShare,
            ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: KoogweColors.error),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

