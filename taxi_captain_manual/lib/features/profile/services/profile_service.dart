import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getDriverProfile(String uid) async {
    final doc = await _firestore.collection('drivers').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return doc.data()!;
    }
    return null;
  }

  Future<void> updateDriverProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('drivers').doc(uid).update(data);
  }
}
