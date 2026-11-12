import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/entities/location_entity.dart';
import '../models/ride_model.dart';

/// تحويل RideModel ↔ RideEntity
class RideMapper {
  /// من Model (Firestore) إلى Entity (Domain)
  static RideEntity toEntity(RideModel model) {
    return RideEntity(
      rideId: model.rideId,
      customerId: model.customerId,
      customerName: model.customerName,
      customerPhone: model.customerPhone,
      driverId: model.driverId,
      driverName: model.driverName,
      driverPhone: model.driverPhone,
      driverCarModel: model.driverCarModel,
      driverCarPlate: model.driverCarPlate,
      pickupLocation: LocationEntity(
        latitude: model.pickupLocation.latitude,
        longitude: model.pickupLocation.longitude,
      ),
      pickupAddress: model.pickupAddress,
      destinationLocation: LocationEntity(
        latitude: model.destinationLocation.latitude,
        longitude: model.destinationLocation.longitude,
      ),
      destinationAddress: model.destinationAddress,
      status: model.status,
      fare: model.fare,
      distanceKm: model.distanceKm,
      createdAt: model.createdAt,
      acceptedAt: model.acceptedAt,
      completedAt: model.completedAt,
    );
  }

  /// من DocumentSnapshot (Firestore) إلى Entity مباشرة
  static RideEntity fromFirestore(DocumentSnapshot doc) {
    final model = RideModel.fromJson(
      doc.data() as Map<String, dynamic>,
      doc.id,
    );
    return toEntity(model);
  }
}
