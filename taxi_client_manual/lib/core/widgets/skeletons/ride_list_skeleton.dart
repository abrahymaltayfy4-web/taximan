import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'shimmer_wrapper.dart';
import 'skeleton_elements.dart';
import 'ride_card_skeleton.dart';

/// Skeleton لقائمة سجل الرحلات — يحاكي: بطاقات ملخص + فلتر + 4 بطاقات رحلات
class RideListSkeleton extends StatelessWidget {
  /// عدد بطاقات الرحلات الوهمية
  final int cardCount;

  const RideListSkeleton({super.key, this.cardCount = 4});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'جاري تحميل سجل الرحلات',
      child: ShimmerWrapper(
        child: ExcludeSemantics(
          child: Column(
            children: [
              // بطاقات الملخص العلوية
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Expanded(child: _SummaryCardSkeleton()),
                    SizedBox(width: 16.w),
                    Expanded(child: _SummaryCardSkeleton()),
                  ],
                ),
              ),
              // فلتر Chips
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SkeletonRect(width: 70, height: 34, borderRadius: 20),
                    SkeletonRect(width: 70, height: 34, borderRadius: 20),
                    SkeletonRect(width: 70, height: 34, borderRadius: 20),
                  ],
                ),
              ),
              // بطاقات الرحلات
              Expanded(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: cardCount,
                  itemBuilder: (_, __) => const RideCardSkeleton(),
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
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          const SkeletonCircle(size: 28),
          SizedBox(height: 8.h),
          const SkeletonLine(width: 80, height: 12),
          SizedBox(height: 6.h),
          const SkeletonLine(width: 60, height: 18),
        ],
      ),
    );
  }
}
