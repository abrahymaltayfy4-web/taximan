// lib/models/ride_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class RideModel extends Equatable {
  final String rideId;
  final String customerId;
  final String? driverId;
  final GeoPoint pickupLocation;
  final GeoPoint destinationLocation;
  final String status; // 'pending', 'accepted', 'driver_arrived', 'started', 'completed', 'cancelled'
  final double fare;
  final DateTime createdAt;

  const RideModel({
    required this.rideId,
    required this.customerId,
    this.driverId,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.status,
    required this.fare,
    required this.createdAt,
  });

  factory RideModel.fromJson(Map<String, dynamic> json, String id) {
    return RideModel(
      rideId: id,
      customerId: json['customerId'] ?? '',
      driverId: json['driverId'],
      pickupLocation: json['pickupLocation'] ?? const GeoPoint(0, 0),
      destinationLocation: json['destinationLocation'] ?? const GeoPoint(0, 0),
      status: json['status'] ?? 'pending',
      fare: (json['fare'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] != null 
          ? (json['createdAt'] as dynamic).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'driverId': driverId,
      'pickupLocation': pickupLocation,
      'destinationLocation': destinationLocation,
      'status': status,
      'fare': fare,
      'createdAt': createdAt,
    };
  }

  RideModel copyWith({
    String? driverId,
    String? status,
    double? fare,
  }) {
    return RideModel(
      rideId: rideId,
      customerId: customerId,
      driverId: driverId ?? this.driverId,
      pickupLocation: pickupLocation,
      destinationLocation: destinationLocation,
      status: status ?? this.status,
      fare: fare ?? this.fare,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        rideId,
        customerId,
        driverId,
        pickupLocation,
        destinationLocation,
        status,
        fare,
        createdAt,
      ];
}