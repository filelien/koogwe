import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/services/supabase_service.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:koogwe/core/config/env.dart';
import 'package:koogwe/core/widgets/supabase_status_widget.dart';

class SupabaseTestScreen extends StatefulWidget {
  const SupabaseTestScreen({super.key});

  @override
  State<SupabaseTestScreen> createState() => _SupabaseTestScreenState();
}

class _SupabaseTestScreenState extends State<SupabaseTestScreen> {
  final List<TestResult> _testResults = [];
  bool _isRunning = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Supabase'),
        backgroundColor: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(KoogweSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Text(
                'Tests de Connexion Supabase',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: KoogweSpacing.md),
              Text(
                'Vérifiez que l\'application communique correctement avec la base de données',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: KoogweSpacing.xl),

              // Widget de statut Supabase
              const SupabaseStatusWidget(),
              const SizedBox(height: KoogweSpacing.lg),

              // Configuration actuelle
              Container(
                padding: const EdgeInsets.all(KoogweSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Configuration actuelle',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: KoogweSpacing.sm),
                    Text(
                      'URL: ${Env.supabaseUrl.isEmpty ? "NON CONFIGURÉE" : Env.supabaseUrl}',
                      style: GoogleFonts.robotoMono(
                        fontSize: 12,
                        color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Key: ${Env.supabaseAnonKey.isEmpty ? "NON CONFIGURÉE" : "${Env.supabaseAnonKey.substring(0, Env.supabaseAnonKey.length > 30 ? 30 : Env.supabaseAnonKey.length)}..."}',
                      style: GoogleFonts.robotoMono(
                        fontSize: 12,
                        color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                      ),
                    ),
                    if (Env.supabaseUrl.isEmpty || Env.supabaseAnonKey.isEmpty) ...[
                      const SizedBox(height: KoogweSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(KoogweSpacing.sm),
                        decoration: BoxDecoration(
                          color: KoogweColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: KoogweColors.error, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '⚠️ Configurez vos clés Supabase dans lib/core/config/env.dart',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: KoogweColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: KoogweSpacing.lg),

              // Boutons de test
              KoogweButton(
                text: 'Test 1: Connexion Supabase',
                onPressed: _isRunning ? null : _testConnection,
                isFullWidth: true,
                size: ButtonSize.large,
              ),
              const SizedBox(height: KoogweSpacing.md),
              KoogweButton(
                text: 'Test 2: Inscription Utilisateur',
                onPressed: _isRunning ? null : _testRegistration,
                isFullWidth: true,
                size: ButtonSize.large,
                variant: ButtonVariant.outline,
              ),
              const SizedBox(height: KoogweSpacing.md),
              KoogweButton(
                text: 'Test 3: Connexion Utilisateur',
                onPressed: _isRunning ? null : _testLogin,
                isFullWidth: true,
                size: ButtonSize.large,
                variant: ButtonVariant.outline,
              ),
              const SizedBox(height: KoogweSpacing.md),
              KoogweButton(
                text: 'Test 4: Insertion Données (Ride)',
                onPressed: _isRunning ? null : _testInsertRide,
                isFullWidth: true,
                size: ButtonSize.large,
                variant: ButtonVariant.outline,
              ),
              const SizedBox(height: KoogweSpacing.md),
              KoogweButton(
                text: 'Test 5: Insertion Données (Wallet)',
                onPressed: _isRunning ? null : _testInsertWallet,
                isFullWidth: true,
                size: ButtonSize.large,
                variant: ButtonVariant.outline,
              ),
              const SizedBox(height: KoogweSpacing.md),
              KoogweButton(
                text: 'Tous les Tests',
                onPressed: _isRunning ? null : _runAllTests,
                isFullWidth: true,
                size: ButtonSize.large,
                variant: ButtonVariant.gradient,
                gradientColors: [KoogweColors.secondary, KoogweColors.secondaryLight],
              ),
              const SizedBox(height: KoogweSpacing.xl),

              // Résultats
              if (_testResults.isNotEmpty) ...[
                Text(
                  'Résultats des Tests',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: KoogweSpacing.md),
                ..._testResults.map((result) => _buildTestResult(result, isDark)),
                const SizedBox(height: KoogweSpacing.md),
                KoogweButton(
                  text: 'Effacer les résultats',
                  onPressed: () {
                    setState(() {
                      _testResults.clear();
                    });
                  },
                  isFullWidth: true,
                  variant: ButtonVariant.outline,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTestResult(TestResult result, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: KoogweSpacing.md),
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: result.success
              ? Colors.green
              : (result.warning ? Colors.orange : Colors.red),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.success
                    ? Icons.check_circle
                    : (result.warning ? Icons.warning : Icons.error),
                color: result.success
                    ? Colors.green
                    : (result.warning ? Colors.orange : Colors.red),
              ),
              const SizedBox(width: KoogweSpacing.sm),
              Expanded(
                child: Text(
                  result.title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (result.message.isNotEmpty) ...[
            const SizedBox(height: KoogweSpacing.sm),
            Text(
              result.message,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
              ),
            ),
          ],
          if (result.details.isNotEmpty) ...[
            const SizedBox(height: KoogweSpacing.xs),
            Text(
              result.details,
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _isRunning = true;
    });

    try {
      final result = await SupabaseService.testConnection();
      setState(() {
        _testResults.insert(
          0,
          TestResult(
            title: 'Test de Connexion',
            success: result['connected'] == true,
            message: result['connected'] == true
                ? '✅ Connexion réussie à Supabase'
                : '❌ Échec de la connexion',
            details: 'URL: ${result['url']}\n'
                'Tables accessibles: ${result['tables']}\n'
                'Erreurs: ${result['errors']}',
          ),
        );
        _isRunning = false;
      });
    } catch (e) {
      setState(() {
        _testResults.insert(
          0,
          TestResult(
            title: 'Test de Connexion',
            success: false,
            message: '❌ Erreur: $e',
            details: '',
          ),
        );
        _isRunning = false;
      });
    }
  }

  Future<void> _testRegistration() async {
    setState(() {
      _isRunning = true;
    });

    try {
      final testEmail = 'test_${DateTime.now().millisecondsSinceEpoch}@koogwe.com';
      final testPassword = 'Test123456';

      final response = await SupabaseService.client.auth.signUp(
        email: testEmail,
        password: testPassword,
        data: {
          'firstName': 'Test',
          'lastName': 'User',
          'phoneNumber': '+594123456789',
        },
      );

      if (response.user != null) {
        // Vérifier que le profil a été créé
        await Future.delayed(const Duration(seconds: 1));
        try {
          final profile = await SupabaseService.client
              .from('profiles')
              .select()
              .eq('id', response.user!.id)
              .maybeSingle();

          setState(() {
            _testResults.insert(
              0,
              TestResult(
                title: 'Test d\'Inscription',
                success: true,
                message: '✅ Utilisateur créé avec succès',
                details: 'Email: $testEmail\n'
                    'User ID: ${response.user!.id}\n'
                    'Profil créé: ${profile != null ? "Oui" : "Non"}',
              ),
            );
            _isRunning = false;
          });
        } catch (e) {
          setState(() {
            _testResults.insert(
              0,
              TestResult(
                title: 'Test d\'Inscription',
                success: true,
                message: '✅ Utilisateur créé avec succès',
                details: 'Email: $testEmail\n'
                    'User ID: ${response.user!.id}\n'
                    'Profil créé: Vérification échouée',
              ),
            );
            _isRunning = false;
          });
        }
      } else {
        setState(() {
          _testResults.insert(
            0,
            TestResult(
              title: 'Test d\'Inscription',
              success: false,
              message: '❌ Échec de l\'inscription',
              details: 'Aucun utilisateur créé',
            ),
          );
          _isRunning = false;
        });
      }
    } catch (e) {
      setState(() {
        _testResults.insert(
          0,
          TestResult(
            title: 'Test d\'Inscription',
            success: false,
            message: '❌ Erreur: $e',
            details: '',
          ),
        );
        _isRunning = false;
      });
    }
  }

  Future<void> _testLogin() async {
    setState(() {
      _isRunning = true;
    });

    try {
      // Utiliser un email de test (vous pouvez le modifier)
      final testEmail = 'test@koogwe.com';
      final testPassword = 'Test123456';

      final response = await SupabaseService.client.auth.signInWithPassword(
        email: testEmail,
        password: testPassword,
      );

      if (response.user != null) {
        setState(() {
          _testResults.insert(
            0,
            TestResult(
              title: 'Test de Connexion',
              success: true,
              message: '✅ Connexion réussie',
              details: 'Email: $testEmail\n'
                  'User ID: ${response.user!.id}\n'
                  'Session: ${response.session != null ? "Active" : "Inactive"}',
            ),
          );
          _isRunning = false;
        });
      } else {
        setState(() {
          _testResults.insert(
            0,
            TestResult(
              title: 'Test de Connexion',
              success: false,
              message: '❌ Échec de la connexion',
              details: 'Aucun utilisateur retourné',
            ),
          );
          _isRunning = false;
        });
      }
    } catch (e) {
      setState(() {
        _testResults.insert(
          0,
          TestResult(
            title: 'Test de Connexion',
            success: false,
            warning: true,
            message: '⚠️ Erreur (peut être normal si l\'utilisateur n\'existe pas)',
            details: '$e',
          ),
        );
        _isRunning = false;
      });
    }
  }

  Future<void> _testInsertRide() async {
    setState(() {
      _isRunning = true;
    });

    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _testResults.insert(
            0,
            TestResult(
              title: 'Test Insertion Ride',
              success: false,
              message: '❌ Vous devez être connecté',
              details: 'Connectez-vous d\'abord',
            ),
          );
          _isRunning = false;
        });
        return;
      }

      final rideData = {
        'user_id': user.id,
        'pickup_text': 'Test Pickup Location',
        'dropoff_text': 'Test Dropoff Location',
        'vehicle_type': 'standard',
        'status': 'requested',
        'estimated_price': 15.50,
        'distance_m': 5000,
        'duration_s': 600,
      };

      final response = await SupabaseService.client
          .from('rides')
          .insert(rideData)
          .select()
          .single();

      setState(() {
        _testResults.insert(
          0,
          TestResult(
            title: 'Test Insertion Ride',
            success: true,
            message: '✅ Ride créé avec succès',
            details: 'Ride ID: ${response['id']}\n'
                'Pickup: ${response['pickup_text']}\n'
                'Dropoff: ${response['dropoff_text']}\n'
                'Prix: ${response['estimated_price']}',
          ),
        );
        _isRunning = false;
      });
    } catch (e) {
      setState(() {
        _testResults.insert(
          0,
          TestResult(
            title: 'Test Insertion Ride',
            success: false,
            message: '❌ Erreur: $e',
            details: '',
          ),
        );
        _isRunning = false;
      });
    }
  }

  Future<void> _testInsertWallet() async {
    setState(() {
      _isRunning = true;
    });

    try {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _testResults.insert(
            0,
            TestResult(
              title: 'Test Insertion Wallet',
              success: false,
              message: '❌ Vous devez être connecté',
              details: 'Connectez-vous d\'abord',
            ),
          );
          _isRunning = false;
        });
        return;
      }

      final walletData = {
        'user_id': user.id,
        'credit': 50.00,
        'debit': 0.00,
        'type': 'topup',
        'meta': {'test': true, 'timestamp': DateTime.now().toIso8601String()},
      };

      final response = await SupabaseService.client
          .from('wallet_transactions')
          .insert(walletData)
          .select()
          .single();

      setState(() {
        _testResults.insert(
          0,
          TestResult(
            title: 'Test Insertion Wallet',
            success: true,
            message: '✅ Transaction wallet créée avec succès',
            details: 'Transaction ID: ${response['id']}\n'
                'Type: ${response['type']}\n'
                'Crédit: ${response['credit']}\n'
                'Débit: ${response['debit']}',
          ),
        );
        _isRunning = false;
      });
    } catch (e) {
      setState(() {
        _testResults.insert(
          0,
          TestResult(
            title: 'Test Insertion Wallet',
            success: false,
            message: '❌ Erreur: $e',
            details: '',
          ),
        );
        _isRunning = false;
      });
    }
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    await _testConnection();
    await Future.delayed(const Duration(seconds: 1));
    await _testRegistration();
    await Future.delayed(const Duration(seconds: 1));
    await _testLogin();
    await Future.delayed(const Duration(seconds: 1));
    await _testInsertRide();
    await Future.delayed(const Duration(seconds: 1));
    await _testInsertWallet();

    setState(() {
      _isRunning = false;
    });
  }
}

class TestResult {
  final String title;
  final bool success;
  final bool warning;
  final String message;
  final String details;

  TestResult({
    required this.title,
    required this.success,
    this.warning = false,
    required this.message,
    required this.details,
  });
}

