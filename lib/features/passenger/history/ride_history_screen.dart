import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/ride_provider.dart';
import 'package:koogwe/core/constants/app_assets.dart';

class RideHistoryScreen extends ConsumerStatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  ConsumerState<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends ConsumerState<RideHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(rideProvider.notifier).refreshHistory());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Historique des trajets')),
      body: ListView.separated(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        itemCount: state.history.length,
        separatorBuilder: (_, __) => const SizedBox(height: KoogweSpacing.md),
        itemBuilder: (context, i) {
          final r = state.history[i];
          final statusColor = switch (r.status) {
            'completed' => KoogweColors.success,
            'cancelled' => KoogweColors.error,
            'requested' => KoogweColors.info,
            _ => (isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary),
          };
          return Container(
            decoration: BoxDecoration(
              color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
              borderRadius: KoogweRadius.lgRadius,
              border: Border.all(color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: KoogweColors.primary.withValues(alpha: 0.12),
                child: ClipOval(
                  child: Image.asset(
                    AppAssets.appLogo,
                    width: 36,
                    height: 36,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.local_taxi, color: KoogweColors.primary),
                  ),
                ),
              ),
              title: Text('${r.pickup} → ${r.dropoff}', maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                '${r.vehicleType} • ${r.createdAt.toLocal()}'.replaceFirst('.000', ''),
                style: GoogleFonts.inter(fontSize: 12),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (r.estimatedPrice != null)
                    Text('€ ${r.estimatedPrice!.toStringAsFixed(2)}', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: KoogweRadius.smRadius,
                    ),
                    child: Text(r.status, style: GoogleFonts.inter(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
