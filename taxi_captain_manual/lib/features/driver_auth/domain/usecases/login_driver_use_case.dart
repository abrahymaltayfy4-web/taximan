import '../entities/driver_entity.dart';
import '../repositories/auth_repository_contract.dart';
import '../repositories/driver_repository_contract.dart';

class LoginDriverUseCase {
  final AuthRepositoryContract _authRepo;
  final DriverRepositoryContract _driverRepo;

  LoginDriverUseCase(this._authRepo, this._driverRepo);

  /// يسجل الدخول ويعيد DriverEntity إذا كان الحساب كابتن
  /// يرمي Exception إذا لم يكن كابتن
  Future<DriverEntity> call({
    required String email,
    required String password,
  }) async {
    final uid = await _authRepo.signInWithEmail(
      email: email,
      password: password,
    );
    final driver = await _driverRepo.getDriverData(uid);
    if (driver == null) {
      await _authRepo.signOut();
      throw Exception('هذا الحساب مسجل كعميل. يرجى استخدام تطبيق العميل');
    }
    return driver;
  }
}
