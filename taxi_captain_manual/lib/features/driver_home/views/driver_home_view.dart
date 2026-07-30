// lib/features/driver_home/views/driver_home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../theme/app_theme.dart';

class DriverHomeView extends StatefulWidget {
  const DriverHomeView({Key? key}) : super(key: key);

  @override
  State<DriverHomeView> createState() => _DriverHomeViewState();
}

class _DriverHomeViewState extends State<DriverHomeView> {
  bool _isOnline = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Background
          const GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(15.369445, 44.191007),
              zoom: 15.0,
            ),
            myLocationEnabled: true,
            zoomControlsEnabled: false,
          ),

          // Top Header & Status Switcher
          Positioned(
            top: 50.h,
            left: 20.w,
            right: 20.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Profile Button
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.pureWhite,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.charcoalBlack.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.person_outline, color: AppTheme.charcoalBlack),
                    onPressed: () {},
                  ),
                ),
                
                // Online / Offline Toggle Badge
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isOnline = !_isOnline;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: _isOnline ? AppTheme.deepBurgundy : AppTheme.pureWhite,
                      borderRadius: BorderRadius.circular(24.r),
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
                          width: 10.w,
                          height: 10.h,
                          decoration: BoxDecoration(
                            color: _isOnline ? Colors.greenAccent : AppTheme.darkGrey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _isOnline ? 'متصل (جاهز للطلبات)' : 'غير متصل',
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: _isOnline ? AppTheme.pureWhite : AppTheme.charcoalBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Ride Request Alert Card (Simulating incoming ride request)
          Positioned(
            bottom: 30.h,
            left: 20.w,
            right: 20.w,
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.charcoalBlack.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'طلب رحلة جديد!',
                        style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.deepBurgundy,
                        ),
                      ),
                      Text(
                        '1,500 ر.ي',
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.charcoalBlack,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppTheme.deepBurgundy, size: 20),
                      SizedBox(width: 8.w),
                      Text(
                        'المسافة للعميل: 0.8 كم • الوجهة: حدة',
                        style: GoogleFonts.cairo(
                          fontSize: 13.sp,
                          color: AppTheme.darkGrey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                          ),
                          child: Text('رفض', style: GoogleFonts.cairo(color: Colors.red)),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('قبول الطلب'),
                        ),
                      ),
                    ],
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