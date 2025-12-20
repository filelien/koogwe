import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/scheduled_ride_provider.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:koogwe/core/widgets/koogwe_text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ScheduledRideScreen extends ConsumerStatefulWidget {
  const ScheduledRideScreen({super.key});

  @override
  ConsumerState<ScheduledRideScreen> createState() => _ScheduledRideScreenState();
}

class _ScheduledRideScreenState extends ConsumerState<ScheduledRideScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  String _selectedVehicleType = 'Confort';

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('fr', 'FR'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: KoogweColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _scheduleRide() async {
    if (_selectedDate == null || _selectedTime == null || 
        _pickupController.text.isEmpty || _dropoffController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final scheduledDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final success = await ref.read(scheduledRideProvider.notifier).scheduleRide(
      scheduledDateTime: scheduledDateTime,
      pickup: _pickupController.text,
      dropoff: _dropoffController.text,
      vehicleType: _selectedVehicleType,
      estimatedPrice: 25.0, // Simulé
      reminderTime: scheduledDateTime.subtract(const Duration(hours: 1)),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trajet planifié avec succès !')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(scheduledRideProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planifier un trajet'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KoogweSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Réservez votre trajet à l\'avance',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ).animate().fadeIn().slideX(begin: -0.2, end: 0),
            const SizedBox(height: KoogweSpacing.md),
            Text(
              'Choisissez la date et l\'heure de votre trajet',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
              ),
            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
            const SizedBox(height: KoogweSpacing.xxxl),
            
            // Date
            InkWell(
              onTap: _selectDate,
              borderRadius: KoogweRadius.mdRadius,
              child: Container(
                padding: const EdgeInsets.all(KoogweSpacing.lg),
                decoration: BoxDecoration(
                  color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                  borderRadius: KoogweRadius.mdRadius,
                  border: Border.all(
                    color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: KoogweColors.primary),
                    const SizedBox(width: KoogweSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedDate != null
                                ? DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_selectedDate!)
                                : 'Sélectionner une date',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: KoogweSpacing.lg),
            
            // Heure
            InkWell(
              onTap: _selectTime,
              borderRadius: KoogweRadius.mdRadius,
              child: Container(
                padding: const EdgeInsets.all(KoogweSpacing.lg),
                decoration: BoxDecoration(
                  color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
                  borderRadius: KoogweRadius.mdRadius,
                  border: Border.all(
                    color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: KoogweColors.primary),
                    const SizedBox(width: KoogweSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Heure',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedTime != null
                                ? _selectedTime!.format(context)
                                : 'Sélectionner une heure',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: KoogweSpacing.xl),
            
            KoogweTextField(
              controller: _pickupController,
              hint: 'Lieu de prise en charge',
              prefixIcon: Icon(Icons.my_location, color: KoogweColors.success),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: KoogweSpacing.lg),
            
            KoogweTextField(
              controller: _dropoffController,
              hint: 'Destination',
              prefixIcon: Icon(Icons.location_on, color: KoogweColors.error),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: KoogweSpacing.xl),
            
            Text(
              'Type de véhicule',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: KoogweSpacing.md),
            Wrap(
              spacing: KoogweSpacing.md,
              runSpacing: KoogweSpacing.md,
              children: ['Éco', 'Confort', 'Premium', 'XL'].map((type) {
                final isSelected = _selectedVehicleType == type;
                return FilterChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedVehicleType = type);
                  },
                  selectedColor: KoogweColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: KoogweColors.primary,
                );
              }).toList(),
            ).animate().fadeIn(delay: 600.ms),
            
            const SizedBox(height: KoogweSpacing.xxxl),
            
            KoogweButton(
              text: 'Planifier le trajet',
              icon: Icons.schedule,
              onPressed: state.isLoading ? null : _scheduleRide,
              isFullWidth: true,
              size: ButtonSize.large,
              isLoading: state.isLoading,
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),
            
            const SizedBox(height: KoogweSpacing.xxl),
            
            // Liste des trajets planifiés
            if (state.rides.isNotEmpty) ...[
              Text(
                'Trajets planifiés',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: KoogweSpacing.lg),
              ...state.rides.map((ride) => _ScheduledRideCard(
                ride: ride,
                onCancel: () {
                  ref.read(scheduledRideProvider.notifier).cancelScheduledRide(ride.id);
                },
                onModify: () {
                  // TODO: Ouvrir modal de modification
                },
              )),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScheduledRideCard extends StatelessWidget {
  final ScheduledRide ride;
  final VoidCallback onCancel;
  final VoidCallback onModify;

  const _ScheduledRideCard({
    required this.ride,
    required this.onCancel,
    required this.onModify,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('d MMM yyyy à HH:mm', 'fr_FR');
    
    return Container(
      margin: const EdgeInsets.only(bottom: KoogweSpacing.md),
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
        borderRadius: KoogweRadius.lgRadius,
        border: Border.all(
          color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule, size: 20, color: KoogweColors.primary),
                  const SizedBox(width: KoogweSpacing.sm),
                  Text(
                    dateFormat.format(ride.scheduledDateTime),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: KoogweColors.primary,
                    ),
                  ),
                ],
              ),
              if (ride.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: KoogweColors.success.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Actif',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: KoogweColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.md),
          Row(
            children: [
              Icon(Icons.my_location, size: 16, color: KoogweColors.success),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  ride.pickup,
                  style: GoogleFonts.inter(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: KoogweColors.error),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  ride.dropoff,
                  style: GoogleFonts.inter(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${ride.vehicleType} • ${ride.estimatedPrice.toStringAsFixed(2)}€',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: onModify,
                    child: const Text('Modifier'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: KoogweColors.error,
                    ),
                    child: const Text('Annuler'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

