import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ShareETAScreen extends ConsumerStatefulWidget {
  final String? rideId;
  final String? pickup;
  final String? dropoff;
  final String? eta;

  const ShareETAScreen({
    super.key,
    this.rideId,
    this.pickup,
    this.dropoff,
    this.eta,
  });

  @override
  ConsumerState<ShareETAScreen> createState() => _ShareETAScreenState();
}

class _ShareETAScreenState extends ConsumerState<ShareETAScreen> {
  final List<Contact> _contacts = [
    Contact(id: '1', name: 'Marie Dupont', phone: '+33612345678', avatar: 'M'),
    Contact(id: '2', name: 'Jean Martin', phone: '+33687654321', avatar: 'J'),
    Contact(id: '3', name: 'Sophie Bernard', phone: '+33611223344', avatar: 'S'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pickup = widget.pickup ?? 'Adresse de départ';
    final dropoff = widget.dropoff ?? 'Adresse de destination';
    final eta = widget.eta ?? '10 min';

    return GradientBackground(
      useDarkAurora: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Partager mon ETA',
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
              // Aperçu du message
              GlassCard(
                borderRadius: KoogweRadius.lgRadius,
                child: Padding(
                  padding: const EdgeInsets.all(KoogweSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aperçu du message',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: KoogweSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(KoogweSpacing.md),
                        decoration: BoxDecoration(
                          color: (isDark ? KoogweColors.darkSurfaceVariant : KoogweColors.lightSurfaceVariant)
                              .withValues(alpha: 0.5),
                          borderRadius: KoogweRadius.mdRadius,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Je serai à destination dans $eta',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                              ),
                            ),
                            const SizedBox(height: KoogweSpacing.sm),
                            Text(
                              'De: $pickup',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                              ),
                            ),
                            Text(
                              'Vers: $dropoff',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),

              const SizedBox(height: KoogweSpacing.xl),

              // Contacts récents
              Text(
                'Partager avec',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: KoogweSpacing.md),

              ..._contacts.map((contact) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: KoogweSpacing.sm),
                  child: GlassCard(
                    borderRadius: KoogweRadius.mdRadius,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: KoogweColors.primary,
                        child: Text(
                          contact.avatar,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                      title: Text(
                        contact.name,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                        ),
                      ),
                      subtitle: Text(contact.phone),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.sms),
                            onPressed: () => _shareViaSMS(contact.phone),
                            color: KoogweColors.primary,
                          ),
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () => _shareViaApp(contact.name),
                            color: KoogweColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: KoogweSpacing.md),

              // Boutons de partage généraux
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareViaSMS(null),
                      icon: const Icon(Icons.sms),
                      label: const Text('SMS'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: KoogweSpacing.md),
                      ),
                    ),
                  ),
                  const SizedBox(width: KoogweSpacing.md),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareViaApp(null),
                      icon: const Icon(Icons.share),
                      label: const Text('Partager'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: KoogweSpacing.md),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareViaSMS(String? phone) {
    final message = 'Je serai à destination dans ${widget.eta ?? '10 min'}. De: ${widget.pickup ?? ''} Vers: ${widget.dropoff ?? ''}';
    final uri = phone != null
        ? Uri(scheme: 'sms', path: phone, queryParameters: {'body': message})
        : Uri(scheme: 'sms', queryParameters: {'body': message});

    launchUrl(uri);
  }

  Future<void> _shareViaApp(String? contactName) async {
    final message = 'Je serai à destination dans ${widget.eta ?? '10 min'}\nDe: ${widget.pickup ?? ''}\nVers: ${widget.dropoff ?? ''}';
    await SharePlus.instance.share(ShareParams(
      text: message,
      subject: contactName != null ? 'ETA pour $contactName' : 'Mon ETA KOOGWE',
    ));
  }
}

class Contact {
  final String id;
  final String name;
  final String phone;
  final String avatar;

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.avatar,
  });
}

