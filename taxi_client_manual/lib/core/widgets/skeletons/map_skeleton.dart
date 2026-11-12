import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'shimmer_wrapper.dart';

/// Skeleton للخريطة — يحاكي خلفية خريطة مع أيقونات markers وهمية
class MapSkeleton extends StatelessWidget {
  /// ارتفاع منطقة الخريطة
  final double? height;

  const MapSkeleton({super.key, this.height});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mapColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFECE9E3);
    final roadColor = isDark ? const Color(0xFF2D2D2D) : const Color(0xFFD9D5CE);

    return Semantics(
      label: 'جاري تحميل الخريطة',
      child: ShimmerWrapper(
        child: ExcludeSemantics(
          child: Container(
            height: height?.h,
            decoration: BoxDecoration(
              color: mapColor,
              borderRadius: height != null ? BorderRadius.circular(16.r) : null,
            ),
            child: Stack(
              children: [
                // خطوط تحاكي الشوارع
                Positioned(
                  top: 80.h, left: 0, right: 0,
                  child: Container(height: 3.h, color: roadColor),
                ),
                Positioned(
                  top: 160.h, left: 0, right: 0,
                  child: Container(height: 2.h, color: roadColor),
                ),
                Positioned(
                  top: 0, bottom: 0, left: 120.w,
                  child: Container(width: 2.w, color: roadColor),
                ),
                Positioned(
                  top: 0, bottom: 0, right: 80.w,
                  child: Container(width: 3.w, color: roadColor),
                ),
                // أيقونة marker وهمية في الوسط
                Center(
                  child: Icon(
                    Icons.location_on,
                    size: 40.w,
                    color: isDark
                        ? Colors.grey.shade700
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
