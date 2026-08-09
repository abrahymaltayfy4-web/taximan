import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class RideModel extends Equatable {
  final String rideId;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final String? driverCarModel;
  final String? driverCarPlate;
  final GeoPoint pickupLocation;
  final String pickupAddress;
  final GeoPoint destinationLocation;
  final String destinationAddress;
  final String status;
  final double fare;
  final double distanceKm;
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  const RideModel({
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

  /// يتعامل مع البيانات القديمة (String) والجديدة (GeoPoint)
  static GeoPoint _parseGeoPoint(dynamic value) {
    if (value is GeoPoint) return value;
    // fallback للبيانات القديمة أو القيم غير الصالحة
    return const GeoPoint(0, 0);
  }

  factory RideModel.fromJson(Map<String, dynamic> json, String id) {
    return RideModel(
      rideId: id,
      customerId: json['customerId'] ?? '',
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      driverId: json['driverId'],
      driverName: json['driverName'],
      driverPhone: json['driverPhone'],
      driverCarModel: json['driverCarModel'],
      driverCarPlate: json['driverCarPlate'],
      pickupLocation: _parseGeoPoint(json['pickupLocation']),
      pickupAddress: json['pickupAddress'] ?? '',
      destinationLocation: _parseGeoPoint(json['destinationLocation']),
      destinationAddress: json['destinationAddress'] ?? '',
      status: json['status'] ?? 'pending',
      fare: (json['fare'] ?? 0.0).toDouble(),
      distanceKm: (json['distanceKm'] ?? 0.0).toDouble(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      acceptedAt: (json['acceptedAt'] as Timestamp?)?.toDate(),
      completedAt: (json['completedAt'] as Timestamp?)?.toDate(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      if (driverId != null) 'driverId': driverId,
      if (driverName != null) 'driverName': driverName,
      if (driverPhone != null) 'driverPhone': driverPhone,
      if (driverCarModel != null) 'driverCarModel': driverCarModel,
      if (driverCarPlate != null) 'driverCarPlate': driverCarPlate,
      'pickupLocation': pickupLocation,
      'pickupAddress': pickupAddress,
      'destinationLocation': destinationLocation,
      'destinationAddress': destinationAddress,
      'status': status,
      'fare': fare,
      'distanceKm': distanceKm,
      'createdAt': Timestamp.fromDate(createdAt),
      if (acceptedAt != null) 'acceptedAt': Timestamp.fromDate(acceptedAt!),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
    };
  }

  RideModel copyWith({
    String? rideId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? driverId,
    String? driverName,
    String? driverPhone,
    String? driverCarModel,
    String? driverCarPlate,
    GeoPoint? pickupLocation,
    String? pickupAddress,
    GeoPoint? destinationLocation,
    String? destinationAddress,
    String? status,
    double? fare,
    double? distanceKm,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
  }) {
    return RideModel(
      rideId: rideId ?? this.rideId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverCarModel: driverCarModel ?? this.driverCarModel,
      driverCarPlate: driverCarPlate ?? this.driverCarPlate,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      status: status ?? this.status,
      fare: fare ?? this.fare,
      distanceKm: distanceKm ?? this.distanceKm,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

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