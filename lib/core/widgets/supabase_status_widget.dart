import 'package:flutter/material.dart';
import 'package:koogwe/core/services/supabase_service.dart';
import 'package:koogwe/core/config/env.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget qui affiche le statut de la connexion Supabase
class SupabaseStatusWidget extends StatefulWidget {
  const SupabaseStatusWidget({super.key});

  @override
  State<SupabaseStatusWidget> createState() => _SupabaseStatusWidgetState();
}

class _SupabaseStatusWidgetState extends State<SupabaseStatusWidget> {
  bool _isConnected = false;
  bool _isChecking = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    try {
      final result = await SupabaseService.testConnection();
      setState(() {
        _isConnected = result['connected'] == true;
        _isChecking = false;
        if (!_isConnected && result['errors'] != null) {
          final errors = result['errors'] as List;
          if (errors.isNotEmpty) {
            _errorMessage = errors.first.toString();
          }
        }
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _isChecking = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isChecking) {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: KoogweColors.info),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Vérification de la connexion Supabase...',
              style: GoogleFonts.inter(),
            ),
          ],
        ),
      );
    }

    if (_isConnected) {
      return const SizedBox.shrink(); // Cacher si connecté
    }

    // Afficher l'alerte si non connecté
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KoogweColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KoogweColors.error, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: KoogweColors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '⚠️ Connexion Supabase échouée',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: KoogweColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'L\'application n\'est pas connectée à Supabase.',
            style: GoogleFonts.inter(
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              'Erreur: $_errorMessage',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: _checkConnection,
                child: const Text('Réessayer'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => context.push('/test-supabase'),
                child: const Text('Diagnostic'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'URL configurée: ${Env.supabaseUrl.isEmpty ? "NON CONFIGURÉE" : Env.supabaseUrl}',
            style: GoogleFonts.robotoMono(
              fontSize: 11,
              color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

