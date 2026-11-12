import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'skeleton_elements.dart';

/// Skeleton لبطاقة رحلة واحدة — يحاكي: تاريخ + سعر + اسم سائق + عناوين
class RideCardSkeleton extends StatelessWidget {
  const RideCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // التاريخ + السعر
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SkeletonLine(width: 120, height: 12),
                SkeletonRect(width: 80, height: 28, borderRadius: 8),
              ],
            ),
            SizedBox(height: 10.h),
            // اسم السائق
            const SkeletonLine(width: 150, height: 16),
            SizedBox(height: 14.h),
            // عنوان البداية
            Row(
              children: [
                const SkeletonCircle(size: 12),
                SizedBox(width: 8.w),
                const Expanded(child: SkeletonLine(width: double.infinity)),
              ],
            ),
            SizedBox(height: 10.h),
            // عنوان الوصول
            Row(
              children: [
                const SkeletonCircle(size: 12),
                SizedBox(width: 8.w),
                const Expanded(child: SkeletonLine(width: double.infinity)),
              ],
            ),
            SizedBox(height: 10.h),
            // المسافة
            Row(
              children: [
                const SkeletonCircle(size: 12),
                SizedBox(width: 8.w),
                const SkeletonLine(width: 60),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
