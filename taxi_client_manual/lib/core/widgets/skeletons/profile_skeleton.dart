import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'shimmer_wrapper.dart';
import 'skeleton_elements.dart';

/// Skeleton لصفحة الملف الشخصي — يحاكي: صورة دائرية + اسم + حقول بيانات
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'جاري تحميل الملف الشخصي',
      child: ShimmerWrapper(
        child: ExcludeSemantics(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Column(
              children: [
                // صورة البروفايل
                const SkeletonCircle(size: 90),
                SizedBox(height: 20.h),
                // الاسم
                const SkeletonLine(width: 160, height: 20),
                SizedBox(height: 12.h),
                // البريد
                const SkeletonLine(width: 200, height: 14),
                SizedBox(height: 32.h),
                // حقول البيانات
                _buildFieldSkeleton(),
                SizedBox(height: 16.h),
                _buildFieldSkeleton(),
                SizedBox(height: 16.h),
                _buildFieldSkeleton(),
                SizedBox(height: 32.h),
                // أزرار
                SkeletonRect(height: 48, borderRadius: 12),
                SizedBox(height: 12.h),
                SkeletonRect(height: 48, borderRadius: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldSkeleton() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          const SkeletonCircle(size: 24),
          SizedBox(width: 12.w),
          const Expanded(child: SkeletonLine(width: double.infinity, height: 16)),
        ],
      ),
    );
  }
}
