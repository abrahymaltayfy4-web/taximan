// lib/repositories/customer_repository.dart
import '../core/services/firestore_service.dart';
import '../models/user_model.dart';

class CustomerRepository {
  final FirestoreService _firestoreService;

  CustomerRepository(this._firestoreService);

  // Save or update customer profile data in Firestore
  Future<void> saveCustomerData(UserModel user) async {
    await _firestoreService.setDocument(
      collectionPath: 'users',
      docId: user.uid,
      data: user.toJson(),
    );
  }

  // Get customer profile data
  Future<UserModel?> getCustomerData(String uid) async {
    final doc = await _firestoreService.getDocument(
      collectionPath: 'users',
      docId: uid,
    );
    if (doc.exists && doc.data() != null) {
      return UserModel.fromJson(doc.data()!, doc.id);
    }
    return null;
  }
}