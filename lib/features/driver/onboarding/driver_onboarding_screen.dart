import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:koogwe/core/services/driver_service.dart';
import 'package:koogwe/core/router/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class DriverOnboardingScreen extends ConsumerStatefulWidget {
  const DriverOnboardingScreen({super.key});

  @override
  ConsumerState<DriverOnboardingScreen> createState() => _DriverOnboardingScreenState();
}

class _DriverOnboardingScreenState extends ConsumerState<DriverOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _licenseController = TextEditingController();
  DateTime? _licenseExpiry;
  final _service = DriverService();
  bool _isLoading = false;
  int _currentStep = 0;
  
  // Documents
  File? _licenseFile;
  File? _insuranceFile;
  File? _registrationFile;
  File? _identityFile;

  @override
  void dispose() {
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument(String documentType) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        final file = File(image.path);
        switch (documentType) {
          case 'license':
            _licenseFile = file;
            break;
          case 'insurance':
            _insuranceFile = file;
            break;
          case 'registration':
            _registrationFile = file;
            break;
          case 'identity':
            _identityFile = file;
            break;
        }
      });
    }
  }

  Future<void> _submitOnboarding() async {
    if (!_formKey.currentState!.validate()) return;
    if (_licenseFile == null || _insuranceFile == null || _registrationFile == null || _identityFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez uploader tous les documents requis')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Créer le profil chauffeur
      await _service.createOrUpdateDriver(
        licenseNumber: _licenseController.text,
        licenseExpiry: _licenseExpiry,
      );

      // Upload des documents
      await _service.uploadDocument(documentType: 'license', filePath: _licenseFile!.path);
      await _service.uploadDocument(documentType: 'insurance', filePath: _insuranceFile!.path);
      await _service.uploadDocument(documentType: 'registration', filePath: _registrationFile!.path);
      await _service.uploadDocument(documentType: 'identity', filePath: _identityFile!.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Votre demande a été soumise. En attente de validation.')),
        );
        context.go(AppRoutes.driverHome);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
            'Onboarding Chauffeur',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
        ),
        body: SafeArea(
          child: Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 2) {
                setState(() => _currentStep++);
              } else {
                _submitOnboarding();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              }
            },
            steps: [
              Step(
                title: const Text('Informations de base'),
                content: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _licenseController,
                        decoration: const InputDecoration(
                          labelText: 'Numéro de permis',
                          hintText: 'Ex: 123456789',
                        ),
                        validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                      ),
                      const SizedBox(height: KoogweSpacing.md),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 3650)),
                          );
                          if (date != null) {
                            setState(() => _licenseExpiry = date);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date d\'expiration du permis',
                          ),
                          child: Text(
                            _licenseExpiry?.toString().split(' ')[0] ?? 'Sélectionner une date',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Step(
                title: const Text('Documents requis'),
                content: Column(
                  children: [
                    _DocumentUploadCard(
                      title: 'Permis de conduire',
                      file: _licenseFile,
                      onTap: () => _pickDocument('license'),
                    ),
                    const SizedBox(height: KoogweSpacing.md),
                    _DocumentUploadCard(
                      title: 'Assurance',
                      file: _insuranceFile,
                      onTap: () => _pickDocument('insurance'),
                    ),
                    const SizedBox(height: KoogweSpacing.md),
                    _DocumentUploadCard(
                      title: 'Carte grise',
                      file: _registrationFile,
                      onTap: () => _pickDocument('registration'),
                    ),
                    const SizedBox(height: KoogweSpacing.md),
                    _DocumentUploadCard(
                      title: 'Pièce d\'identité',
                      file: _identityFile,
                      onTap: () => _pickDocument('identity'),
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('Confirmation'),
                content: Column(
                  children: [
                    Text(
                      'Votre demande sera examinée par notre équipe. Vous recevrez une notification une fois votre compte approuvé.',
                      style: GoogleFonts.inter(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: KoogweSpacing.xl),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      KoogweButton(
                        text: 'Soumettre',
                        icon: Icons.check,
                        onPressed: _submitOnboarding,
                        isFullWidth: true,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentUploadCard extends StatelessWidget {
  final String title;
  final File? file;
  final VoidCallback onTap;

  const _DocumentUploadCard({
    required this.title,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: KoogweRadius.lgRadius,
      child: GlassCard(
        padding: const EdgeInsets.all(KoogweSpacing.md),
        child: Row(
          children: [
            Icon(
              file != null ? Icons.check_circle : Icons.upload_file,
              color: file != null ? KoogweColors.success : KoogweColors.primary,
            ),
            const SizedBox(width: KoogweSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  if (file != null)
                    Text(
                      file!.path.split('/').last,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

