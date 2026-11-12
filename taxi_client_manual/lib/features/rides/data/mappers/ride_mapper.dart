import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/domain/location_entity.dart';
import '../../../../core/domain/ride_status.dart';
import '../../domain/entities/ride_entity.dart';
import '../models/ride_model.dart';

/// RideModel ⇄ Firestore / RideEntity
abstract final class RideMapper {
  static RideEntity toEntity(RideModel m) {
    return RideEntity(
      rideId: m.rideId,
      customerId: m.text('customerId'),
      customerName: m.text('customerName'),
      customerPhone: m.text('customerPhone'),
      driverId: m.optionalText('driverId'),
      driverName: m.optionalText('driverName'),
      driverPhone: m.optionalText('driverPhone'),
      driverCarModel: m.optionalText('driverCarModel'),
      driverCarPlate: m.optionalText('driverCarPlate'),
      pickupLocation: _location(m.geoPoint('pickupLocation')),
      pickupAddress: m.text('pickupAddress'),
      destinationLocation: _location(m.geoPoint('destinationLocation')),
      destinationAddress: m.text('destinationAddress'),
      status: RideStatus.fromString(m.optionalText('status')),
      fare: m.number('fare'),
      distanceKm: m.number('distanceKm'),
      createdAt: m.timestamp('createdAt') ?? DateTime.now(),
      acceptedAt: m.timestamp('acceptedAt'),
      completedAt: m.timestamp('completedAt'),
    );
  }

  /// LocationEntity → GeoPoint
  static GeoPoint toGeoPoint(LocationEntity loc) =>
      GeoPoint(loc.latitude, loc.longitude);

  /// Firestore driver doc → LocationEntity
  static LocationEntity? driverLocation(Map<String, dynamic>? data) {
    final location = data?['location'];
    if (location is GeoPoint) {
      return LocationEntity(
        latitude: location.latitude,
        longitude: location.longitude,
      );
    }
    return null;
  }

  static LocationEntity _location(GeoPoint? p) => p == null
      ? LocationEntity.zero
      : LocationEntity(latitude: p.latitude, longitude: p.longitude);
}
