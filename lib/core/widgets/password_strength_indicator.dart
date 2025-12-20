import 'package:flutter/material.dart';
import 'package:koogwe/core/validators/password_validator.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final PasswordValidationResult? validationResult;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    this.validationResult,
  });

  @override
  Widget build(BuildContext context) {
    final result = validationResult ?? PasswordValidator.validate(password);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (password.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(KoogweSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.grey[900]!.withValues(alpha: 0.5)
            : Colors.grey[100]!.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${'password_strength'.tr()} : ${result.strength.label.tr()}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: result.strength.color,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: result.strength.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${result.strength.score}/4',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: result.strength.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: result.strength.score / 4,
              minHeight: 6,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(result.strength.color),
            ),
          ),
          if (result.strength.description.isNotEmpty) ...[
            const SizedBox(height: KoogweSpacing.xs),
            Text(
              result.strength.description.tr(),
              style: GoogleFonts.inter(
                fontSize: 11,
                color: isDark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: KoogweSpacing.sm),
          ...result.requirements.map((req) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(
                  req.isValid ? Icons.check_circle : Icons.circle_outlined,
                  size: 16,
                  color: req.isValid
                      ? Colors.green
                      : (isDark ? Colors.grey[600] : Colors.grey[400]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    req.text.tr(),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: req.isValid
                          ? Colors.green
                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      decoration: req.isValid ? TextDecoration.none : null,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

