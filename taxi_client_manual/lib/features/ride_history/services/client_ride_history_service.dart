import 'package:cloud_firestore/cloud_firestore.dart';

class ClientRideHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getCompletedRides({
    required String customerId,
    required DateTime startDate,
  }) async {
    final snapshot = await _firestore.collection('rides')
        .where('customerId', isEqualTo: customerId)
        .where('status', isEqualTo: 'completed')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }
}
