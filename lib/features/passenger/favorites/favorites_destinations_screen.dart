import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FavoritesDestinationsScreen extends ConsumerStatefulWidget {
  const FavoritesDestinationsScreen({super.key});

  @override
  ConsumerState<FavoritesDestinationsScreen> createState() => _FavoritesDestinationsScreenState();
}

class _FavoritesDestinationsScreenState extends ConsumerState<FavoritesDestinationsScreen> {
  final List<FavoriteDestination> _favorites = [
    FavoriteDestination(
      id: '1',
      name: 'Maison',
      address: '123 Rue de la Paix, Paris',
      icon: Icons.home,
      color: KoogweColors.primary,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    FavoriteDestination(
      id: '2',
      name: 'Bureau',
      address: '456 Avenue des Champs, Paris',
      icon: Icons.business,
      color: KoogweColors.accent,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    FavoriteDestination(
      id: '3',
      name: 'Aéroport CDG',
      address: 'Aéroport Charles de Gaulle',
      icon: Icons.flight,
      color: KoogweColors.secondary,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
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
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Destinations favorites',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddFavoriteDialog(context),
            ),
          ],
        ),
        body: SafeArea(
          child: _favorites.isEmpty
              ? _buildEmptyState(isDark)
              : ListView.separated(
                  padding: const EdgeInsets.all(KoogweSpacing.lg),
                  itemCount: _favorites.length,
                  separatorBuilder: (_, __) => const SizedBox(height: KoogweSpacing.md),
                  itemBuilder: (context, index) {
                    final favorite = _favorites[index];
                    return GlassCard(
                      borderRadius: KoogweRadius.lgRadius,
                      onTap: () {
                        // Utiliser cette destination pour un nouveau trajet
                        context.push('/passenger/ride-booking', extra: {
                          'destination': favorite.address,
                        });
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(KoogweSpacing.md),
                        leading: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: favorite.color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(favorite.icon, color: favorite.color, size: 24),
                        ),
                        title: Text(
                          favorite.name,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                          ),
                        ),
                        subtitle: Text(
                          favorite.address,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _deleteFavorite(favorite.id),
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 80,
            color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
          ),
          const SizedBox(height: KoogweSpacing.xl),
          Text(
            'Aucune destination favorite',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: KoogweSpacing.sm),
          Text(
            'Ajoutez vos destinations fréquentes\npour un accès rapide',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: KoogweSpacing.xl),
          ElevatedButton.icon(
            onPressed: () => _showAddFavoriteDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter une destination'),
            style: ElevatedButton.styleFrom(
              backgroundColor: KoogweColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: KoogweSpacing.xl, vertical: KoogweSpacing.md),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFavoriteDialog(BuildContext context) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une destination favorite'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nom (ex: Maison, Bureau)',
                prefixIcon: Icon(Icons.label),
              ),
            ),
            const SizedBox(height: KoogweSpacing.md),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse',
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty && addressController.text.isNotEmpty) {
                setState(() {
                  _favorites.add(FavoriteDestination(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    address: addressController.text,
                    icon: Icons.place,
                    color: KoogweColors.primary,
                    createdAt: DateTime.now(),
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  void _deleteFavorite(String id) {
    setState(() {
      _favorites.removeWhere((f) => f.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Destination supprimée')),
    );
  }
}

class FavoriteDestination {
  final String id;
  final String name;
  final String address;
  final IconData icon;
  final Color color;
  final DateTime createdAt;

  FavoriteDestination({
    required this.id,
    required this.name,
    required this.address,
    required this.icon,
    required this.color,
    required this.createdAt,
  });
}

