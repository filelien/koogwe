import 'package:flutter/material.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:google_fonts/google_fonts.dart';

enum ButtonSize { small, medium, large }
enum ButtonVariant { primary, secondary, outline, ghost, gradient }

class KoogweButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Color? customColor;
  final List<Color>? gradientColors;
  // Optional custom border radius (e.g., pill). Defaults to KoogweRadius.lgRadius
  final BorderRadius? borderRadius;

  const KoogweButton({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.customColor,
    this.gradientColors,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    double height;
    double fontSize;
    double horizontalPadding;

    switch (size) {
      case ButtonSize.small:
        height = 40;
        fontSize = 14;
        horizontalPadding = KoogweSpacing.lg;
        break;
      case ButtonSize.medium:
        height = 48;
        fontSize = 16;
        horizontalPadding = KoogweSpacing.xl;
        break;
      case ButtonSize.large:
        height = 56;
        fontSize = 18;
        horizontalPadding = KoogweSpacing.xxl;
        break;
    }

    Color backgroundColor;
    Color foregroundColor;
    Color borderColor;

    final baseColor = customColor ?? KoogweColors.primary;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = baseColor;
        foregroundColor = Colors.white;
        borderColor = Colors.transparent;
        break;
      case ButtonVariant.secondary:
        backgroundColor = isDark ? KoogweColors.darkSurfaceVariant : KoogweColors.lightSurfaceVariant;
        foregroundColor = isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary;
        borderColor = Colors.transparent;
        break;
      case ButtonVariant.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = baseColor;
        borderColor = baseColor;
        break;
      case ButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = baseColor;
        borderColor = Colors.transparent;
        break;
      case ButtonVariant.gradient:
        backgroundColor = Colors.transparent; // Decorated outside
        foregroundColor = Colors.white;
        borderColor = Colors.transparent;
        break;
    }

    Future<void> handlePress() async {
      if (onPressed == null || isLoading) return;
      try {
        Feedback.forTap(context);
        onPressed!.call();
      } catch (e) {
        debugPrint('KoogweButton onPressed error: $e');
      }
    }

    final buttonChild = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: fontSize + 2, color: foregroundColor),
                const SizedBox(width: KoogweSpacing.sm),
              ],
              // Prevent rare horizontal overflows on very small screens by ellipsizing
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: GoogleFonts.inter(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: foregroundColor,
                  ),
                ),
              ),
            ],
          );

    final coreButton = SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : handlePress,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: variant == ButtonVariant.primary ? 0 : 0,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? KoogweRadius.lgRadius,
            side: BorderSide(
              color: borderColor,
              width: variant == ButtonVariant.outline ? 1.5 : 0,
            ),
          ),
          splashFactory: NoSplash.splashFactory,
          overlayColor: Colors.transparent,
        ),
        child: buttonChild,
      ),
    );

    if (variant != ButtonVariant.gradient) return coreButton;

    final colors = gradientColors ?? [KoogweColors.secondary, KoogweColors.secondaryLight];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
        borderRadius: borderRadius ?? KoogweRadius.lgRadius,
      ),
      child: coreButton,
    );
  }
}
