import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/glass_card.dart';

/// Widget réutilisable pour afficher une carte KPI (Key Performance Indicator)
class KPICard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final Color? iconColor;
  final VoidCallback? onTap;
  final bool showTrend;
  final double? trendValue;
  final bool trendIsPositive;

  const KPICard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
    this.iconColor,
    this.onTap,
    this.showTrend = false,
    this.trendValue,
    this.trendIsPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = color ?? KoogweColors.primary;
    final iconBgColor = iconColor ?? cardColor;

    return GlassCard(
      onTap: onTap,
      borderRadius: KoogweRadius.lgRadius,
      child: Padding(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(KoogweSpacing.md),
                  decoration: BoxDecoration(
                    color: iconBgColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconBgColor, size: 24),
                ),
                if (showTrend && trendValue != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: KoogweSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (trendIsPositive ? KoogweColors.success : KoogweColors.error)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trendIsPositive ? Icons.trending_up : Icons.trending_down,
                          size: 14,
                          color: trendIsPositive ? KoogweColors.success : KoogweColors.error,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${trendIsPositive ? '+' : ''}${trendValue!.toStringAsFixed(1)}%',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: trendIsPositive ? KoogweColors.success : KoogweColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: KoogweSpacing.md),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: KoogweSpacing.xs),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: KoogweSpacing.xs),
              Text(
                subtitle!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

