import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:koogwe/core/config/env.dart';

class OsrmService {
  OsrmService({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 8)));

  final Dio _dio;

  /// Fetches a route polyline between [startLon, startLat] and [endLon, endLat].
  /// Returns a list of [lat, lon] points (GeoJSON order is [lon, lat]).
  Future<List<List<double>>> route({
    required double startLat,
    required double startLon,
    required double endLat,
    required double endLon,
  }) async {
    final base = Env.osrmEndpoint.replaceAll(RegExp(r'/+'), '/');
    final url =
        '$base/route/v1/driving/$startLon,$startLat;$endLon,$endLat?overview=full&geometries=geojson';
    try {
      final res = await _dio.get(url);
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data is Map ? res.data as Map : jsonDecode(res.data as String) as Map;
        final routes = data['routes'] as List?;
        if (routes == null || routes.isEmpty) return const [];
        final geometry = routes.first['geometry'] as Map?;
        final coords = geometry?['coordinates'] as List?;
        if (coords == null) return const [];
        // coords: [[lon,lat], ...] => convert to [[lat,lon], ...] for flutter_map
        return coords
            .map<List<double>>((e) => [
                  (e[1] as num).toDouble(),
                  (e[0] as num).toDouble(),
                ])
            .toList(growable: false);
      }
      return const [];
    } catch (e, st) {
      debugPrint('OSRM error: $e\n$st');
      return const [];
    }
  }
}
