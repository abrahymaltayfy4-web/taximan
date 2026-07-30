// lib/repositories/driver_repository.dart
import '../core/services/firestore_service.dart';
import '../models/driver_model.dart';

class DriverRepository {
  final FirestoreService _firestoreService;

  DriverRepository(this._firestoreService);

  // Save or update driver profile data
  Future<void> saveDriverData(DriverModel driver) async {
    await _firestoreService.setDocument(
      collectionPath: 'drivers',
      docId: driver.uid,
      data: driver.toJson(),
    );
  }

  // Get driver data
  Future<DriverModel?> getDriverData(String uid) async {
    final doc = await _firestoreService.getDocument(
      collectionPath: 'drivers',
      docId: uid,
    );
    if (doc.exists && doc.data() != null) {
      return DriverModel.fromJson(doc.data()!, doc.id);
    }
    return null;
  }

  // Update live GPS location efficiently
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
}