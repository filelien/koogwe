import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/glass_card.dart';

/// Widget réutilisable pour afficher un tableau de données
class KoogweDataTable extends StatelessWidget {
  final List<String> headers;
  final List<List<String>> rows;
  final List<TableColumnConfig>? columnConfigs;
  final bool isSortable;
  final Function(int columnIndex, bool ascending)? onSort;
  final int? sortedColumn;
  final bool? ascending;
  final bool paginated;
  final int rowsPerPage;
  final Function(int page)? onPageChanged;
  final int currentPage;
  final bool isLoading;
  final String? emptyMessage;
  final Color? headerColor;
  final bool striped;

  const KoogweDataTable({
    super.key,
    required this.headers,
    required this.rows,
    this.columnConfigs,
    this.isSortable = false,
    this.onSort,
    this.sortedColumn,
    this.ascending,
    this.paginated = false,
    this.rowsPerPage = 10,
    this.onPageChanged,
    this.currentPage = 1,
    this.isLoading = false,
    this.emptyMessage,
    this.headerColor,
    this.striped = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerBgColor = headerColor ?? 
        (isDark ? KoogweColors.darkSurfaceVariant : KoogweColors.lightSurfaceVariant);

    if (isLoading) {
      return GlassCard(
        borderRadius: KoogweRadius.lgRadius,
        child: const Padding(
          padding: EdgeInsets.all(KoogweSpacing.xl),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (rows.isEmpty) {
      return GlassCard(
        borderRadius: KoogweRadius.lgRadius,
        child: Padding(
          padding: const EdgeInsets.all(KoogweSpacing.xxl),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.table_chart_outlined,
                  size: 48,
                  color: isDark ? KoogweColors.darkTextTertiary : KoogweColors.lightTextTertiary,
                ),
                const SizedBox(height: KoogweSpacing.md),
                Text(
                  emptyMessage ?? 'Aucune donnée disponible',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Calculate pagination
    final startIndex = paginated ? (currentPage - 1) * rowsPerPage : 0;
    final endIndex = paginated 
        ? (startIndex + rowsPerPage > rows.length ? rows.length : startIndex + rowsPerPage)
        : rows.length;
    final displayedRows = rows.sublist(startIndex, endIndex);
    final totalPages = paginated ? (rows.length / rowsPerPage).ceil() : 1;

    return GlassCard(
      borderRadius: KoogweRadius.lgRadius,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: headerBgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Table(
              columnWidths: _getColumnWidths(),
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                        width: 1,
                      ),
                    ),
                  ),
                  children: headers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final header = entry.value;
                    final isSorted = sortedColumn == index;
                    return InkWell(
                      onTap: isSortable && onSort != null
                          ? () => onSort!(index, isSorted ? !(ascending ?? false) : true)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(KoogweSpacing.md),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                header,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark 
                                      ? KoogweColors.darkTextPrimary 
                                      : KoogweColors.lightTextPrimary,
                                ),
                              ),
                            ),
                            if (isSortable && isSorted)
                              Icon(
                                ascending == true ? Icons.arrow_upward : Icons.arrow_downward,
                                size: 16,
                                color: KoogweColors.primary,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // Rows
          Table(
            columnWidths: _getColumnWidths(),
            children: displayedRows.asMap().entries.map((entry) {
              final rowIndex = entry.key;
              final row = entry.value;
              final isEvenRow = (startIndex + rowIndex) % 2 == 0;
              
              return TableRow(
                decoration: BoxDecoration(
                  color: striped && isEvenRow
                      ? (isDark 
                          ? KoogweColors.darkSurface.withValues(alpha: 0.3)
                          : KoogweColors.lightSurfaceVariant.withValues(alpha: 0.3))
                      : Colors.transparent,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                      width: 0.5,
                    ),
                  ),
                ),
                children: row.asMap().entries.map((cellEntry) {
                  final cellIndex = cellEntry.key;
                  final cellValue = cellEntry.value;
                  final config = columnConfigs != null && cellIndex < columnConfigs!.length
                      ? columnConfigs![cellIndex]
                      : null;

                  return Padding(
                    padding: const EdgeInsets.all(KoogweSpacing.md),
                    child: Align(
                      alignment: config?.alignment ?? Alignment.centerLeft,
                      child: Text(
                        cellValue,
                        style: GoogleFonts.inter(
                          fontSize: config?.fontSize ?? 14,
                          fontWeight: config?.fontWeight ?? FontWeight.normal,
                          color: config?.textColor ??
                              (isDark 
                                  ? KoogweColors.darkTextPrimary 
                                  : KoogweColors.lightTextPrimary),
                        ),
                        textAlign: config?.textAlign ?? TextAlign.left,
                      ),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
          // Pagination
          if (paginated && totalPages > 1)
            Container(
              padding: const EdgeInsets.all(KoogweSpacing.md),
              decoration: BoxDecoration(
                color: headerBgColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Page $currentPage sur $totalPages (${rows.length} résultats)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark 
                          ? KoogweColors.darkTextSecondary 
                          : KoogweColors.lightTextSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: currentPage > 1
                            ? () => onPageChanged?.call(currentPage - 1)
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: currentPage < totalPages
                            ? () => onPageChanged?.call(currentPage + 1)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Map<int, TableColumnWidth> _getColumnWidths() {
    if (columnConfigs == null || columnConfigs!.isEmpty) {
      // Equal widths by default
      final width = 1.0 / headers.length;
      final result = <int, TableColumnWidth>{};
      for (var i = 0; i < headers.length; i++) {
        result[i] = FlexColumnWidth(width);
      }
      return result;
    }

    final widths = <int, TableColumnWidth>{};
    for (int i = 0; i < headers.length; i++) {
      if (i < columnConfigs!.length && columnConfigs![i].width != null) {
        widths[i] = columnConfigs![i].width!;
      } else {
        // Calculate remaining width for columns without explicit width
        final explicitWidths = columnConfigs!
            .where((c) => c.width != null)
            .length;
        double totalExplicitFlex = 0.0;
        for (final c in columnConfigs!) {
          final width = c.width;
          if (width != null && width is FlexColumnWidth) {
            // FlexColumnWidth.flex is a Function, so we can't directly access it
            // Instead, we'll use a default flex value of 1.0 for calculations
            totalExplicitFlex += 1.0;
          }
        }
        final remainingWidth = (1.0 - totalExplicitFlex) / (headers.length - explicitWidths);
        widths[i] = FlexColumnWidth(remainingWidth);
      }
    }
    return widths;
  }
}

/// Configuration pour une colonne de tableau
class TableColumnConfig {
  final TableColumnWidth? width;
  final Alignment alignment;
  final TextAlign textAlign;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? textColor;

  const TableColumnConfig({
    this.width,
    this.alignment = Alignment.centerLeft,
    this.textAlign = TextAlign.left,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.textColor,
  });
}

