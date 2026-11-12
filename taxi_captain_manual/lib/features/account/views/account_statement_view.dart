import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/widgets/skeletons/skeletons.dart';
import '../cubit/account_cubit.dart';

class AccountStatementView extends StatelessWidget {
  const AccountStatementView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccountCubit>()..loadAccount(),
      child: const _AccountStatementBody(),
    );
  }
}

class _AccountStatementBody extends StatelessWidget {
  const _AccountStatementBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      appBar: AppBar(
        title: Text(
          'كشف الحساب',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.deepBurgundy,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<AccountCubit, AccountState>(
        builder: (context, state) {
          if (state is AccountLoading || state is AccountInitial) {
            return const AccountSkeleton();
          }
          if (state is AccountError) {
            return Center(
              child: Text(state.message, style: GoogleFonts.cairo()),
            );
          }
          if (state is AccountLoaded) {
            return _buildContent(context, state.data);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AccountData data) {
    return RefreshIndicator(
      onRefresh: () => context.read<AccountCubit>().loadAccount(),
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // بطاقات الملخص
          Row(
            children: [
              Expanded(
                child: _summaryCard(
                  'عمولات مستحقة',
                  '${data.totalCommissionOwed.toStringAsFixed(0)} ريال',
                  Icons.account_balance_wallet,
                  Colors.red.shade700,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _summaryCard(
                  'إجمالي المدفوع',
                  '${data.totalPaid.toStringAsFixed(0)} ريال',
                  Icons.check_circle,
                  Colors.green.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          Text(
            'سجل المعاملات',
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),

          if (data.transactions.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(40.w),
                child: Text(
                  'لا توجد معاملات بعد',
                  style: GoogleFonts.cairo(color: Colors.grey),
                ),
              ),
            )
          else
            ...data.transactions.asMap().entries.map((entry) {
              final index = entry.key;
              final tx = entry.value;
              return _transactionCard(tx)
                  .animate(delay: (index < 8 ? index * 80 : 0).ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.2, duration: 300.ms);
            }),
        ],
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28.sp),
          SizedBox(height: 8.h),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.cairo(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionCard(Map<String, dynamic> tx) {
    final isCommission = tx['type'] == 'commission';
    final date = DateFormat(
      'yyyy/MM/dd — hh:mm a',
      'ar',
    ).format(tx['createdAt'] as DateTime);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border(
          right: BorderSide(
            color: isCommission ? Colors.red : Colors.green,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: (isCommission ? Colors.red : Colors.green).withValues(
                alpha: 0.1,
              ),
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
                  style: GoogleFonts.cairo(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  date,
                  style: GoogleFonts.cairo(fontSize: 11.sp, color: Colors.grey),
                ),
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
