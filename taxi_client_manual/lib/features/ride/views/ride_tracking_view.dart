// lib/features/ride/views/ride_tracking_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class RideTrackingView extends StatelessWidget {
  const RideTrackingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      body: Stack(
        children: [
          // Background simulation for Google Map tracking
          Container(
            color: AppTheme.lightGrey,
            child: Center(
              child: Text(
                'الخريطة - تتبع الرحلة الحيّة',
                style: GoogleFonts.cairo(fontSize: 16.sp, color: AppTheme.darkGrey),
              ),
            ),
          ),

          // Top Header status badge
          Positioned(
            top: 50.h,
            left: 20.w,
            right: 20.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.charcoalBlack.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 12.w,
                    height: 12.h,
                    decoration: const BoxDecoration(
                      color: AppTheme.deepBurgundy,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'الكابتن في طريقه إليك (الوصول خلال 3 دقائق)',
                    style: GoogleFonts.cairo(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.charcoalBlack,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Ride Details Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28.r),
                  topRight: Radius.circular(28.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.charcoalBlack.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Driver Info Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30.r,
                        backgroundColor: AppTheme.lightGrey,
                        backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150'),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'أحمد علي',
                              style: GoogleFonts.cairo(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.charcoalBlack,
                              ),
                            ),
                            Text(
                              'تويوتا كامري • أبيض • أ ب ج 1234',
                              style: GoogleFonts.cairo(
                                fontSize: 12.sp,
                                color: AppTheme.darkGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Call Button
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.creamBackground,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.phone_outlined, color: AppTheme.deepBurgundy),
                          onPressed: () {
                            // TODO: Call driver
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  const Divider(color: AppTheme.lightGrey),
                  SizedBox(height: 16.h),

                  // Fare & Distance details
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'التكلفة الإجمالية المتوقعة',
                        style: GoogleFonts.cairo(fontSize: 14.sp, color: AppTheme.darkGrey),
                      ),
                      Text(
                        '1,500 ر.ي',
                        style: GoogleFonts.cairo(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppTheme.deepBurgundy),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Cancel Ride Button
                  OutlinedButton(
                    onPressed: () {
                      // TODO: Cancel Ride
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50.h),
                      side: const BorderSide(color: AppTheme.deepBurgundy),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
                    child: Text(
                      'إلغاء الرحلة',
                      style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppTheme.deepBurgundy),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}