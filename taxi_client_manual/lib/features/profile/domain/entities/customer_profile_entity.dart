import 'package:equatable/equatable.dart';

/// كيان ملف العميل — Domain Layer (بدون Firebase)
class CustomerProfileEntity extends Equatable {
  final String name;
  final String email;
  final String phone;

  const CustomerProfileEntity({
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  List<Object?> get props => [name, email, phone];
}
