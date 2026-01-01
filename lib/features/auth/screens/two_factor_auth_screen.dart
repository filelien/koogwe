import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TwoFactorAuthScreen extends ConsumerStatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  ConsumerState<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

class _TwoFactorAuthScreenState extends ConsumerState<TwoFactorAuthScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  bool _useAuthenticatorApp = true; // Toggle entre SMS et Authenticator App

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify2FA() async {
    if (_codeController.text.length != 6) {
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
      bool success;
      
      if (_useAuthenticatorApp) {
        // Vérifier le code TOTP depuis l'app d'authentification
        success = await ref.read(authProvider.notifier).verify2FA(_codeController.text);
      } else {
        // Vérifier le code SMS
        final authState = ref.read(authProvider);
        final email = authState.user?.email;
        final phone = authState.user?.phoneNumber;
        success = await ref.read(authProvider.notifier).verifyOTP(
          _codeController.text,
          email: email,
          phone: phone,
        );
      }
      
      if (mounted) {
        if (success) {
          // Rediriger vers la page appropriée selon le rôle
          final authState = ref.read(authProvider);
          final userRole = authState.user?.role;
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
          final authState = ref.read(authProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authState.error ?? 'Code invalide. Veuillez réessayer.'),
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

  Future<void> _resendCode() async {
    if (_useAuthenticatorApp) {
      // Pour TOTP, on ne peut pas renvoyer - l'utilisateur doit utiliser son app
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Utilisez votre application d\'authentification pour obtenir un nouveau code'),
          backgroundColor: KoogweColors.info,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final authState = ref.read(authProvider);
      final email = authState.user?.email;
      final phone = authState.user?.phoneNumber;
      
      final success = await ref.read(authProvider.notifier).resendOTP(
        email: email,
        phone: phone,
        type: OtpType.sms,
      );

      if (mounted) {
        if (success) {
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
                            context.go('/login');
                          }
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(height: KoogweSpacing.xxl),
                      // Icône de sécurité
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: KoogweColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.security,
                            size: 40,
                            color: KoogweColors.primary,
                          ),
                        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                      ),
                      const SizedBox(height: KoogweSpacing.xxl),
                      Text(
                        'Authentification à deux facteurs',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.md),
                      Text(
                        _useAuthenticatorApp
                            ? 'Entrez le code à 6 chiffres depuis votre application d\'authentification'
                            : 'Entrez le code à 6 chiffres envoyé par SMS',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                      const SizedBox(height: KoogweSpacing.xxxl),
                      // Champ de code PIN
                      PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: KoogweRadius.mdRadius,
                          fieldHeight: 60,
                          fieldWidth: 50,
                          activeFillColor: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                          inactiveFillColor: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                          selectedFillColor: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                          activeColor: KoogweColors.primary,
                          inactiveColor: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                          selectedColor: KoogweColors.primary,
                        ),
                        enableActiveFill: true,
                        onCompleted: (v) => _verify2FA(),
                        onChanged: (value) {},
                      ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms, duration: 400.ms, begin: const Offset(0.95, 0.95)),
                      const SizedBox(height: KoogweSpacing.xl),
                      // Option pour changer de méthode
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _useAuthenticatorApp = !_useAuthenticatorApp;
                              _codeController.clear();
                            });
                          },
                          icon: Icon(
                            _useAuthenticatorApp ? Icons.sms : Icons.security,
                            size: 18,
                          ),
                          label: Text(
                            _useAuthenticatorApp
                                ? 'Utiliser le code SMS à la place'
                                : 'Utiliser l\'application d\'authentification',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: KoogweColors.primary,
                            ),
                          ),
                        ),
                      ),
                      // Bouton renvoyer le code (uniquement pour SMS)
                      if (!_useAuthenticatorApp)
                        Center(
                          child: TextButton(
                            onPressed: _resendCode,
                            child: Text(
                              'Renvoyer le code',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom + KoogweSpacing.xl),
                      KoogweButton(
                        text: 'Vérifier',
                        icon: Icons.check_circle_outline,
                        onPressed: _verify2FA,
                        isFullWidth: true,
                        size: ButtonSize.large,
                        isLoading: _isLoading,
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
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
