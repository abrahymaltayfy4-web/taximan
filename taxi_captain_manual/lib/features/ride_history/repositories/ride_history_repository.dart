import 'package:firebase_auth/firebase_auth.dart';
import '../services/ride_history_service.dart';
import '../../../models/ride_model.dart';

class RideHistoryRepository {
  final RideHistoryService _service;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RideHistoryRepository(this._service);

  String? get currentUserId => _auth.currentUser?.uid;

  Future<List<RideModel>> getCompletedRides(String filterType) async {
    final uid = currentUserId;
    if (uid == null) throw Exception('المستخدم غير مسجل الدخول');

    final now = DateTime.now();
    DateTime startDate;

    if (filterType == 'اليوم') {
      // من بداية اليوم الحالي
      startDate = DateTime(now.year, now.month, now.day);
    } else if (filterType == 'الأسبوع') {
      // آخر 7 أيام
      startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
    } else if (filterType == 'الشهر') {
      // من بداية الشهر الحالي
      startDate = DateTime(now.year, now.month, 1);
    } else {
      startDate = DateTime(now.year, now.month, now.day);
    }

    final docsData = await _service.getCompletedRides(
      driverId: uid,
      startDate: startDate,
    );
    return docsData.map((data) {
      final id = data.remove('id') as String;
      return RideModel.fromJson(data, id);
    }).toList();
  }
}
