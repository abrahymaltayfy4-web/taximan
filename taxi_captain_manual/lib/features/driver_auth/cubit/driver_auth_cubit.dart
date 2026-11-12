import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../domain/entities/driver_entity.dart';
import '../domain/usecases/login_driver_use_case.dart';
import '../domain/usecases/register_driver_use_case.dart';

// States
abstract class DriverAuthState extends Equatable {
  const DriverAuthState();
  @override
  List<Object?> get props => [];
}

class DriverAuthInitial extends DriverAuthState {}

class DriverAuthLoading extends DriverAuthState {}

class DriverAuthenticated extends DriverAuthState {
  final DriverEntity driver;
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

// Cubit — يستخدم Use Cases فقط
class DriverAuthCubit extends Cubit<DriverAuthState> {
  final LoginDriverUseCase _loginDriver;
  final RegisterDriverUseCase _registerDriver;

  DriverAuthCubit({
    required LoginDriverUseCase loginDriver,
    required RegisterDriverUseCase registerDriver,
  })  : _loginDriver = loginDriver,
        _registerDriver = registerDriver,
        super(DriverAuthInitial());

  Future<void> login(String email, String password) async {
    emit(DriverAuthLoading());
    try {
      final driver = await _loginDriver(email: email, password: password);
      emit(DriverAuthenticated(driver));
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
      final driver = await _registerDriver(
        email: email,
        password: password,
        name: name,
        phone: phone,
        carModel: carModel,
        carPlate: carPlate,
        pricePerKm: pricePerKm,
      );
      emit(DriverAuthenticated(driver));
    } catch (e) {
      emit(DriverAuthError(e.toString()));
    }
  }
}
