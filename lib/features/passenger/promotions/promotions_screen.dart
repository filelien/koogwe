import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class PromotionsScreen extends ConsumerStatefulWidget {
  const PromotionsScreen({super.key});

  @override
  ConsumerState<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends ConsumerState<PromotionsScreen> {
  final TextEditingController _codeController = TextEditingController();
  final List<Promotion> _promotions = [
    Promotion(
      id: '1',
      title: 'Première course offerte',
      description: 'Gagnez 10€ de réduction sur votre première course',
      code: 'WELCOME10',
      discount: 10.0,
      discountType: DiscountType.amount,
      validUntil: DateTime.now().add(const Duration(days: 30)),
      isActive: true,
      color: KoogweColors.primary,
    ),
    Promotion(
      id: '2',
      title: 'Réduction 20%',
      description: 'Profitez de 20% de réduction sur tous vos trajets ce week-end',
      code: 'WEEKEND20',
      discount: 20.0,
      discountType: DiscountType.percentage,
      validUntil: DateTime.now().add(const Duration(days: 5)),
      isActive: true,
      color: KoogweColors.accent,
    ),
    Promotion(
      id: '3',
      title: 'Parrainage',
      description: 'Invitez un ami et recevez 15€ chacun',
      code: 'FRIEND15',
      discount: 15.0,
      discountType: DiscountType.amount,
      validUntil: DateTime.now().add(const Duration(days: 60)),
      isActive: true,
      color: KoogweColors.secondary,
    ),
  ];

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientBackground(
      useDarkAurora: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Promotions & Codes',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(KoogweSpacing.lg),
            children: [
              // Section saisie de code
              GlassCard(
                borderRadius: KoogweRadius.lgRadius,
                child: Padding(
                  padding: const EdgeInsets.all(KoogweSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vous avez un code promo ?',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: KoogweSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _codeController,
                              decoration: InputDecoration(
                                hintText: 'Entrez votre code',
                                prefixIcon: const Icon(Icons.local_offer),
                                border: OutlineInputBorder(
                                  borderRadius: KoogweRadius.mdRadius,
                                  borderSide: BorderSide(
                                    color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                                  ),
                                ),
                              ),
                              textCapitalization: TextCapitalization.characters,
                            ),
                          ),
                          const SizedBox(width: KoogweSpacing.md),
                          ElevatedButton(
                            onPressed: () => _applyCode(_codeController.text),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KoogweColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: KoogweSpacing.xl),
                            ),
                            child: const Text('Appliquer'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),

              const SizedBox(height: KoogweSpacing.xl),

              // Liste des promotions
              Text(
                'Promotions disponibles',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: KoogweSpacing.md),
              
              ..._promotions.map((promo) {
                final index = _promotions.indexOf(promo);
                return _PromotionCard(
                  promotion: promo,
                  isDark: isDark,
                  onTap: () => _showPromoDetails(promo),
                  onShare: () => _sharePromo(promo),
                  onCopy: () => _copyCode(promo.code),
                ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0);
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _applyCode(String code) {
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un code')),
      );
      return;
    }

    final promo = _promotions.firstWhere(
      (p) => p.code.toUpperCase() == code.toUpperCase(),
      orElse: () => Promotion.empty(),
    );

    if (promo.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Code invalide'),
          backgroundColor: KoogweColors.error,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Code ${promo.code} appliqué avec succès !'),
          backgroundColor: KoogweColors.success,
        ),
      );
      _codeController.clear();
    }
  }

  void _showPromoDetails(Promotion promo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _PromoDetailSheet(promotion: promo),
    );
  }

  Future<void> _sharePromo(Promotion promo) async {
    await SharePlus.instance.share(ShareParams(
      text: 'Utilisez le code ${promo.code} sur KOOGWE ! ${promo.description}',
    ));
  }

  void _copyCode(String code) {
    // Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Code $code copié !')),
    );
  }
}

class _PromotionCard extends StatelessWidget {
  final Promotion promotion;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final VoidCallback onCopy;

  const _PromotionCard({
    required this.promotion,
    required this.isDark,
    required this.onTap,
    required this.onShare,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final isValid = promotion.validUntil.isAfter(DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(bottom: KoogweSpacing.md),
      child: GlassCard(
        borderRadius: KoogweRadius.lgRadius,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                promotion.color,
                promotion.color.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: KoogweRadius.lgRadius,
          ),
          padding: const EdgeInsets.all(KoogweSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promotion.title,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          promotion.description,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: KoogweSpacing.md, vertical: KoogweSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      promotion.discountType == DiscountType.percentage
                          ? '${promotion.discount.toInt()}%'
                          : '€${promotion.discount.toInt()}',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KoogweSpacing.md),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: KoogweSpacing.md, vertical: KoogweSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      promotion.code,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isValid)
                    Text(
                      'Valide jusqu\'au ${DateFormat('dd/MM/yyyy').format(promotion.validUntil)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: KoogweSpacing.sm, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'EXPIRÉ',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: KoogweSpacing.md),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copier'),
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                  ),
                  const SizedBox(width: KoogweSpacing.sm),
                  TextButton.icon(
                    onPressed: onShare,
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Partager'),
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoDetailSheet extends StatelessWidget {
  final Promotion promotion;

  const _PromoDetailSheet({required this.promotion});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(KoogweSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: KoogweSpacing.xl),
              decoration: BoxDecoration(
                color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            promotion.title,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: KoogweSpacing.md),
          Text(
            promotion.description,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: KoogweSpacing.xl),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: promotion.color,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text('Utiliser ce code : ${promotion.code}'),
          ),
        ],
      ),
    );
  }
}

enum DiscountType { amount, percentage }

class Promotion {
  final String id;
  final String title;
  final String description;
  final String code;
  final double discount;
  final DiscountType discountType;
  final DateTime validUntil;
  final bool isActive;
  final Color color;

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    required this.discount,
    required this.discountType,
    required this.validUntil,
    required this.isActive,
    required this.color,
  });

  factory Promotion.empty() => Promotion(
        id: '',
        title: '',
        description: '',
        code: '',
        discount: 0,
        discountType: DiscountType.amount,
        validUntil: DateTime.now(),
        isActive: false,
        color: Colors.grey,
      );
}

