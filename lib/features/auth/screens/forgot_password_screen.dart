import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:koogwe/core/widgets/koogwe_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        _emailController.text.trim(),
        redirectTo: 'koogwe://login-callback',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lien de réinitialisation envoyé à votre email')),
      );
      context.pop();
    } on AuthApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'envoi du lien')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.all(KoogweSpacing.xl),
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
                'Mot de passe oublié ?',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                   color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: KoogweSpacing.sm),
              Text(
                'Entrez votre email pour recevoir un lien de réinitialisation',
                style: GoogleFonts.inter(
                  fontSize: 16,
                   color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: KoogweSpacing.xxxl),
              KoogweTextField(
                label: 'Email',
                hint: 'votre@email.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
              ),
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom + KoogweSpacing.xl),
              KoogweButton(
                text: 'Envoyer le lien',
                onPressed: _sendResetLink,
                isFullWidth: true,
                size: ButtonSize.large,
                isLoading: _isLoading,
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
