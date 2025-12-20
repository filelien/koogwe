import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/providers/auth_provider.dart';

class SelectedRoleNotifier extends Notifier<UserRole?> {
  @override
  UserRole? build() => null;

  void setRole(UserRole? role) {
    state = role;
  }
}

/// Provider pour stocker temporairement le rôle sélectionné par l'utilisateur
/// avant l'inscription/connexion
final selectedRoleProvider = NotifierProvider<SelectedRoleNotifier, UserRole?>(() {
  return SelectedRoleNotifier();
});

/// Provider pour obtenir le rôle sélectionné ou le rôle de l'utilisateur connecté
final currentRoleProvider = Provider<UserRole?>((ref) {
  final selected = ref.watch(selectedRoleProvider);
  final authState = ref.watch(authProvider);
  
  // Si un utilisateur est connecté, utiliser son rôle
  if (authState.isAuthenticated && authState.user != null) {
    return authState.user!.role;
  }
  
  // Sinon, utiliser le rôle sélectionné temporairement
  return selected;
});

