import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/providers/auth_provider.dart';

class OTPScreen extends ConsumerStatefulWidget {
  final String? email;
  final String? phone;
  
  const OTPScreen({super.key, this.email, this.phone});

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  bool _canResend = true;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    // Démarrer le cooldown de 60 secondes
    _startResendCooldown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    _canResend = false;
    _resendCooldown = 60;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _resendCooldown--;
          if (_resendCooldown <= 0) {
            _canResend = true;
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Veuillez entrer un code à 6 chiffres'),
            backgroundColor: KoogweColors.error,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final success = await ref.read(authProvider.notifier).verifyOTP(
        _otpController.text,
        email: widget.email,
        phone: widget.phone,
      );

      if (mounted) {
        if (success) {
          // Rediriger selon le rôle
          final authStateAfter = ref.read(authProvider);
          final userRole = authStateAfter.user?.role;
          if (userRole == UserRole.driver) {
            context.go('/driver/home');
          } else if (userRole == UserRole.business) {
            context.go('/business/dashboard');
          } else if (userRole == UserRole.admin) {
            context.go('/admin/dashboard');
          } else {
            context.go('/passenger/home');
          }
        } else {
          final authStateAfter = ref.read(authProvider);
          final error = authStateAfter.error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Code invalide. Veuillez réessayer.'),
              backgroundColor: KoogweColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la vérification: $e'),
            backgroundColor: KoogweColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendOTP() async {
    if (!_canResend) return;

    setState(() => _isLoading = true);
    
    try {
      final success = await ref.read(authProvider.notifier).resendOTP(
        email: widget.email,
        phone: widget.phone,
      );

      if (mounted) {
        if (success) {
          _startResendCooldown();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Code renvoyé avec succès'),
              backgroundColor: KoogweColors.success,
            ),
          );
        } else {
          final authState = ref.read(authProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.error ?? 'Erreur lors de l\'envoi du code'),
              backgroundColor: KoogweColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: KoogweColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: KoogweSpacing.xl,
                    right: KoogweSpacing.xl,
                    top: KoogweSpacing.xl,
                    bottom: MediaQuery.of(context).viewInsets.bottom + KoogweSpacing.xl,
                  ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home-hero');
                  }
                },
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(height: KoogweSpacing.xxl),
              Text(
                'Vérification',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                   color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: KoogweSpacing.sm),
              Text(
                'Entrez le code à 6 chiffres envoyé à votre téléphone',
                style: GoogleFonts.inter(
                  fontSize: 16,
                   color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: KoogweSpacing.xxxl),
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _otpController,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 56,
                  fieldWidth: 48,
                   activeFillColor: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                   inactiveFillColor: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                   selectedFillColor: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                   activeColor: KoogweColors.primary,
                   inactiveColor: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                   selectedColor: KoogweColors.primary,
                ),
                enableActiveFill: true,
                onCompleted: (v) => _verifyOTP(),
                onChanged: (value) {},
              ),
              const SizedBox(height: KoogweSpacing.xl),
              Center(
                child: _canResend
                    ? TextButton(
                        onPressed: _isLoading ? null : _resendOTP,
                        child: Text(
                          'Renvoyer le code',
                          style: GoogleFonts.inter(
                            color: KoogweColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : Text(
                        'Renvoyer dans ${_resendCooldown}s',
                        style: GoogleFonts.inter(
                          color: isDark 
                              ? KoogweColors.darkTextTertiary 
                              : KoogweColors.lightTextTertiary,
                          fontSize: 14,
                        ),
                      ),
              ),
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom + KoogweSpacing.xl),
              KoogweButton(
                text: 'Vérifier',
                onPressed: _verifyOTP,
                isFullWidth: true,
                size: ButtonSize.large,
                isLoading: _isLoading,
              ),
            ],
          ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
