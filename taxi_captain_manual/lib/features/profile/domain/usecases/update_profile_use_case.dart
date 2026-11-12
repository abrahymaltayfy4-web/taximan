import '../repositories/profile_repository_contract.dart';

class UpdateProfileUseCase {
  final ProfileRepositoryContract _repository;
  UpdateProfileUseCase(this._repository);

  Future<void> call({
    String? name,
    String? phone,
    String? carModel,
    String? carPlate,
    double? pricePerKm,
  }) {
    return _repository.updateProfile(
      name: name,
      phone: phone,
      carModel: carModel,
      carPlate: carPlate,
      pricePerKm: pricePerKm,
    );
  }
}
