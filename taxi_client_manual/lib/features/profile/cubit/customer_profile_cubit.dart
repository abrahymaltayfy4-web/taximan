// lib/features/profile/cubit/customer_profile_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../repositories/customer_profile_repository.dart';

// === States ===
abstract class CustomerProfileState extends Equatable {
  const CustomerProfileState();
  @override
  List<Object?> get props => [];
}

class CustomerProfileInitial extends CustomerProfileState {}

class CustomerProfileLoading extends CustomerProfileState {}

class CustomerProfileLoaded extends CustomerProfileState {
  final String name;
  final String email;
  final String phone;

  const CustomerProfileLoaded({
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  List<Object?> get props => [name, email, phone];
}

class CustomerProfileUpdating extends CustomerProfileState {}

class CustomerProfileUpdated extends CustomerProfileState {}

class CustomerProfileError extends CustomerProfileState {
  final String message;
  const CustomerProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

// === Cubit ===
class CustomerProfileCubit extends Cubit<CustomerProfileState> {
  final CustomerProfileRepository _repository;

  CustomerProfileCubit(this._repository) : super(CustomerProfileInitial());

  Future<void> loadProfile() async {
    emit(CustomerProfileLoading());
    try {
      final profileData = await _repository.getProfile();
      if (profileData != null) {
        emit(CustomerProfileLoaded(
          name: profileData['name'] ?? '',
          email: profileData['email'] ?? '',
          phone: profileData['phone'] ?? '',
        ));
      } else {
        emit(const CustomerProfileError('لم يتم العثور على بيانات الحساب'));
      }
    } catch (e) {
      emit(CustomerProfileError(e.toString()));
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
    emit(CustomerProfileUpdating());
    try {
      await _repository.updateProfile(name: name, phone: phone);

      emit(CustomerProfileUpdated());
      // إعادة تحميل البيانات بعد التحديث
      await loadProfile();
    } catch (e) {
      emit(CustomerProfileError(e.toString()));
    }
  }
}
