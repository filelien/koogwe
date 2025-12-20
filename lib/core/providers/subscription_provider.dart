import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SubscriptionType { weekly, monthly, yearly }
enum SubscriptionStatus { active, expired, cancelled, pending }

class Subscription {
  final String id;
  final SubscriptionType type;
  final SubscriptionStatus status;
  final DateTime startDate;
  final DateTime endDate;
  final double price;
  final double savings;
  final int ridesUsed;
  final int ridesLimit;
  final double discountPercentage;

  Subscription({
    required this.id,
    required this.type,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.price,
    this.savings = 0.0,
    this.ridesUsed = 0,
    this.ridesLimit = 0,
    this.discountPercentage = 0.0,
  });

  int get remainingRides => ridesLimit - ridesUsed;
  bool get isActive => status == SubscriptionStatus.active && DateTime.now().isBefore(endDate);
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
}

class SubscriptionState {
  final Subscription? currentSubscription;
  final List<Subscription> availablePlans;
  final bool isLoading;
  final String? error;

  SubscriptionState({
    this.currentSubscription,
    this.availablePlans = const [],
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    Subscription? currentSubscription,
    List<Subscription>? availablePlans,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionState(
      currentSubscription: currentSubscription ?? this.currentSubscription,
      availablePlans: availablePlans ?? this.availablePlans,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SubscriptionNotifier extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() {
    _loadSubscriptions();
    return SubscriptionState();
  }

  Future<void> _loadSubscriptions() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    final now = DateTime.now();
    final plans = [
      Subscription(
        id: 'weekly',
        type: SubscriptionType.weekly,
        status: SubscriptionStatus.active,
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 5)),
        price: 19.99,
        savings: 15.50,
        ridesUsed: 8,
        ridesLimit: 20,
        discountPercentage: 15.0,
      ),
      Subscription(
        id: 'monthly',
        type: SubscriptionType.monthly,
        status: SubscriptionStatus.active,
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 20)),
        price: 69.99,
        savings: 45.00,
        ridesUsed: 32,
        ridesLimit: 100,
        discountPercentage: 20.0,
      ),
      Subscription(
        id: 'yearly',
        type: SubscriptionType.yearly,
        status: SubscriptionStatus.pending,
        startDate: now,
        endDate: now.add(const Duration(days: 365)),
        price: 599.99,
        savings: 200.00,
        ridesUsed: 0,
        ridesLimit: 1200,
        discountPercentage: 25.0,
      ),
    ];

    state = state.copyWith(
      currentSubscription: plans.firstWhere((p) => p.isActive, orElse: () => plans.first),
      availablePlans: plans,
      isLoading: false,
    );
  }

  Future<bool> subscribe(SubscriptionType type) async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    // Simuler l'abonnement
    final newSubscription = Subscription(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      status: SubscriptionStatus.active,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(
        type == SubscriptionType.weekly
            ? const Duration(days: 7)
            : type == SubscriptionType.monthly
                ? const Duration(days: 30)
                : const Duration(days: 365),
      ),
      price: type == SubscriptionType.weekly
          ? 19.99
          : type == SubscriptionType.monthly
              ? 69.99
              : 599.99,
      ridesLimit: type == SubscriptionType.weekly
          ? 20
          : type == SubscriptionType.monthly
              ? 100
              : 1200,
      discountPercentage: type == SubscriptionType.weekly
          ? 15.0
          : type == SubscriptionType.monthly
              ? 20.0
              : 25.0,
    );

    state = state.copyWith(
      currentSubscription: newSubscription,
      isLoading: false,
    );

    return true;
  }

  Future<bool> cancelSubscription() async {
    if (state.currentSubscription == null) return false;

    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(seconds: 1));

    final cancelled = Subscription(
      id: state.currentSubscription!.id,
      type: state.currentSubscription!.type,
      status: SubscriptionStatus.cancelled,
      startDate: state.currentSubscription!.startDate,
      endDate: state.currentSubscription!.endDate,
      price: state.currentSubscription!.price,
      savings: state.currentSubscription!.savings,
      ridesUsed: state.currentSubscription!.ridesUsed,
      ridesLimit: state.currentSubscription!.ridesLimit,
      discountPercentage: state.currentSubscription!.discountPercentage,
    );

    state = state.copyWith(
      currentSubscription: cancelled,
      isLoading: false,
    );

    return true;
  }
}

final subscriptionProvider = NotifierProvider<SubscriptionNotifier, SubscriptionState>(
  SubscriptionNotifier.new,
);

