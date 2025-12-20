import 'package:flutter/material.dart';
import 'package:koogwe/core/constants/app_colors.dart';

/// Aurora-style gradient background used across premium screens.
/// Lightweight and GPU-friendly. Place as the first child of a Stack.
class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool useDarkAurora; // Force dark palette even in light mode

  // Default to a light, airy gradient to avoid dark blocks in light mode.
  const GradientBackground({super.key, required this.child, this.useDarkAurora = false});

  @override
  Widget build(BuildContext context) {
    final themeDark = Theme.of(context).brightness == Brightness.dark;
    final isDark = useDarkAurora || themeDark;
    // Light palette inspired by references (soft violet -> warm sunrise -> white)
    final colors = isDark
        ? [KoogweColors.auroraStart, KoogweColors.auroraMid, KoogweColors.auroraEnd]
        : const [Color(0xFFF7F2FF), Color(0xFFFFF4E5), Color(0xFFFFFFFF)];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: child,
    );
  }
}
