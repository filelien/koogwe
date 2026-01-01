import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/services/carpool_service.dart';
import 'package:koogwe/core/services/location_service.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:koogwe/core/widgets/route_preview.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geocoding/geocoding.dart';

class CarpoolScreen extends ConsumerStatefulWidget {
  const CarpoolScreen({super.key});

  @override
  ConsumerState<CarpoolScreen> createState() => _CarpoolScreenState();
}

class _CarpoolScreenState extends ConsumerState<CarpoolScreen> with SingleTickerProviderStateMixin {
  final CarpoolService _carpoolService = CarpoolService();
  late TabController _tabController;
  bool _isLoading = false;
  List<Map<String, dynamic>> _availableRides = [];
  List<Map<String, dynamic>> _myBookings = [];
  List<Map<String, dynamic>> _myRides = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final available = await _carpoolService.getAvailableCarpoolRides();
      final bookings = await _carpoolService.getMyCarpoolBookings();
      final myRides = await _carpoolService.getMyCarpoolRidesAsDriver();
      
      setState(() {
        _availableRides = available;
        _myBookings = bookings;
        _myRides = myRides;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('[CarpoolScreen] Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Covoiturage',
          style: GoogleFonts.inter(fontSize: isSmallScreen ? 18 : 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: GoogleFonts.inter(
            fontSize: isSmallScreen ? 11 : 12,
            fontWeight: FontWeight.w600,
          ),
          tabs: [
            Tab(
              text: 'Disponibles',
              icon: Icon(Icons.search, size: isSmallScreen ? 18 : 20),
            ),
            Tab(
              text: 'Réservations',
              icon: Icon(Icons.bookmark, size: isSmallScreen ? 18 : 20),
            ),
            Tab(
              text: 'Mes trajets',
              icon: Icon(Icons.directions_car, size: isSmallScreen ? 18 : 20),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, size: isSmallScreen ? 20 : 24),
            onPressed: () => _showCreateCarpoolDialog(context),
            tooltip: 'Créer un trajet',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAvailableRidesTab(isDark),
                  _buildMyBookingsTab(isDark),
                  _buildMyRidesTab(isDark),
                ],
              ),
            ),
    );
  }

  Widget _buildAvailableRidesTab(bool isDark) {
    if (_availableRides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: KoogweColors.darkTextSecondary),
            const SizedBox(height: KoogweSpacing.md),
            Text(
              'Aucun trajet disponible',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: KoogweSpacing.lg),
            KoogweButton(
              text: 'Créer un trajet',
              onPressed: () => _showCreateCarpoolDialog(context),
              icon: Icons.add,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      itemCount: _availableRides.length,
      itemBuilder: (context, index) {
        final ride = _availableRides[index];
        return _CarpoolRideCard(
          ride: ride,
          onBook: () => _bookRide(ride),
          isDark: isDark,
        ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildMyBookingsTab(bool isDark) {
    if (_myBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: KoogweColors.darkTextSecondary),
            const SizedBox(height: KoogweSpacing.md),
            Text(
              'Aucune réservation',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      itemCount: _myBookings.length,
      itemBuilder: (context, index) {
        final booking = _myBookings[index];
        return _BookingCard(
          booking: booking,
          onCancel: () => _cancelBooking(booking['id'] as String),
          isDark: isDark,
        ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildMyRidesTab(bool isDark) {
    if (_myRides.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car_outlined, size: 64, color: KoogweColors.darkTextSecondary),
            const SizedBox(height: KoogweSpacing.md),
            Text(
              'Aucun trajet créé',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: KoogweSpacing.lg),
            KoogweButton(
              text: 'Créer un trajet',
              onPressed: () => _showCreateCarpoolDialog(context),
              icon: Icons.add,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      itemCount: _myRides.length,
      itemBuilder: (context, index) {
        final ride = _myRides[index];
        return _MyRideCard(
          ride: ride,
          onCancel: () => _cancelRide(ride['id'] as String),
          isDark: isDark,
        ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Future<void> _bookRide(Map<String, dynamic> ride) async {
    final rideId = ride['id'] as String?;
    if (rideId == null) return;

    // Demander le nombre de places
    final seatsController = TextEditingController(text: '1');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réserver une place'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: seatsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nombre de places',
                hintText: '1',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Réserver'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final seats = int.tryParse(seatsController.text) ?? 1;
      final booking = await _carpoolService.bookCarpoolSeat(
        carpoolRideId: rideId,
        seatsRequested: seats,
      );

      if (booking != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation effectuée avec succès !')),
        );
        _loadData();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la réservation')),
        );
      }
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    final success = await _carpoolService.cancelCarpoolBooking(bookingId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation annulée')),
      );
      _loadData();
    }
  }

  Future<void> _cancelRide(String rideId) async {
    final success = await _carpoolService.cancelCarpoolRide(rideId);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trajet annulé')),
      );
      _loadData();
    }
  }

  void _showCreateCarpoolDialog(BuildContext context) async {
    final pickupController = TextEditingController();
    final dropoffController = TextEditingController();
    final priceController = TextEditingController(text: '5.00');
    final seatsController = TextEditingController(text: '4');
    final descriptionController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;
    String selectedVehicleType = 'comfort';
    LatLng? pickupLocation;
    LatLng? dropoffLocation;
    
    // Obtenir la position actuelle pour le pickup
    try {
      final locationService = LocationService();
      final currentLocation = await locationService.getCurrentLocation();
      if (currentLocation != null) {
        pickupLocation = currentLocation;
        // Obtenir l'adresse
        final placemarks = await placemarkFromCoordinates(
          currentLocation.latitude,
          currentLocation.longitude,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final address = _formatAddress(place);
          pickupController.text = address;
        }
      }
    } catch (e) {
      debugPrint('[Carpool] Error getting location: $e');
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Créer un trajet de covoiturage'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Date et heure
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(selectedDate != null
                            ? DateFormat('d MMM yyyy', 'fr').format(selectedDate!)
                            : 'Date'),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 1)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (picked != null) {
                            setDialogState(() => selectedDate = picked);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(selectedTime != null
                            ? selectedTime!.format(context)
                            : 'Heure'),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setDialogState(() => selectedTime = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                TextField(
                  controller: pickupController,
                  decoration: InputDecoration(
                    labelText: 'Lieu de départ',
                    prefixIcon: const Icon(Icons.my_location),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.my_location),
                      onPressed: () async {
                        try {
                          final locationService = LocationService();
                          final location = await locationService.getCurrentLocation();
                          if (location != null) {
                            pickupLocation = location;
                            final placemarks = await placemarkFromCoordinates(
                              location.latitude,
                              location.longitude,
                            );
                            if (placemarks.isNotEmpty) {
                              final address = _formatAddress(placemarks.first);
                              setDialogState(() {
                                pickupController.text = address;
                              });
                            }
                          }
                        } catch (e) {
                          debugPrint('[Carpool] Error: $e');
                        }
                      },
                      tooltip: 'Utiliser ma position',
                    ),
                  ),
                  onChanged: (value) async {
                    if (value.isNotEmpty) {
                      try {
                        final locations = await locationFromAddress(value);
                        if (locations.isNotEmpty) {
                          pickupLocation = LatLng(
                            locations.first.latitude,
                            locations.first.longitude,
                          );
                        }
                      } catch (e) {
                        debugPrint('[Carpool] Geocoding error: $e');
                      }
                    }
                  },
                ),
                TextField(
                  controller: dropoffController,
                  decoration: const InputDecoration(
                    labelText: 'Destination',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  onChanged: (value) async {
                    if (value.isNotEmpty) {
                      try {
                        final locations = await locationFromAddress(value);
                        if (locations.isNotEmpty) {
                          dropoffLocation = LatLng(
                            locations.first.latitude,
                            locations.first.longitude,
                          );
                        }
                      } catch (e) {
                        debugPrint('[Carpool] Geocoding error: $e');
                      }
                    }
                  },
                ),
                TextField(
                  controller: seatsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Places disponibles',
                    prefixIcon: Icon(Icons.people),
                  ),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Prix par place (€)',
                    prefixIcon: Icon(Icons.euro),
                  ),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optionnel)',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedDate == null || selectedTime == null ||
                    pickupController.text.isEmpty ||
                    dropoffController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Veuillez remplir tous les champs')),
                  );
                  return;
                }

                final scheduledDateTime = DateTime(
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                );

                final price = double.tryParse(priceController.text.replaceAll(',', '.')) ?? 5.0;
                final seats = int.tryParse(seatsController.text) ?? 4;

                final ride = await _carpoolService.createCarpoolRide(
                  pickup: pickupController.text,
                  dropoff: dropoffController.text,
                  scheduledDeparture: scheduledDateTime,
                  availableSeats: seats,
                  pricePerSeat: price,
                  description: descriptionController.text.isEmpty ? null : descriptionController.text,
                  vehicleType: selectedVehicleType,
                  pickupLat: pickupLocation?.latitude,
                  pickupLng: pickupLocation?.longitude,
                  dropoffLat: dropoffLocation?.latitude,
                  dropoffLng: dropoffLocation?.longitude,
                );

                if (ride != null && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Trajet créé avec succès !')),
                  );
                  _loadData();
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erreur lors de la création')),
                  );
                }
              },
              child: const Text('Créer'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAddress(Placemark place) {
    final parts = <String>[];
    if (place.street != null && place.street!.isNotEmpty) parts.add(place.street!);
    if (place.postalCode != null && place.postalCode!.isNotEmpty) parts.add(place.postalCode!);
    if (place.locality != null && place.locality!.isNotEmpty) parts.add(place.locality!);
    return parts.join(', ');
  }
}

class _CarpoolRideCard extends StatelessWidget {
  final Map<String, dynamic> ride;
  final VoidCallback onBook;
  final bool isDark;

  const _CarpoolRideCard({
    required this.ride,
    required this.onBook,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final driver = ride['driver'] as Map<String, dynamic>?;
    final pickupLat = ride['pickup_lat'] as double?;
    final pickupLng = ride['pickup_lng'] as double?;
    final dropoffLat = ride['dropoff_lat'] as double?;
    final dropoffLng = ride['dropoff_lng'] as double?;
    final scheduledDeparture = DateTime.tryParse(ride['scheduled_departure']?.toString() ?? '');
    final availableSeats = (ride['available_seats'] as num?)?.toInt() ?? 0;
    final pricePerSeat = (ride['price_per_seat'] as num?)?.toDouble() ?? 0.0;

    return GlassCard(
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec conducteur
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: KoogweColors.primary,
                child: Text(
                  (driver?['first_name']?.toString() ?? 'D')[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: KoogweSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${driver?['first_name'] ?? ''} ${driver?['last_name'] ?? ''}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                      ),
                    ),
                    if (scheduledDeparture != null)
                      Text(
                        DateFormat('dd MMM yyyy à HH:mm', 'fr').format(scheduledDeparture),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: KoogweColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$availableSeats places',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: KoogweColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.md),
          const Divider(),
          const SizedBox(height: KoogweSpacing.md),
          
          // Itinéraire
          Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: KoogweColors.success,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 30,
                    color: KoogweColors.darkTextTertiary,
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: KoogweColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: KoogweSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride['pickup_text']?.toString() ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      ride['dropoff_text']?.toString() ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Carte si coordonnées disponibles
          if (pickupLat != null && pickupLng != null && dropoffLat != null && dropoffLng != null) ...[
            const SizedBox(height: KoogweSpacing.md),
            SizedBox(
              height: 150,
              child: RoutePreview(
                pickupLocation: LatLng(pickupLat, pickupLng),
                dropoffLocation: LatLng(dropoffLat, dropoffLng),
                showCurrentLocationMarker: false,
              ),
            ),
          ],
          
          const SizedBox(height: KoogweSpacing.md),
          const Divider(),
          const SizedBox(height: KoogweSpacing.md),
          
          // Prix et bouton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prix par place',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                    ),
                  ),
                  Text(
                    '${pricePerSeat.toStringAsFixed(2)}€',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: KoogweColors.primary,
                    ),
                  ),
                ],
              ),
              KoogweButton(
                text: 'Réserver',
                onPressed: onBook,
                icon: Icons.bookmark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onCancel;
  final bool isDark;

  const _BookingCard({
    required this.booking,
    required this.onCancel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final carpoolRide = booking['carpool_ride'] as Map<String, dynamic>?;
    final status = booking['status'] as String? ?? 'pending';
    
    return GlassCard(
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                carpoolRide?['pickup_text']?.toString() ?? '',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'confirmed' 
                      ? KoogweColors.success.withValues(alpha: 0.2)
                      : KoogweColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status == 'confirmed' ? 'Confirmé' : 'En attente',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: status == 'confirmed' ? KoogweColors.success : KoogweColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: KoogweSpacing.sm),
          Text(
            carpoolRide?['dropoff_text']?.toString() ?? '',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: KoogweSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(booking['total_price'] as num?)?.toStringAsFixed(2) ?? '0'}€',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: KoogweColors.primary,
                ),
              ),
              if (status == 'pending' || status == 'confirmed')
                TextButton(
                  onPressed: onCancel,
                  child: const Text('Annuler'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MyRideCard extends StatelessWidget {
  final Map<String, dynamic> ride;
  final VoidCallback onCancel;
  final bool isDark;

  const _MyRideCard({
    required this.ride,
    required this.onCancel,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final scheduledDeparture = DateTime.tryParse(ride['scheduled_departure']?.toString() ?? '');
    final availableSeats = (ride['available_seats'] as num?)?.toInt() ?? 0;
    final bookings = ride['bookings'] as List<dynamic>? ?? [];
    
    return GlassCard(
      padding: const EdgeInsets.all(KoogweSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride['pickup_text']?.toString() ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? KoogweColors.darkTextPrimary : KoogweColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      ride['dropoff_text']?.toString() ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (ride['status'] == 'open')
                TextButton(
                  onPressed: onCancel,
                  child: const Text('Annuler'),
                ),
            ],
          ),
          if (scheduledDeparture != null) ...[
            const SizedBox(height: KoogweSpacing.sm),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: KoogweColors.primary),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd MMM yyyy à HH:mm', 'fr').format(scheduledDeparture),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: KoogweSpacing.sm),
          Row(
            children: [
              Icon(Icons.people, size: 16, color: KoogweColors.accent),
              const SizedBox(width: 4),
              Text(
                '$availableSeats places disponibles • ${bookings.length} réservation(s)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isDark ? KoogweColors.darkTextSecondary : KoogweColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

