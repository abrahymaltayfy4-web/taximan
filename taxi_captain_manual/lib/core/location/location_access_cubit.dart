import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'location_service.dart';
import 'location_use_cases.dart';

sealed class LocationAccessState extends Equatable {
  const LocationAccessState();
  @override
  List<Object?> get props => [];
}

final class LocationAccessInitial extends LocationAccessState {
  const LocationAccessInitial();
}

/// الصلاحية ممنوحة والموقع الحالي جاهز (position قد تكون null إن فشل الجلب)
final class LocationAccessReady extends LocationAccessState {
  final DevicePosition? position;
  const LocationAccessReady(this.position);

  @override
  List<Object?> get props => [position?.location, position?.heading];
}

/// الصلاحية غير ممنوحة — الواجهة تعرض Dialog حسب [status]
final class LocationAccessBlocked extends LocationAccessState {
  final LocationAccessStatus status;
  const LocationAccessBlocked(this.status);

  @override
  List<Object?> get props => [status];
}

/// يدير دورة فحص صلاحية الموقع + جلب الموقع الحالي للشاشات الرئيسية.
/// كان هذا المنطق مكرراً داخل HomeView (Client) و DriverHomeView (Captain).
class LocationAccessCubit extends Cubit<LocationAccessState> {
  final CheckLocationAccessUseCase _checkAccess;
  final GetCurrentLocationUseCase _getCurrentLocation;
  final OpenLocationSettingsUseCase _openSettings;

  LocationAccessCubit({
    required CheckLocationAccessUseCase checkAccess,
    required GetCurrentLocationUseCase getCurrentLocation,
    required OpenLocationSettingsUseCase openSettings,
  }) : _checkAccess = checkAccess,
       _getCurrentLocation = getCurrentLocation,
       _openSettings = openSettings,
       super(const LocationAccessInitial());

  Future<void> check() async {
    final status = await _checkAccess();
    if (status != LocationAccessStatus.granted) {
      emit(LocationAccessBlocked(status));
      return;
    }
    final position = await _getCurrentLocation();
    emit(LocationAccessReady(position));
  }

  Future<void> openSettings({required bool appSettings}) =>
      _openSettings(appSettings: appSettings);
}
