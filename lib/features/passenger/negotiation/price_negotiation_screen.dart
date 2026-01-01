import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/price_negotiation_provider.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:koogwe/core/widgets/koogwe_text_field.dart';
import 'package:google_fonts/google_fonts.dart';

class PriceNegotiationScreen extends ConsumerStatefulWidget {
  const PriceNegotiationScreen({super.key});

  @override
  ConsumerState<PriceNegotiationScreen> createState() => _PriceNegotiationScreenState();
}

class _PriceNegotiationScreenState extends ConsumerState<PriceNegotiationScreen> {
  final _priceController = TextEditingController();
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final double _initialPrice = 30.0;

  @override
  void dispose() {
    _priceController.dispose();
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  Future<void> _startNegotiation() async {
    if (_priceController.text.isEmpty || _pickupController.text.isEmpty || _dropoffController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final suggestedPrice = double.tryParse(_priceController.text.replaceAll(',', '.'));
    if (suggestedPrice == null || suggestedPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prix invalide')),
      );
      return;
    }

    if (suggestedPrice > _initialPrice * 1.2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Le prix proposé ne peut pas dépasser ${(_initialPrice * 1.2).toStringAsFixed(2)}€')),
      );
      return;
    }

    await ref.read(priceNegotiationProvider.notifier).startNegotiation(
      initialPrice: _initialPrice,
      suggestedPrice: suggestedPrice,
      pickup: _pickupController.text,
      dropoff: _dropoffController.text,
    );
  }

  Future<void> _submitCounterOffer() async {
    final price = double.tryParse(_priceController.text.replaceAll(',', '.'));
    if (price == null || price <= 0) return;

    await ref.read(priceNegotiationProvider.notifier).submitCounterOffer(price, true);
    _priceController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(priceNegotiationProvider);
    final negotiation = state.currentNegotiation;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prix transparent'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (negotiation == null) ...[
              // Formulaire initial
              Text(
                'Proposez votre prix',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                ),
              ).animate().fadeIn().slideX(begin: -0.2, end: 0),
              const SizedBox(height: KoogweSpacing.md),
              Text(
                'Suggérez le prix que vous souhaitez payer pour ce trajet',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                ),
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: KoogweSpacing.xxxl),
              
              Container(
                padding: const EdgeInsets.all(KoogweSpacing.lg),
                decoration: BoxDecoration(
                  color: KoogweColors.primary.withValues(alpha: 0.1),
                  borderRadius: KoogweRadius.lgRadius,
                  border: Border.all(color: KoogweColors.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Prix estimé standard',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: KoogweColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_initialPrice.toStringAsFixed(2)}€',
                      style: GoogleFonts.inter(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: KoogweColors.primary,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).scale(),
              
              const SizedBox(height: KoogweSpacing.xl),
              
              KoogweTextField(
                controller: _pickupController,
                hint: 'Lieu de prise en charge',
                prefixIcon: Icon(Icons.my_location, color: KoogweColors.success),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: KoogweSpacing.lg),
              
              KoogweTextField(
                controller: _dropoffController,
                hint: 'Destination',
                prefixIcon: Icon(Icons.location_on, color: KoogweColors.error),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: KoogweSpacing.xl),
              
              Text(
                'Votre prix proposé',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: KoogweSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: KoogweTextField(
                      controller: _priceController,
                      hint: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: const Text('€', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: KoogweSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                      borderRadius: KoogweRadius.mdRadius,
                    ),
                    child: Icon(Icons.euro, color: KoogweColors.primary),
                  ),
                ],
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
              
              const SizedBox(height: KoogweSpacing.xxxl),
              
              KoogweButton(
                text: 'Lancer la négociation',
                icon: Icons.handshake,
                onPressed: state.isLoading ? null : _startNegotiation,
                isFullWidth: true,
                size: ButtonSize.large,
                isLoading: state.isLoading,
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
            ] else ...[
              // Interface de négociation en cours
              _buildNegotiationUI(negotiation, isDark, state),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNegotiationUI(negotiation, bool isDark, negotiationState) {
    final status = negotiation.status;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          status == NegotiationStatus.accepted
              ? 'Négociation acceptée !'
              : status == NegotiationStatus.rejected
                  ? 'Négociation refusée'
                  : 'Négociation en cours',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: status == NegotiationStatus.accepted
                ? KoogweColors.success
                : status == NegotiationStatus.rejected
                    ? KoogweColors.error
                    : (isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary),
          ),
        ).animate().fadeIn().slideX(begin: -0.2, end: 0),
        
        const SizedBox(height: KoogweSpacing.xxxl),
        
        // Historique des offres
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Historique des offres',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: KoogweSpacing.lg),
              ...negotiation.offers.map((offer) => Container(
                margin: const EdgeInsets.only(bottom: KoogweSpacing.md),
                padding: const EdgeInsets.all(KoogweSpacing.md),
                decoration: BoxDecoration(
                  color: offer.isFromPassenger
                      ? KoogweColors.primary.withValues(alpha: 0.1)
                      : KoogweColors.secondary.withValues(alpha: 0.1),
                  borderRadius: KoogweRadius.mdRadius,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          offer.isFromPassenger ? Icons.person : Icons.drive_eta,
                          color: offer.isFromPassenger ? KoogweColors.primary : KoogweColors.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: KoogweSpacing.sm),
                        Text(
                          offer.isFromPassenger ? 'Vous' : 'Chauffeur',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${offer.amount.toStringAsFixed(2)}€',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: offer.isFromPassenger ? KoogweColors.primary : KoogweColors.secondary,
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        
        const SizedBox(height: KoogweSpacing.xl),
        
        // Prix actuel suggéré
        Container(
          padding: const EdgeInsets.all(KoogweSpacing.xl),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [KoogweColors.primary, KoogweColors.primaryDark],
            ),
            borderRadius: KoogweRadius.lgRadius,
          ),
          child: Column(
            children: [
              Text(
                'Prix actuel',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${negotiation.suggestedPrice.toStringAsFixed(2)}€',
                style: GoogleFonts.inter(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms).scale(),
        
        if (status == NegotiationStatus.negotiating || status == NegotiationStatus.waiting) ...[
          const SizedBox(height: KoogweSpacing.xl),
          
          Row(
            children: [
              Expanded(
                child: KoogweTextField(
                  controller: _priceController,
                  hint: 'Contre-offre',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Text('€', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: KoogweSpacing.md),
              KoogweButton(
                text: 'Envoyer',
                icon: Icons.send,
                onPressed: negotiationState.isLoading ? null : _submitCounterOffer,
                isLoading: negotiationState.isLoading,
              ),
            ],
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
          
          const SizedBox(height: KoogweSpacing.md),
          
          Row(
            children: [
              Expanded(
                child: KoogweButton(
                  text: 'Accepter',
                  onPressed: negotiationState.isLoading
                      ? null
                      : () async {
                          await ref.read(priceNegotiationProvider.notifier).acceptOffer();
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Négociation acceptée !')),
                          );
                        },
                  variant: ButtonVariant.gradient,
                  isLoading: negotiationState.isLoading,
                ),
              ),
              const SizedBox(width: KoogweSpacing.md),
              Expanded(
                child: KoogweButton(
                  text: 'Refuser',
                  onPressed: negotiationState.isLoading
                      ? null
                      : () async {
                          await ref.read(priceNegotiationProvider.notifier).rejectNegotiation();
                        },
                  variant: ButtonVariant.outline,
                  customColor: KoogweColors.error,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
        ] else if (status == NegotiationStatus.accepted) ...[
          const SizedBox(height: KoogweSpacing.xl),
          KoogweButton(
            text: 'Confirmer la course',
            icon: Icons.check_circle,
            onPressed: () {
              // Rediriger vers la confirmation de course
              context.pop();
              context.push('/passenger/ride-preview');
            },
            isFullWidth: true,
            size: ButtonSize.large,
            variant: ButtonVariant.gradient,
          ),
        ],
      ],
    );
  }
}

