import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/client_ride_history_repository.dart';
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
  final ClientRideHistoryRepository _repository;

  ClientRideHistoryCubit(this._repository) : super(ClientRideHistoryInitial());

  Future<void> loadHistory(String filterType) async {
    emit(ClientRideHistoryLoading());
    try {
      final rides = await _repository.getCompletedRides(filterType);
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
