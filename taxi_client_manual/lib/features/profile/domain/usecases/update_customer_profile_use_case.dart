import '../repositories/customer_profile_repository_contract.dart';

class UpdateCustomerProfileUseCase {
  final CustomerProfileRepositoryContract _repository;
  UpdateCustomerProfileUseCase(this._repository);

  Future<void> call({required String name, required String phone}) =>
      _repository.updateProfile(name: name, phone: phone);
}
