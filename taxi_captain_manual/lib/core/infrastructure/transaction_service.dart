import 'package:cloud_firestore/cloud_firestore.dart';

/// خدمة المعاملات المالية — CRUD على مجموعة transactions
class TransactionService {
  final FirebaseFirestore _firestore;

  TransactionService(this._firestore);

  /// إنشاء سجل عمولة
  Future<void> createCommission({
    required String driverId,
    required String driverName,
    required double amount,
    required String rideId,
    required double rideFare,
  }) async {
    await _firestore.collection('transactions').add({
      'driverId': driverId,
      'driverName': driverName,
      'type': 'commission',
      'amount': amount,
      'rideId': rideId,
      'rideFare': rideFare,
      'note':
          'عمولة رحلة — ${amount.toStringAsFixed(0)} ريال من ${rideFare.toStringAsFixed(0)} ريال',
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': 'system',
    });
  }

  /// جلب معاملات سائق
  Future<List<Map<String, dynamic>>> getDriverTransactions(
    String driverId,
  ) async {
    final snap = await _firestore
        .collection('transactions')
        .where('driverId', isEqualTo: driverId)
        .get();

    final list = snap.docs.map((d) {
      final data = d.data();
      return {
        'id': d.id,
        'type': data['type'] ?? 'commission',
        'amount': (data['amount'] ?? 0.0).toDouble(),
        'note': data['note'] ?? '',
        'rideFare': (data['rideFare'] ?? 0.0).toDouble(),
        'createdAt':
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      };
    }).toList();

    list.sort(
      (a, b) =>
          (b['createdAt'] as DateTime).compareTo(a['createdAt'] as DateTime),
    );

    return list;
  }
}
