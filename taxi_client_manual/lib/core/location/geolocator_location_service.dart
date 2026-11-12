import 'package:geolocator/geolocator.dart';
import '../domain/location_entity.dart';
import 'location_service.dart';

class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<LocationAccessStatus> checkAndRequestAccess() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationAccessStatus.serviceDisabled;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationAccessStatus.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationAccessStatus.deniedForever;
    }
    return LocationAccessStatus.granted;
  }

  @override
  Future<DevicePosition?> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return _toDevicePosition(position);
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<DevicePosition> watchPosition() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // تحديث الموقع كلما تحرك 10 أمتار
    );
    return Geolocator.getPositionStream(
      locationSettings: settings,
    ).map(_toDevicePosition);
  }

  @override
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  @override
  Future<void> openAppSettings() => Geolocator.openAppSettings();

  DevicePosition _toDevicePosition(Position p) => DevicePosition(
    location: LocationEntity(latitude: p.latitude, longitude: p.longitude),
    heading: p.heading,
  );
}
