import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'shimmer_wrapper.dart';
import 'skeleton_elements.dart';

/// Skeleton لبوابة الجلسة — يحاكي: شعار التطبيق + شريط تحميل
class SessionSkeleton extends StatelessWidget {
  const SessionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'جاري التحقق من الجلسة',
      child: ShimmerWrapper(
        child: ExcludeSemantics(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // أيقونة التطبيق
                const SkeletonCircle(size: 80),
                SizedBox(height: 24.h),
                // اسم التطبيق
                const SkeletonLine(width: 140, height: 22),
                SizedBox(height: 32.h),
                // شريط تحميل وهمي
                SkeletonRect(width: 200, height: 4, borderRadius: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
