// lib/core/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generic method to set document data
  Future<void> setDocument({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collectionPath).doc(docId).set(data, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  // Generic method to get document data
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument({
    required String collectionPath,
    required String docId,
  }) async {
    try {
      return await _firestore.collection(collectionPath).doc(docId).get();
    } catch (e) {
      rethrow;
    }
  }

  // Update driver live location efficiently
  Future<void> updateDriverLocation({
    required String driverId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _firestore.collection('drivers').doc(driverId).update({
        'location': GeoPoint(latitude, longitude),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }
}