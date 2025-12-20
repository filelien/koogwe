import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:koogwe/core/constants/app_colors.dart';

/// Simple map preview using OpenStreetMap tiles (no keys required).
/// Draws a given route as a polyline if provided.
class RoutePreview extends StatelessWidget {
  final List<LatLng> polyline;
  final LatLng? center;
  final double zoom;
  const RoutePreview({super.key, this.polyline = const [], this.center, this.zoom = 13});

  @override
  Widget build(BuildContext context) {
    final c = center ?? (polyline.isNotEmpty ? polyline[polyline.length ~/ 2] : const LatLng(4.9224, -52.3135)); // Cayenne area
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: FlutterMap(
        options: MapOptions(initialCenter: c, initialZoom: zoom),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'koogwe.app',
          ),
          if (polyline.isNotEmpty)
            PolylineLayer(polylines: [
              Polyline(points: polyline, color: KoogweColors.mapRoute, strokeWidth: 4),
            ]),
        ],
      ),
    );
  }
}
