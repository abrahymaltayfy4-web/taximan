import 'package:equatable/equatable.dart';
import '../../../../core/domain/location_entity.dart';

/// حالة توفر الكابتن
enum DriverAvailability {
  offline('offline'),
  online('online'),
  busy('busy');

  final String value;
  const DriverAvailability(this.value);

  static DriverAvailability fromString(String? value) {
    return DriverAvailability.values.firstWhere(
      (s) => s.value == value,
      orElse: () => DriverAvailability.offline,
    );
  }
}

/// حالة موافقة الإدارة على حساب الكابتن
enum ApprovalStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  final String value;
  const ApprovalStatus(this.value);

  static ApprovalStatus fromString(String? value) {
    return ApprovalStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ApprovalStatus.approved,
    );
  }
}

/// كيان الكابتن — مستقل عن Firebase
class DriverEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String carModel;
  final String carPlate;
  final double pricePerKm;
  final DriverAvailability availability;
  final LocationEntity? location;
  final double rating;
  final ApprovalStatus approvalStatus;
  final bool isBlocked;

  const DriverEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.carModel,
    required this.carPlate,
    required this.pricePerKm,
    required this.availability,
    this.location,
    required this.rating,
    this.approvalStatus = ApprovalStatus.approved,
    this.isBlocked = false,
  });

  @override
  List<Object?> get props => [
    uid,
    name,
    email,
    phone,
    carModel,
    carPlate,
    pricePerKm,
    availability,
    location,
    rating,
    approvalStatus,
    isBlocked,
  ];
}

/// بيانات تسجيل كابتن جديد
class NewDriverData extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String carModel;
  final String carPlate;
  final double pricePerKm;

  const NewDriverData({
    required this.name,
    required this.email,
    required this.phone,
    required this.carModel,
    required this.carPlate,
    required this.pricePerKm,
  });

  @override
  List<Object?> get props => [
    name,
    email,
    phone,
    carModel,
    carPlate,
    pricePerKm,
  ];
}

/// تحديث جزئي للملف الشخصي — الحقول null لا تُعدَّل
class DriverProfileUpdate extends Equatable {
  final String? name;
  final String? phone;
  final String? carModel;
  final String? carPlate;
  final double? pricePerKm;

  const DriverProfileUpdate({
    this.name,
    this.phone,
    this.carModel,
    this.carPlate,
    this.pricePerKm,
  });

  @override
  List<Object?> get props => [name, phone, carModel, carPlate, pricePerKm];
}
