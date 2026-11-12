import 'package:equatable/equatable.dart';
import '../domain/location_entity.dart';

/// نتيجة طلب مسار بين نقطتين — مستقلة عن google_maps
class RouteInfo extends Equatable {
  final List<LocationEntity> points;
  final String distanceText;
  final double distanceKm;
  final String durationText;

  const RouteInfo({
    required this.points,
    required this.distanceText,
    required this.distanceKm,
    required this.durationText,
  });

  @override
  List<Object?> get props => [points, distanceText, distanceKm, durationText];
}
