import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:koogwe/core/constants/app_colors.dart';

/// A reusable glassmorphic card with subtle blur, translucent fill, and hairline border.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final VoidCallback? onTap;
  final Color? overlayColor; // for custom tint

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.onTap,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = overlayColor ?? (isDark ? KoogweColors.glassDark : KoogweColors.glassLight);
    final border = isDark ? KoogweColors.glassBorderDark : KoogweColors.glassBorderLight;

    final content = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: borderRadius,
            border: Border.all(color: border, width: 1),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: content,
    );
  }
}
