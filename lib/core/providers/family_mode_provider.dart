import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum FamilyMemberRole { parent, child }
enum FamilyMemberStatus { active, pending, blocked }

class FamilyMember {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final FamilyMemberRole role;
  final FamilyMemberStatus status;
  final DateTime? lastRideDate;
  final double? monthlySpending;
  final bool canRequestRides;
  final bool canReceiveRides;

  FamilyMember({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.status = FamilyMemberStatus.active,
    this.lastRideDate,
    this.monthlySpending,
    this.canRequestRides = true,
    this.canReceiveRides = true,
  });
}

class FamilyModeState {
  final bool isActive;
  final List<FamilyMember> members;
  final FamilyMember? currentMember;
  final double monthlyBudget;
  final double monthlySpent;
  final bool isLoading;

  FamilyModeState({
    this.isActive = false,
    this.members = const [],
    this.currentMember,
    this.monthlyBudget = 0.0,
    this.monthlySpent = 0.0,
    this.isLoading = false,
  });

  FamilyModeState copyWith({
    bool? isActive,
    List<FamilyMember>? members,
    FamilyMember? currentMember,
    double? monthlyBudget,
    double? monthlySpent,
    bool? isLoading,
  }) {
    return FamilyModeState(
      isActive: isActive ?? this.isActive,
      members: members ?? this.members,
      currentMember: currentMember ?? this.currentMember,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      monthlySpent: monthlySpent ?? this.monthlySpent,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FamilyModeNotifier extends Notifier<FamilyModeState> {
  final _client = Supabase.instance.client;

  @override
  FamilyModeState build() {
    _loadFamilyData();
    return FamilyModeState();
  }

  Future<void> _loadFamilyData() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // Charger les paramètres du mode famille
      final settings = await _client
          .from('family_settings')
          .select()
          .eq('owner_id', user.id)
          .maybeSingle();

      final isActive = settings?['is_active'] ?? false;
      final monthlyBudget = (settings?['monthly_budget'] as num?)?.toDouble() ?? 0.0;

      // Charger les membres de la famille
      final membersData = await _client
          .from('family_members')
          .select()
          .eq('family_owner_id', user.id)
          .order('created_at', ascending: false);

      final members = (membersData as List).map((data) {
        // Calculer les dépenses mensuelles du membre
        // (à implémenter avec une requête sur les rides)
        return FamilyMember(
          id: data['id'].toString(),
          name: data['name'].toString(),
          email: data['email'].toString(),
          phone: data['phone']?.toString(),
          role: data['role'] == 'parent' 
              ? FamilyMemberRole.parent 
              : FamilyMemberRole.child,
          status: _statusFromString(data['status']?.toString() ?? 'pending'),
          canRequestRides: data['can_request_rides'] ?? true,
          canReceiveRides: data['can_receive_rides'] ?? true,
          monthlySpending: null, // TODO: Calculer depuis les rides
        );
      }).toList();

      // Calculer le total dépensé ce mois
      final now = DateTime.now();
      final monthStart = DateTime(now.year, now.month, 1);
      final memberIds = members.map((m) => m.id).toList();
      
      double monthlySpent = 0.0;
      if (memberIds.isNotEmpty) {
        // Récupérer les rides des membres de la famille ce mois
        // Note: Cela nécessite une relation entre rides et family_members
        // Pour l'instant, on calcule depuis les rides de l'owner
        final rides = await _client
            .from('rides')
            .select('total_price, created_at')
            .eq('user_id', user.id)
            .eq('status', 'completed')
            .gte('created_at', monthStart.toIso8601String());

        monthlySpent = (rides as List).fold<double>(
          0.0,
          (sum, ride) => sum + ((ride['total_price'] as num?)?.toDouble() ?? 0.0),
        );
      }

      state = state.copyWith(
        isActive: isActive,
        members: members,
        monthlyBudget: monthlyBudget,
        monthlySpent: monthlySpent,
        isLoading: false,
      );
    } catch (e, st) {
      debugPrint('[FamilyMode] Erreur chargement données: $e\n$st');
      state = state.copyWith(isLoading: false);
    }
  }

  FamilyMemberStatus _statusFromString(String status) {
    switch (status) {
      case 'active':
        return FamilyMemberStatus.active;
      case 'blocked':
        return FamilyMemberStatus.blocked;
      default:
        return FamilyMemberStatus.pending;
    }
  }

  /// Activer le mode famille
  Future<bool> activateFamilyMode({required double monthlyBudget}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      state = state.copyWith(isLoading: true);

      await _client.from('family_settings').upsert({
        'owner_id': user.id,
        'is_active': true,
        'monthly_budget': monthlyBudget,
        'updated_at': DateTime.now().toIso8601String(),
      });

      state = state.copyWith(
        isActive: true,
        monthlyBudget: monthlyBudget,
        isLoading: false,
      );

      return true;
    } catch (e, st) {
      debugPrint('[FamilyMode] Erreur activation: $e\n$st');
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  /// Désactiver le mode famille
  Future<bool> deactivateFamilyMode() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      state = state.copyWith(isLoading: true);

      await _client
          .from('family_settings')
          .update({'is_active': false})
          .eq('owner_id', user.id);

      state = state.copyWith(
        isActive: false,
        isLoading: false,
      );

      return true;
    } catch (e, st) {
      debugPrint('[FamilyMode] Erreur désactivation: $e\n$st');
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  Future<bool> addMember({
    required String name,
    required String email,
    required FamilyMemberRole role,
    String? phone,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;

      state = state.copyWith(isLoading: true);

      // Vérifier si l'utilisateur existe déjà
      final existingUser = await _client
          .from('profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      final payload = {
        'family_owner_id': user.id,
        'member_user_id': existingUser?['id'],
        'name': name,
        'email': email,
        'phone': phone,
        'role': role.name,
        'status': 'pending',
        'can_request_rides': true,
        'can_receive_rides': true,
      };

      final result = await _client
          .from('family_members')
          .insert(payload)
          .select()
          .maybeSingle();

      if (result != null) {
        final newMember = FamilyMember(
          id: result['id'].toString(),
          name: name,
          email: email,
          phone: phone,
          role: role,
          status: FamilyMemberStatus.pending,
          canRequestRides: true,
          canReceiveRides: true,
        );

        state = state.copyWith(
          members: [...state.members, newMember],
          isLoading: false,
        );

        return true;
      }

      state = state.copyWith(isLoading: false);
      return false;
    } catch (e, st) {
      debugPrint('[FamilyMode] Erreur ajout membre: $e\n$st');
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  Future<bool> removeMember(String memberId) async {
    try {
      state = state.copyWith(isLoading: true);

      await _client
          .from('family_members')
          .delete()
          .eq('id', memberId);

      state = state.copyWith(
        members: state.members.where((m) => m.id != memberId).toList(),
        isLoading: false,
      );

      return true;
    } catch (e, st) {
      debugPrint('[FamilyMode] Erreur suppression membre: $e\n$st');
      state = state.copyWith(isLoading: false);
      return false;
    }
  }

  Future<bool> updateMemberPermissions(
    String memberId, {
    bool? canRequestRides,
    bool? canReceiveRides,
  }) async {
    try {
      state = state.copyWith(isLoading: true);

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (canRequestRides != null) {
        updates['can_request_rides'] = canRequestRides;
      }
      if (canReceiveRides != null) {
        updates['can_receive_rides'] = canReceiveRides;
      }

      await _client
          .from('family_members')
          .update(updates)
          .eq('id', memberId);

      final members = state.members.map((member) {
        if (member.id == memberId) {
          return FamilyMember(
            id: member.id,
            name: member.name,
            email: member.email,
            phone: member.phone,
            role: member.role,
            status: member.status,
            lastRideDate: member.lastRideDate,
            monthlySpending: member.monthlySpending,
            canRequestRides: canRequestRides ?? member.canRequestRides,
            canReceiveRides: canReceiveRides ?? member.canReceiveRides,
          );
        }
        return member;
      }).toList();

      state = state.copyWith(
        members: members,
        isLoading: false,
      );

      return true;
    } catch (e, st) {
      debugPrint('[FamilyMode] Erreur mise à jour permissions: $e\n$st');
      state = state.copyWith(isLoading: false);
      return false;
    }
  }
}

final familyModeProvider = NotifierProvider<FamilyModeNotifier, FamilyModeState>(
  FamilyModeNotifier.new,
);

