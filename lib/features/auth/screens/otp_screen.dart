import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:google_fonts/google_fonts.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOTP() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);
    if (mounted) context.go('/passenger/home');
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
                child: TextButton(
                  onPressed: () {
                    // TODO: Implémenter le renvoi du code OTP
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Code renvoyé')),
                    );
                  },
                  child: const Text('Renvoyer le code'),
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
