import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class InvoiceDetailScreen extends StatelessWidget {
  final String? rideId;
  final String? invoiceId;

  const InvoiceDetailScreen({
    super.key,
    this.rideId,
    this.invoiceId,
  });

  Future<void> _generateAndSharePDF(BuildContext context, InvoiceData invoice) async {
    try {
      // Afficher un indicateur de chargement
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Génération du PDF...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Créer le document PDF
      final pdf = pw.Document();
      final dateFormat = DateFormat('dd MMMM yyyy', 'fr_FR');
      final timeFormat = DateFormat('HH:mm', 'fr_FR');

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // En-tête
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'KOOGWE',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue700,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Plateforme de Mobilité Intelligente',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'FACTURE',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        invoice.invoiceNumber,
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Informations facture
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Facturé à:',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          invoice.passengerName,
                          style: const pw.TextStyle(fontSize: 14),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          invoice.passengerEmail,
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Date:',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          dateFormat.format(invoice.date),
                          style: const pw.TextStyle(fontSize: 14),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          timeFormat.format(invoice.date),
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Détails du trajet
              pw.Text(
                'Détails du trajet',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(
                  invoice.rideDetails,
                  style: const pw.TextStyle(fontSize: 12),
                ),
              ),
              pw.SizedBox(height: 30),

              // Tableau des montants
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Description',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Montant',
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Sous-total',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '${invoice.subtotal.toStringAsFixed(2)} €',
                          style: const pw.TextStyle(fontSize: 12),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  if (invoice.taxes > 0)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'TVA (${(invoice.taxRate * 100).toStringAsFixed(1)}%)',
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '${invoice.taxes.toStringAsFixed(2)} €',
                            style: const pw.TextStyle(fontSize: 12),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'TOTAL',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '${invoice.total.toStringAsFixed(2)} €',
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue700,
                          ),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Informations de paiement
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Row(
                  children: [
                    pw.Text(
                      'Moyen de paiement: ',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      invoice.paymentMethod,
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Pied de page
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                'Merci d\'avoir utilisé KOOGWE !',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.grey700,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ];
          },
        ),
      );

      // Partager ou sauvegarder le PDF
      if (context.mounted) {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdf.save(),
        );
      }
    } catch (e) {
      debugPrint('[InvoiceDetail] Erreur génération PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la génération du PDF: $e'),
            backgroundColor: KoogweColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Données simulées - à remplacer par les vraies données de Supabase
    final invoice = InvoiceData(
      invoiceNumber: invoiceId ?? 'INV-${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      passengerName: 'John Doe',
      passengerEmail: 'john.doe@example.com',
      subtotal: 25.50,
      taxes: 5.10,
      taxRate: 0.20,
      total: 30.60,
      rideDetails: 'Trajet de Point A à Point B',
      paymentMethod: 'Carte bancaire',
    );

    return Scaffold(
      backgroundColor: isDark ? KoogweColors.darkBackground : KoogweColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Facture'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareInvoice(context, invoice),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _generateAndSharePDF(context, invoice),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            GlassCard(
              borderRadius: KoogweRadius.lgRadius,
              child: Padding(
                padding: const EdgeInsets.all(KoogweSpacing.xl),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'KOOGWE',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: KoogweColors.primary,
                              ),
                            ),
                            const SizedBox(height: KoogweSpacing.xs),
                            Text(
                              'Facture n° ${invoice.invoiceNumber}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: isDark
                                    ? KoogweColors.darkTextSecondary
                                    : KoogweColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.receipt_long,
                          size: 48,
                          color: KoogweColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: KoogweSpacing.lg),
                    Divider(
                      color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                    ),
                    const SizedBox(height: KoogweSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Date',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: isDark
                                ? KoogweColors.darkTextSecondary
                                : KoogweColors.lightTextSecondary,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMMM yyyy', 'fr_FR').format(invoice.date),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? KoogweColors.darkTextPrimary
                                : KoogweColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn().slideY(begin: -0.2, end: 0),
            
            const SizedBox(height: KoogweSpacing.xl),
            
            // Client info
            Text(
              'Facturé à',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: KoogweSpacing.md),
            GlassCard(
              borderRadius: KoogweRadius.lgRadius,
              child: Padding(
                padding: const EdgeInsets.all(KoogweSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invoice.passengerName,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? KoogweColors.darkTextPrimary
                            : KoogweColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: KoogweSpacing.xs),
                    Text(
                      invoice.passengerEmail,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark
                            ? KoogweColors.darkTextSecondary
                            : KoogweColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
            
            const SizedBox(height: KoogweSpacing.xl),
            
            // Invoice details
            Text(
              'Détails',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: KoogweSpacing.md),
            GlassCard(
              borderRadius: KoogweRadius.lgRadius,
              child: Column(
                children: [
                  _InvoiceLineItem(
                    label: 'Sous-total',
                    value: '${invoice.subtotal.toStringAsFixed(2)} €',
                    isDark: isDark,
                  ),
                  if (invoice.taxes > 0)
                    _InvoiceLineItem(
                      label: 'TVA (${(invoice.taxRate * 100).toStringAsFixed(1)}%)',
                      value: '${invoice.taxes.toStringAsFixed(2)} €',
                      isDark: isDark,
                    ),
                  Divider(
                    color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                  ),
                  _InvoiceLineItem(
                    label: 'Total',
                    value: '${invoice.total.toStringAsFixed(2)} €',
                    isDark: isDark,
                    isTotal: true,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: KoogweSpacing.xl),
            
            // Payment info
            GlassCard(
              borderRadius: KoogweRadius.lgRadius,
              child: Padding(
                padding: const EdgeInsets.all(KoogweSpacing.lg),
                child: Row(
                  children: [
                    Icon(
                      Icons.payment,
                      color: KoogweColors.success,
                    ),
                    const SizedBox(width: KoogweSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Moyen de paiement',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark
                                  ? KoogweColors.darkTextSecondary
                                  : KoogweColors.lightTextSecondary,
                            ),
                          ),
                          Text(
                            invoice.paymentMethod,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? KoogweColors.darkTextPrimary
                                  : KoogweColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: KoogweColors.success,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }

  Future<void> _shareInvoice(BuildContext context, InvoiceData invoice) async {
    final text = '''
Facture KOOGWE
${invoice.invoiceNumber}

Date: ${DateFormat('dd/MM/yyyy').format(invoice.date)}
Total: ${invoice.total.toStringAsFixed(2)} €
''';
    await SharePlus.instance.share(ShareParams(text: text));
  }
}

class _InvoiceLineItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isTotal;

  const _InvoiceLineItem({
    required this.label,
    required this.value,
    required this.isDark,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KoogweSpacing.lg,
        vertical: KoogweSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.normal,
              color: isDark
                  ? KoogweColors.darkTextPrimary
                  : KoogweColors.lightTextPrimary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isTotal ? 18 : 14,
              fontWeight: FontWeight.w700,
              color: isTotal ? KoogweColors.primary : (isDark
                  ? KoogweColors.darkTextPrimary
                  : KoogweColors.lightTextPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class InvoiceData {
  final String invoiceNumber;
  final DateTime date;
  final String passengerName;
  final String passengerEmail;
  final double subtotal;
  final double taxes;
  final double taxRate;
  final double total;
  final String rideDetails;
  final String paymentMethod;

  InvoiceData({
    required this.invoiceNumber,
    required this.date,
    required this.passengerName,
    required this.passengerEmail,
    required this.subtotal,
    required this.taxes,
    required this.taxRate,
    required this.total,
    required this.rideDetails,
    required this.paymentMethod,
  });
}

