import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/ride_entity.dart';
import '../domain/location_entity.dart';

/// تحويل بين Firestore Map و RideEntity
class RideMapper {
  /// من Firestore Map → RideEntity
  static RideEntity fromFirestore(Map<String, dynamic> json, String id) {
    return RideEntity(
      rideId: id,
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      driverId: json['driverId'],
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
      driverCarModel: json['driverCarModel'],
      driverCarPlate: json['driverCarPlate'],
      pickupLocation: _geoPointToLocation(json['pickupLocation']),
      pickupAddress: json['pickupAddress'] ?? '',
      destinationLocation: _geoPointToLocation(json['destinationLocation']),
      destinationAddress: json['destinationAddress'] ?? '',
      status: json['status'] ?? 'pending',
      fare: (json['fare'] ?? 0.0).toDouble(),
      distanceKm: (json['distanceKm'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      acceptedAt: json['acceptedAt'] != null
          ? (json['acceptedAt'] as Timestamp).toDate()
          : null,
      completedAt: json['completedAt'] != null
          ? (json['completedAt'] as Timestamp).toDate()
          : null,
    );
  }

  /// LocationEntity → GeoPoint
  static GeoPoint locationToGeoPoint(LocationEntity loc) {
    return GeoPoint(loc.latitude, loc.longitude);
  }

  /// GeoPoint/dynamic → LocationEntity
  static LocationEntity _geoPointToLocation(dynamic value) {
    if (value is GeoPoint) {
      return LocationEntity(
        latitude: value.latitude,
        longitude: value.longitude,
      );
    }
    return LocationEntity.zero;
  }

  /// Firestore driver doc → LocationEntity
  static LocationEntity? driverLocationFromFirestore(
    Map<String, dynamic>? data,
  ) {
    if (data == null) return null;
    final location = data['location'];
    if (location is GeoPoint) {
      return LocationEntity(
        latitude: location.latitude,
        longitude: location.longitude,
      );
    }
    return null;
  }
}
