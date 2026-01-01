import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:koogwe/core/constants/app_assets.dart';

/// Service centralisé pour l'export PDF et Excel
class ExportService {
  /// Exporter une liste de données en PDF
  Future<bool> exportToPDF({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
    String? fileName,
  }) async {
    try {
      final pdf = pw.Document();
      
      // Charger le logo Koogwe
      Uint8List? logoBytes;
      try {
        final logoData = await rootBundle.load(AppAssets.appLogo);
        logoBytes = logoData.buffer.asUint8List();
      } catch (e) {
        debugPrint('[ExportService] Logo not found, continuing without logo: $e');
      }
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // En-tête avec logo et titre
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  if (logoBytes != null)
                    pw.Image(
                      pw.MemoryImage(logoBytes),
                      width: 80,
                      height: 80,
                    )
                  else
                    pw.Container(
                      width: 80,
                      height: 80,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue700,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'KOOGWE',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          title,
                          style: pw.TextStyle(
                            fontSize: 24,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue700,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Généré le ${DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.now())}',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              
              // Table professionnelle avec style moderne
              pw.Table(
                border: pw.TableBorder(
                  left: const pw.BorderSide(color: PdfColors.grey300, width: 1),
                  top: const pw.BorderSide(color: PdfColors.grey300, width: 1),
                  right: const pw.BorderSide(color: PdfColors.grey300, width: 1),
                  bottom: const pw.BorderSide(color: PdfColors.grey300, width: 1),
                  horizontalInside: const pw.BorderSide(color: PdfColors.grey300, width: 1),
                  verticalInside: const pw.BorderSide(color: PdfColors.grey300, width: 1),
                ),
                columnWidths: {
                  for (int i = 0; i < headers.length; i++)
                    i: pw.FlexColumnWidth(1.0),
                },
                children: [
                  // Headers avec style professionnel
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.blue700,
                    ),
                    children: headers.map((h) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: pw.Text(
                        h,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                          fontSize: 11,
                        ),
                      ),
                    )).toList(),
                  ),
                  // Rows avec alternance de couleurs
                  ...rows.asMap().entries.map((entry) {
                    final index = entry.key;
                    final row = entry.value;
                    final isEven = index % 2 == 0;
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: isEven ? PdfColors.white : PdfColors.grey100,
                      ),
                      children: row.map((cell) => pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: pw.Text(
                          cell,
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey900,
                          ),
                        ),
                      )).toList(),
                    );
                  }),
                ],
              ),
              
              pw.SizedBox(height: 20),
              
              // Pied de page
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'KOOGWE - Plateforme de transport',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ];
          },
        ),
      );

      final bytes = await pdf.save();
      
      // Partager le PDF
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${fileName ?? 'export_${DateTime.now().millisecondsSinceEpoch}.pdf'}');
      await file.writeAsBytes(bytes);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: title,
      );
      
      return true;
    } catch (e, st) {
      debugPrint('[ExportService] exportToPDF error: $e\n$st');
      return false;
    }
  }

  /// Exporter une liste de données en CSV (Excel)
  Future<bool> exportToCSV({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
    String? fileName,
  }) async {
    try {
      final buffer = StringBuffer();
      
      // Headers
      buffer.writeln(headers.join(','));
      
      // Rows
      for (final row in rows) {
        buffer.writeln(row.map((cell) => '"${cell.replaceAll('"', '""')}"').join(','));
      }
      
      final csvContent = buffer.toString();
      
      // Sauvegarder et partager
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${fileName ?? 'export_${DateTime.now().millisecondsSinceEpoch}.csv'}');
      await file.writeAsString(csvContent);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: title,
      );
      
      return true;
    } catch (e, st) {
      debugPrint('[ExportService] exportToCSV error: $e\n$st');
      return false;
    }
  }

  /// Exporter les transactions du portefeuille
  Future<bool> exportWalletTransactions(List<Map<String, dynamic>> transactions) async {
    final headers = ['Date', 'Type', 'Crédit', 'Débit', 'Solde'];
    final rows = <List<String>>[];
    
    double balance = 0.0;
    for (final tx in transactions) {
      final credit = (tx['credit'] as num?)?.toDouble() ?? 0.0;
      final debit = (tx['debit'] as num?)?.toDouble() ?? 0.0;
      balance += credit - debit;
      
      final date = DateTime.tryParse(tx['created_at']?.toString() ?? '') ?? DateTime.now();
      
      rows.add([
        DateFormat('dd/MM/yyyy HH:mm').format(date),
        tx['type']?.toString() ?? '',
        credit > 0 ? credit.toStringAsFixed(2) : '0.00',
        debit > 0 ? debit.toStringAsFixed(2) : '0.00',
        balance.toStringAsFixed(2),
      ]);
    }
    
    return await exportToPDF(
      title: 'Historique des Transactions',
      headers: headers,
      rows: rows,
      fileName: 'transactions_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  /// Exporter les courses
  Future<bool> exportRides(List<Map<String, dynamic>> rides) async {
    final headers = ['Date', 'Départ', 'Destination', 'Type', 'Prix', 'Statut'];
    final rows = rides.map((ride) {
      final date = DateTime.tryParse(ride['created_at']?.toString() ?? '') ?? DateTime.now();
      return [
        DateFormat('dd/MM/yyyy HH:mm').format(date),
        ride['pickup_text']?.toString() ?? '',
        ride['dropoff_text']?.toString() ?? '',
        ride['vehicle_type']?.toString() ?? '',
        (ride['fare'] as num?)?.toStringAsFixed(2) ?? '0.00',
        ride['status']?.toString() ?? '',
      ];
    }).toList();
    
    return await exportToPDF(
      title: 'Historique des Courses',
      headers: headers,
      rows: rows,
      fileName: 'rides_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  /// Exporter les statistiques admin
  Future<bool> exportAdminStats(Map<String, dynamic> stats) async {
    try {
      final pdf = pw.Document();
      
      // Charger le logo Koogwe
      Uint8List? logoBytes;
      try {
        final logoData = await rootBundle.load(AppAssets.appLogo);
        logoBytes = logoData.buffer.asUint8List();
      } catch (e) {
        debugPrint('[ExportService] Logo not found, continuing without logo: $e');
      }
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // En-tête avec logo
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  if (logoBytes != null)
                    pw.Image(
                      pw.MemoryImage(logoBytes),
                      width: 100,
                      height: 100,
                    )
                  else
                    pw.Container(
                      width: 100,
                      height: 100,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.blue700,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'KOOGWE',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Rapport Administrateur',
                          style: pw.TextStyle(
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue700,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Généré le ${DateFormat('dd/MM/yyyy à HH:mm').format(DateTime.now())}',
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              
              // Table professionnelle avec statistiques
              pw.Table(
                border: pw.TableBorder(
                  left: const pw.BorderSide(color: PdfColors.grey300, width: 1),
                  top: const pw.BorderSide(color: PdfColors.grey300, width: 1),
                  right: const pw.BorderSide(color: PdfColors.grey300, width: 1),
                  bottom: const pw.BorderSide(color: PdfColors.grey300, width: 1),
                  horizontalInside: const pw.BorderSide(color: PdfColors.grey300, width: 1),
                  verticalInside: const pw.BorderSide(color: PdfColors.grey300, width: 1),
                ),
                columnWidths: {
                  0: pw.FlexColumnWidth(2.0),
                  1: pw.FlexColumnWidth(1.0),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.blue700),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: pw.Text(
                          'Métrique',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: pw.Text(
                          'Valeur',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...stats.entries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final statEntry = entry.value;
                    final isEven = index % 2 == 0;
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: isEven ? PdfColors.white : PdfColors.grey100,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: pw.Text(
                            _formatStatKey(statEntry.key),
                            style: pw.TextStyle(
                              fontSize: 11,
                              color: PdfColors.grey900,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: pw.Text(
                            _formatStatValue(statEntry.value),
                            style: pw.TextStyle(
                              fontSize: 11,
                              color: PdfColors.grey900,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              
              pw.SizedBox(height: 30),
              
              // Pied de page
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'KOOGWE - Plateforme de transport • Rapport confidentiel',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey600,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ];
          },
        ),
      );

    try {
      final bytes = await pdf.save();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/admin_stats_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes);
      
      await Share.shareXFiles([XFile(file.path)], subject: 'Rapport Administrateur');
      return true;
    } catch (e, st) {
      debugPrint('[ExportService] exportAdminStats error: $e\n$st');
      return false;
    }
  }

  String _formatStatKey(String key) {
    final keyMap = {
      'total_users': 'Total Utilisateurs',
      'total_rides': 'Total Courses',
      'total_revenue': 'Revenus Totaux',
      'month_revenue': 'Revenus du Mois',
      'today_revenue': 'Revenus Aujourd\'hui',
      'active_drivers': 'Chauffeurs Actifs',
      'pending_drivers': 'Chauffeurs en Attente',
      'new_users_last_7_days': 'Nouveaux Utilisateurs (7j)',
      'today_rides': 'Courses Aujourd\'hui',
    };
    return keyMap[key] ?? key.replaceAll('_', ' ').split(' ').map((w) => 
      w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1)
    ).join(' ');
  }

  String _formatStatValue(dynamic value) {
    if (value is num) {
      if (value >= 1000000) {
        return '${(value / 1000000).toStringAsFixed(2)}M';
      } else if (value >= 1000) {
        return '${(value / 1000).toStringAsFixed(1)}k';
      } else if (value is double && value.toString().contains('.')) {
        return value.toStringAsFixed(2);
      }
      return value.toString();
    }
    if (value is Map) {
      return value.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    }
    if (value is List) {
      return '${value.length} éléments';
    }
    return value.toString();
  }
}

