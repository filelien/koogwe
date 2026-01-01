import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/ride_provider.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/services/export_service.dart';
import 'package:intl/intl.dart';

class RideHistoryScreen extends ConsumerStatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  ConsumerState<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends ConsumerState<RideHistoryScreen> {
  String _selectedFilter = 'Tous';
  final TextEditingController _searchController = TextEditingController();
  bool _showStats = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(rideProvider.notifier).refreshHistory());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rideProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filtrer selon la sélection et la recherche
    var filteredHistory = _selectedFilter == 'Tous' 
        ? state.history 
        : state.history.where((r) => r.status == _selectedFilter.toLowerCase()).toList();
    
    // Appliquer la recherche
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filteredHistory = filteredHistory.where((r) {
        return r.pickup.toLowerCase().contains(query) ||
               r.dropoff.toLowerCase().contains(query) ||
               r.vehicleType.toLowerCase().contains(query);
      }).toList();
    }

    // Calculer les statistiques
    final totalRides = state.history.length;
    final completedRides = state.history.where((r) => r.status == 'completed').length;
    final totalSpent = state.history
        .where((r) => r.estimatedPrice != null && r.status == 'completed')
        .fold<double>(0, (sum, r) => sum + (r.estimatedPrice ?? 0));
    final avgPrice = completedRides > 0 ? totalSpent / completedRides : 0.0;

    return GradientBackground(
      useDarkAurora: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Historique des trajets',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () async {
                final exportService = ExportService();
                await exportService.exportRides(
                  filteredHistory.map((r) => {
                    'created_at': r.createdAt.toIso8601String(),
                    'pickup_text': r.pickup,
                    'dropoff_text': r.dropoff,
                    'vehicle_type': r.vehicleType,
                    'fare': r.estimatedPrice ?? 0.0,
                    'status': r.status,
                  }).toList(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export PDF généré avec succès')),
                  );
                }
              },
              tooltip: 'Exporter en PDF',
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Recherche
              Padding(
                padding: const EdgeInsets.fromLTRB(KoogweSpacing.lg, KoogweSpacing.md, KoogweSpacing.lg, 0),
                child: GlassCard(
                  borderRadius: KoogweRadius.mdRadius,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un trajet...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
              ),

              // Statistiques
              if (_showStats && state.history.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(KoogweSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(KoogweSpacing.md),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [KoogweColors.primary, KoogweColors.primaryDark],
                      ),
                      borderRadius: KoogweRadius.lgRadius,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: 'Total',
                          value: '$totalRides',
                          icon: Icons.directions_car,
                        ),
                        _StatItem(
                          label: 'Complétés',
                          value: '$completedRides',
                          icon: Icons.check_circle,
                        ),
                        _StatItem(
                          label: 'Total dépensé',
                          value: '€${totalSpent.toStringAsFixed(0)}',
                          icon: Icons.euro,
                        ),
                        _StatItem(
                          label: 'Moyenne',
                          value: '€${avgPrice.toStringAsFixed(0)}',
                          icon: Icons.trending_up,
                        ),
                      ],
                    ),
                  ),
                ),

              // Filtres
              Padding(
                padding: const EdgeInsets.fromLTRB(KoogweSpacing.lg, 0, KoogweSpacing.lg, KoogweSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['Tous', 'completed', 'cancelled', 'requested'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: KoogweSpacing.sm),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(
                            filter == 'Tous' ? 'Tous' : _getStatusLabel(filter),
                            style: GoogleFonts.inter(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          onSelected: (selected) {
                            setState(() => _selectedFilter = filter);
                          },
                          backgroundColor: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                          selectedColor: KoogweColors.primary.withValues(alpha: 0.2),
                          checkmarkColor: KoogweColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? KoogweColors.primary
                                : (isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary),
                          ),
                        ),
                      );
                    }).toList(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(_showStats ? Icons.expand_less : Icons.expand_more),
                      onPressed: () => setState(() => _showStats = !_showStats),
                      tooltip: _showStats ? 'Masquer stats' : 'Afficher stats',
                    ),
                  ],
                ),
              ),

              // Bouton export
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: KoogweSpacing.lg),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final exportService = ExportService();
                          // Export PDF
                          final pdfSuccess = await exportService.exportRides(
                            filteredHistory.map((r) => {
                              'created_at': r.createdAt.toIso8601String(),
                              'pickup_text': r.pickup,
                              'dropoff_text': r.dropoff,
                              'vehicle_type': r.vehicleType,
                              'fare': r.estimatedPrice ?? 0.0,
                              'status': r.status,
                            }).toList(),
                          );
                          // Export Excel
                          final headers = ['Date', 'Départ', 'Destination', 'Type', 'Prix', 'Statut'];
                          final rows = filteredHistory.map((r) {
                            return [
                              DateFormat('dd/MM/yyyy HH:mm').format(r.createdAt),
                              r.pickup,
                              r.dropoff,
                              r.vehicleType,
                              (r.estimatedPrice ?? 0.0).toStringAsFixed(2),
                              _getStatusLabel(r.status),
                            ];
                          }).toList();
                          final excelSuccess = await exportService.exportToCSV(
                            title: 'Historique des Courses',
                            headers: headers,
                            rows: rows,
                            fileName: 'rides_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  pdfSuccess && excelSuccess 
                                    ? 'Exports PDF et Excel générés avec succès'
                                    : pdfSuccess 
                                      ? 'Export PDF généré'
                                      : excelSuccess
                                        ? 'Export Excel généré'
                                        : 'Erreur lors de l\'export',
                                ),
                                backgroundColor: (pdfSuccess || excelSuccess) 
                                  ? KoogweColors.success 
                                  : KoogweColors.error,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Exporter PDF/Excel'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KoogweSpacing.sm),
              
              // Liste des trajets
              Expanded(
                child: filteredHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
                            ),
                            const SizedBox(height: KoogweSpacing.md),
                            Text(
                              'Aucun trajet',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                              ),
                            ),
                            const SizedBox(height: KoogweSpacing.xs),
                            Text(
                              'Vos trajets apparaîtront ici',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(KoogweSpacing.md),
                        itemCount: filteredHistory.length,
                        separatorBuilder: (_, __) => const SizedBox(height: KoogweSpacing.md),
                        itemBuilder: (context, i) {
                          final r = filteredHistory[i];
                          final statusColor = _getStatusColor(r.status, isDark);
                          final statusLabel = _getStatusLabel(r.status);
                          
                          return GlassCard(
                            borderRadius: KoogweRadius.lgRadius,
                            onTap: () {
                              // Afficher les détails du trajet
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (context) => _RideDetailSheet(
                                  ride: r,
                                  isDark: isDark,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(KoogweSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(KoogweSpacing.sm),
                                        decoration: BoxDecoration(
                                          color: KoogweColors.primary.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.local_taxi,
                                          color: KoogweColors.primary,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: KoogweSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${r.pickup} → ${r.dropoff}',
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  size: 12,
                                                  color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  DateFormat('dd MMM yyyy à HH:mm', 'fr_FR').format(r.createdAt),
                                                  style: GoogleFonts.inter(
                                                    fontSize: 12,
                                                    color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (r.estimatedPrice != null)
                                            Text(
                                              '€ ${r.estimatedPrice!.toStringAsFixed(2)}',
                                              style: GoogleFonts.inter(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: KoogweColors.primary,
                                              ),
                                            ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                                              color: statusColor.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              statusLabel,
                                              style: GoogleFonts.inter(
                                                color: statusColor,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: KoogweSpacing.md),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: (isDark ? KoogweColors.darkSurfaceVariant : KoogweColors.lightSurfaceVariant)
                                              .withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          r.vehicleType,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      if (r.status == 'completed') ...[
                                        IconButton(
                                          icon: const Icon(Icons.receipt, size: 20),
                                          onPressed: () {
                                            context.push('/passenger/invoice?rideId=${r.id}');
                                          },
                                          tooltip: 'Voir la facture',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.star_outline, size: 20),
                                          onPressed: () {
                                            context.push('/passenger/feedback?rideId=${r.id}');
                                          },
                                          tooltip: 'Noter',
                                        ),
                                      ],
                                      if (r.status == 'in_progress' || r.status == 'requested')
                                        IconButton(
                                          icon: const Icon(Icons.chat_bubble_outline, size: 20),
                                          onPressed: () {
                                            if (r.driverId != null) {
                                              context.push('/passenger/chat?rideId=${r.id}&driverId=${r.driverId}');
                                            }
                                          },
                                          tooltip: 'Chat',
                                        ),
                                    ],
                  ),
                ],
              ),
            ),
                          ).animate().fadeIn(delay: (i * 50).ms).slideX(begin: -0.1, end: 0);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status, bool isDark) {
    return switch (status) {
      'completed' => KoogweColors.success,
      'cancelled' => KoogweColors.error,
      'requested' => KoogweColors.info,
      'in_progress' => KoogweColors.accent,
      _ => (isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary),
    };
  }

  String _getStatusLabel(String status) {
    return switch (status) {
      'completed' => 'Terminé',
      'cancelled' => 'Annulé',
      'requested' => 'Demandé',
      'in_progress' => 'En cours',
      _ => status,
    };
  }
}

class _RideDetailSheet extends StatelessWidget {
  final dynamic ride;
  final bool isDark;

  const _RideDetailSheet({
    required this.ride,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(KoogweSpacing.xl),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: KoogweSpacing.xl),
                  decoration: BoxDecoration(
                    color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Détails du trajet',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: KoogweSpacing.xl),
              _DetailRow(
                icon: Icons.place,
                label: 'Départ',
                value: ride.pickup,
                isDark: isDark,
              ),
              const SizedBox(height: KoogweSpacing.md),
              _DetailRow(
                icon: Icons.location_on,
                label: 'Destination',
                value: ride.dropoff,
                isDark: isDark,
              ),
              const SizedBox(height: KoogweSpacing.md),
              _DetailRow(
                icon: Icons.local_taxi,
                label: 'Type de véhicule',
                value: ride.vehicleType,
                isDark: isDark,
              ),
              if (ride.estimatedPrice != null) ...[
                const SizedBox(height: KoogweSpacing.md),
                _DetailRow(
                  icon: Icons.euro,
                  label: 'Prix',
                  value: '€ ${ride.estimatedPrice!.toStringAsFixed(2)}',
                  isDark: isDark,
                ),
              ],
              const SizedBox(height: KoogweSpacing.xl),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Fermer'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: KoogweColors.primary, size: 20),
        const SizedBox(width: KoogweSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
