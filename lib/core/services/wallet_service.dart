import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalletService {
  WalletService({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;
  final SupabaseClient _client;

  Future<double> getBalance() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return 0;
      // Try profiles.balance first
      final p = await _client.from('profiles').select('balance').eq('id', user.id).maybeSingle();
      final bal = (p?['balance'] as num?)?.toDouble();
      if (bal != null) return bal;
      // Fallback: compute from wallet_transactions sum(credit - debit)
      final tx = await listTransactions(limit: 500);
      final sum = tx.fold<double>(0, (acc, e) => acc + ((e['credit'] as num?)?.toDouble() ?? 0) - ((e['debit'] as num?)?.toDouble() ?? 0));
      return sum;
    } on PostgrestException catch (e) {
      debugPrint('[WalletService] getBalance pg error: ${e.message}');
      return 0;
    } catch (e, st) {
      debugPrint('[WalletService] getBalance error: $e\n$st');
      return 0;
    }
  }

  Future<bool> topUp(double amount) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      await _client.from('wallet_transactions').insert({
        'user_id': user.id,
        'credit': amount,
        'debit': 0,
        'type': 'topup',
        'created_at': DateTime.now().toIso8601String(),
      });
      // Try to update profiles.balance if column exists
      try {
        await _client.rpc('wallet_add_balance', params: {'uid': user.id, 'amount': amount});
      } catch (_) {
        // ignore: function may not exist; rely on computed balance
      }
      return true;
    } catch (e, st) {
      debugPrint('[WalletService] topUp error: $e\n$st');
      return false;
    }
  }

  Future<bool> withdraw(double amount) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return false;
      await _client.from('wallet_transactions').insert({
        'user_id': user.id,
        'credit': 0,
        'debit': amount,
        'type': 'withdrawal',
        'created_at': DateTime.now().toIso8601String(),
      });
      try {
        await _client.rpc('wallet_subtract_balance', params: {'uid': user.id, 'amount': amount});
      } catch (_) {}
      return true;
    } catch (e, st) {
      debugPrint('[WalletService] withdraw error: $e\n$st');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> listTransactions({int limit = 100}) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return const [];
      final res = await _client
          .from('wallet_transactions')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(limit);
      return (res as List).cast<Map<String, dynamic>>();
    } on PostgrestException catch (e) {
      debugPrint('[WalletService] listTransactions pg error: ${e.message}');
      return const [];
    } catch (e, st) {
      debugPrint('[WalletService] listTransactions error: $e\n$st');
      return const [];
    }
  }
}
