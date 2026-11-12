import 'package:equatable/equatable.dart';

/// موقع جغرافي مستقل عن Firebase GeoPoint و google_maps LatLng
class LocationEntity extends Equatable {
  final double latitude;
  final double longitude;

  const LocationEntity({required this.latitude, required this.longitude});

  static const zero = LocationEntity(latitude: 0, longitude: 0);

  @override
  List<Object?> get props => [latitude, longitude];

  @override
  String toString() => 'LocationEntity($latitude, $longitude)';
}
