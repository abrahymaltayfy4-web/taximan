// lib/features/home/cubit/ride_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ride_model.dart';
import 'ride_state.dart';

class RideCubit extends Cubit<RideState> {
  RideCubit() : super(RideInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> requestRide({
    required String pickup,
    required String destination,
  }) async {
    emit(RideLoading());
    try {
      final user = _auth.currentUser;
      if (user == null) {
        emit(RideError('يجب تسجيل الدخول أولاً'));
        return;
      }

      // جلب اسم المستخدم أو استخدام البريد كبديل مؤقت
      final clientName = user.displayName ?? user.email ?? 'عميل رحال';

      RideModel newRide = RideModel(
        clientId: user.uid,
        clientName: clientName,
        pickupLocation: pickup,
        destinationLocation: destination,
        status: 'pending',
        fare: 50.0, // سعر افتراضي تجريبي
      );

      DocumentReference docRef = await _firestore.collection('rides').add(newRide.toJson());
      
      emit(RideRequestedSuccess(docRef.id));
    } catch (e) {
      emit(RideError('حدث خطأ أثناء طلب الرحلة: ${e.toString()}'));
    }
  }

  // الدالة الناقصة: للاستماع لتغيرات حالة الرحلة بشكل حي (Real-time)
  Stream<DocumentSnapshot<Map<String, dynamic>>> streamRideStatus(String rideId) {
    return _firestore.collection('rides').doc(rideId).snapshots();
  }
}