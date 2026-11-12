import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'shimmer_wrapper.dart';
import 'skeleton_elements.dart';
import 'map_skeleton.dart';

/// Skeleton لشاشة رحلة نشطة — يحاكي: خريطة + شريط حالة + بطاقة تفاصيل
class ActiveRideSkeleton extends StatelessWidget {
  const ActiveRideSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'جاري تحميل بيانات الرحلة',
      child: Stack(
        children: [
          // الخريطة
          const MapSkeleton(),
          // شريط الحالة العلوي
          Positioned(
            top: 50.h, left: 20.w, right: 20.w,
            child: ShimmerWrapper(
              child: ExcludeSemantics(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SkeletonCircle(size: 10),
                      SizedBox(width: 10.w),
                      const SkeletonLine(width: 160, height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // بطاقة التفاصيل السفلية
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: ShimmerWrapper(
              child: ExcludeSemantics(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F6F0),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                  ),
                  padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 32.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // مقبض السحب
                      Container(
                        width: 40.w, height: 4.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E2DC),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // معلومات السائق
                      Row(
                        children: [
                          const SkeletonCircle(size: 48),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SkeletonLine(width: 120, height: 18),
                                SizedBox(height: 6.h),
                                const SkeletonLine(width: 180, height: 13),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      const Divider(color: Color(0xFFE5E2DC)),
                      SizedBox(height: 16.h),
                      // السعر والمسافة
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SkeletonRect(width: 120, height: 40, borderRadius: 12),
                          SkeletonRect(width: 100, height: 40, borderRadius: 12),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
