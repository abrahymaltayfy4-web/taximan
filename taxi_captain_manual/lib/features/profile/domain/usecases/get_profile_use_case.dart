import '../entities/driver_profile_entity.dart';
import '../repositories/profile_repository_contract.dart';

class GetProfileUseCase {
  final ProfileRepositoryContract _repository;
  GetProfileUseCase(this._repository);

  Future<DriverProfileEntity?> call() => _repository.getProfile();
}
