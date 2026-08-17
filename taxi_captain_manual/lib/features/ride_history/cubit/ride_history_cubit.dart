import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/ride_model.dart';

abstract class RideHistoryState extends Equatable {
  const RideHistoryState();
  @override
  List<Object?> get props => [];
}

class RideHistoryInitial extends RideHistoryState {}

class RideHistoryLoading extends RideHistoryState {}

class RideHistoryLoaded extends RideHistoryState {
  final List<RideModel> rides;
  final int totalRides;
  final double totalFare;
  final double totalDistance;
  final String filterType;

  const RideHistoryLoaded({
    required this.rides,
    required this.totalRides,
    required this.totalFare,
    required this.totalDistance,
    required this.filterType,
  });

  @override
  List<Object?> get props => [rides, totalRides, totalFare, totalDistance, filterType];
}

class RideHistoryError extends RideHistoryState {
  final String message;
  const RideHistoryError(this.message);
  @override
  List<Object?> get props => [message];
}

class RideHistoryCubit extends Cubit<RideHistoryState> {
  RideHistoryCubit() : super(RideHistoryInitial());

  Future<void> loadRideHistory(String filterType) async {
    try {
      emit(RideHistoryLoading());
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('المستخدم غير مسجل الدخول');

      DateTime startDate = DateTime.now();
      if (filterType == 'اليوم') {
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
      } else if (filterType == 'الأسبوع') {
        startDate = startDate.subtract(Duration(days: startDate.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
      } else if (filterType == 'الشهر') {
        startDate = DateTime(startDate.year, startDate.month, 1);
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('rides')
          .where('driverId', isEqualTo: uid)
          .where('status', isEqualTo: 'completed')
          .where('createdAt', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .orderBy('createdAt', descending: true)
          .get();

      List<RideModel> rides = snapshot.docs.map((doc) => RideModel.fromJson(doc.data(), doc.id)).toList();

      double totalFare = 0.0;
      double totalDistance = 0.0;
      for (var ride in rides) {
        totalFare += ride.fare;
        totalDistance += ride.distanceKm;
      }

      emit(RideHistoryLoaded(
        rides: rides,
        totalRides: rides.length,
        totalFare: totalFare,
        totalDistance: totalDistance,
        filterType: filterType,
      ));
    } catch (e) {
      emit(RideHistoryError(e.toString()));
    }
  }
}
