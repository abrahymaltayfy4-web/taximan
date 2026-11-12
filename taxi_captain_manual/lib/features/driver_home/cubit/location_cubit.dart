import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_state.dart';

/// Cubit يغلّف Geolocator بالكامل — الـ Views لا تلمس Geolocator أبداً
class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(const LocationState());

  /// فحص الأذونات وخدمة الموقع
  Future<void> checkAndRequestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      emit(state.copyWith(
        permissionStatus: LocationPermissionStatus.serviceDisabled,
      ));
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        emit(state.copyWith(
          permissionStatus: LocationPermissionStatus.denied,
        ));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      emit(state.copyWith(
        permissionStatus: LocationPermissionStatus.deniedForever,
      ));
      return;
    }

    // الصلاحية ممنوحة — اجلب الموقع
    emit(state.copyWith(
      permissionStatus: LocationPermissionStatus.granted,
    ));
    await getCurrentPosition();
  }

  /// جلب الموقع الحالي
  Future<void> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      emit(state.copyWith(
        currentPosition: LatLng(position.latitude, position.longitude),
        permissionStatus: LocationPermissionStatus.granted,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// فتح إعدادات الموقع
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// فتح إعدادات التطبيق
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
