import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:koogwe/core/constants/app_colors.dart';

/// Widget de carte amélioré avec style Google Maps, marqueur de position actuelle précis,
/// zoom intelligent automatique et affichage d'itinéraire
class RoutePreview extends StatefulWidget {
  final List<LatLng> polyline;
  final LatLng? center;
  final double zoom;
  final LatLng? currentLocation; // Position actuelle de l'utilisateur
  final LatLng? pickupLocation; // Position de prise en charge
  final LatLng? dropoffLocation; // Position de destination
  final LatLng? driverLocation; // Position du chauffeur (pour le suivi)
  final bool showCurrentLocationMarker; // Afficher le marqueur de position actuelle
  final bool autoFitBounds; // Zoom intelligent automatique pour afficher tous les points

  const RoutePreview({
    super.key,
    this.polyline = const [],
    this.center,
    this.zoom = 15,
    this.currentLocation,
    this.pickupLocation,
    this.dropoffLocation,
    this.driverLocation,
    this.showCurrentLocationMarker = true,
    this.autoFitBounds = true,
  });

  @override
  State<RoutePreview> createState() => _RoutePreviewState();
}

class _RoutePreviewState extends State<RoutePreview> with TickerProviderStateMixin {
  late MapController _mapController;
  late AnimationController _pulseController;
  late AnimationController _pickupPulseController;
  late AnimationController _dropoffPulseController;
  late AnimationController _driverPulseController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _pickupPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _dropoffPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _driverPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    
    // Ajuster le zoom intelligent après le premier build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fitBounds();
    });
  }

  @override
  void didUpdateWidget(RoutePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Réajuster les bounds si les positions ont changé
    if (widget.autoFitBounds &&
        (widget.currentLocation != oldWidget.currentLocation ||
            widget.pickupLocation != oldWidget.pickupLocation ||
            widget.dropoffLocation != oldWidget.dropoffLocation ||
            widget.driverLocation != oldWidget.driverLocation)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fitBounds();
      });
    }
  }

  /// Calculer et ajuster le zoom pour afficher tous les points importants
  void _fitBounds() {
    if (!widget.autoFitBounds) return;

    final points = <LatLng>[];
    if (widget.currentLocation != null) points.add(widget.currentLocation!);
    if (widget.pickupLocation != null) points.add(widget.pickupLocation!);
    if (widget.dropoffLocation != null) points.add(widget.dropoffLocation!);
    if (widget.driverLocation != null) points.add(widget.driverLocation!);
    if (widget.polyline.isNotEmpty) {
      points.addAll(widget.polyline);
    }

    if (points.isEmpty) return;

    // Calculer les bounds
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLon = points.first.longitude;
    double maxLon = points.first.longitude;

    for (final point in points) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLon = math.min(minLon, point.longitude);
      maxLon = math.max(maxLon, point.longitude);
    }

    // Calculer le centre
    final centerLat = (minLat + maxLat) / 2;
    final centerLon = (minLon + maxLon) / 2;
    final center = LatLng(centerLat, centerLon);

    // Calculer le zoom approprié
    final latDiff = maxLat - minLat;
    final lonDiff = maxLon - minLon;
    final maxDiff = math.max(latDiff, lonDiff);

    double calculatedZoom = 15.0;
    if (maxDiff > 0.1) {
      calculatedZoom = 10.0;
    } else if (maxDiff > 0.05) {
      calculatedZoom = 11.0;
    } else if (maxDiff > 0.02) {
      calculatedZoom = 12.0;
    } else if (maxDiff > 0.01) {
      calculatedZoom = 13.0;
    } else if (maxDiff > 0.005) {
      calculatedZoom = 14.0;
    } else {
      calculatedZoom = 15.0;
    }

    // Appliquer le zoom avec animation fluide
    _mapController.move(center, calculatedZoom);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pickupPulseController.dispose();
    _dropoffPulseController.dispose();
    _driverPulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Déterminer le centre de la carte
    LatLng center;
    if (widget.center != null) {
      center = widget.center!;
    } else if (widget.currentLocation != null) {
      center = widget.currentLocation!;
    } else if (widget.polyline.isNotEmpty) {
      center = widget.polyline[widget.polyline.length ~/ 2];
    } else {
      center = const LatLng(48.8566, 2.3522); // Paris par défaut
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: center,
          initialZoom: widget.zoom,
          minZoom: 8,
          maxZoom: 19,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          // Couche de tuiles avec style moderne amélioré (OpenStreetMap style esthétique)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'koogwe.app',
            maxZoom: 19,
            minZoom: 3,
            tileProvider: NetworkTileProvider(),
            // Utiliser un style plus moderne si disponible
            additionalOptions: const {
              'attribution': '© OpenStreetMap contributors',
            },
          ),
          
          // Polyline de l'itinéraire avec style moderne amélioré
          if (widget.polyline.isNotEmpty)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: widget.polyline,
                  color: KoogweColors.primary,
                  strokeWidth: 6,
                  borderStrokeWidth: 3,
                  borderColor: Colors.white,
                ),
              ],
            ),
          
          // Marqueurs
          MarkerLayer(
            markers: [
              // Marqueur de position actuelle (point rouge précis comme Google Maps)
              if (widget.showCurrentLocationMarker && widget.currentLocation != null)
                Marker(
                  point: widget.currentLocation!,
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  child: _CurrentLocationMarker(
                    animationController: _pulseController,
                  ),
                ),
              
              // Marqueur de prise en charge avec animation
              if (widget.pickupLocation != null)
                Marker(
                  point: widget.pickupLocation!,
                  width: 70,
                  height: 70,
                  alignment: Alignment.center,
                  child: _PickupMarker(
                    animationController: _pickupPulseController,
                  ),
                ),
              
              // Marqueur de destination avec animation
              if (widget.dropoffLocation != null)
                Marker(
                  point: widget.dropoffLocation!,
                  width: 70,
                  height: 70,
                  alignment: Alignment.center,
                  child: _DropoffMarker(
                    animationController: _dropoffPulseController,
                  ),
                ),
              
              // Marqueur du chauffeur avec animation
              if (widget.driverLocation != null)
                Marker(
                  point: widget.driverLocation!,
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  child: _DriverMarker(
                    animationController: _driverPulseController,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Marqueur de position actuelle (point rouge précis comme Google Maps)
class _CurrentLocationMarker extends StatelessWidget {
  final AnimationController animationController;

  const _CurrentLocationMarker({
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final scale = 1.0 + (animationController.value * 0.3);
        final opacity = 1.0 - (animationController.value * 0.7);
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Cercle externe pulsant (animation)
            Transform.scale(
              scale: scale,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withValues(alpha: opacity * 0.3),
                ),
              ),
            ),
            // Cercle intermédiaire
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withValues(alpha: 0.2),
              ),
            ),
            // Point rouge central précis (comme Google Maps)
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.shade700,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Marqueur de prise en charge - Style moderne avec icône personnalisée et animation
class _PickupMarker extends StatelessWidget {
  final AnimationController animationController;

  const _PickupMarker({
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final scale = 1.0 + (animationController.value * 0.15);
        final opacity = 1.0 - (animationController.value * 0.5);
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Cercle externe pulsant
            Transform.scale(
              scale: scale,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: KoogweColors.success.withValues(alpha: opacity * 0.2),
                ),
              ),
            ),
            // Container principal avec ombre
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: KoogweColors.success.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 4,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Cercle externe
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: KoogweColors.success.withValues(alpha: 0.15),
                    ),
                  ),
                  // Cercle de fond avec gradient vibrant
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF34C759), // Vert vif
                          const Color(0xFF30D158), // Vert clair
                          const Color(0xFF28CD41), // Vert foncé
                        ],
                      ),
                    ),
                  ),
                  // Icône personnalisée avec badge
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.my_location,
                        color: Colors.white,
                        size: 28,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      // Badge "DÉPART" en haut
                      Positioned(
                        top: -8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            'DÉPART',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: KoogweColors.success,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Marqueur de destination - Style moderne avec icône personnalisée et animation
class _DropoffMarker extends StatelessWidget {
  final AnimationController animationController;

  const _DropoffMarker({
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final scale = 1.0 + (animationController.value * 0.15);
        final opacity = 1.0 - (animationController.value * 0.5);
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Cercle externe pulsant
            Transform.scale(
              scale: scale,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: KoogweColors.error.withValues(alpha: opacity * 0.2),
                ),
              ),
            ),
            // Container principal avec ombre
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: KoogweColors.error.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 4,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Cercle externe
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: KoogweColors.error.withValues(alpha: 0.15),
                    ),
                  ),
                  // Cercle de fond avec gradient vibrant
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFF3B30), // Rouge vif
                          const Color(0xFFFF453A), // Rouge clair
                          const Color(0xFFFF2D20), // Rouge foncé
                        ],
                      ),
                    ),
                  ),
                  // Icône personnalisée avec badge
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.place,
                        color: Colors.white,
                        size: 28,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      // Badge "ARRIVÉE" en haut
                      Positioned(
                        top: -8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            'ARRIVÉE',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: KoogweColors.error,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Marqueur du chauffeur - Style moderne avec animation et icône personnalisée
class _DriverMarker extends StatelessWidget {
  final AnimationController animationController;

  const _DriverMarker({
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        final scale = 1.0 + (animationController.value * 0.2);
        final opacity = 1.0 - (animationController.value * 0.6);
        final rotation = animationController.value * 0.1; // Légère rotation
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Cercle externe pulsant
            Transform.scale(
              scale: scale,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: KoogweColors.primary.withValues(alpha: opacity * 0.25),
                ),
              ),
            ),
            // Container principal avec ombre
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: KoogweColors.primary.withValues(alpha: 0.5),
                    blurRadius: 18,
                    spreadRadius: 3,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Cercle externe
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: KoogweColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  // Cercle de fond avec gradient vibrant
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF007AFF), // Bleu vif
                          const Color(0xFF0051D5), // Bleu foncé
                          const Color(0xFF0040B8), // Bleu très foncé
                        ],
                      ),
                    ),
                  ),
                  // Icône voiture avec rotation subtile
                  Transform.rotate(
                    angle: rotation,
                    child: Icon(
                      Icons.directions_car_filled,
                      color: Colors.white,
                      size: 26,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
