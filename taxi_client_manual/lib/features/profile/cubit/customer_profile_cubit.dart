import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/entities/customer_profile_entity.dart';
import '../domain/usecases/get_customer_profile_use_case.dart';
import '../domain/usecases/update_customer_profile_use_case.dart';

// === States ===
abstract class CustomerProfileState extends Equatable {
  const CustomerProfileState();
  @override
  List<Object?> get props => [];
}

class CustomerProfileInitial extends CustomerProfileState {}

class CustomerProfileLoading extends CustomerProfileState {}

class CustomerProfileLoaded extends CustomerProfileState {
  final CustomerProfileEntity profile;

  const CustomerProfileLoaded(this.profile);

  // Backward-compatible getters
  String get name => profile.name;
  String get email => profile.email;
  String get phone => profile.phone;

  @override
  List<Object?> get props => [profile];
}

class CustomerProfileUpdating extends CustomerProfileState {}

class CustomerProfileUpdated extends CustomerProfileState {}

class CustomerProfileError extends CustomerProfileState {
  final String message;
  const CustomerProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

// === Cubit — يستخدم Use Cases فقط ===
class CustomerProfileCubit extends Cubit<CustomerProfileState> {
  final GetCustomerProfileUseCase _getProfile;
  final UpdateCustomerProfileUseCase _updateProfile;
  final FirebaseAuth _auth;

  CustomerProfileCubit({
    required GetCustomerProfileUseCase getProfile,
    required UpdateCustomerProfileUseCase updateProfile,
    required FirebaseAuth auth,
  })  : _getProfile = getProfile,
        _updateProfile = updateProfile,
        _auth = auth,
        super(CustomerProfileInitial());

  /// تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> loadProfile() async {
    emit(CustomerProfileLoading());
    try {
      final profile = await _getProfile();
      if (profile != null) {
        emit(CustomerProfileLoaded(profile));
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
      await _updateProfile(name: name, phone: phone);
      emit(CustomerProfileUpdated());
      await loadProfile();
    } catch (e) {
      emit(CustomerProfileError(e.toString()));
    }
  }
}
