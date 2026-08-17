import 'package:firebase_auth/firebase_auth.dart';
import '../services/client_ride_history_service.dart';
import '../../home/models/ride_model.dart';

class ClientRideHistoryRepository {
  final ClientRideHistoryService _service;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ClientRideHistoryRepository(this._service);

  String? get currentUserId => _auth.currentUser?.uid;

  Future<List<RideModel>> getCompletedRides(String filterType) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('يجب تسجيل الدخول');

    DateTime startDate;
    final now = DateTime.now();
    switch (filterType) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, now.day);
    }

    final docsData = await _service.getCompletedRides(
      customerId: uid,
      startDate: startDate,
    );
    return docsData.map((data) {
      final id = data.remove('id') as String;
      return RideModel.fromJson(data, id);
    }).toList();
  }
}
