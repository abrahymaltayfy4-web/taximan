import '../../../../core/auth/auth_session.dart';
import '../../../../core/domain/location_entity.dart';
import '../../../../core/domain/pricing_config.dart';
import '../../../../core/error/result.dart';
import '../../../../core/pricing/pricing_repository.dart';
import '../../../client/domain/repositories/client_repository.dart';
import '../entities/ride_entity.dart';
import '../repositories/customer_ride_repository.dart';

/// طلب رحلة جديدة:
/// 1) يتحقق أن الحساب مسموح له بطلب الرحلات
/// 2) يحسب الأجرة بالمعادلة الموحدة (مع الإعدادات الافتراضية إن تعذّر جلبها)
/// 3) ينشئ الرحلة
class RequestRideUseCase {
  final CustomerRideRepository _rides;
  final ClientRepository _clients;
  final PricingRepository _pricing;
  final AuthSession _session;

  const RequestRideUseCase(
    this._rides,
    this._clients,
    this._pricing,
    this._session,
  );

  Future<Result<String>> call({
    required LocationEntity pickupLocation,
    required String pickupAddress,
    required LocationEntity destinationLocation,
    required String destinationAddress,
    required double distanceKm,
  }) async {
    final uid = _session.currentUserId;
    if (uid == null) return Result<String>.failure(const AuthFailure());

    final clientResult = await _clients.getCurrentClient();
    if (clientResult case Err(failure: final f)) {
      return Result<String>.failure(f);
    }
    final client = clientResult.data;

    if (client != null && !client.accountStatus.canUseRides) {
      return Result<String>.failure(
        BlockedAccountFailure(client.accountStatus.userMessage),
      );
    }

    final customerName = (client?.name.isNotEmpty ?? false)
        ? client!.name
        : (_session.fallbackDisplayName ?? 'عميل رحال');

    final pricingResult = await _pricing.getPricingConfig();
    final PricingConfig config = switch (pricingResult) {
      Success(data: final c) => c,
      Err() => const PricingConfig(),
    };

    return _rides.createRide(
      NewRideRequest(
        customerId: uid,
        customerName: customerName,
        customerPhone: client?.phone ?? '',
        pickupLocation: pickupLocation,
        pickupAddress: pickupAddress,
        destinationLocation: destinationLocation,
        destinationAddress: destinationAddress,
        distanceKm: distanceKm,
        fare: config.calculateFare(distanceKm),
      ),
    );
  }
}
