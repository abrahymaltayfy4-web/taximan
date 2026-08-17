import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getClientProfile(String uid) async {
    final doc = await _firestore.collection('clients').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return doc.data()!;
    }
    return null;
  }

  Future<void> updateClientProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('clients').doc(uid).update(data);
  }
}
