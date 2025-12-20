import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/providers/wallet_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(walletProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Portefeuille')),
      body: ListView(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        children: [
          Container(
            padding: const EdgeInsets.all(KoogweSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [KoogweColors.primary, KoogweColors.primaryLight]),
              borderRadius: KoogweRadius.xlRadius,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Solde actuel', style: GoogleFonts.inter(color: Colors.white70)),
                const SizedBox(height: 6),
                Text('€ ${state.balance.toStringAsFixed(2)}', style: GoogleFonts.inter(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const SizedBox(height: KoogweSpacing.xl),
          Text('Moyens de paiement', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: KoogweSpacing.md),
          _PaymentTile(
            icon: Icons.credit_card, 
            title: 'Carte bancaire', 
            subtitle: 'Visa •••• 4242', 
            onTap: () {
              // TODO: Ouvrir modal de gestion de carte bancaire
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gestion des cartes bancaires à venir')),
              );
            },
          ),
          _PaymentTile(
            icon: Icons.phone_iphone, 
            title: 'Mobile Money', 
            subtitle: 'Orange / MTN', 
            onTap: () {
              // TODO: Ouvrir modal de configuration Mobile Money
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuration Mobile Money à venir')),
              );
            },
          ),
          _PaymentTile(
            icon: Icons.attach_money, 
            title: 'Espèces', 
            subtitle: 'Payer en cash', 
            onTap: () {
              // Paiement en espèces disponible par défaut
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Paiement en espèces disponible')),
              );
            },
          ),
          const SizedBox(height: KoogweSpacing.xl),
          Text('Actions', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: KoogweSpacing.md),
          Row(children: [
            Expanded(child: _ActionBtn(label: 'Recharger', icon: Icons.add, onTap: () => ref.read(walletProvider.notifier).topUp(10))),
            const SizedBox(width: 12),
            Expanded(child: _ActionBtn(label: 'Retirer', icon: Icons.remove, onTap: () => ref.read(walletProvider.notifier).withdraw(10))),
          ]),
          const SizedBox(height: KoogweSpacing.xl),
          Text('Transactions', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: KoogweSpacing.md),
          for (final t in state.transactions)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                borderRadius: KoogweRadius.lgRadius,
                border: Border.all(color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
              ),
              child: ListTile(
                leading: Icon(
                  (t['credit'] ?? 0) > 0 ? Icons.arrow_downward : Icons.arrow_upward,
                  color: (t['credit'] ?? 0) > 0 ? KoogweColors.success : KoogweColors.error,
                ),
                title: Text('${t['type'] ?? 'transaction'}'),
                subtitle: Text('${t['created_at'] ?? ''}'),
                trailing: Text(
                  (t['credit'] ?? 0) > 0
                      ? '+€ ${((t['credit'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}'
                      : '-€ ${((t['debit'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _PaymentTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
        borderRadius: KoogweRadius.lgRadius,
        border: Border.all(color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
      ),
      child: ListTile(
        leading: Icon(icon, color: KoogweColors.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}

