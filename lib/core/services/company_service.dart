import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service complet pour la gestion des entreprises
class CompanyService {
  CompanyService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;
  final SupabaseClient _client;

  /// Créer une entreprise
  Future<Map<String, dynamic>?> createCompany({
    required String name,
    required String email,
    String? phone,
    String? address,
    String? taxId,
    double monthlyBudget = 0,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final res = await _client.from('companies').insert({
        'owner_id': user.id,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'tax_id': taxId,
        'monthly_budget': monthlyBudget,
        'status': 'pending',
      }).select().maybeSingle();

      debugPrint('[CompanyService] Company created: ${res?['id']}');
      return res;
    } catch (e, st) {
      debugPrint('[CompanyService] createCompany error: $e\n$st');
      return null;
    }
  }

  /// Obtenir l'entreprise de l'utilisateur
  Future<Map<String, dynamic>?> getMyCompany() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final res = await _client
          .from('companies')
          .select()
          .eq('owner_id', user.id)
          .maybeSingle();

      return res;
    } catch (e, st) {
      debugPrint('[CompanyService] getMyCompany error: $e\n$st');
      return null;
    }
  }

  /// Ajouter un employé
  Future<Map<String, dynamic>?> addEmployee({
    required String userId,
    String role = 'employee',
    String? department,
    double? monthlyLimit,
  }) async {
    try {
      final company = await getMyCompany();
      if (company == null) return null;

      final res = await _client.from('company_users').insert({
        'company_id': company['id'],
        'user_id': userId,
        'role': role,
        'department': department,
        'monthly_limit': monthlyLimit,
        'is_active': true,
      }).select().maybeSingle();

      debugPrint('[CompanyService] Employee added');
      return res;
    } catch (e, st) {
      debugPrint('[CompanyService] addEmployee error: $e\n$st');
      return null;
    }
  }

  /// Obtenir tous les employés
  Future<List<Map<String, dynamic>>> getEmployees() async {
    try {
      final company = await getMyCompany();
      if (company == null) return [];

      final res = await _client
          .from('company_users')
          .select('*, user:profiles(*)')
          .eq('company_id', company['id'])
          .eq('is_active', true);

      return (res as List).cast<Map<String, dynamic>>();
    } catch (e, st) {
      debugPrint('[CompanyService] getEmployees error: $e\n$st');
      return [];
    }
  }

  /// Réserver un trajet pour un employé
  Future<Map<String, dynamic>?> bookRideForEmployee({
    required String employeeId,
    required String pickup,
    required String dropoff,
    required String vehicleType,
    DateTime? scheduledTime,
    String? department,
    String? purpose,
  }) async {
    try {
      final company = await getMyCompany();
      if (company == null) return null;

      // Vérifier le budget
      if (company['current_spent'] >= company['monthly_budget']) {
        debugPrint('[CompanyService] Budget exceeded');
        return null;
      }

      // Créer la course
      final rideRes = await _client.from('rides').insert({
        'user_id': employeeId,
        'company_id': company['id'],
        'pickup_text': pickup,
        'dropoff_text': dropoff,
        'vehicle_type': vehicleType,
        'status': scheduledTime != null ? 'requested' : 'requested',
      }).select().maybeSingle();

      if (rideRes == null) return null;

      // Lier à l'entreprise
      await _client.from('company_rides').insert({
        'company_id': company['id'],
        'employee_id': employeeId,
        'ride_id': rideRes['id'],
        'department': department,
        'purpose': purpose,
      });

      return rideRes;
    } catch (e, st) {
      debugPrint('[CompanyService] bookRideForEmployee error: $e\n$st');
      return null;
    }
  }

  /// Obtenir le budget actuel
  Future<Map<String, dynamic>?> getBudget() async {
    try {
      final company = await getMyCompany();
      if (company == null) return null;

      return {
        'monthly_budget': company['monthly_budget'],
        'current_spent': company['current_spent'],
        'remaining': (company['monthly_budget'] as num).toDouble() - (company['current_spent'] as num).toDouble(),
      };
    } catch (e, st) {
      debugPrint('[CompanyService] getBudget error: $e\n$st');
      return null;
    }
  }

  /// Obtenir les factures
  Future<List<Map<String, dynamic>>> getInvoices() async {
    try {
      final company = await getMyCompany();
      if (company == null) return [];

      final res = await _client
          .from('invoices')
          .select()
          .eq('company_id', company['id'])
          .order('created_at', ascending: false);

      return (res as List).cast<Map<String, dynamic>>();
    } catch (e, st) {
      debugPrint('[CompanyService] getInvoices error: $e\n$st');
      return [];
    }
  }

  /// Obtenir les courses de l'entreprise
  Future<List<Map<String, dynamic>>> getCompanyRides() async {
    try {
      final company = await getMyCompany();
      if (company == null) return [];

      final res = await _client
          .from('company_rides')
          .select('*, ride:rides(*)')
          .eq('company_id', company['id'])
          .order('created_at', ascending: false);

      return (res as List).cast<Map<String, dynamic>>().map((cr) {
        final ride = cr['ride'] as Map<String, dynamic>?;
        return ride ?? {};
      }).toList();
    } catch (e, st) {
      debugPrint('[CompanyService] getCompanyRides error: $e\n$st');
      return [];
    }
  }

  /// Retirer un employé
  Future<bool> removeEmployee(String userId) async {
    try {
      final company = await getMyCompany();
      if (company == null) return false;

      await _client
          .from('company_users')
          .update({'is_active': false})
          .eq('company_id', company['id'])
          .eq('user_id', userId);

      debugPrint('[CompanyService] Employee removed');
      return true;
    } catch (e, st) {
      debugPrint('[CompanyService] removeEmployee error: $e\n$st');
      return false;
    }
  }

  /// Ajouter un employé par email
  Future<bool> addEmployeeByEmail(String email) async {
    try {
      // Trouver l'utilisateur par email
      final userRes = await _client
          .from('profiles')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (userRes == null) return false;

      return await addEmployee(userId: userRes['id']) != null;
    } catch (e, st) {
      debugPrint('[CompanyService] addEmployeeByEmail error: $e\n$st');
      return false;
    }
  }

  /// Obtenir les statistiques détaillées de l'entreprise
  Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final company = await getMyCompany();
      if (company == null) return null;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final monthAgo = today.subtract(const Duration(days: 30));

      // Courses de l'entreprise
      final companyRides = await _client
          .from('company_rides')
          .select('ride:rides(*), created_at')
          .eq('company_id', company['id'])
          .order('created_at', ascending: false);

      final rides = (companyRides as List)
          .map((cr) => cr['ride'] as Map<String, dynamic>?)
          .whereType<Map<String, dynamic>>()
          .toList();

      // Courses terminées
      final completedRides = rides.where((r) => r['status'] == 'completed').toList();

      // Total revenus/dépenses
      final totalSpent = completedRides.fold<double>(
          0, (sum, ride) => sum + ((ride['total_price'] as num?)?.toDouble() ?? 0));

      // Revenus ce mois
      final monthRides = completedRides.where((ride) {
        final createdAt = DateTime.tryParse(ride['created_at']?.toString() ?? '');
        return createdAt != null && createdAt.isAfter(monthAgo);
      }).toList();

      final monthSpent = monthRides.fold<double>(
          0, (sum, ride) => sum + ((ride['total_price'] as num?)?.toDouble() ?? 0));

      // Revenus par jour (7 derniers jours)
      final spendingByDay = <Map<String, dynamic>>[];
      for (int i = 6; i >= 0; i--) {
        final dayStart = today.subtract(Duration(days: i));
        final dayEnd = dayStart.add(const Duration(days: 1));

        final dayRides = completedRides.where((ride) {
          final createdAt = DateTime.tryParse(ride['created_at']?.toString() ?? '');
          return createdAt != null &&
              createdAt.isAfter(dayStart) &&
              createdAt.isBefore(dayEnd);
        }).toList();

        final daySpent = dayRides.fold<double>(
            0, (sum, ride) => sum + ((ride['total_price'] as num?)?.toDouble() ?? 0));

        spendingByDay.add({
          'date': dayStart,
          'spent': daySpent,
        });
      }

      // Employés
      final employees = await getEmployees();

      // Budget
      final monthlyBudget = (company['monthly_budget'] as num?)?.toDouble() ?? 0.0;
      final currentSpent = (company['current_spent'] as num?)?.toDouble() ?? 0.0;
      final remaining = monthlyBudget - currentSpent;

      // Courses par statut
      final statusCounts = <String, int>{};
      for (var ride in rides) {
        final status = ride['status']?.toString() ?? 'unknown';
        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
      }

      return {
        'total_rides': rides.length,
        'completed_rides': completedRides.length,
        'total_spent': totalSpent,
        'month_spent': monthSpent,
        'monthly_budget': monthlyBudget,
        'current_spent': currentSpent,
        'remaining_budget': remaining,
        'employees_count': employees.length,
        'spending_last_7_days': spendingByDay,
        'rides_by_status': statusCounts,
      };
    } catch (e, st) {
      debugPrint('[CompanyService] getDashboardStats error: $e\n$st');
      return null;
    }
  }
}

