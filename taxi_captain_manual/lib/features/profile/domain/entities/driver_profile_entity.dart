import 'package:equatable/equatable.dart';

/// كيان الملف الشخصي للسائق — Domain Layer
class DriverProfileEntity extends Equatable {
  final String uid;
  final String name;
  final String phone;
  final String email;
  final String carModel;
  final String carPlate;
  final double pricePerKm;
  final String status;
  final double totalCommissionOwed;
  final double totalPaid;

  const DriverProfileEntity({
    required this.uid,
    required this.name,
    required this.phone,
    this.email = '',
    required this.carModel,
    required this.carPlate,
    required this.pricePerKm,
    required this.status,
    this.totalCommissionOwed = 0.0,
    this.totalPaid = 0.0,
  });

  @override
  List<Object?> get props => [uid, name, phone, status];
}
