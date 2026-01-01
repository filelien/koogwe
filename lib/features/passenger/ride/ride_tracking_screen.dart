import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';
import 'package:koogwe/core/widgets/koogwe_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:koogwe/core/providers/ride_provider.dart';
import 'package:koogwe/core/widgets/floating_sheet.dart';
import 'package:koogwe/core/widgets/gradient_background.dart';
import 'package:koogwe/core/widgets/route_preview.dart';
import 'package:koogwe/core/constants/app_assets.dart';
import 'package:koogwe/core/services/location_service.dart';
import 'package:koogwe/core/services/osrm_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';

class RideTrackingScreen extends ConsumerStatefulWidget {
  const RideTrackingScreen({super.key});

  @override
  ConsumerState<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends ConsumerState<RideTrackingScreen> {
  final _locationService = LocationService();
  final _osrmService = OsrmService();
  
  bool _sosActive = false;
  LatLng? _currentLocation;
  LatLng? _driverLocation;
  List<LatLng> _routePolyline = [];
  
  StreamSubscription<LatLng>? _locationSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _driverLocationSubscription;
  Timer? _driverLocationTimer;

  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _driverLocationSubscription?.cancel();
    _driverLocationTimer?.cancel();
    super.dispose();
  }

  /// Initialiser le suivi de position
  Future<void> _initializeTracking() async {
    // Obtenir la position actuelle
    final location = await _locationService.getCurrentLocation();
    if (location != null) {
      setState(() {
        _currentLocation = location;
      });
    }

    // Démarrer le suivi en temps réel de la position du passager
    await _locationService.startLocationTracking();
    _locationSubscription = _locationService.locationStream.listen((location) {
      if (mounted) {
        setState(() {
          _currentLocation = location;
        });
        // Recalculer l'itinéraire si le chauffeur est défini
        if (_driverLocation != null) {
          _calculateRoute();
        }
      }
    });

    // Démarrer le suivi de la position du chauffeur
    _startDriverLocationTracking();
  }

  /// Démarrer le suivi de la position du chauffeur depuis Supabase
  void _startDriverLocationTracking() {
    final ride = ref.read(rideProvider).current;
    if (ride == null || ride.driverId == null) return;

    // Récupérer la position initiale
    _fetchDriverLocation(ride.driverId!);

    // Mettre à jour la position toutes les 5 secondes
    _driverLocationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && ride.driverId != null) {
        _fetchDriverLocation(ride.driverId!);
      }
    });

    // Écouter les changements en temps réel via Supabase Realtime
    try {
      _driverLocationSubscription = Supabase.instance.client
          .from('driver_locations')
          .stream(primaryKey: ['driver_id'])
          .eq('driver_id', ride.driverId!)
          .listen((List<Map<String, dynamic>> data) {
        if (data.isNotEmpty && mounted) {
          final location = data.first;
          final lat = location['latitude'] as num?;
          final lon = location['longitude'] as num?;
          if (lat != null && lon != null) {
            setState(() {
              _driverLocation = LatLng(lat.toDouble(), lon.toDouble());
            });
            // Recalculer l'itinéraire
            if (_currentLocation != null) {
              _calculateRoute();
            }
          }
        }
      });
    } catch (e) {
      debugPrint('Erreur subscription position chauffeur: $e');
    }
  }

  /// Récupérer la position du chauffeur depuis Supabase
  Future<void> _fetchDriverLocation(String driverId) async {
    try {
      final response = await Supabase.instance.client
          .from('driver_locations')
          .select('latitude, longitude')
          .eq('driver_id', driverId)
          .maybeSingle();

      if (response != null && mounted) {
        final lat = response['latitude'] as num?;
        final lon = response['longitude'] as num?;
        if (lat != null && lon != null) {
          setState(() {
            _driverLocation = LatLng(lat.toDouble(), lon.toDouble());
          });
          // Recalculer l'itinéraire
          if (_currentLocation != null) {
            _calculateRoute();
          }
        }
      }
    } catch (e) {
      debugPrint('Erreur récupération position chauffeur: $e');
    }
  }

  /// Calculer l'itinéraire entre le passager et le chauffeur
  Future<void> _calculateRoute() async {
    if (_currentLocation == null || _driverLocation == null) return;

    try {
      final polyline = await _osrmService.route(
        startLat: _currentLocation!.latitude,
        startLon: _currentLocation!.longitude,
        endLat: _driverLocation!.latitude,
        endLon: _driverLocation!.longitude,
      );

      if (mounted) {
        setState(() {
          _routePolyline = polyline.map((p) => LatLng(p[0], p[1])).toList();
        });
      }
    } catch (e) {
      debugPrint('Erreur calcul itinéraire: $e');
    }
  }

  Future<void> _triggerSOS() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => _SOSConfirmDialog(),
    );

    if (confirm == true && mounted) {
      setState(() => _sosActive = true);
      
      try {
        final rideState = ref.read(rideProvider);
        final rideId = rideState.current?.id;
        
        if (rideId != null) {
          await Supabase.instance.client.from('rides').update({
            'status': 'emergency',
            'sos_activated_at': DateTime.now().toIso8601String(),
          }).eq('id', rideId);
          
          try {
            await Supabase.instance.client.functions.invoke('send_sos_alert', body: {
              'ride_id': rideId,
              'timestamp': DateTime.now().toIso8601String(),
              'latitude': _currentLocation?.latitude,
              'longitude': _currentLocation?.longitude,
            });
          } catch (e) {
            debugPrint('SOS Edge Function non disponible: $e');
          }
        }
        
        final emergencyUri = Uri(scheme: 'tel', path: '112');
        if (await canLaunchUrl(emergencyUri)) {
          await launchUrl(emergencyUri);
        }
      } catch (e) {
        debugPrint('Erreur activation SOS: $e');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Alerte SOS activée. Vos contacts d\'urgence ont été notifiés.'),
            backgroundColor: KoogweColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ride = ref.watch(rideProvider).current;

    return GradientBackground(
      useDarkAurora: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Carte avec positions
            Positioned.fill(
              child: RoutePreview(
                currentLocation: _currentLocation,
                pickupLocation: _currentLocation, // Position passager
                driverLocation: _driverLocation, // Position chauffeur
                center: _currentLocation,
                showCurrentLocationMarker: true,
                polyline: _routePolyline,
                autoFitBounds: true,
              ),
            ),
            
            // Boutons en haut
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(KoogweSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.pop(),
                        ),
                      ),
                      // Bouton SOS
                      Container(
                        decoration: BoxDecoration(
                          color: _sosActive
                              ? KoogweColors.error
                              : KoogweColors.error.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: _sosActive
                              ? [
                                  BoxShadow(
                                    color: KoogweColors.error.withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ]
                              : null,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _sosActive ? Icons.warning : Icons.emergency,
                            color: Colors.white,
                          ),
                          onPressed: _triggerSOS,
                          tooltip: 'Alerte SOS',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Informations en bas
            if (ride != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: FloatingSheet(
                    padding: const EdgeInsets.all(KoogweSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Votre chauffeur arrive',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? KoogweColors.darkTextPrimary
                                : KoogweColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: KoogweSpacing.lg),
                        
                        // Informations du chauffeur
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: KoogweColors.primary.withValues(alpha: 0.1),
                              child: ClipOval(
                                child: Image.asset(
                                  AppAssets.appLogo,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.person,
                                          size: 40, color: KoogweColors.primary),
                                ),
                              ),
                            ),
                            const SizedBox(width: KoogweSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'James Smith Myers',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? KoogweColors.darkTextPrimary
                                          : KoogweColors.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        Icons.star,
                                        size: 18,
                                        color: index < 4
                                            ? KoogweColors.accent
                                            : (isDark
                                                ? KoogweColors.darkTextTertiary
                                                : KoogweColors.lightTextTertiary),
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Toyota Camry • 23-10-00',
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
                          ],
                        ),
                        
                        const SizedBox(height: KoogweSpacing.xl),
                        
                        // ETA et Prix
                        Container(
                          padding: const EdgeInsets.all(KoogweSpacing.md),
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? KoogweColors.darkSurfaceVariant
                                    : KoogweColors.lightSurfaceVariant)
                                .withValues(alpha: 0.5),
                            borderRadius: KoogweRadius.mdRadius,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'Temps d\'arrivée',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: isDark
                                          ? KoogweColors.darkTextSecondary
                                          : KoogweColors.lightTextSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '10 min',
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: KoogweColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: isDark
                                    ? KoogweColors.darkBorder
                                    : KoogweColors.lightBorder,
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Tarif',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: isDark
                                          ? KoogweColors.darkTextSecondary
                                          : KoogweColors.lightTextSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '€${ride.estimatedPrice?.toStringAsFixed(2) ?? '0.00'}',
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: KoogweColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: KoogweSpacing.xl),
                        
                        // Bouton Partager ETA
                        OutlinedButton.icon(
                          onPressed: () {
                            final rideState = ref.read(rideProvider);
                            final currentRide = rideState.current;
                            if (currentRide != null) {
                              context.push(
                                  '/passenger/share-eta?rideId=${currentRide.id}&pickup=${Uri.encodeComponent(currentRide.pickup)}&dropoff=${Uri.encodeComponent(currentRide.dropoff)}&eta=10%20min');
                            }
                          },
                          icon: const Icon(Icons.share_location),
                          label: const Text('Partager mon ETA'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: KoogweColors.primary),
                            padding: const EdgeInsets.symmetric(
                                vertical: KoogweSpacing.md),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                        
                        const SizedBox(height: KoogweSpacing.md),
                        
                        // Boutons Appeler et Message
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  final rideState = ref.read(rideProvider);
                                  String? phoneNumber = rideState.current?.driverPhone;
                                  
                                  if (phoneNumber == null || phoneNumber.isEmpty) {
                                    try {
                                      final driverId = rideState.current?.driverId;
                                      if (driverId != null && driverId.isNotEmpty) {
                                        final profile = await Supabase.instance.client
                                            .from('profiles')
                                            .select('phone_number')
                                            .eq('id', driverId)
                                            .maybeSingle();
                                        phoneNumber = profile?['phone_number']?.toString();
                                      }
                                    } catch (e) {
                                      debugPrint('Erreur récupération téléphone: $e');
                                    }
                                  }
                                  
                                  phoneNumber ??= '+594694123456';
                                  final uri = Uri(scheme: 'tel', path: phoneNumber);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  } else {
                                    if (!mounted) return;
                                    messenger.showSnackBar(
                                      SnackBar(
                                          content: Text('Impossible d\'appeler $phoneNumber')),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.phone, color: Colors.white),
                                label: const Text(
                                  'Appeler',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: KoogweColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: KoogweSpacing.lg),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: KoogweRadius.mdRadius,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: KoogweSpacing.md),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  final rideState = ref.read(rideProvider);
                                  final driverId = rideState.current?.driverId;
                                  if (driverId != null) {
                                    context.push(
                                        '/passenger/chat?rideId=${ride.id}&driverId=$driverId');
                                  }
                                },
                                icon: Icon(Icons.message, color: KoogweColors.primary),
                                label: Text(
                                  'Message',
                                  style: GoogleFonts.inter(
                                    color: KoogweColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: KoogweColors.primary, width: 2),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: KoogweSpacing.lg),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: KoogweRadius.mdRadius,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: KoogweSpacing.xl),
                        
                        // Informations détaillées
                        Container(
                          padding: const EdgeInsets.all(KoogweSpacing.lg),
                          decoration: BoxDecoration(
                            color: isDark
                                ? KoogweColors.darkSurfaceVariant
                                : KoogweColors.lightSurfaceVariant,
                            borderRadius: KoogweRadius.lgRadius,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text(
                                    '5 min',
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: KoogweColors.primary,
                                    ),
                                  ),
                                  Text(
                                    'Arrivée',
                                    style: GoogleFonts.inter(fontSize: 12),
                                  ),
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 32,
                                color: isDark
                                    ? KoogweColors.darkBorder
                                    : KoogweColors.lightBorder,
                              ),
                              Column(
                                children: [
                                  Text(
                                    '3.2 km',
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: KoogweColors.primary,
                                    ),
                                  ),
                                  Text(
                                    'Distance',
                                    style: GoogleFonts.inter(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: KoogweSpacing.lg),
                        
                        // Bouton Annuler
                        KoogweButton(
                          text: 'Annuler la course',
                          onPressed: () async {
                            await ref.read(rideProvider.notifier).cancelCurrentRide();
                            if (context.mounted) context.pop();
                          },
                          isFullWidth: true,
                          variant: ButtonVariant.outline,
                          customColor: KoogweColors.error,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Dialogue de confirmation pour le bouton SOS
class _SOSConfirmDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor:
          isDark ? KoogweColors.darkSurface : KoogweColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: KoogweRadius.lgRadius),
      title: Row(
        children: [
          Icon(Icons.emergency, color: KoogweColors.error, size: 28),
          const SizedBox(width: KoogweSpacing.md),
          Text(
            'Alerte SOS',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: KoogweColors.error,
            ),
          ),
        ],
      ),
      content: Text(
        'Voulez-vous activer l\'alerte SOS ? Vos contacts d\'urgence et les services de secours seront notifiés de votre position.',
        style: GoogleFonts.inter(
          fontSize: 14,
          color: isDark
              ? KoogweColors.darkTextSecondary
              : KoogweColors.lightTextSecondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Annuler',
            style: GoogleFonts.inter(
                color: isDark
                    ? KoogweColors.darkTextSecondary
                    : KoogweColors.lightTextSecondary),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: KoogweColors.error,
          ),
          child: const Text('Activer SOS'),
        ),
      ],
    );
  }
}
