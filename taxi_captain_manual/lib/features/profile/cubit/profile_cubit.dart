import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../repositories/profile_repository.dart';
import '../../../models/driver_model.dart';

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
  final DriverModel driver;
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

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit(this._repository) : super(ProfileInitial());

  Future<void> loadProfile() async {
    try {
      emit(ProfileLoading());
      final driver = await _repository.getProfile();
      if (driver == null) throw Exception('الملف الشخصي غير موجود');
      emit(ProfileLoaded(driver));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile({String? name, String? phone, String? carModel, String? carPlate, double? pricePerKm}) async {
    try {
      emit(ProfileUpdating());
      await _repository.updateProfile(
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
