import 'dart:math' as math;
import 'location_entity.dart';

/// حساب المسافة (كم) بين نقطتين — Haversine.
/// كان مكرراً في RideRepository (Captain) وفي HomeView (Client).
double distanceInKm(LocationEntity a, LocationEntity b) {
  const p = 0.017453292519943295;
  final c = math.cos;
  final x =
      0.5 -
      c((b.latitude - a.latitude) * p) / 2 +
      c(a.latitude * p) *
          c(b.latitude * p) *
          (1 - c((b.longitude - a.longitude) * p)) /
          2;
  return 12742 * math.asin(math.sqrt(x));
}
