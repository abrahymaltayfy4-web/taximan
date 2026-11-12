import '../../../core/error/result.dart';
import '../domain/customer_ride_repository.dart';
import '../domain/ride_entity.dart';
import '../domain/location_entity.dart';
import 'ride_remote_data_source.dart';

/// تنفيذ Repository الرحلات — Data Layer
class CustomerRideRepositoryImpl implements CustomerRideRepository {
  final RideRemoteDataSource _dataSource;

  CustomerRideRepositoryImpl(this._dataSource);

  @override
  Future<Result<String>> requestRide({
    required LocationEntity pickupLocation,
    required String pickupAddress,
    required LocationEntity destinationLocation,
    required String destinationAddress,
    required double distanceKm,
  }) async {
    try {
      final user = _dataSource.currentUser;
      if (user == null) {
        return Result.failure(const AuthFailure());
      }

      final clientData = await _dataSource.getClientData(user.uid);
      final status = _dataSource.getAccountStatus(clientData);
      if (!status.canUseRides) {
        return Result.failure(BlockedAccountFailure(status.userMessage));
      }

      final customerName =
          clientData?['name'] ?? user.displayName ?? user.email ?? 'عميل رحال';
      final customerPhone = clientData?['phone'] ?? '';

      final pricing = await _dataSource.getPricingConfig();
      final fare = pricing.calculateFare(distanceKm);

      final rideId = await _dataSource.createRide(
        customerId: user.uid,
        customerName: customerName,
        customerPhone: customerPhone,
        pickupLocation: pickupLocation,
        pickupAddress: pickupAddress,
        destinationLocation: destinationLocation,
        destinationAddress: destinationAddress,
        fare: fare,
        distanceKm: distanceKm,
      );

      return Result.success(rideId);
    } catch (e) {
      return Result.failure(
        UnknownFailure('حدث خطأ أثناء طلب الرحلة: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<Result<RideEntity>> watchActiveRide(String rideId) {
    return _dataSource
        .watchRide(rideId)
        .map((ride) {
          if (ride == null) {
            return Result<RideEntity>.failure(
              const RideNotFoundFailure('الرحلة غير موجودة'),
            );
          }
          return Result<RideEntity>.success(ride);
        })
        .handleError((e) {
          return Result<RideEntity>.failure(
            UnknownFailure('خطأ في تتبع الرحلة: ${e.toString()}'),
          );
        });
  }

  @override
  Stream<Result<LocationEntity>> watchDriverLocation(String driverId) {
    return _dataSource.watchDriverLocation(driverId).map((location) {
      if (location == null) {
        return Result<LocationEntity>.failure(
          const UnknownFailure('موقع السائق غير متاح'),
        );
      }
      return Result<LocationEntity>.success(location);
    });
  }

  @override
  Future<Result<void>> cancelRide(String rideId) async {
    try {
      await _dataSource.cancelRide(rideId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        UnknownFailure('حدث خطأ أثناء إلغاء الرحلة: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<RideEntity>>> loadRideHistory() async {
    try {
      final user = _dataSource.currentUser;
      if (user == null) {
        return Result.failure(const AuthFailure());
      }
      final rides = await _dataSource.getRideHistory(user.uid);
      return Result.success(rides);
    } catch (e) {
      return Result.failure(
        UnknownFailure('خطأ في جلب سجل الرحلات: ${e.toString()}'),
      );
    }
  }
}
