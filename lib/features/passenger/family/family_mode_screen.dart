import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/family_mode_provider.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:koogwe/core/widgets/koogwe_text_field.dart';
import 'package:google_fonts/google_fonts.dart';

class FamilyModeScreen extends ConsumerStatefulWidget {
  const FamilyModeScreen({super.key});

  @override
  ConsumerState<FamilyModeScreen> createState() => _FamilyModeScreenState();
}

class _FamilyModeScreenState extends ConsumerState<FamilyModeScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  FamilyMemberRole _selectedRole = FamilyMemberRole.child;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _addMember() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Veuillez remplir tous les champs'),
            backgroundColor: KoogweColors.error,
          ),
        );
      }
      return;
    }

    final success = await ref.read(familyModeProvider.notifier).addMember(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      role: _selectedRole,
    );

    if (mounted) {
      if (success) {
        _nameController.clear();
        _emailController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Membre ajouté avec succès. Une invitation sera envoyée.'),
            backgroundColor: KoogweColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erreur lors de l\'ajout du membre. Veuillez réessayer.'),
            backgroundColor: KoogweColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showActivateDialog(BuildContext dialogContext) async {
    final budgetController = TextEditingController();
    final isDark = Theme.of(dialogContext).brightness == Brightness.dark;

    final result = await showDialog<double>(
      context: dialogContext,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
        title: Text(
          'Activer le mode famille',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Définissez un budget mensuel pour votre famille',
              style: GoogleFonts.inter(
                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: KoogweSpacing.lg),
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Budget mensuel (€)',
                prefixIcon: const Icon(Icons.euro),
                border: OutlineInputBorder(
                  borderRadius: KoogweRadius.mdRadius,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              final budget = double.tryParse(budgetController.text);
              if (budget != null && budget > 0) {
                Navigator.of(context).pop(budget);
              }
            },
            child: const Text('Activer'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      final success = await ref.read(familyModeProvider.notifier).activateFamilyMode(
        monthlyBudget: result,
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      if (success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Mode famille activé avec un budget de ${result.toStringAsFixed(2)}€/mois'),
            backgroundColor: KoogweColors.success,
          ),
        );
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Erreur lors de l\'activation. Veuillez réessayer.'),
            backgroundColor: KoogweColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(familyModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mode Famille'),
        elevation: 0,
        actions: [
          if (!state.isActive)
            TextButton(
              onPressed: () => _showActivateDialog(context),
              child: const Text('Activer'),
            )
          else
            TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Désactiver le mode famille'),
                    content: const Text(
                      'Êtes-vous sûr de vouloir désactiver le mode famille ? Les membres ne pourront plus utiliser le compte partagé.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Annuler'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: KoogweColors.error,
                        ),
                        child: const Text('Désactiver'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && mounted) {
                  await ref.read(familyModeProvider.notifier).deactivateFamilyMode();
                }
              },
              child: const Text('Désactiver'),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(KoogweSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Budget mensuel
                  Container(
                    padding: const EdgeInsets.all(KoogweSpacing.xl),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [KoogweColors.primary, KoogweColors.primaryDark],
                      ),
                      borderRadius: KoogweRadius.lgRadius,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget mensuel',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: KoogweSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${state.monthlySpent.toStringAsFixed(2)}€',
                                  style: GoogleFonts.inter(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Dépensé ce mois',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '/ ${state.monthlyBudget.toStringAsFixed(2)}€',
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                                Text(
                                  'Budget total',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: KoogweSpacing.lg),
                        LinearProgressIndicator(
                          value: state.monthlySpent / state.monthlyBudget,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ).animate().fadeIn().scale(),

                  const SizedBox(height: KoogweSpacing.xxxl),

                  // Liste des membres
                  Text(
                    'Membres de la famille',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: KoogweSpacing.lg),
                  ...state.members.map((member) => _FamilyMemberCard(
                    member: member,
                    onRemove: () => ref.read(familyModeProvider.notifier).removeMember(member.id),
                    onUpdatePermissions: (canRequest, canReceive) {
                      ref.read(familyModeProvider.notifier).updateMemberPermissions(
                        member.id,
                        canRequestRides: canRequest,
                        canReceiveRides: canReceive,
                      );
                    },
                  )),

                  const SizedBox(height: KoogweSpacing.xxxl),

                  // Ajouter un membre
                  Text(
                    'Ajouter un membre',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: KoogweSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(KoogweSpacing.lg),
                    decoration: BoxDecoration(
                      color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                      borderRadius: KoogweRadius.lgRadius,
                      border: Border.all(
                        color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        KoogweTextField(
                          controller: _nameController,
                          hint: 'Nom complet',
                          prefixIcon: const Icon(Icons.person),
                        ),
                        const SizedBox(height: KoogweSpacing.lg),
                        KoogweTextField(
                          controller: _emailController,
                          hint: 'Email',
                          prefixIcon: const Icon(Icons.email),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: KoogweSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: FilterChip(
                                label: const Text('Parent'),
                                selected: _selectedRole == FamilyMemberRole.parent,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedRole = FamilyMemberRole.parent);
                                  }
                                },
                                selectedColor: KoogweColors.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            const SizedBox(width: KoogweSpacing.md),
                            Expanded(
                              child: FilterChip(
                                label: const Text('Enfant'),
                                selected: _selectedRole == FamilyMemberRole.child,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => _selectedRole = FamilyMemberRole.child);
                                  }
                                },
                                selectedColor: KoogweColors.primary.withValues(alpha: 0.2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: KoogweSpacing.lg),
                        KoogweButton(
                          text: 'Ajouter le membre',
                          icon: Icons.person_add,
                          onPressed: _addMember,
                          isFullWidth: true,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
    );
  }
}

class _FamilyMemberCard extends StatelessWidget {
  final FamilyMember member;
  final VoidCallback onRemove;
  final Function(bool?, bool?) onUpdatePermissions;

  const _FamilyMemberCard({
    required this.member,
    required this.onRemove,
    required this.onUpdatePermissions,
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
          color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: member.role == FamilyMemberRole.parent
                    ? KoogweColors.primary.withValues(alpha: 0.1)
                    : KoogweColors.accent.withValues(alpha: 0.1),
                child: Icon(
                  member.role == FamilyMemberRole.parent ? Icons.person : Icons.child_care,
                  color: member.role == FamilyMemberRole.parent ? KoogweColors.primary : KoogweColors.accent,
                ),
              ),
              const SizedBox(width: KoogweSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      member.email,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                      ),
                    ),
                    if (member.phone != null)
                      Text(
                        member.phone!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: member.status == FamilyMemberStatus.active
                      ? KoogweColors.success.withValues(alpha: 0.2)
                      : KoogweColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  member.status == FamilyMemberStatus.active ? 'Actif' : 'En attente',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: member.status == FamilyMemberStatus.active ? KoogweColors.success : KoogweColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (member.monthlySpending != null) ...[
            const SizedBox(height: KoogweSpacing.md),
            Row(
              children: [
                Icon(Icons.euro, size: 16, color: KoogweColors.primary),
                Text(
                  '${member.monthlySpending!.toStringAsFixed(2)}€ ce mois',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: KoogweColors.primary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: KoogweSpacing.md),
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  title: const Text('Peut réserver'),
                  value: member.canRequestRides,
                  onChanged: (value) => onUpdatePermissions(value, member.canReceiveRides),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: SwitchListTile(
                  title: const Text('Peut recevoir'),
                  value: member.canReceiveRides,
                  onChanged: (value) => onUpdatePermissions(member.canRequestRides, value),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.sm),
          TextButton.icon(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Retirer'),
            style: TextButton.styleFrom(
              foregroundColor: KoogweColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

