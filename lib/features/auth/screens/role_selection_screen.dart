import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/role_selection_provider.dart';
import 'package:koogwe/core/providers/auth_provider.dart';
import 'package:koogwe/core/widgets/animated_vehicle_widget.dart';
import 'package:koogwe/core/widgets/koogwe_logo.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  VehicleType _selectedVehicleType = VehicleType.economy;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? KoogweColors.darkBackground : KoogweColors.lightBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: KoogweSpacing.xl,
                    right: KoogweSpacing.xl,
                    top: KoogweSpacing.xl,
                    bottom: MediaQuery.of(context).viewInsets.bottom + KoogweSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header avec logo
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/language-selection');
                              }
                            },
                            icon: Icon(
                              Icons.arrow_back,
                              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                            ),
                          ),
                          const Spacer(),
                          KoogweLogo(size: 48, showWordmark: false),
                        ],
                      ),
                      const SizedBox(height: KoogweSpacing.xxl),
                      
                      // Titre
                      Text(
                        'Choisissez votre rôle',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                        ),
                      ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.md),
                      Text(
                        'Sélectionnez comment vous souhaitez utiliser KOOGWE',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                        ),
                      ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.xl),
                      
                      // Voiture animée - hauteur adaptative
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final screenHeight = MediaQuery.of(context).size.height;
                          final vehicleHeight = screenHeight < 700 ? 140.0 : 180.0;
                          return SizedBox(
                            height: vehicleHeight,
                            child: AnimatedVehicleWidget(
                              vehicleType: _selectedVehicleType,
                              height: vehicleHeight,
                              showRoad: true,
                            ),
                          );
                        },
                      ).animate().fadeIn(delay: 150.ms).scale(),
                      
                      SizedBox(height: MediaQuery.of(context).size.height < 700 ? KoogweSpacing.xl : KoogweSpacing.xxxl),
                      
                      // Cartes de rôles améliorées
                      _buildRoleCard(
                        context: context,
                        ref: ref,
                        icon: Icons.person,
                        title: 'Passager',
                        description: 'Réservez des courses, voyagez confortablement, partagez vos trajets',
                        features: ['Recherche intelligente', 'Multi-stop', 'Comparaison prix', 'Gamification'],
                        color: KoogweColors.primary,
                        role: UserRole.passenger,
                        vehicleType: VehicleType.economy,
                      ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.lg),
                      _buildRoleCard(
                        context: context,
                        ref: ref,
                        icon: Icons.directions_car,
                        title: 'Chauffeur',
                        description: 'Conduisez, gagnez de l\'argent, gérez vos revenus en temps réel',
                        features: ['Statut intelligent', 'Heatmap zones', 'Revenus détaillés', 'Gestion véhicules'],
                        color: KoogweColors.secondary,
                        role: UserRole.driver,
                        vehicleType: VehicleType.comfort,
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.lg),
                      _buildRoleCard(
                        context: context,
                        ref: ref,
                        icon: Icons.business,
                        title: 'Entreprise',
                        description: 'Gérez les déplacements de votre équipe, suivez les coûts',
                        features: ['Gestion employés', 'Rapports analytics', 'Catalogue véhicules', 'Facturation'],
                        color: KoogweColors.accent,
                        role: UserRole.business,
                        vehicleType: VehicleType.suv,
                      ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.lg),
                      _buildRoleCard(
                        context: context,
                        ref: ref,
                        icon: Icons.admin_panel_settings,
                        title: 'Administrateur',
                        description: 'Contrôle total, supervision globale, gestion système',
                        features: ['Accès global', 'Gestion utilisateurs', 'Analytics avancés', 'Sécurité & audit'],
                        color: Colors.purple.shade400,
                        role: UserRole.admin,
                        vehicleType: VehicleType.luxury,
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.xl),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required String description,
    required List<String> features,
    required Color color,
    required UserRole role,
    required VehicleType vehicleType,
  }) {
    return RoleCard(
      icon: icon,
      title: title,
      description: description,
      features: features,
      color: color,
      onTap: () {
        // Sauvegarder le rôle sélectionné
        ref.read(selectedRoleProvider.notifier).setRole(role);
        setState(() {
          _selectedVehicleType = vehicleType;
        });
        // Rediriger vers login/register avec le rôle
        context.go('/register');
      },
    );
  }
}

class RoleCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<String> features;
  final Color color;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.features,
    required this.color,
    required this.onTap,
  });

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: KoogweRadius.lgRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(KoogweSpacing.xl),
          decoration: BoxDecoration(
            gradient: _isHovered
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.color.withValues(alpha: 0.1),
                      widget.color.withValues(alpha: 0.05),
                    ],
                  )
                : null,
            color: _isHovered
                ? null
                : (isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface),
            borderRadius: KoogweRadius.lgRadius,
            border: Border.all(
              color: _isHovered
                  ? widget.color
                  : (isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: _isHovered ? 0.2 : 0.1),
                      borderRadius: KoogweRadius.mdRadius,
                      boxShadow: _isHovered
                          ? [
                              BoxShadow(
                                color: widget.color.withValues(alpha: 0.5),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      widget.icon,
                      size: 32,
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(width: KoogweSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: KoogweSpacing.xs),
                        Text(
                          widget.description,
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
              const SizedBox(height: KoogweSpacing.lg),
              Wrap(
                spacing: KoogweSpacing.sm,
                runSpacing: KoogweSpacing.sm,
                children: widget.features.map((feature) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KoogweSpacing.md,
                      vertical: KoogweSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.1),
                      borderRadius: KoogweRadius.fullRadius,
                      border: Border.all(
                        color: widget.color.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      feature,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.color,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
