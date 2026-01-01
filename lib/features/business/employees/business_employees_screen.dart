import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:koogwe/core/services/company_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BusinessEmployeesScreen extends ConsumerStatefulWidget {
  const BusinessEmployeesScreen({super.key});

  @override
  ConsumerState<BusinessEmployeesScreen> createState() => _BusinessEmployeesScreenState();
}

class _BusinessEmployeesScreenState extends ConsumerState<BusinessEmployeesScreen> {
  final _service = CompanyService();
  List<Map<String, dynamic>> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    final employees = await _service.getEmployees();
    setState(() {
      _employees = employees;
      _isLoading = false;
    });
  }

  Future<void> _addEmployee() async {
    final email = await showDialog<String>(
      context: context,
      builder: (context) => _AddEmployeeDialog(),
    );
    if (email != null && email.isNotEmpty) {
      await _service.addEmployeeByEmail(email);
      _loadEmployees();
    }
  }

  Future<void> _removeEmployee(String userId) async {
    await _service.removeEmployee(userId);
    _loadEmployees();
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
            'Employés',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addEmployee,
            ),
          ],
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _employees.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                          ),
                          const SizedBox(height: KoogweSpacing.lg),
                          Text(
                            'Aucun employé',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: KoogweSpacing.md),
                          KoogweButton(
                            text: 'Ajouter un employé',
                            icon: Icons.add,
                            onPressed: _addEmployee,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(KoogweSpacing.lg),
                      itemCount: _employees.length,
                      itemBuilder: (context, index) {
                        final employee = _employees[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: KoogweSpacing.md),
                          child: GlassCard(
                            padding: const EdgeInsets.all(KoogweSpacing.md),
                            child: ListTile(
                            leading: CircleAvatar(
                              child: Text(
                                employee['email']?.toString().substring(0, 1).toUpperCase() ?? 'E',
                              ),
                            ),
                            title: Text(employee['email']?.toString() ?? 'N/A'),
                            subtitle: Text(employee['role']?.toString() ?? 'employee'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeEmployee(employee['user_id']),
                            ),
                          ),
                          ),
                        ).animate().fadeIn(delay: (index * 100).ms);
                      },
                    ),
        ),
      ),
    );
  }
}

class _AddEmployeeDialog extends StatefulWidget {
  @override
  State<_AddEmployeeDialog> createState() => _AddEmployeeDialogState();
}

class _AddEmployeeDialogState extends State<_AddEmployeeDialog> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un employé'),
      content: TextField(
        controller: _emailController,
        decoration: const InputDecoration(
          labelText: 'Email',
          hintText: 'employe@example.com',
        ),
        keyboardType: TextInputType.emailAddress,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _emailController.text),
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}

