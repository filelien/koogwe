import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/providers/scheduled_ride_provider.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:koogwe/core/widgets/koogwe_text_field.dart';
import 'package:koogwe/core/widgets/route_preview.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/services/location_service.dart';
import 'package:koogwe/core/services/osrm_service.dart';
import 'package:koogwe/core/services/pricing_service.dart';
import 'package:koogwe/core/services/rides_service.dart';
import 'package:koogwe/core/services/notification_service.dart';
import 'package:koogwe/core/router/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class ScheduledRideScreenImproved extends ConsumerStatefulWidget {
  const ScheduledRideScreenImproved({super.key});

  @override
  ConsumerState<ScheduledRideScreenImproved> createState() => _ScheduledRideScreenImprovedState();
}

class _ScheduledRideScreenImprovedState extends ConsumerState<ScheduledRideScreenImproved> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  String _selectedVehicleType = 'comfort';
  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;
  List<LatLng> _routePolyline = [];
  double _estimatedPrice = 0.0;
  int _estimatedDuration = 0;
  bool _isCalculating = false;
  final LocationService _locationService = LocationService();
  final OsrmService _osrmService = OsrmService();
  final PricingService _pricingService = PricingService();
  final RidesService _ridesService = RidesService();
  final NotificationService _notificationService = NotificationService();

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final location = await _locationService.getCurrentLocation();
      if (location != null && mounted) {
        setState(() {
          _pickupLocation = LatLng(location.latitude, location.longitude);
        });
        // Geocoder pour obtenir l'adresse
        final placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
        if (placemarks.isNotEmpty && mounted) {
          final place = placemarks.first;
          _pickupController.text = '${place.street ?? ''} ${place.locality ?? ''} ${place.country ?? ''}'.trim();
        }
      }
    } catch (e) {
      debugPrint('Erreur obtention localisation: $e');
    }
  }

  Future<void> _searchAddress(String query, bool isPickup) async {
    if (query.isEmpty) return;
    
    try {
      final locations = await locationFromAddress(query);
      if (locations.isNotEmpty && mounted) {
        final location = locations.first;
        final latLng = LatLng(location.latitude, location.longitude);
        
        setState(() {
          if (isPickup) {
            _pickupLocation = latLng;
          } else {
            _dropoffLocation = latLng;
          }
        });
        
        _calculateRoute();
      }
    } catch (e) {
      debugPrint('Erreur recherche adresse: $e');
    }
  }

  Future<void> _calculateRoute() async {
    if (_pickupLocation == null || _dropoffLocation == null) return;

    setState(() => _isCalculating = true);

    try {
      final routeDetails = await _pricingService.calculatePrice(
        pickupLocation: _pickupLocation!,
        dropoffLocation: _dropoffLocation!,
        vehicleType: _selectedVehicleType,
      );

      if (mounted) {
        setState(() {
          _estimatedPrice = routeDetails['price'] as double;
          _estimatedDuration = routeDetails['duration_min'] as int;
          _routePolyline = (routeDetails['polyline'] as List<dynamic>)
              .map((p) => LatLng((p[0] as num).toDouble(), (p[1] as num).toDouble()))
              .toList();
          _isCalculating = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur calcul itinéraire: $e');
      if (mounted) {
        setState(() => _isCalculating = false);
      }
    }
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
            colorScheme: ColorScheme.light(primary: KoogweColors.primary),
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
        _pickupController.text.isEmpty || _dropoffController.text.isEmpty ||
        _pickupLocation == null || _dropoffLocation == null) {
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

    // Vérifier que la date n'est pas dans le passé
    if (scheduledDateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La date et l\'heure doivent être dans le futur')),
      );
      return;
    }

    // Créer la course avec scheduled_at
    final ride = await _ridesService.createRide(
      pickup: _pickupController.text,
      dropoff: _dropoffController.text,
      vehicleType: _selectedVehicleType,
      estimatedPrice: _estimatedPrice,
      pickupLat: _pickupLocation!.latitude,
      pickupLng: _pickupLocation!.longitude,
      dropoffLat: _dropoffLocation!.latitude,
      dropoffLng: _dropoffLocation!.longitude,
    );

    if (ride != null) {
      // Mettre à jour avec scheduled_at
      // TODO: Ajouter méthode updateRide dans RidesService pour mettre scheduled_at
      
      // Créer une notification de rappel
      final reminderTime = scheduledDateTime.subtract(const Duration(hours: 1));
      if (reminderTime.isAfter(DateTime.now())) {
        // TODO: Programmer notification locale pour le rappel
      }

      final success = await ref.read(scheduledRideProvider.notifier).scheduleRide(
        scheduledDateTime: scheduledDateTime,
        pickup: _pickupController.text,
        dropoff: _dropoffController.text,
        vehicleType: _selectedVehicleType,
        estimatedPrice: _estimatedPrice,
        reminderTime: reminderTime,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trajet planifié avec succès !')),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(scheduledRideProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return GradientBackground(
      useDarkAurora: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Planifier un trajet',
            style: GoogleFonts.inter(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Carte avec itinéraire
                if (_pickupLocation != null && _dropoffLocation != null)
                  GlassCard(
                    borderRadius: KoogweRadius.lgRadius,
                    child: SizedBox(
                      height: isSmallScreen ? 200 : 250,
                      child: RoutePreview(
                        polyline: _routePolyline,
                        currentLocation: _pickupLocation,
                        pickupLocation: _pickupLocation,
                        dropoffLocation: _dropoffLocation,
                        autoFitBounds: true,
                      ),
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1, end: 0),
                
                SizedBox(height: isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                
                // Date et Heure
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectDate,
                        borderRadius: KoogweRadius.mdRadius,
                        child: GlassCard(
                          padding: EdgeInsets.all(isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: KoogweColors.primary, size: isSmallScreen ? 20 : 24),
                              SizedBox(width: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date',
                                      style: GoogleFonts.inter(fontSize: isSmallScreen ? 11 : 12, color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary),
                                    ),
                                    Text(
                                      _selectedDate != null
                                          ? DateFormat('d MMM yyyy', 'fr_FR').format(_selectedDate!)
                                          : 'Sélectionner',
                                      style: GoogleFonts.inter(fontSize: isSmallScreen ? 14 : 16, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
                    Expanded(
                      child: InkWell(
                        onTap: _selectTime,
                        borderRadius: KoogweRadius.mdRadius,
                        child: GlassCard(
                          padding: EdgeInsets.all(isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                          child: Row(
                            children: [
                              Icon(Icons.access_time, color: KoogweColors.primary, size: isSmallScreen ? 20 : 24),
                              SizedBox(width: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Heure',
                                      style: GoogleFonts.inter(fontSize: isSmallScreen ? 11 : 12, color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary),
                                    ),
                                    Text(
                                      _selectedTime != null
                                          ? _selectedTime!.format(context)
                                          : 'Sélectionner',
                                      style: GoogleFonts.inter(fontSize: isSmallScreen ? 14 : 16, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0),
                
                SizedBox(height: isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                
                // Lieu de prise en charge
                KoogweTextField(
                  controller: _pickupController,
                  hint: 'Lieu de prise en charge',
                  prefixIcon: Icon(Icons.my_location, color: KoogweColors.success, size: isSmallScreen ? 20 : 24),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.gps_fixed),
                    onPressed: _getCurrentLocation,
                    tooltip: 'Utiliser ma position',
                  ),
                  onChanged: (value) => _searchAddress(value, true),
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
                
                SizedBox(height: isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                
                // Destination
                KoogweTextField(
                  controller: _dropoffController,
                  hint: 'Destination',
                  prefixIcon: Icon(Icons.location_on, color: KoogweColors.error, size: isSmallScreen ? 20 : 24),
                  onChanged: (value) => _searchAddress(value, false),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0),
                
                SizedBox(height: isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                
                // Type de véhicule
                Text(
                  'Type de véhicule',
                  style: GoogleFonts.inter(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
                Wrap(
                  spacing: KoogweSpacing.sm,
                  runSpacing: KoogweSpacing.sm,
                  children: [
                    {'value': 'economy', 'label': 'Éco'},
                    {'value': 'comfort', 'label': 'Confort'},
                    {'value': 'premium', 'label': 'Premium'},
                    {'value': 'luxury', 'label': 'Luxe'},
                  ].map((type) {
                    final isSelected = _selectedVehicleType == type['value'];
                    return ChoiceChip(
                      label: Text(type['label']!),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedVehicleType = type['value']!;
                            if (_pickupLocation != null && _dropoffLocation != null) {
                              _calculateRoute();
                            }
                          });
                        }
                      },
                      selectedColor: KoogweColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: KoogweColors.primary,
                    );
                  }).toList(),
                ).animate().fadeIn(delay: 400.ms),
                
                SizedBox(height: isSmallScreen ? KoogweSpacing.lg : KoogweSpacing.xl),
                
                // Estimation prix et durée
                if (_estimatedPrice > 0)
                  GlassCard(
                    padding: EdgeInsets.all(isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              'Prix estimé',
                              style: GoogleFonts.inter(fontSize: isSmallScreen ? 12 : 14, color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary),
                            ),
                            Text(
                              '€${_estimatedPrice.toStringAsFixed(2)}',
                              style: GoogleFonts.inter(fontSize: isSmallScreen ? 20 : 24, fontWeight: FontWeight.w700, color: KoogweColors.primary),
                            ),
                          ],
                        ),
                        Container(width: 1, height: 40, color: isDark ? KoogweColors.darkBorder : KoogweColors.lightBorder),
                        Column(
                          children: [
                            Text(
                              'Durée estimée',
                              style: GoogleFonts.inter(fontSize: isSmallScreen ? 12 : 14, color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary),
                            ),
                            Text(
                              '$_estimatedDuration min',
                              style: GoogleFonts.inter(fontSize: isSmallScreen ? 20 : 24, fontWeight: FontWeight.w700, color: KoogweColors.secondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms),
                
                SizedBox(height: isSmallScreen ? KoogweSpacing.lg : KoogweSpacing.xl),
                
                // Bouton planifier
                KoogweButton(
                  text: 'Planifier le trajet',
                  icon: Icons.schedule,
                  onPressed: state.isLoading || _isCalculating ? null : _scheduleRide,
                  isFullWidth: true,
                  size: ButtonSize.large,
                  isLoading: state.isLoading || _isCalculating,
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
                
                SizedBox(height: isSmallScreen ? KoogweSpacing.lg : KoogweSpacing.xl),
                
                // Liste des trajets planifiés
                if (state.rides.isNotEmpty) ...[
                  Text(
                    'Mes trajets planifiés',
                    style: GoogleFonts.inter(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.w700,
                      color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg),
                  ...state.rides.map((ride) => _ScheduledRideCardImproved(
                    ride: ride,
                    onCancel: () {
                      ref.read(scheduledRideProvider.notifier).cancelScheduledRide(ride.id);
                    },
                    onModify: () {
                      // Pré-remplir le formulaire
                      setState(() {
                        _selectedDate = ride.scheduledDateTime;
                        _selectedTime = TimeOfDay.fromDateTime(ride.scheduledDateTime);
                        _pickupController.text = ride.pickup;
                        _dropoffController.text = ride.dropoff;
                        _selectedVehicleType = ride.vehicleType;
                      });
                    },
                  )).toList(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduledRideCardImproved extends StatelessWidget {
  final ScheduledRide ride;
  final VoidCallback onCancel;
  final VoidCallback onModify;

  const _ScheduledRideCardImproved({
    required this.ride,
    required this.onCancel,
    required this.onModify,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('d MMM yyyy à HH:mm', 'fr_FR');
    
    return GlassCard(
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      borderRadius: KoogweRadius.lgRadius,
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
                    style: TextButton.styleFrom(foregroundColor: KoogweColors.error),
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

