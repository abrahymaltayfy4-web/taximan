import '../domain/location_entity.dart';
import 'route_info.dart';

/// جلب مسار القيادة بين نقطتين. يعيد null عند أي فشل (المسار غير حرج).
abstract interface class DirectionsRepository {
  Future<RouteInfo?> getRoute({
    required LocationEntity origin,
    required LocationEntity destination,
  });
}
