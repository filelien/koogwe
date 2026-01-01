import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:koogwe/core/services/export_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class AdminRidesScreen extends StatefulWidget {
  const AdminRidesScreen({super.key});

  @override
  State<AdminRidesScreen> createState() => _AdminRidesScreenState();
}

class _AdminRidesScreenState extends State<AdminRidesScreen> {
  String _filterStatus = 'all';
  bool _isLoading = true;
  List<Map<String, dynamic>> _rides = [];
  List<Map<String, dynamic>> _filteredRides = [];

  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  Future<void> _loadRides() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('rides')
          .select('''
            *,
            passenger:profiles!rides_user_id_fkey(id, first_name, last_name, email),
            driver:profiles!rides_driver_id_fkey(id, first_name, last_name, email)
          ''')
          .order('created_at', ascending: false)
          .limit(100);
      
      setState(() {
        _rides = List<Map<String, dynamic>>.from(response);
        _filteredRides = _rides;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _filterRides() {
    setState(() {
      _filteredRides = _filterStatus == 'all'
          ? _rides
          : _rides.where((ride) => ride['status']?.toString() == _filterStatus).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GradientBackground(
      useDarkAurora: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Suivi des Courses',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
          actions: [
            PopupMenuButton(
              icon: const Icon(Icons.download),
              tooltip: 'Exporter',
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.picture_as_pdf, size: 20),
                      SizedBox(width: 8),
                      Text('Exporter en PDF'),
                    ],
                  ),
                  onTap: () async {
                    await Future.delayed(const Duration(milliseconds: 100));
                    final exportService = ExportService();
                    final headers = ['Date', 'Passager', 'Chauffeur', 'Départ', 'Destination', 'Type', 'Prix', 'Statut'];
                    final rows = _filteredRides.map((ride) {
                      final date = DateTime.tryParse(ride['created_at']?.toString() ?? '') ?? DateTime.now();
                      final passenger = ride['passenger'] as Map<String, dynamic>?;
                      final driver = ride['driver'] as Map<String, dynamic>?;
                      return [
                        DateFormat('dd/MM/yyyy HH:mm').format(date),
                        '${passenger?['first_name'] ?? ''} ${passenger?['last_name'] ?? ''}'.trim(),
                        '${driver?['first_name'] ?? ''} ${driver?['last_name'] ?? ''}'.trim(),
                        ride['pickup_text']?.toString() ?? '',
                        ride['dropoff_text']?.toString() ?? '',
                        ride['vehicle_type']?.toString() ?? '',
                        ((ride['fare'] as num?) ?? (ride['estimated_price'] as num?) ?? 0.0).toStringAsFixed(2),
                        ride['status']?.toString() ?? '',
                      ];
                    }).toList();
                    final pdfSuccess = await exportService.exportToPDF(
                      title: 'Suivi des Courses',
                      headers: headers,
                      rows: rows,
                      fileName: 'rides_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
                    );
                    final excelSuccess = await exportService.exportToCSV(
                      title: 'Suivi des Courses',
                      headers: headers,
                      rows: rows,
                      fileName: 'rides_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            pdfSuccess && excelSuccess
                                ? 'Exports PDF et Excel générés avec succès'
                                : pdfSuccess
                                    ? 'Export PDF généré'
                                    : excelSuccess
                                        ? 'Export Excel généré'
                                        : 'Erreur lors de l\'export',
                          ),
                          backgroundColor: (pdfSuccess || excelSuccess) ? KoogweColors.success : KoogweColors.error,
                        ),
                      );
                    }
                  },
                ),
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.table_chart, size: 20),
                      SizedBox(width: 8),
                      Text('Exporter en Excel'),
                    ],
                  ),
                  onTap: () async {
                    await Future.delayed(const Duration(milliseconds: 100));
                    final exportService = ExportService();
                    final headers = ['Date', 'Passager', 'Chauffeur', 'Départ', 'Destination', 'Type', 'Prix', 'Statut'];
                    final rows = _filteredRides.map((ride) {
                      final date = DateTime.tryParse(ride['created_at']?.toString() ?? '') ?? DateTime.now();
                      final passenger = ride['passenger'] as Map<String, dynamic>?;
                      final driver = ride['driver'] as Map<String, dynamic>?;
                      return [
                        DateFormat('dd/MM/yyyy HH:mm').format(date),
                        '${passenger?['first_name'] ?? ''} ${passenger?['last_name'] ?? ''}'.trim(),
                        '${driver?['first_name'] ?? ''} ${driver?['last_name'] ?? ''}'.trim(),
                        ride['pickup_text']?.toString() ?? '',
                        ride['dropoff_text']?.toString() ?? '',
                        ride['vehicle_type']?.toString() ?? '',
                        ((ride['fare'] as num?) ?? (ride['estimated_price'] as num?) ?? 0.0).toStringAsFixed(2),
                        ride['status']?.toString() ?? '',
                      ];
                    }).toList();
                    final success = await exportService.exportToCSV(
                      title: 'Suivi des Courses',
                      headers: headers,
                      rows: rows,
                      fileName: 'rides_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Export Excel généré avec succès' : 'Erreur lors de l\'export'),
                          backgroundColor: success ? KoogweColors.success : KoogweColors.error,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(KoogweSpacing.lg),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Toutes',
                        isSelected: _filterStatus == 'all',
                        onTap: () {
                          setState(() => _filterStatus = 'all');
                          _filterRides();
                        },
                      ),
                      const SizedBox(width: KoogweSpacing.sm),
                      _FilterChip(
                        label: 'En attente',
                        isSelected: _filterStatus == 'pending',
                        onTap: () {
                          setState(() => _filterStatus = 'pending');
                          _filterRides();
                        },
                      ),
                      const SizedBox(width: KoogweSpacing.sm),
                      _FilterChip(
                        label: 'En cours',
                        isSelected: _filterStatus == 'in_progress',
                        onTap: () {
                          setState(() => _filterStatus = 'in_progress');
                          _filterRides();
                        },
                      ),
                      const SizedBox(width: KoogweSpacing.sm),
                      _FilterChip(
                        label: 'Terminées',
                        isSelected: _filterStatus == 'completed',
                        onTap: () {
                          setState(() => _filterStatus = 'completed');
                          _filterRides();
                        },
                      ),
                      const SizedBox(width: KoogweSpacing.sm),
                      _FilterChip(
                        label: 'Annulées',
                        isSelected: _filterStatus == 'cancelled',
                        onTap: () {
                          setState(() => _filterStatus = 'cancelled');
                          _filterRides();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredRides.isEmpty
                        ? Center(
                            child: Text(
                              'Aucune course trouvée',
                              style: GoogleFonts.inter(
                                color: isDark
                                    ? KoogweColors.darkTextSecondary
                                    : KoogweColors.lightTextSecondary,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: KoogweSpacing.lg),
                            itemCount: _filteredRides.length,
                            itemBuilder: (context, index) {
                              final ride = _filteredRides[index];
                              return _RideCard(ride: ride).animate().fadeIn(delay: (index * 50).ms);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: KoogweRadius.fullRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: KoogweSpacing.md, vertical: KoogweSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? KoogweColors.primary : Colors.transparent,
          borderRadius: KoogweRadius.fullRadius,
          border: Border.all(
            color: isSelected ? KoogweColors.primary : KoogweColors.lightBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            color: isSelected ? Colors.white : KoogweColors.lightTextPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _RideCard extends StatelessWidget {
  final Map<String, dynamic> ride;

  const _RideCard({required this.ride});

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return KoogweColors.success;
      case 'in_progress':
        return KoogweColors.info;
      case 'cancelled':
        return KoogweColors.error;
      default:
        return KoogweColors.warning;
    }
  }

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'in_progress':
        return 'En cours';
      case 'completed':
        return 'Terminée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status ?? 'Inconnu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = ride['status']?.toString() ?? 'unknown';
    final pickup = ride['pickup_text']?.toString() ?? 'N/A';
    final dropoff = ride['dropoff_text']?.toString() ?? 'N/A';
    final price = ((ride['fare'] as num?) ?? (ride['estimated_price'] as num?) ?? 0.0).toStringAsFixed(2);
    final passenger = ride['passenger'] as Map<String, dynamic>?;
    final driver = ride['driver'] as Map<String, dynamic>?;
    final passengerName = passenger != null
        ? '${passenger['first_name'] ?? ''} ${passenger['last_name'] ?? ''}'.trim()
        : 'Passager inconnu';
    final driverName = driver != null
        ? '${driver['first_name'] ?? ''} ${driver['last_name'] ?? ''}'.trim()
        : 'Chauffeur non assigné';

    return Padding(
      padding: const EdgeInsets.only(bottom: KoogweSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(KoogweSpacing.md),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'De: $pickup',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vers: $dropoff',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha: 0.2),
                  borderRadius: KoogweRadius.smRadius,
                ),
                child: Text(
                  _getStatusLabel(status),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.md),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: KoogweColors.primary),
              const SizedBox(width: 4),
              Text(
                passengerName,
                style: GoogleFonts.inter(fontSize: 12),
              ),
              const SizedBox(width: KoogweSpacing.md),
              Icon(Icons.drive_eta, size: 16, color: KoogweColors.secondary),
              const SizedBox(width: 4),
              Text(
                driverName,
                style: GoogleFonts.inter(fontSize: 12),
              ),
              const Spacer(),
              Text(
                '€$price',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: KoogweColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

