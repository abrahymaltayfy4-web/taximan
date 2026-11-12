import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// أشكال Skeleton الأساسية — بلوكات رمادية تحاكي المحتوى الحقيقي
/// تتبع مبدأ Single Responsibility: كل عنصر مسؤول عن شكل واحد فقط

/// خط نصي وهمي — يحاكي سطر نص
class SkeletonLine extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLine({
    super.key,
    required this.width,
    this.height = 14,
    this.borderRadius = 6,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width.w,
      height: height.h,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E4DF),
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
    );
  }
}

/// دائرة وهمية — تحاكي صورة بروفايل أو أيقونة
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E4DF),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// مستطيل وهمي — يحاكي بطاقة أو خريطة أو صورة
class SkeletonRect extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const SkeletonRect({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width?.w,
      height: height.h,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E4DF),
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
    );
  }
}
