import 'package:equatable/equatable.dart';
import '../../../../core/domain/location_entity.dart';
import '../../../../core/domain/ride_status.dart';

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
  final RideStatus status;
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

  bool get isActive => status.isActive;

  @override
  List<Object?> get props => [
    rideId,
    customerId,
    customerName,
    customerPhone,
    driverId,
    driverName,
    driverPhone,
    driverCarModel,
    driverCarPlate,
    pickupLocation,
    pickupAddress,
    destinationLocation,
    destinationAddress,
    status,
    fare,
    distanceKm,
    createdAt,
    acceptedAt,
    completedAt,
  ];
}

/// بيانات طلب رحلة جديدة (قبل الحساب والحفظ)
class NewRideRequest extends Equatable {
  final String customerId;
  final String customerName;
  final String customerPhone;
  final LocationEntity pickupLocation;
  final String pickupAddress;
  final LocationEntity destinationLocation;
  final String destinationAddress;
  final double distanceKm;
  final double fare;

  const NewRideRequest({
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.pickupLocation,
    required this.pickupAddress,
    required this.destinationLocation,
    required this.destinationAddress,
    required this.distanceKm,
    required this.fare,
  });

  @override
  List<Object?> get props => [
    customerId,
    customerName,
    customerPhone,
    pickupLocation,
    pickupAddress,
    destinationLocation,
    destinationAddress,
    distanceKm,
    fare,
  ];
}
