import 'package:equatable/equatable.dart';
import '../../../../core/domain/account_status.dart';

/// كيان العميل — مستقل عن Firebase
class ClientEntity extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final AccountStatus accountStatus;

  const ClientEntity({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    this.accountStatus = AccountStatus.active,
  });

  @override
  List<Object?> get props => [uid, name, email, phone, accountStatus];
}

/// بيانات تسجيل عميل جديد
class NewClientData extends Equatable {
  final String name;
  final String email;
  final String phone;

  const NewClientData({
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  List<Object?> get props => [name, email, phone];
}
