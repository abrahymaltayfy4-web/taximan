import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class DirectionsService {
  static const String _apiKey = 'AIzaSyA1tBE_7QmoNJvjCVpT-fQkJXuhjUtqCTs';

  Future<Map<String, dynamic>?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$_apiKey&mode=driving&language=ar';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if ((data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          String encodedPoints = route['overview_polyline']['points'];
          List<PointLatLng> result = PolylinePoints.decodePolyline(encodedPoints);
          List<LatLng> polylineCoordinates = result.map((point) => LatLng(point.latitude, point.longitude)).toList();
          return {
            'polylineCoordinates': polylineCoordinates,
            'distanceText': leg['distance']['text'],
            'distanceValue': (leg['distance']['value'] / 1000).toDouble(),
            'durationText': leg['duration']['text'],
          };
        }
      }
    } catch (e) {
      // Silent fail - directions are non-critical
    }
    return null;
  }
}
