import 'package:flutter/material.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';

/// A lightweight floating bottom sheet panel with rounded corners,
/// subtle shadow, and an optional drag handle. Designed to sit above
/// maps or gradient backgrounds, matching the reference minimal UI.
class FloatingSheet extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool showHandle;
  final ScrollController? scrollController;

  const FloatingSheet({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(KoogweSpacing.xl),
    this.showHandle = true,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface;
    final border = isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showHandle)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: KoogweSpacing.lg),
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        // If a ScrollController is provided, assume the child is a ListView
        // and forward the controller via PrimaryScrollController.
        if (scrollController != null)
          PrimaryScrollController(
            controller: scrollController!,
            child: Padding(padding: padding, child: child),
          )
        else
          Padding(padding: padding, child: child),
      ],
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24), bottom: Radius.circular(20)),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: content,
    );
  }
}
