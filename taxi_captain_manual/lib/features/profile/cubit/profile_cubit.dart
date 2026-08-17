import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  ProfileCubit() : super(ProfileInitial());

  Future<void> loadProfile() async {
    try {
      emit(ProfileLoading());
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('المستخدم غير مسجل الدخول');

      final doc = await FirebaseFirestore.instance.collection('drivers').doc(uid).get();
      if (!doc.exists || doc.data() == null) throw Exception('الملف الشخصي غير موجود');

      final driver = DriverModel.fromJson(doc.data()!, doc.id);
      emit(ProfileLoaded(driver));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile({String? name, String? phone, String? carModel, String? carPlate, double? pricePerKm}) async {
    try {
      emit(ProfileUpdating());
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('المستخدم غير مسجل الدخول');

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (carModel != null) updates['carModel'] = carModel;
      if (carPlate != null) updates['carPlate'] = carPlate;
      if (pricePerKm != null) updates['pricePerKm'] = pricePerKm;

      await FirebaseFirestore.instance.collection('drivers').doc(uid).update(updates);
      emit(ProfileUpdated());
      loadProfile();
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
