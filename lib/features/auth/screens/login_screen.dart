import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/auth_provider.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:koogwe/core/widgets/koogwe_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:koogwe/core/constants/app_strings.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authProvider.notifier).login(
        _emailController.text,
        _passwordController.text,
      );
      
      if (mounted && ref.read(authProvider).isAuthenticated) {
        final authState = ref.read(authProvider);
        final user = authState.user;
        if (user != null) {
          // Redirect based on user role
                                        switch (user.role) {
                                          case UserRole.admin:
                                            context.go('/admin/dashboard');
                                            break;
                                          case UserRole.driver:
                                            context.go('/driver/home');
                                            break;
                                          case UserRole.business:
                                            context.go('/business/dashboard');
                                            break;
                                          case UserRole.passenger:
                                            context.go('/passenger/home');
                                            break;
                                        }
        } else {
          context.go('/passenger/home');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      body: Stack(
        children: [
          // Violet gradient background
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF3E8FF), Colors.white],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: KoogweSpacing.xl,
                    right: KoogweSpacing.xl,
                    top: KoogweSpacing.xl,
                    bottom: MediaQuery.of(context).viewInsets.bottom + KoogweSpacing.xl,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                  // Top nav/back
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: KoogweRadius.fullRadius,
                      border: Border.all(color: KoogweColors.lightBorder, width: 1),
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home-hero');
                        }
                      },
                      icon: Icon(Icons.arrow_back, color: KoogweColors.primary),
                    ),
                  ),
                  const SizedBox(height: KoogweSpacing.xxxl),
                  // Floating form card centered
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Card(
                        elevation: 0,
                        color: isDark ? KoogweColors.darkSurface : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: KoogweRadius.xlRadius),
                        child: Padding(
                          padding: const EdgeInsets.all(KoogweSpacing.xxl),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.welcome,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: KoogweColors.primaryLight,
                                  ),
                                ),
                                const SizedBox(height: KoogweSpacing.xs),
                                Text(
                                  'Bon retour !',
                                  style: GoogleFonts.inter(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightOnBackground,
                                  ),
                                ),
                                const SizedBox(height: KoogweSpacing.xxl),
                                KoogweTextField(
                                  label: 'Email',
                                  hint: 'votre@email.com',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer votre email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Email invalide';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: KoogweSpacing.lg),
                                KoogweTextField(
                                  label: 'Mot de passe',
                                  hint: '••••••••',
                                  controller: _passwordController,
                                  obscureText: true,
                                  prefixIcon: const Icon(Icons.lock_outlined),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Veuillez entrer votre mot de passe';
                                    }
                                    if (value.length < 6) {
                                      return 'Le mot de passe doit contenir au moins 6 caractères';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: KoogweSpacing.md),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () => context.push('/forgot-password'),
                                    child: const Text('Mot de passe oublié ?'),
                                  ),
                                ),
                                const SizedBox(height: KoogweSpacing.xl),
                                if (authState.error != null) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(KoogweSpacing.md),
                                    decoration: BoxDecoration(
                                      color: authState.error!.contains('confirmé') || authState.error!.contains('confirmation')
                                          ? Colors.blue.withValues(alpha: 0.2)
                                          : Colors.amber.withValues(alpha: 0.2),
                                      border: Border.all(
                                        color: authState.error!.contains('confirmé') || authState.error!.contains('confirmation')
                                            ? Colors.blue
                                            : Colors.amber,
                                      ),
                                      borderRadius: KoogweRadius.mdRadius,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              authState.error!.contains('confirmé') || authState.error!.contains('confirmation')
                                                  ? Icons.email_outlined
                                                  : Icons.info_outline,
                                              color: authState.error!.contains('confirmé') || authState.error!.contains('confirmation')
                                                  ? Colors.blue
                                                  : Colors.amber,
                                            ),
                                            const SizedBox(width: KoogweSpacing.sm),
                                            Expanded(
                                              child: Text(
                                                authState.error == 'google_provider_disabled'
                                                    ? 'google_provider_disabled'.tr()
                                                    : authState.error!,
                                                style: GoogleFonts.inter(),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if ((authState.error!.contains('confirmé') || authState.error!.contains('confirmation')) && 
                                            !authState.error!.contains('renvoyer')) ...[
                                          const SizedBox(height: KoogweSpacing.md),
                                          KoogweButton(
                                            text: 'Renvoyer l\'email de confirmation',
                                            onPressed: () async {
                                              final messenger = ScaffoldMessenger.of(context);
                                              await ref.read(authProvider.notifier).resendConfirmationEmail(
                                                _emailController.text.trim(),
                                              );
                                              if (mounted) {
                                                messenger.showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Email de confirmation renvoyé ! Vérifiez votre boîte de réception.'),
                                                    backgroundColor: Colors.green,
                                                  ),
                                                );
                                              }
                                            },
                                            isFullWidth: true,
                                            variant: ButtonVariant.outline,
                                            size: ButtonSize.small,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: KoogweSpacing.md),
                                ],
                                // Primary button: strong, high-contrast
                                KoogweButton(
                                  text: 'Se connecter',
                                  onPressed: _handleLogin,
                                  isFullWidth: true,
                                  size: ButtonSize.large,
                                  isLoading: authState.isLoading,
                                  variant: ButtonVariant.gradient,
                                  gradientColors: [KoogweColors.secondary, KoogweColors.secondaryLight],
                                ),
                                const SizedBox(height: KoogweSpacing.lg),
                                KoogweButton(
                                  text: 'Connexion avec Google',
                                  onPressed: () async {
                                    await ref.read(authProvider.notifier).signInWithGoogle();
                                    if (!mounted) return;
                                    final authState = ref.read(authProvider);
                                    if (authState.isAuthenticated && context.mounted) {
                                      final user = authState.user;
                                      if (user != null) {
                                        // Redirect based on user role
                                        switch (user.role) {
                                          case UserRole.admin:
                                            context.go('/admin/dashboard');
                                            break;
                                          case UserRole.driver:
                                            context.go('/driver/home');
                                            break;
                                          case UserRole.business:
                                            context.go('/business/dashboard');
                                            break;
                                          case UserRole.passenger:
                                            context.go('/passenger/home');
                                            break;
                                        }
                                      } else {
                                        context.go('/passenger/home');
                                      }
                                    }
                                  },
                                  isFullWidth: true,
                                  size: ButtonSize.large,
                                  variant: ButtonVariant.outline,
                                  // Use a neutral login icon for accessibility and visibility
                                  icon: Icons.login,
                                ),
                                const SizedBox(height: KoogweSpacing.xl),
                                Wrap(
                                  spacing: 4,
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'Pas encore de compte ? ',
                                      style: GoogleFonts.inter(
                                        color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => context.go('/register'),
                                      child: const Text('Inscrivez-vous'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
          ),
        ],
      ),
    );
  }
}
