import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:koogwe/core/widgets/koogwe_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/providers/ride_provider.dart';
import 'package:koogwe/core/widgets/route_preview.dart';
import 'package:koogwe/core/widgets/floating_sheet.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/glass_card.dart';
import 'package:koogwe/core/services/location_service.dart';
import 'package:koogwe/core/services/osrm_service.dart';
import 'package:koogwe/core/router/app_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RideBookingScreen extends ConsumerStatefulWidget {
  const RideBookingScreen({super.key});

  @override
  ConsumerState<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends ConsumerState<RideBookingScreen> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _locationService = LocationService();
  final _osrmService = OsrmService();
  
  bool _loading = true;
  bool _loadingLocation = false;
  bool _calculatingRoute = false;
  LatLng? _currentLocation;
  LatLng? _pickupLocation;
  LatLng? _dropoffLocation;
  List<LatLng> _routePolyline = [];
  StreamSubscription<LatLng>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  /// Initialiser la géolocalisation et démarrer le suivi
  Future<void> _initializeLocation() async {
    setState(() {
      _loading = true;
      _loadingLocation = true;
    });

    try {
      // Obtenir la position actuelle
      final location = await _locationService.getCurrentLocation();
      
      if (location != null) {
        // Obtenir l'adresse à partir des coordonnées
        await _updateAddressFromLocation(location, isPickup: true);
        
        setState(() {
          _currentLocation = location;
          _pickupLocation = location;
          _loading = false;
          _loadingLocation = false;
        });

        // Démarrer le suivi en temps réel
        await _locationService.startLocationTracking();
        _locationSubscription = _locationService.locationStream.listen((location) {
          if (mounted) {
            setState(() {
              _currentLocation = location;
              // Mettre à jour la position de pickup si elle n'a pas été modifiée manuellement
              if (_pickupLocation == null || 
                  _locationService.calculateDistance(_pickupLocation!, location) < 50) {
                _pickupLocation = location;
              }
            });
            // Recalculer l'itinéraire si la destination est définie
            if (_dropoffLocation != null) {
              _calculateRoute();
            }
          }
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Impossible d\'obtenir votre position. Vérifiez les permissions de localisation.'),
              backgroundColor: KoogweColors.warning,
            ),
          );
        }
        setState(() {
          _loading = false;
          _loadingLocation = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur initialisation localisation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la récupération de votre position: $e'),
            backgroundColor: KoogweColors.error,
          ),
        );
      }
      setState(() {
        _loading = false;
        _loadingLocation = false;
      });
    }
  }

  /// Mettre à jour l'adresse à partir d'une localisation
  Future<void> _updateAddressFromLocation(LatLng location, {required bool isPickup}) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = _formatAddress(place);
        if (isPickup) {
          _pickupController.text = address;
        } else {
          _dropoffController.text = address;
        }
      }
    } catch (e) {
      debugPrint('Erreur geocoding: $e');
      final address = '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
      if (isPickup) {
        _pickupController.text = address;
      } else {
        _dropoffController.text = address;
      }
    }
  }

  /// Obtenir la position actuelle (bouton refresh)
  Future<void> _getCurrentLocation() async {
    setState(() {
      _loadingLocation = true;
    });

    try {
      final location = await _locationService.getCurrentLocation();
      if (location != null) {
        await _updateAddressFromLocation(location, isPickup: true);
        setState(() {
          _currentLocation = location;
          _pickupLocation = location;
          _loadingLocation = false;
        });
        // Recalculer l'itinéraire si nécessaire
        if (_dropoffLocation != null) {
          _calculateRoute();
        }
      } else {
        setState(() {
          _loadingLocation = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur obtention localisation: $e');
      setState(() {
        _loadingLocation = false;
      });
    }
  }

  /// Calculer l'itinéraire entre pickup et dropoff
  Future<void> _calculateRoute() async {
    if (_pickupLocation == null || _dropoffLocation == null) return;

    setState(() {
      _calculatingRoute = true;
    });

    try {
      final polyline = await _osrmService.route(
        startLat: _pickupLocation!.latitude,
        startLon: _pickupLocation!.longitude,
        endLat: _dropoffLocation!.latitude,
        endLon: _dropoffLocation!.longitude,
      );

      if (mounted) {
        setState(() {
          _routePolyline = polyline.map((p) => LatLng(p[0], p[1])).toList();
          _calculatingRoute = false;
        });
      }
    } catch (e) {
      debugPrint('Erreur calcul itinéraire: $e');
      if (mounted) {
        setState(() {
          _calculatingRoute = false;
        });
      }
    }
  }

  String _formatAddress(Placemark place) {
    final parts = <String>[];
    if (place.street != null && place.street!.isNotEmpty) parts.add(place.street!);
    if (place.postalCode != null && place.postalCode!.isNotEmpty) parts.add(place.postalCode!);
    if (place.locality != null && place.locality!.isNotEmpty) parts.add(place.locality!);
    return parts.join(', ');
  }

  Future<void> _searchAddress(String query, bool isPickup) async {
    if (query.isEmpty) {
      // Si le champ est vidé, réinitialiser la position
      setState(() {
        if (isPickup) {
          _pickupLocation = _currentLocation;
          _routePolyline = [];
        } else {
          _dropoffLocation = null;
          _routePolyline = [];
        }
      });
      return;
    }

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final latLng = LatLng(location.latitude, location.longitude);
        
        // Obtenir l'adresse complète
        await _updateAddressFromLocation(latLng, isPickup: isPickup);

        setState(() {
          if (isPickup) {
            _pickupLocation = latLng;
          } else {
            _dropoffLocation = latLng;
          }
        });

        // Recalculer l'itinéraire si les deux positions sont définies
        if (_pickupLocation != null && _dropoffLocation != null) {
          _calculateRoute();
        }
      }
    } catch (e) {
      debugPrint('Erreur recherche adresse: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final horizontalPadding = isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg;
    
    return GradientBackground(
      useDarkAurora: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Carte en arrière-plan
            Positioned.fill(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : RoutePreview(
                      currentLocation: _currentLocation,
                      pickupLocation: _pickupLocation,
                      dropoffLocation: _dropoffLocation,
                      center: _currentLocation,
                      showCurrentLocationMarker: true,
                      polyline: _routePolyline,
                      autoFitBounds: true,
                    ),
            ),
            
            // Indicateur de calcul d'itinéraire
            if (_calculatingRoute)
              Positioned(
                top: isSmallScreen ? 80 : 100,
                left: 0,
                right: 0,
                child: Center(
                  child: GlassCard(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? KoogweSpacing.md : KoogweSpacing.lg,
                      vertical: KoogweSpacing.sm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: isSmallScreen ? 16 : 20,
                          height: isSmallScreen ? 16 : 20,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: isSmallScreen ? KoogweSpacing.sm : KoogweSpacing.md),
                        Text(
                          'Calcul de l\'itinéraire...',
                          style: GoogleFonts.inter(
                            fontSize: isSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            // Bouton retour
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(horizontalPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GlassCard(
                        padding: EdgeInsets.zero,
                        borderRadius: KoogweRadius.fullRadius,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutes.passengerHome);
                            }
                          },
                        ),
                      ),
                      // Bouton de localisation
                      GlassCard(
                        padding: EdgeInsets.zero,
                        borderRadius: KoogweRadius.fullRadius,
                        child: IconButton(
                          icon: _loadingLocation
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.my_location),
                          onPressed: _getCurrentLocation,
                          tooltip: 'Ma position',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Feuille de saisie
            DraggableScrollableSheet(
              initialChildSize: 0.45,
              minChildSize: 0.35,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return FloatingSheet(
                  scrollController: scrollController,
                  child: ListView(
                    shrinkWrap: true,
                    controller: scrollController,
                    padding: EdgeInsets.all(horizontalPadding),
                    children: [
                      // En-tête
                      Text(
                        'Où allez-vous ?',
                        style: GoogleFonts.inter(
                          fontSize: isSmallScreen ? 20 : 24,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? KoogweColors.darkTextPrimary
                              : KoogweColors.lightTextPrimary,
                        ),
                      ).animate().fadeIn(),
                      SizedBox(height: isSmallScreen ? KoogweSpacing.lg : KoogweSpacing.xl),
                      
                      // Champ de prise en charge
                      GlassCard(
                        padding: EdgeInsets.zero,
                        child: KoogweTextField(
                          controller: _pickupController,
                          hint: 'Lieu de prise en charge',
                          prefixIcon: Icon(
                            Icons.my_location,
                            color: KoogweColors.success,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              _searchAddress(value, true);
                            }
                          },
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                      
                      const SizedBox(height: KoogweSpacing.lg),
                      
                      // Champ de destination
                      GlassCard(
                        padding: EdgeInsets.zero,
                        child: KoogweTextField(
                          controller: _dropoffController,
                          hint: 'Destination',
                          prefixIcon: Icon(
                            Icons.location_on,
                            color: KoogweColors.error,
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              _searchAddress(value, false);
                            }
                          },
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      
                      const SizedBox(height: KoogweSpacing.xxl),
                      
                      // Bouton continuer
                      KoogweButton(
                        text: 'Choisir un véhicule',
                        onPressed: (_pickupController.text.isNotEmpty &&
                                _dropoffController.text.isNotEmpty)
                            ? () {
                                ref.read(rideProvider.notifier).setDraft(
                                      pickup: _pickupController.text.trim(),
                                      dropoff: _dropoffController.text.trim(),
                                      pickupLocation: _pickupLocation,
                                      dropoffLocation: _dropoffLocation,
                                    );
                                context.push(AppRoutes.vehicleSelection);
                              }
                            : null,
                        isFullWidth: true,
                        size: ButtonSize.large,
                      ).animate().fadeIn(delay: 300.ms),
                      
                      const SizedBox(height: KoogweSpacing.lg),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
