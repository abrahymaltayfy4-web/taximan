import 'package:equatable/equatable.dart';
import 'location_entity.dart';

/// كيان الرحلة — مستقل عن Firebase تماماً
class RideEntity extends Equatable {
  final String rideId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? driverCarModel;
  final String? driverCarPlate;
  final LocationEntity pickupLocation;
  final String pickupAddress;
  final LocationEntity destinationLocation;
  final String destinationAddress;
  final String status;
  final double fare;
  final double distanceKm;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  const RideEntity({
    required this.rideId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    this.driverId,
    this.driverName,
    this.driverPhone,
    this.driverCarModel,
    this.driverCarPlate,
    required this.pickupLocation,
    required this.pickupAddress,
    required this.destinationLocation,
    required this.destinationAddress,
    required this.status,
    required this.fare,
    required this.distanceKm,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
  });

  bool get isActive => status != 'completed' && status != 'cancelled';

  @override
  List<Object?> get props => [
    rideId, customerId, customerName, customerPhone,
    driverId, driverName, driverPhone, driverCarModel, driverCarPlate,
    pickupLocation, pickupAddress, destinationLocation, destinationAddress,
    status, fare, distanceKm, createdAt, acceptedAt, completedAt,
  ];
}
