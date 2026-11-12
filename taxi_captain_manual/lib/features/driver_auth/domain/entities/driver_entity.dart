import 'package:equatable/equatable.dart';

/// كيان بيانات السائق — Domain Layer (بدون Firebase)
class DriverEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String carModel;
  final String carPlate;
  final double pricePerKm;
  final String status;
  final double rating;
  final String approvalStatus;

  const DriverEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.carModel,
    required this.carPlate,
    required this.pricePerKm,
    required this.status,
    this.rating = 5.0,
    this.approvalStatus = 'approved',
  });

  @override
  List<Object?> get props => [uid, name, email, status];
}
