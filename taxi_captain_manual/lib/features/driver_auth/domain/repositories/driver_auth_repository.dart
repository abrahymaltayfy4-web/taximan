import '../../../../core/error/result.dart';
import '../../../driver/domain/entities/driver_entity.dart';
import '../entities/driver_session.dart';

/// عقد مصادقة الكابتن — Domain
abstract interface class DriverAuthRepository {
  /// تسجيل الدخول. يفشل بـ [WrongAccountTypeFailure] إن كان الحساب عميلاً.
  Future<Result<DriverEntity>> login({
    required String email,
    required String password,
  });

  /// إنشاء حساب كابتن جديد (approvalStatus = pending)
  Future<Result<DriverEntity>> register({
    required String password,
    required NewDriverData data,
  });

  /// فحص الجلسة الحالية (حظر / موافقة / نوع الحساب)
  Future<Result<DriverSession>> checkSession();

  Future<Result<void>> logout();
}
