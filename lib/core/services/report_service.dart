import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Service pour la génération de rapports
class ReportService {
  ReportService({SupabaseClient? client}) 
      : _client = client ?? Supabase.instance.client;
  
  final SupabaseClient _client;

  /// Générer un rapport PDF pour une entreprise
  Future<Uint8List?> generateBusinessReport({
    required DateTime startDate,
    required DateTime endDate,
    String? companyId,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      // Obtenir les données
      final analytics = await _getBusinessData(startDate, endDate, companyId);

      // Créer le PDF
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Rapport d\'Activité KOOGWE',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Paragraph(
                text: 'Période: ${startDate.toString().split(' ')[0]} - ${endDate.toString().split(' ')[0]}',
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                children: [
                  _buildTableRow('Total des courses', '${analytics['total_rides']}'),
                  _buildTableRow('Total dépensé', '${analytics['total_spent']}€'),
                  _buildTableRow('Employés actifs', '${analytics['active_employees']}'),
                  _buildTableRow('Moyenne par employé', '${analytics['average_per_employee']}€'),
                ],
              ),
            ];
          },
        ),
      );

      return pdf.save();
    } catch (e, st) {
      debugPrint('[ReportService] generateBusinessReport error: $e\n$st');
      return null;
    }
  }

  /// Générer un rapport pour un chauffeur
  Future<Uint8List?> generateDriverReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      // Obtenir les données
      final rides = await _client
          .from('rides')
          .select()
          .eq('driver_id', user.id)
          .eq('status', 'completed')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: false);

      final totalEarnings = (rides as List).fold<double>(
        0.0,
        (sum, ride) => sum + ((ride['fare'] as num?)?.toDouble() ?? 0.0),
      );

      // Créer le PDF
      final pdf = pw.Document();
      
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Rapport de Revenus - Chauffeur',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Paragraph(
                text: 'Période: ${startDate.toString().split(' ')[0]} - ${endDate.toString().split(' ')[0]}',
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                children: [
                  _buildTableRow('Total des courses', '${rides.length}'),
                  _buildTableRow('Total des revenus', '${totalEarnings.toStringAsFixed(2)}€'),
                  _buildTableRow('Moyenne par course', '${rides.isNotEmpty ? (totalEarnings / rides.length).toStringAsFixed(2) : 0}€'),
                ],
              ),
            ];
          },
        ),
      );

      return pdf.save();
    } catch (e, st) {
      debugPrint('[ReportService] generateDriverReport error: $e\n$st');
      return null;
    }
  }

  /// Obtenir les données d'une entreprise
  Future<Map<String, dynamic>> _getBusinessData(
    DateTime startDate,
    DateTime endDate,
    String? companyId,
  ) async {
    // Implémentation similaire à AnalyticsService.getBusinessAnalytics
    return {};
  }

  /// Construire une ligne de tableau
  pw.TableRow _buildTableRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(value),
        ),
      ],
    );
  }

  /// Exporter les données en CSV
  Future<String?> exportToCSV({
    required List<Map<String, dynamic>> data,
    required List<String> headers,
  }) async {
    try {
      final buffer = StringBuffer();
      
      // Headers
      buffer.writeln(headers.join(','));

      // Data
      for (final row in data) {
        final values = headers.map((h) => row[h]?.toString() ?? '').join(',');
        buffer.writeln(values);
      }

      return buffer.toString();
    } catch (e, st) {
      debugPrint('[ReportService] exportToCSV error: $e\n$st');
      return null;
    }
  }
}

