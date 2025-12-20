import 'package:flutter/material.dart';

class PasswordStrength {
  final int score; // 0-4
  final String label;
  final String description;
  final Color color;

  PasswordStrength({
    required this.score,
    required this.label,
    required this.description,
    required this.color,
  });
}

class PasswordRequirement {
  final String text;
  final bool isValid;

  PasswordRequirement({
    required this.text,
    required this.isValid,
  });
}

class PasswordValidator {
  /// Valide un mot de passe selon un protocole strict
  static PasswordValidationResult validate(String password) {
    if (password.isEmpty) {
      return PasswordValidationResult(
        isValid: false,
        strength: PasswordStrength(
          score: 0,
          label: 'password_very_weak',
          description: 'password_very_weak_desc',
          color: const Color(0xFF9E9E9E),
        ),
        requirements: _getAllRequirements(password),
      );
    }

    // Calculer la force
    int score = 0;
    
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    
    final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = password.contains(RegExp(r'[a-z]'));
    final hasNumbers = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    if (hasUpperCase && hasLowerCase) score++;
    if (hasNumbers) score++;
    if (hasSpecialChars) score++;
    
    // Score final (max 4)
    score = score.clamp(0, 4);
    
    String label;
    String description;
    Color color;
    
    switch (score) {
      case 0:
      case 1:
        label = 'password_very_weak';
        description = 'password_very_weak_desc';
        color = const Color(0xFFFF3B30);
        break;
      case 2:
        label = 'password_weak';
        description = 'password_weak_desc';
        color = const Color(0xFFFF9500);
        break;
      case 3:
        label = 'password_medium';
        description = 'password_medium_desc';
        color = const Color(0xFFFFCC00);
        break;
      case 4:
        label = 'password_strong';
        description = 'password_strong_desc';
        color = const Color(0xFF34C759);
        break;
      default:
        label = 'password_very_weak';
        description = 'password_very_weak_desc';
        color = const Color(0xFFFF3B30);
    }
    
    final requirements = _getAllRequirements(password);
    final isValid = requirements.every((req) => req.isValid);
    
    return PasswordValidationResult(
      isValid: isValid && score >= 3, // Minimum 3/4 pour valider
      strength: PasswordStrength(
        score: score,
        label: label,
        description: description,
        color: color,
      ),
      requirements: requirements,
    );
  }

  static List<PasswordRequirement> _getAllRequirements(String password) {
    return [
      PasswordRequirement(
        text: 'password_requirement_length_8',
        isValid: password.length >= 8,
      ),
      PasswordRequirement(
        text: 'password_requirement_length_12',
        isValid: password.length >= 12,
      ),
      PasswordRequirement(
        text: 'password_requirement_uppercase',
        isValid: password.contains(RegExp(r'[A-Z]')),
      ),
      PasswordRequirement(
        text: 'password_requirement_lowercase',
        isValid: password.contains(RegExp(r'[a-z]')),
      ),
      PasswordRequirement(
        text: 'password_requirement_number',
        isValid: password.contains(RegExp(r'[0-9]')),
      ),
      PasswordRequirement(
        text: 'password_requirement_special',
        isValid: password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
      ),
    ];
  }
}

class PasswordValidationResult {
  final bool isValid;
  final PasswordStrength strength;
  final List<PasswordRequirement> requirements;

  PasswordValidationResult({
    required this.isValid,
    required this.strength,
    required this.requirements,
  });
}


