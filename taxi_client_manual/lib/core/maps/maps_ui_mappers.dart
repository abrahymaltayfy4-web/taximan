import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../domain/location_entity.dart';
import 'route_info.dart';

/// تحويلات بين كيانات Domain وأنواع google_maps_flutter — للـ Presentation فقط.
extension LocationEntityMaps on LocationEntity {
  LatLng toLatLng() => LatLng(latitude, longitude);
}

extension LatLngMaps on LatLng {
  LocationEntity toLocation() =>
      LocationEntity(latitude: latitude, longitude: longitude);
}

extension RouteInfoMaps on RouteInfo {
  List<LatLng> get latLngPoints =>
      points.map((p) => LatLng(p.latitude, p.longitude)).toList();
}
