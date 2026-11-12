import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../domain/location_entity.dart';
import 'directions_repository.dart';
import 'route_info.dart';

/// تنفيذ [DirectionsRepository] عبر Google Directions API
class GoogleDirectionsRepository implements DirectionsRepository {
  final http.Client _client;

  GoogleDirectionsRepository(this._client);

  @override
  Future<RouteInfo?> getRoute({
    required LocationEntity origin,
    required LocationEntity destination,
  }) async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&key=${AppConfig.mapsApiKey}&mode=driving&language=ar';
    try {
      final response = await _client.get(Uri.parse(url));
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      if ((data['routes'] as List).isEmpty) return null;

      final route = data['routes'][0];
      final leg = route['legs'][0];
      final String encodedPoints = route['overview_polyline']['points'];
      final decoded = PolylinePoints.decodePolyline(encodedPoints);

      return RouteInfo(
        points: decoded
            .map(
              (p) => LocationEntity(latitude: p.latitude, longitude: p.longitude),
            )
            .toList(),
        distanceText: leg['distance']['text'],
        distanceKm: (leg['distance']['value'] / 1000).toDouble(),
        durationText: leg['duration']['text'],
      );
    } catch (_) {
      // المسار غير حرج — فشل صامت كما كان سابقاً
      return null;
    }
  }
}
