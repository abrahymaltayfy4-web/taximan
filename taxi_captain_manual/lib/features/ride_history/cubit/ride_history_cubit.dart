import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../repositories/ride_history_repository.dart';
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
  final RideHistoryRepository _repository;

  RideHistoryCubit(this._repository) : super(RideHistoryInitial());

  Future<void> loadRideHistory(String filterType) async {
    try {
      emit(RideHistoryLoading());
      
      final rides = await _repository.getCompletedRides(filterType);

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
