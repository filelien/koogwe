import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  @override
  FamilyModeState build() {
    _loadFamilyData();
    return FamilyModeState();
  }

  Future<void> _loadFamilyData() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    final members = [
      FamilyMember(
        id: '1',
        name: 'Marie Dupont',
        email: 'marie@example.com',
        phone: '+594 694 12 34 56',
        role: FamilyMemberRole.parent,
        status: FamilyMemberStatus.active,
        lastRideDate: DateTime.now().subtract(const Duration(hours: 2)),
        monthlySpending: 125.50,
        canRequestRides: true,
        canReceiveRides: true,
      ),
      FamilyMember(
        id: '2',
        name: 'Lucas Dupont',
        email: 'lucas@example.com',
        phone: '+594 694 12 34 57',
        role: FamilyMemberRole.child,
        status: FamilyMemberStatus.active,
        lastRideDate: DateTime.now().subtract(const Duration(days: 1)),
        monthlySpending: 45.00,
        canRequestRides: true,
        canReceiveRides: true,
      ),
    ];

    state = state.copyWith(
      isActive: true,
      members: members,
      monthlyBudget: 500.0,
      monthlySpent: 170.50,
      isLoading: false,
    );
  }

  Future<bool> addMember({
    required String name,
    required String email,
    required FamilyMemberRole role,
  }) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    final newMember = FamilyMember(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      role: role,
      status: FamilyMemberStatus.pending,
    );

    state = state.copyWith(
      members: [...state.members, newMember],
      isLoading: false,
    );

    return true;
  }

  Future<bool> removeMember(String memberId) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      members: state.members.where((m) => m.id != memberId).toList(),
      isLoading: false,
    );

    return true;
  }

  Future<bool> updateMemberPermissions(
    String memberId, {
    bool? canRequestRides,
    bool? canReceiveRides,
  }) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 300));

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
  }
}

final familyModeProvider = NotifierProvider<FamilyModeNotifier, FamilyModeState>(
  FamilyModeNotifier.new,
);

