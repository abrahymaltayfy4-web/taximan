import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../rides/domain/entities/ride_entity.dart';
import '../domain/usecases/load_ride_history_use_case.dart';

// === States ===
abstract class RideHistoryState extends Equatable {
  const RideHistoryState();
  @override
  List<Object?> get props => [];
}

class RideHistoryInitial extends RideHistoryState {}

class RideHistoryLoading extends RideHistoryState {}

class RideHistoryLoaded extends RideHistoryState {
  final List<RideEntity> rides;
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

// === Cubit ===
class RideHistoryCubit extends Cubit<RideHistoryState> {
  final LoadRideHistoryUseCase _loadRideHistory;

  RideHistoryCubit(this._loadRideHistory) : super(RideHistoryInitial());

  Future<void> loadRideHistory(String filterType) async {
    try {
      emit(RideHistoryLoading());

      final rides = await _loadRideHistory(filterType);

      double totalFare = 0.0;
      double totalDistance = 0.0;
      for (var ride in rides) {
        totalFare += ride.fare;
        totalDistance += ride.distanceKm;
      }

      emit(
        RideHistoryLoaded(
          rides: rides,
          totalRides: rides.length,
          totalFare: totalFare,
          totalDistance: totalDistance,
          filterType: filterType,
        ),
      );
    } catch (e) {
      emit(RideHistoryError(e.toString()));
    }
  }
}
