// lib/features/driver_auth/cubit/driver_auth_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../repositories/auth_repository.dart';
import '../../../repositories/driver_repository.dart';
import '../../../models/driver_model.dart';

// States
abstract class DriverAuthState extends Equatable {
  const DriverAuthState();
  @override
  List<Object?> get props => [];
}

class DriverAuthInitial extends DriverAuthState {}
class DriverAuthLoading extends DriverAuthState {}
class DriverAuthenticated extends DriverAuthState {
  final DriverModel driver;
  const DriverAuthenticated(this.driver);
  @override
  List<Object?> get props => [driver];
}
class DriverAuthError extends DriverAuthState {
  final String message;
  const DriverAuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
class DriverAuthCubit extends Cubit<DriverAuthState> {
  final AuthRepository _authRepository;
  final DriverRepository _driverRepository;

  DriverAuthCubit(this._authRepository, this._driverRepository) : super(DriverAuthInitial());

  Future<void> login(String email, String password) async {
    emit(DriverAuthLoading());
    try {
      final credential = await _authRepository.signInWithEmail(email: email, password: password);
      final driverData = await _driverRepository.getDriverData(credential.user!.uid);
      
      if (driverData != null) {
        emit(DriverAuthenticated(driverData));
      } else {
        emit(const DriverAuthError('بيانات الكابتن غير موجودة في النظام'));
      }
    } catch (e) {
      emit(DriverAuthError(e.toString()));
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String carModel,
    required String carPlate,
    required double pricePerKm,
  }) async {
    emit(DriverAuthLoading());
    try {
      final credential = await _authRepository.registerWithEmail(email: email, password: password);
      final uid = credential.user!.uid;

      final newDriver = DriverModel(
        uid: uid,
        name: name,
        email: email,
        phone: phone,
        carModel: carModel,
        carPlate: carPlate,
        pricePerKm: pricePerKm,
        status: 'offline',
        rating: 5.0,
      );

      await _driverRepository.saveDriverData(newDriver);
      emit(DriverAuthenticated(newDriver));
    } catch (e) {
      emit(DriverAuthError(e.toString()));
    }
  }
}