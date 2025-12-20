import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/network_status_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class NetworkStatusBanner extends ConsumerWidget {
  const NetworkStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkState = ref.watch(networkStatusProvider);
    
    // Afficher uniquement si hors ligne ou connexion faible
    if (networkState.status == NetworkStatus.online) {
      return const SizedBox.shrink();
    }

    final color = networkState.status == NetworkStatus.offline
        ? KoogweColors.error
        : KoogweColors.accent;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KoogweSpacing.md,
        vertical: KoogweSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: color, width: 1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            networkState.status == NetworkStatus.offline
                ? Icons.wifi_off
                : Icons.signal_cellular_alt,
            color: color,
            size: 20,
          ),
          const SizedBox(width: KoogweSpacing.sm),
          Expanded(
            child: Text(
              networkState.status == NetworkStatus.offline
                  ? 'Mode hors ligne - Données mises en cache'
                  : 'Connexion faible - Mode cache activé',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

