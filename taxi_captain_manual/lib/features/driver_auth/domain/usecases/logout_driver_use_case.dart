import '../../../../core/error/result.dart';
import '../repositories/driver_auth_repository.dart';

class LogoutDriverUseCase {
  final DriverAuthRepository _repository;

  const LogoutDriverUseCase(this._repository);

  Future<Result<void>> call() => _repository.logout();
}
