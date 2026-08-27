// lib/models/driver_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class DriverModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String carModel;
  final String carPlate;
  final double pricePerKm;
  final String status; // 'offline', 'online', 'busy'
  final GeoPoint? location;
  final double rating;
  final String approvalStatus; // 'pending', 'approved', 'rejected'
  final bool isBlocked;

  const DriverModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.carModel,
    required this.carPlate,
    required this.pricePerKm,
    required this.status,
    this.location,
    required this.rating,
    this.approvalStatus = 'approved',
    this.isBlocked = false,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json, String id) {
    return DriverModel(
      uid: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      carModel: json['carModel'] ?? '',
      carPlate: json['carPlate'] ?? '',
      pricePerKm: (json['pricePerKm'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'offline',
      location: json['location'] as GeoPoint?,
      rating: (json['rating'] ?? 5.0).toDouble(),
      approvalStatus: json['approvalStatus'] ?? 'approved',
      isBlocked: json['isBlocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'carModel': carModel,
      'carPlate': carPlate,
      'pricePerKm': pricePerKm,
      'status': status,
      'location': location,
      'rating': rating,
      'approvalStatus': approvalStatus,
      'isBlocked': isBlocked,
    };
  }

  DriverModel copyWith({
    String? name,
    String? phone,
    String? carModel,
    String? carPlate,
    double? pricePerKm,
    String? status,
    GeoPoint? location,
    double? rating,
    String? approvalStatus,
    bool? isBlocked,
  }) {
    return DriverModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      carModel: carModel ?? this.carModel,
      carPlate: carPlate ?? this.carPlate,
      pricePerKm: pricePerKm ?? this.pricePerKm,
      status: status ?? this.status,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }

  @override
  List<Object?> get props => [
        uid, name, email, phone,
        carModel, carPlate, pricePerKm,
        status, location, rating,
        approvalStatus, isBlocked,
      ];
}