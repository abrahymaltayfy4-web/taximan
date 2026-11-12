import 'location_service.dart';

/// فحص/طلب صلاحية الموقع
class CheckLocationAccessUseCase {
  final LocationService _service;
  const CheckLocationAccessUseCase(this._service);

  Future<LocationAccessStatus> call() => _service.checkAndRequestAccess();
}

/// الموقع الحالي للجهاز (null إن تعذّر)
class GetCurrentLocationUseCase {
  final LocationService _service;
  const GetCurrentLocationUseCase(this._service);

  Future<DevicePosition?> call() => _service.getCurrentPosition();
}

/// بث موقع الجهاز
class WatchDeviceLocationUseCase {
  final LocationService _service;
  const WatchDeviceLocationUseCase(this._service);

  Stream<DevicePosition> call() => _service.watchPosition();
}

/// فتح إعدادات الموقع أو إعدادات التطبيق
class OpenLocationSettingsUseCase {
  final LocationService _service;
  const OpenLocationSettingsUseCase(this._service);

  Future<void> call({bool appSettings = false}) =>
      appSettings ? _service.openAppSettings() : _service.openLocationSettings();
}
