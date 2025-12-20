import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/auth_provider.dart';
import 'package:koogwe/core/providers/role_selection_provider.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:koogwe/core/widgets/koogwe_text_field.dart';
import 'package:koogwe/core/widgets/country_phone_field.dart';
import 'package:koogwe/core/widgets/password_strength_indicator.dart';
import 'package:koogwe/core/validators/password_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_strings.dart';
import 'package:country_picker/country_picker.dart';
import 'package:easy_localization/easy_localization.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  Country _selectedCountry = Country.parse('GF'); // Guyane par défaut
  PasswordValidationResult? _passwordValidation;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordController.removeListener(_validatePassword);
    super.dispose();
  }

  void _validatePassword() {
    setState(() {
      _passwordValidation = PasswordValidator.validate(_passwordController.text);
    });
  }

  Future<void> _handleRegister() async {
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('terms_accept_required'.tr())),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Construire le numéro complet avec l'indice
      final fullPhoneNumber = '+${_selectedCountry.phoneCode}${_phoneController.text.replaceAll(RegExp(r'\s+'), '')}';
      
      // Obtenir le rôle sélectionné ou utiliser passenger par défaut
      final selectedRole = ref.read(selectedRoleProvider) ?? UserRole.passenger;
      
      await ref.read(authProvider.notifier).register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: fullPhoneNumber,
        role: selectedRole,
      );
      
      if (mounted && ref.read(authProvider).isAuthenticated) {
        // Rediriger vers la page appropriée selon le rôle
        final userRole = selectedRole;
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    
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
                  child: Form(
                    key: _formKey,
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
                        const SizedBox(height: KoogweSpacing.xl),
                        Text(
                          'create_account'.tr(),
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: KoogweSpacing.sm),
                        Text(
                          'join_today'.tr().replaceAll('{app}', AppStrings.appName),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: KoogweSpacing.xxl),
                        Row(
                          children: [
                            Expanded(
                              child: KoogweTextField(
                                label: 'first_name'.tr(),
                                hint: 'Jean',
                                controller: _firstNameController,
                                validator: (v) => v!.isEmpty ? 'required_field'.tr() : null,
                              ),
                            ),
                            const SizedBox(width: KoogweSpacing.md),
                            Expanded(
                              child: KoogweTextField(
                                label: 'last_name'.tr(),
                                hint: 'Dupont',
                                controller: _lastNameController,
                                validator: (v) => v!.isEmpty ? 'required_field'.tr() : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: KoogweSpacing.lg),
                        KoogweTextField(
                          label: 'email'.tr(),
                          hint: 'votre@email.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'required_field'.tr();
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'invalid_email'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: KoogweSpacing.lg),
                        // Nouveau champ avec sélection de pays
                        CountryPhoneField(
                          label: 'phone_number'.tr(),
                          hint: '694 12 34 56',
                          phoneController: _phoneController,
                          initialCountry: _selectedCountry,
                          onCountryChanged: (country) {
                            setState(() {
                              _selectedCountry = country;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'required_field'.tr();
                            }
                            // Valider que c'est un numéro valide
                            if (!RegExp(r'^[0-9\s\-]+$').hasMatch(value)) {
                              return 'invalid_phone'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: KoogweSpacing.lg),
                        // Champ mot de passe avec indicateur de force
                        KoogweTextField(
                          label: 'password'.tr(),
                          hint: '••••••••',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'required_field'.tr();
                            }
                            final validation = PasswordValidator.validate(value);
                            if (!validation.isValid) {
                              return 'weak_password'.tr();
                            }
                            return null;
                          },
                        ),
                        if (_passwordValidation != null) ...[
                          const SizedBox(height: KoogweSpacing.sm),
                          PasswordStrengthIndicator(
                            password: _passwordController.text,
                            validationResult: _passwordValidation,
                          ),
                        ],
                        const SizedBox(height: KoogweSpacing.lg),
                        KoogweTextField(
                          label: 'confirm_password'.tr(),
                          hint: '••••••••',
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'passwords_not_match'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: KoogweSpacing.lg),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _acceptedTerms,
                              onChanged: (value) => setState(() => _acceptedTerms = value!),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
                                child: Text(
                                  'accept_terms'.tr(),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: KoogweSpacing.xl),
                        if (authState.error != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(KoogweSpacing.md),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              border: Border.all(color: Colors.amber),
                              borderRadius: KoogweRadius.mdRadius,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Colors.amber),
                                const SizedBox(width: KoogweSpacing.sm),
                                Expanded(
                                  child: Text(
                                    authState.error!,
                                    style: GoogleFonts.inter(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: KoogweSpacing.md),
                        ],
                        KoogweButton(
                          text: 'register'.tr(),
                          onPressed: _handleRegister,
                          isFullWidth: true,
                          size: ButtonSize.large,
                          isLoading: authState.isLoading,
                        ),
                        const SizedBox(height: KoogweSpacing.xl),
                        Center(
                          child: Wrap(
                            spacing: 4,
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'already_have_account'.tr(),
                                style: GoogleFonts.inter(
                                  color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: () => context.go('/login'),
                                child: Text('login'.tr()),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
