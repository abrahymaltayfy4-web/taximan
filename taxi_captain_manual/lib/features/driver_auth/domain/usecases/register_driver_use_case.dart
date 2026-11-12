import '../entities/driver_entity.dart';
import '../repositories/auth_repository_contract.dart';
import '../repositories/driver_repository_contract.dart';

class RegisterDriverUseCase {
  final AuthRepositoryContract _authRepo;
  final DriverRepositoryContract _driverRepo;

  RegisterDriverUseCase(this._authRepo, this._driverRepo);

  Future<DriverEntity> call({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String carModel,
    required String carPlate,
    required double pricePerKm,
  }) async {
    final uid = await _authRepo.registerWithEmail(
      email: email,
      password: password,
    );

    final newDriver = DriverEntity(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      carModel: carModel,
      carPlate: carPlate,
      pricePerKm: pricePerKm,
      status: 'offline',
      rating: 5.0,
      approvalStatus: 'pending',
    );

    await _driverRepo.saveDriverData(newDriver, isRegistration: true);
    return newDriver;
  }
}
