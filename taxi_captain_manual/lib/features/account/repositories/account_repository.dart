import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/error/result.dart';
import '../../../core/infrastructure/transaction_service.dart';
import '../../../core/di/service_locator.dart';

/// Repository لكشف حساب السائق
class AccountRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AccountRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore,
       _auth = auth;

  String get _uid => _auth.currentUser?.uid ?? '';

  /// جلب بيانات الحساب (المستحقات + المدفوع)
  Future<Result<AccountData>> getAccountData() async {
    try {
      if (_uid.isEmpty) return Result.failure(const AuthFailure());

      final doc = await _firestore.collection('drivers').doc(_uid).get();
      if (!doc.exists) return Result.failure(const AccountNotFoundFailure());

      final data = doc.data()!;
      final totalOwed = (data['totalCommissionOwed'] ?? 0.0).toDouble();
      final totalPaid = (data['totalPaid'] ?? 0.0).toDouble();

      // جلب المعاملات
      final txService = sl<TransactionService>();
      final transactions = await txService.getDriverTransactions(_uid);

      return Result.success(
        AccountData(
          totalCommissionOwed: totalOwed,
          totalPaid: totalPaid,
          transactions: transactions,
        ),
      );
    } catch (e) {
      return Result.failure(UnknownFailure('خطأ في جلب بيانات الحساب', e));
    }
  }
}

/// بيانات الحساب
class AccountData {
  final double totalCommissionOwed;
  final double totalPaid;
  final List<Map<String, dynamic>> transactions;

  const AccountData({
    required this.totalCommissionOwed,
    required this.totalPaid,
    required this.transactions,
  });
}
