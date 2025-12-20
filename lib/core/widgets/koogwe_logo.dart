import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_strings.dart';
import 'package:koogwe/core/constants/app_assets.dart';

/// KOOGWE brand-safe logo loader with graceful fallbacks.
class KoogweLogo extends StatelessWidget {
  final double size; // height of the square logo circle
  final bool showWordmark;

  const KoogweLogo({super.key, this.size = 64, this.showWordmark = true});

  Future<Uint8List?> _tryLoad() async {
    const candidates = <String>[
      // Preferred app icon provided by user (single source of truth)
      AppAssets.appLogo,
      // Brand fallbacks (optional)
      'assets/icons/koogwe.png',
      'assets/brand/koogwe_logo_square.png',
      'assets/brand/koogwe_logo.png',
      'assets/brand/koogwe_logo_1024.png',
    ];
    for (final path in candidates) {
      try {
        final data = await rootBundle.load(path);
        return data.buffer.asUint8List();
      } catch (_) {}
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<Uint8List?>(
      future: _tryLoad(),
      builder: (context, snap) {
        final imageBytes = snap.data;
        final logo = Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            // Adapter la couleur selon le thème
            color: isDark 
                ? KoogweColors.primary.withValues(alpha: 0.2)
                : KoogweColors.accent,
            shape: BoxShape.circle,
            // Ajouter un effet glow en mode sombre
            boxShadow: isDark ? [
              BoxShadow(
                color: KoogweColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ] : null,
          ),
          child: Center(
            child: imageBytes != null
                ? ClipOval(
                    child: ColorFiltered(
                      // Adapter la luminosité selon le thème
                      colorFilter: isDark
                          ? ColorFilter.mode(
                              Colors.white.withValues(alpha: 0.9),
                              BlendMode.modulate,
                            )
                          : const ColorFilter.mode(Colors.white, BlendMode.dst),
                      child: Image.memory(imageBytes, fit: BoxFit.cover),
                    ),
                  )
                : Icon(
                    Icons.route,
                    color: isDark ? KoogweColors.primary : Colors.white,
                    size: size * 0.45,
                  ),
          ),
        );

        if (!showWordmark) return logo;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            logo,
            const SizedBox(width: 12),
            Text(
              AppStrings.appName.toUpperCase(),
              style: TextStyle(
                fontSize: size * 0.5,
                fontWeight: FontWeight.w800,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                letterSpacing: -1,
              ),
            ),
          ],
        );
      },
    );
  }
}
