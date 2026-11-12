import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'shimmer_wrapper.dart';
import 'skeleton_elements.dart';

/// Skeleton لكشف الحساب — يحاكي: بطاقتي ملخص + عنوان + قائمة معاملات
class AccountSkeleton extends StatelessWidget {
  /// عدد بطاقات المعاملات الوهمية
  final int transactionCount;

  const AccountSkeleton({super.key, this.transactionCount = 5});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'جاري تحميل كشف الحساب',
      child: ShimmerWrapper(
        child: ExcludeSemantics(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            children: [
              // بطاقات الملخص
              Row(
                children: [
                  Expanded(child: _SummaryCardSkeleton()),
                  SizedBox(width: 12.w),
                  Expanded(child: _SummaryCardSkeleton()),
                ],
              ),
              SizedBox(height: 20.h),
              // عنوان "سجل المعاملات"
              const SkeletonLine(width: 120, height: 18),
              SizedBox(height: 12.h),
              // بطاقات المعاملات
              ...List.generate(
                transactionCount,
                (_) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: const _TransactionCardSkeleton(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          const SkeletonCircle(size: 28),
          SizedBox(height: 8.h),
          const SkeletonLine(width: 80, height: 12),
          SizedBox(height: 6.h),
          const SkeletonLine(width: 70, height: 18),
        ],
      ),
    );
  }
}

class _TransactionCardSkeleton extends StatelessWidget {
  const _TransactionCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          // أيقونة المعاملة
          SkeletonRect(width: 36, height: 36, borderRadius: 8),
          SizedBox(width: 12.w),
          // التفاصيل
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLine(width: 150, height: 13),
                SizedBox(height: 4.h),
                const SkeletonLine(width: 100, height: 11),
              ],
            ),
          ),
          // المبلغ
          const SkeletonLine(width: 50, height: 16),
        ],
      ),
    );
  }
}
