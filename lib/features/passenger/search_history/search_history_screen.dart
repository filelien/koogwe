import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class SearchHistoryScreen extends StatefulWidget {
  const SearchHistoryScreen({super.key});

  @override
  State<SearchHistoryScreen> createState() => _SearchHistoryScreenState();
}

class _SearchHistoryScreenState extends State<SearchHistoryScreen> {
  final List<SearchHistoryItem> _history = [
    SearchHistoryItem(
      id: '1',
      pickup: '123 Rue de la Paix',
      dropoff: 'Aéroport CDG',
      searchedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    SearchHistoryItem(
      id: '2',
      pickup: '456 Avenue des Champs',
      dropoff: 'Gare du Nord',
      searchedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SearchHistoryItem(
      id: '3',
      pickup: '789 Boulevard Saint-Michel',
      dropoff: 'Tour Eiffel',
      searchedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

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
            'Historique de recherche',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
          actions: [
            if (_history.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    _history.clear();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Historique effacé')),
                  );
                },
                child: const Text('Effacer tout'),
              ),
          ],
        ),
        body: SafeArea(
          child: _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 80,
                        color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
                      ),
                      const SizedBox(height: KoogweSpacing.xl),
                      Text(
                        'Aucun historique',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: KoogweSpacing.sm),
                      Text(
                        'Vos recherches récentes apparaîtront ici',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(KoogweSpacing.lg),
                  itemCount: _history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: KoogweSpacing.md),
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return GlassCard(
                      borderRadius: KoogweRadius.lgRadius,
                      onTap: () {
                        // Réutiliser cette recherche
                        context.push('/passenger/ride-booking', extra: {
                          'pickup': item.pickup,
                          'dropoff': item.dropoff,
                        });
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(KoogweSpacing.md),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: KoogweColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.search,
                            color: KoogweColors.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          '${item.pickup} → ${item.dropoff}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          DateFormat('dd/MM/yyyy à HH:mm').format(item.searchedAt),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() {
                              _history.removeAt(index);
                            });
                          },
                          color: KoogweColors.error,
                        ),
                      ),
                    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: -0.1, end: 0);
                  },
                ),
        ),
      ),
    );
  }
}

class SearchHistoryItem {
  final String id;
  final String pickup;
  final String dropoff;
  final DateTime searchedAt;

  SearchHistoryItem({
    required this.id,
    required this.pickup,
    required this.dropoff,
    required this.searchedAt,
  });
}

