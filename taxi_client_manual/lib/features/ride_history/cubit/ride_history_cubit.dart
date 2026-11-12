import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../rides/domain/ride_entity.dart';
import '../domain/usecases/load_client_ride_history_use_case.dart';

abstract class ClientRideHistoryState extends Equatable {
  const ClientRideHistoryState();
  @override
  List<Object?> get props => [];
}

class ClientRideHistoryInitial extends ClientRideHistoryState {}

class ClientRideHistoryLoading extends ClientRideHistoryState {}

class ClientRideHistoryLoaded extends ClientRideHistoryState {
  final List<RideEntity> rides;
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
  final LoadClientRideHistoryUseCase _loadHistory;

  ClientRideHistoryCubit(this._loadHistory) : super(ClientRideHistoryInitial());

  Future<void> loadHistory(String filterType) async {
    emit(ClientRideHistoryLoading());
    try {
      final rides = await _loadHistory(filterType);
      final totalFare = rides.fold<double>(0, (sum, r) => sum + r.fare);

      emit(
        ClientRideHistoryLoaded(
          rides: rides,
          totalRides: rides.length,
          totalFare: totalFare,
          filterType: filterType,
        ),
      );
    } catch (e) {
      emit(ClientRideHistoryError(e.toString()));
    }
  }
}
