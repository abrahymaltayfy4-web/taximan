import '../../../../core/error/result.dart';
import '../entities/driver_session.dart';
import '../repositories/driver_auth_repository.dart';

/// يتحقق عند فتح التطبيق: هل الكابتن مسجل دخول، غير محظور، وموافق عليه؟
class CheckDriverSessionUseCase {
  final DriverAuthRepository _repository;

  const CheckDriverSessionUseCase(this._repository);

  Future<Result<DriverSession>> call() => _repository.checkSession();
}
