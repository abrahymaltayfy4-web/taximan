import '../domain/location_entity.dart';

/// نتيجة فحص/طلب صلاحية الموقع
enum LocationAccessStatus { granted, serviceDisabled, denied, deniedForever }

/// موقع الجهاز + اتجاه الحركة
class DevicePosition {
  final LocationEntity location;
  final double heading;

  const DevicePosition({required this.location, this.heading = 0});
}

/// موقع الجهاز — abstraction فوق geolocator.
/// التنفيذ في [GeolocatorLocationService].
abstract interface class LocationService {
  /// يتحقق من تفعيل الخدمة والصلاحية ويطلبها إن لزم
  Future<LocationAccessStatus> checkAndRequestAccess();

  /// الموقع الحالي بدقة عالية، أو null إن تعذّر
  Future<DevicePosition?> getCurrentPosition();

  /// بث الموقع (يتحدث كلما تحرك الجهاز 10 أمتار)
  Stream<DevicePosition> watchPosition();

  Future<void> openLocationSettings();

  Future<void> openAppSettings();
}
