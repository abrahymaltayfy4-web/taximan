import '../entities/customer_profile_entity.dart';
import '../repositories/customer_profile_repository_contract.dart';

class GetCustomerProfileUseCase {
  final CustomerProfileRepositoryContract _repository;
  GetCustomerProfileUseCase(this._repository);

  Future<CustomerProfileEntity?> call() => _repository.getProfile();
}
