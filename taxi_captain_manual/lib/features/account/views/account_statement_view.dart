import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';

class AccountStatementView extends StatefulWidget {
  const AccountStatementView({super.key});

  @override
  State<AccountStatementView> createState() => _AccountStatementViewState();
}

class _AccountStatementViewState extends State<AccountStatementView> {
  final _firestore = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  double _totalOwed = 0.0;
  double _totalPaid = 0.0;
  List<Map<String, dynamic>> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // جلب بيانات السائق
    final driverDoc = await _firestore.collection('drivers').doc(_uid).get();
    if (driverDoc.exists) {
      _totalOwed = (driverDoc.data()?['totalCommissionOwed'] ?? 0.0).toDouble();
      _totalPaid = (driverDoc.data()?['totalPaid'] ?? 0.0).toDouble();
    }

    // جلب المعاملات
    final txSnap = await _firestore
        .collection('transactions')
        .where('driverId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .get();

    _transactions = txSnap.docs.map((d) {
      final data = d.data();
      return {
        'type': data['type'] ?? 'commission',
        'amount': (data['amount'] ?? 0.0).toDouble(),
        'note': data['note'] ?? '',
        'rideFare': (data['rideFare'] ?? 0.0).toDouble(),
        'createdAt': (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      };
    }).toList();

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      appBar: AppBar(
        title: Text('كشف الحساب', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.deepBurgundy,
        foregroundColor: Colors.white,
      ),
      body: _loading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.deepBurgundy))
            : RefreshIndicator(
                onRefresh: () async {
                  setState(() => _loading = true);
                  await _loadData();
                },
                child: ListView(
                  padding: EdgeInsets.all(16.w),
                  children: [
                    // بطاقات الملخص
                    Row(
                      children: [
                        Expanded(child: _summaryCard(
                          'عمولات مستحقة',
                          '${_totalOwed.toStringAsFixed(0)} ريال',
                          Icons.account_balance_wallet,
                          Colors.red.shade700,
                        )),
                        SizedBox(width: 12.w),
                        Expanded(child: _summaryCard(
                          'إجمالي المدفوع',
                          '${_totalPaid.toStringAsFixed(0)} ريال',
                          Icons.check_circle,
                          Colors.green.shade700,
                        )),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // عنوان السجل
                    Text(
                      'سجل المعاملات',
                      style: GoogleFonts.cairo(fontSize: 18.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.h),

                    if (_transactions.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.w),
                          child: Text('لا توجد معاملات بعد', style: GoogleFonts.cairo(color: Colors.grey)),
                        ),
                      )
                    else
                      ..._transactions.map((tx) => _transactionCard(tx)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28.sp),
          SizedBox(height: 8.h),
          Text(title, style: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.grey.shade600)),
          SizedBox(height: 4.h),
          Text(value, style: GoogleFonts.cairo(fontSize: 18.sp, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _transactionCard(Map<String, dynamic> tx) {
    final isCommission = tx['type'] == 'commission';
    final date = DateFormat('yyyy/MM/dd — hh:mm a', 'ar').format(tx['createdAt'] as DateTime);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border(right: BorderSide(
          color: isCommission ? Colors.red : Colors.green,
          width: 4,
        )),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: (isCommission ? Colors.red : Colors.green).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              isCommission ? Icons.arrow_upward : Icons.arrow_downward,
              color: isCommission ? Colors.red : Colors.green,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx['note'] as String,
                  style: GoogleFonts.cairo(fontSize: 13.sp, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2.h),
                Text(date, style: GoogleFonts.cairo(fontSize: 11.sp, color: Colors.grey)),
              ],
            ),
          ),
          Text(
            '${isCommission ? '+' : '-'}${(tx['amount'] as double).toStringAsFixed(0)}',
            style: GoogleFonts.cairo(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isCommission ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
