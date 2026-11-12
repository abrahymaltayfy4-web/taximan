import 'package:equatable/equatable.dart';

/// نقطة جغرافية — Domain Layer (بدل GeoPoint من Firebase)
class LocationEntity extends Equatable {
  final double latitude;
  final double longitude;

  const LocationEntity({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}
