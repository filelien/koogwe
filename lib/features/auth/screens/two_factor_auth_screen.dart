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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un code à 6 chiffres')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // Vérifier le code 2FA via le provider d'authentification
      // Pour l'instant, simulation - à remplacer par l'appel réel au provider
      await Future.delayed(const Duration(seconds: 1)); // Simulation
      
      if (mounted) {
        // Rediriger vers la page appropriée selon le rôle de l'utilisateur connecté
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Code invalide. Veuillez réessayer.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resendCode() async {
    // TODO: Implémenter l'envoi d'un nouveau code
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code renvoyé')),
    );
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
