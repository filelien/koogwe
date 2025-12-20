import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/services/wallet_service.dart';

class WalletState {
  final double balance;
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> transactions;

  WalletState({
    this.balance = 0,
    this.isLoading = false,
    this.error,
    this.transactions = const [],
  });

  WalletState copyWith({
    double? balance,
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? transactions,
  }) => WalletState(
        balance: balance ?? this.balance,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        transactions: transactions ?? this.transactions,
      );
}

class WalletNotifier extends Notifier<WalletState> {
  final _svc = WalletService();

  @override
  WalletState build() {
    // Lazy initial load
    _refresh();
    return WalletState();
  }

  Future<void> _refresh() async {
    try {
      final bal = await _svc.getBalance();
      final tx = await _svc.listTransactions();
      state = state.copyWith(balance: bal, transactions: tx);
    } catch (e, st) {
      debugPrint('[WalletNotifier] refresh error: $e\n$st');
    }
  }

  Future<void> topUp(double amount) async {
    state = state.copyWith(isLoading: true, error: null);
    final ok = await _svc.topUp(amount);
    if (!ok) state = state.copyWith(error: 'Echec rechargement');
    await _refresh();
    state = state.copyWith(isLoading: false);
  }

  Future<void> withdraw(double amount) async {
    state = state.copyWith(isLoading: true, error: null);
    final ok = await _svc.withdraw(amount);
    if (!ok) state = state.copyWith(error: 'Echec retrait');
    await _refresh();
    state = state.copyWith(isLoading: false);
  }
}

final walletProvider = NotifierProvider<WalletNotifier, WalletState>(WalletNotifier.new);
