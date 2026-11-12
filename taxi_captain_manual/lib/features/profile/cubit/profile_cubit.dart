import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../domain/entities/driver_profile_entity.dart';
import '../domain/usecases/get_profile_use_case.dart';
import '../domain/usecases/update_profile_use_case.dart';

// === States ===
abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileUpdating extends ProfileState {}

class ProfileUpdated extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final DriverProfileEntity driver;
  const ProfileLoaded(this.driver);
  @override
  List<Object?> get props => [driver];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

// === Cubit ===
class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase _getProfile;
  final UpdateProfileUseCase _updateProfile;

  ProfileCubit({
    required GetProfileUseCase getProfile,
    required UpdateProfileUseCase updateProfile,
  })  : _getProfile = getProfile,
        _updateProfile = updateProfile,
        super(ProfileInitial());

  Future<void> loadProfile() async {
    try {
      emit(ProfileLoading());
      final driver = await _getProfile();
      if (driver == null) throw Exception('الملف الشخصي غير موجود');
      emit(ProfileLoaded(driver));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? carModel,
    String? carPlate,
    double? pricePerKm,
  }) async {
    try {
      emit(ProfileUpdating());
      await _updateProfile(
        name: name,
        phone: phone,
        carModel: carModel,
        carPlate: carPlate,
        pricePerKm: pricePerKm,
      );
      emit(ProfileUpdated());
      loadProfile();
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
