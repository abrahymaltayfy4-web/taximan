import 'package:equatable/equatable.dart';
import '../../../driver/domain/entities/driver_entity.dart';

/// نتيجة فحص الجلسة عند فتح التطبيق
enum DriverSessionStatus {
  authenticated,
  unauthenticated,
  blocked,
  pendingApproval,
  rejected,
}

class DriverSession extends Equatable {
  final DriverSessionStatus status;
  final DriverEntity? driver;

  const DriverSession(this.status, [this.driver]);

  static const unauthenticated = DriverSession(
    DriverSessionStatus.unauthenticated,
  );

  @override
  List<Object?> get props => [status, driver];
}
