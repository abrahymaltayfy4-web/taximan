import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/firestore_collections.dart';
import '../models/client_model.dart';

abstract interface class ClientRemoteDataSource {
  Future<ClientModel?> getClient(String uid);

  Future<void> createClient({
    required String uid,
    required String name,
    required String email,
    required String phone,
  });

  Future<void> updateProfile(
    String uid, {
    required String name,
    required String phone,
  });
}

class FirebaseClientRemoteDataSource implements ClientRemoteDataSource {
  final FirebaseFirestore _firestore;

  const FirebaseClientRemoteDataSource(this._firestore);

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection(FirestoreCollections.clients).doc(uid);

  @override
  Future<ClientModel?> getClient(String uid) async {
    final doc = await _doc(uid).get();
    final data = doc.data();
    if (!doc.exists || data == null) return null;
    return ClientModel.fromJson(data, doc.id);
  }

  @override
  Future<void> createClient({
    required String uid,
    required String name,
    required String email,
    required String phone,
  }) {
    return _doc(uid).set({
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> updateProfile(
    String uid, {
    required String name,
    required String phone,
  }) {
    return _doc(uid).update({'name': name, 'phone': phone});
  }
}
