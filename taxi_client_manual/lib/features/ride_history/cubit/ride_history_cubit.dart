import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../home/models/ride_model.dart';

abstract class ClientRideHistoryState extends Equatable {
  const ClientRideHistoryState();
  @override
  List<Object?> get props => [];
}

class ClientRideHistoryInitial extends ClientRideHistoryState {}

class ClientRideHistoryLoading extends ClientRideHistoryState {}

class ClientRideHistoryLoaded extends ClientRideHistoryState {
  final List<RideModel> rides;
  final int totalRides;
  final double totalFare;
  final String filterType;

  const ClientRideHistoryLoaded({
    required this.rides,
    required this.totalRides,
    required this.totalFare,
    required this.filterType,
  });

  @override
  List<Object?> get props => [rides, totalRides, totalFare, filterType];
}

class ClientRideHistoryError extends ClientRideHistoryState {
  final String message;
  const ClientRideHistoryError(this.message);
  @override
  List<Object?> get props => [message];
}

class ClientRideHistoryCubit extends Cubit<ClientRideHistoryState> {
  ClientRideHistoryCubit() : super(ClientRideHistoryInitial());
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> loadHistory(String filterType) async {
    emit(ClientRideHistoryLoading());
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        emit(const ClientRideHistoryError('يجب تسجيل الدخول'));
        return;
      }

      DateTime startDate;
      final now = DateTime.now();
      switch (filterType) {
        case 'today':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          break;
        default:
          startDate = DateTime(now.year, now.month, now.day);
      }

      final snapshot = await _firestore.collection('rides')
          .where('customerId', isEqualTo: uid)
          .where('status', isEqualTo: 'completed')
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('createdAt', descending: true)
          .get();

      final rides = snapshot.docs.map((doc) => RideModel.fromJson(doc.data(), doc.id)).toList();
      final totalFare = rides.fold<double>(0, (sum, r) => sum + r.fare);

      emit(ClientRideHistoryLoaded(
        rides: rides,
        totalRides: rides.length,
        totalFare: totalFare,
        filterType: filterType,
      ));
    } catch (e) {
      emit(ClientRideHistoryError(e.toString()));
    }
  }
}
