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

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _searchController = TextEditingController();
  String _filterRole = 'all';
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      // Utiliser une requête simple sans jointures pour éviter la récursion
      final response = await Supabase.instance.client
          .from('profiles')
          .select('id, email, first_name, last_name, phone_number, role, created_at, avatar_url')
          .order('created_at', ascending: false)
          .limit(500);
      
      setState(() {
        _users = List<Map<String, dynamic>>.from(response);
        _filteredUsers = _users;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[AdminUsers] Error loading users: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        final errorMsg = e.toString().contains('infinite recursion') 
            ? 'Erreur de configuration RLS. Veuillez appliquer les politiques Supabase (voir lib/supabase/APPLY_POLICIES.md)'
            : 'Erreur lors du chargement: ${e.toString().length > 100 ? e.toString().substring(0, 100) + "..." : e}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: KoogweColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        final matchesSearch = query.isEmpty ||
            (user['email']?.toString().toLowerCase().contains(query) ?? false) ||
            (user['first_name']?.toString().toLowerCase().contains(query) ?? false) ||
            (user['last_name']?.toString().toLowerCase().contains(query) ?? false);
        
        final matchesRole = _filterRole == 'all' || 
            (user['role']?.toString() == _filterRole);
        
        return matchesSearch && matchesRole;
      }).toList();
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
            'Gestion des Utilisateurs',
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
                    final headers = ['Nom', 'Email', 'Rôle', 'Téléphone', 'Date d\'inscription'];
                    final rows = _filteredUsers.map((user) {
                      final firstName = user['first_name']?.toString() ?? '';
                      final lastName = user['last_name']?.toString() ?? '';
                      final name = '$firstName $lastName'.trim().isEmpty ? 'Utilisateur' : '$firstName $lastName';
                      final createdAt = DateTime.tryParse(user['created_at']?.toString() ?? '') ?? DateTime.now();
                      return [
                        name,
                        user['email']?.toString() ?? '',
                        user['role']?.toString() ?? '',
                        user['phone_number']?.toString() ?? 'N/A',
                        DateFormat('dd/MM/yyyy').format(createdAt),
                      ];
                    }).toList();
                    final pdfSuccess = await exportService.exportToPDF(
                      title: 'Liste des Utilisateurs',
                      headers: headers,
                      rows: rows,
                      fileName: 'users_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
                    );
                    final excelSuccess = await exportService.exportToCSV(
                      title: 'Liste des Utilisateurs',
                      headers: headers,
                      rows: rows,
                      fileName: 'users_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
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
                    final headers = ['Nom', 'Email', 'Rôle', 'Téléphone', 'Date d\'inscription'];
                    final rows = _filteredUsers.map((user) {
                      final firstName = user['first_name']?.toString() ?? '';
                      final lastName = user['last_name']?.toString() ?? '';
                      final name = '$firstName $lastName'.trim().isEmpty ? 'Utilisateur' : '$firstName $lastName';
                      final createdAt = DateTime.tryParse(user['created_at']?.toString() ?? '') ?? DateTime.now();
                      return [
                        name,
                        user['email']?.toString() ?? '',
                        user['role']?.toString() ?? '',
                        user['phone_number']?.toString() ?? 'N/A',
                        DateFormat('dd/MM/yyyy').format(createdAt),
                      ];
                    }).toList();
                    final success = await exportService.exportToCSV(
                      title: 'Liste des Utilisateurs',
                      headers: headers,
                      rows: rows,
                      fileName: 'users_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv',
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
                child: Column(
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(KoogweSpacing.md),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Rechercher un utilisateur...',
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                        ),
                        onChanged: (_) => _filterUsers(),
                      ),
                    ),
                    const SizedBox(height: KoogweSpacing.md),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _FilterChip(
                            label: 'Tous',
                            isSelected: _filterRole == 'all',
                            onTap: () {
                              setState(() => _filterRole = 'all');
                              _filterUsers();
                            },
                          ),
                          const SizedBox(width: KoogweSpacing.sm),
                          _FilterChip(
                            label: 'Passagers',
                            isSelected: _filterRole == 'passenger',
                            onTap: () {
                              setState(() => _filterRole = 'passenger');
                              _filterUsers();
                            },
                          ),
                          const SizedBox(width: KoogweSpacing.sm),
                          _FilterChip(
                            label: 'Chauffeurs',
                            isSelected: _filterRole == 'driver',
                            onTap: () {
                              setState(() => _filterRole = 'driver');
                              _filterUsers();
                            },
                          ),
                          const SizedBox(width: KoogweSpacing.sm),
                          _FilterChip(
                            label: 'Entreprises',
                            isSelected: _filterRole == 'business',
                            onTap: () {
                              setState(() => _filterRole = 'business');
                              _filterUsers();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: KoogweSpacing.md),
                            Text(
                              'Chargement des utilisateurs...',
                              style: GoogleFonts.inter(
                                color: isDark
                                    ? KoogweColors.darkTextSecondary
                                    : KoogweColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _filteredUsers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 64,
                                  color: isDark
                                      ? KoogweColors.darkTextTertiary
                                      : KoogweColors.lightTextTertiary,
                                ),
                                const SizedBox(height: KoogweSpacing.md),
                                Text(
                                  _users.isEmpty 
                                      ? 'Aucun utilisateur dans la base de données'
                                      : 'Aucun utilisateur ne correspond à votre recherche',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? KoogweColors.darkTextSecondary
                                        : KoogweColors.lightTextSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (_users.isEmpty) ...[
                                  const SizedBox(height: KoogweSpacing.md),
                                  Text(
                                    'Les utilisateurs apparaîtront ici une fois inscrits',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: isDark
                                          ? KoogweColors.darkTextTertiary
                                          : KoogweColors.lightTextTertiary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ],
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final isSmallScreen = constraints.maxWidth < 600;
                              return ListView.builder(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg,
                                ),
                                itemCount: _filteredUsers.length,
                                itemBuilder: (context, index) {
                                  final user = _filteredUsers[index];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md,
                                    ),
                                    child: _UserCard(
                                      user: user,
                                      isCompact: isSmallScreen,
                                    ).animate().fadeIn(delay: (index * 30).ms),
                                  );
                                },
                              );
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

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isCompact;

  const _UserCard({required this.user, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final role = user['role']?.toString() ?? 'passenger';
    final email = user['email']?.toString() ?? 'N/A';
    final firstName = user['first_name']?.toString() ?? '';
    final lastName = user['last_name']?.toString() ?? '';
    final name = '$firstName $lastName'.trim().isEmpty ? 'Utilisateur' : '$firstName $lastName';

    Color roleColor;
    IconData roleIcon;
    switch (role) {
      case 'driver':
        roleColor = KoogweColors.secondary;
        roleIcon = Icons.drive_eta;
        break;
      case 'business':
        roleColor = KoogweColors.accent;
        roleIcon = Icons.business;
        break;
      case 'admin':
        roleColor = KoogweColors.error;
        roleIcon = Icons.admin_panel_settings;
        break;
      default:
        roleColor = KoogweColors.primary;
        roleIcon = Icons.person;
    }

    return GlassCard(
      padding: EdgeInsets.all(isCompact ? KoogweSpacing.sm : KoogweSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: isCompact ? 20 : 24,
            backgroundColor: roleColor.withValues(alpha: 0.2),
            child: Icon(roleIcon, color: roleColor, size: isCompact ? 20 : 24),
          ),
          SizedBox(width: isCompact ? KoogweSpacing.sm : KoogweSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: isCompact ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isCompact) ...[
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 6 : 8,
                    vertical: isCompact ? 2 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.2),
                    borderRadius: KoogweRadius.smRadius,
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: isCompact ? 9 : 10,
                      fontWeight: FontWeight.w600,
                      color: roleColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, size: isCompact ? 20 : 24),
            onPressed: () {
              _showUserActions(context, user);
            },
          ),
        ],
      ),
    );
  }

  void _showUserActions(BuildContext context, Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(KoogweSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Voir les détails'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to user details
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Open edit dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Suspendre'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Suspend user
              },
            ),
          ],
        ),
      ),
    );
  }
}

