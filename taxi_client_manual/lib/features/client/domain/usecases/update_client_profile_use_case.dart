import '../../../../core/error/result.dart';
import '../repositories/client_repository.dart';

class UpdateClientProfileUseCase {
  final ClientRepository _repository;

  const UpdateClientProfileUseCase(this._repository);

  Future<Result<void>> call({required String name, required String phone}) {
    return _repository.updateProfile(name: name, phone: phone);
  }
}
