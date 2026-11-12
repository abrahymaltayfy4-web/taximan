import '../core/infrastructure/firestore_service.dart';
import '../models/driver_model.dart';
import '../features/driver_auth/domain/entities/driver_entity.dart';
import '../features/driver_auth/domain/repositories/driver_repository_contract.dart';

/// تنفيذ DriverRepository — Data Layer
class DriverRepository implements DriverRepositoryContract {
  final FirestoreService _firestoreService;

  DriverRepository(this._firestoreService);

  @override
  Future<void> saveDriverData(DriverEntity driver, {bool isRegistration = false}) async {
    final model = DriverModel(
      uid: driver.uid,
      name: driver.name,
      email: driver.email,
      phone: driver.phone,
      carModel: driver.carModel,
      carPlate: driver.carPlate,
      pricePerKm: driver.pricePerKm,
      status: driver.status,
      rating: driver.rating,
      approvalStatus: driver.approvalStatus,
    );
    await _firestoreService.setDocument(
      collectionPath: 'drivers',
      docId: driver.uid,
      data: isRegistration ? model.toJsonForRegistration() : model.toJson(),
    );
  }

  @override
  Future<DriverEntity?> getDriverData(String uid) async {
    final doc = await _firestoreService.getDocument(
      collectionPath: 'drivers',
      docId: uid,
    );
    if (doc.exists && doc.data() != null) {
      final model = DriverModel.fromJson(doc.data()!, doc.id);
      return DriverEntity(
        uid: model.uid,
        name: model.name,
        email: model.email,
        phone: model.phone,
        carModel: model.carModel,
        carPlate: model.carPlate,
        pricePerKm: model.pricePerKm,
        status: model.status,
        rating: model.rating,
        approvalStatus: model.approvalStatus,
      );
    }
    return null;
  }

  @override
  Future<void> updateLocation({
    required String driverId,
    required double latitude,
    required double longitude,
  }) async {
    await _firestoreService.updateDriverLocation(
      driverId: driverId,
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  Future<void> updateDriverStatus(String driverId, String status) async {
    await _firestoreService.setDocument(
      collectionPath: 'drivers',
      docId: driverId,
      data: {'status': status},
    );
  }
}
