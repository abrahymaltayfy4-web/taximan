// lib/features/home/views/search_drivers_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class SearchDriversView extends StatelessWidget {
  const SearchDriversView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy driver list representing nearby drivers
    final List<Map<String, dynamic>> nearbyDrivers = [
      {
        'name': 'أحمد علي',
        'car': 'تويوتا كامري',
        'color': 'أبيض',
        'plate': 'أ ب ج 1234',
        'rating': 4.9,
        'distance': '0.5 كم',
        'pricePerKm': '500 ر.ي',
        'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      },
      {
        'name': 'خالد محمد',
        'car': 'هيونداي النترا',
        'color': 'فضي',
        'plate': 'د هـ و 5678',
        'rating': 4.8,
        'distance': '1.2 كم',
        'pricePerKm': '450 ر.ي',
        'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      appBar: AppBar(
        title: const Text('السائقون المتاحون بالقرب منك'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.charcoalBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        itemCount: nearbyDrivers.length,
        itemBuilder: (context, index) {
          final driver = nearbyDrivers[index];
          return Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.charcoalBlack.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Driver Avatar
                CircleAvatar(
                  radius: 32.r,
                  backgroundColor: AppTheme.lightGrey,
                  backgroundImage: NetworkImage(driver['image']),
                ),
                SizedBox(width: 16.w),
                // Driver Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            driver['name'],
                            style: GoogleFonts.cairo(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.charcoalBlack,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16.sp),
                              SizedBox(width: 4.w),
                              Text(
                                driver['rating'].toString(),
                                style: GoogleFonts.cairo(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.charcoalBlack,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${driver['car']} • ${driver['color']} • ${driver['plate']}',
                        style: GoogleFonts.cairo(
                          fontSize: 12.sp,
                          color: AppTheme.darkGrey,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المسافة: ${driver['distance']}',
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.deepBurgundy,
                            ),
                          ),
                          Text(
                            driver['pricePerKm'],
                            style: GoogleFonts.cairo(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.charcoalBlack,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          boxShadow: [
            BoxShadow(
              color: AppTheme.charcoalBlack.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            // TODO: Request Ride
          },
          child: const Text('طلب رحلة فورية (لجميع السائقين)'),
        ),
      ),
    );
  }
}