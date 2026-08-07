import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taxi_captain_manual/core/services/ride_service.dart';
import '../../../theme/app_theme.dart';
// استيراد ملف الـ Backend

class AvailableRidesView extends StatelessWidget {
  AvailableRidesView({Key? key}) : super(key: key);

  // تعريف كلاس الخدمة (الباك اند)
  final RideService _rideService = RideService();

  @override
  Widget build(BuildContext context) {
    // جلب معرف الكابتن الحالي بشكل آمن من فايربيس
    final String currentDriverId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.deepBurgundy,
        title: Text(
          'الرحلات المتاحة للطلبات',
          style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // زر الرجوع للخلف
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // الاستماع للرحلات التي حالتها 'pending' فقط
        stream: FirebaseFirestore.instance
            .collection('rides')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.deepBurgundy),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'لا توجد رحلات متاحة حالياً',
                style: GoogleFonts.cairo(fontSize: 16.sp, color: AppTheme.darkGrey),
              ),
            );
          }

          final rides = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final rideDoc = rides[index];
              // حماية إضافية للبيانات القادمة من فايربيس إذا كانت Map أو null
              final rideData = rideDoc.data();
              final rideId = rideDoc.id;
              
              // قراءة آمنة تماماً لأي حقل لمنع الانهيار نهائياً
              final destinationName = (rideData['destinationName'] ?? 'وجهة غير معروفة').toString();
              final price = (rideData['price'] ?? 'غير محدد').toString();

              return Container(
                margin: EdgeInsets.only(bottom: 16.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'إلى: $destinationName',
                            style: GoogleFonts.cairo(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.charcoalBlack,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'التكلفة المتوقعة: $price',
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            color: AppTheme.deepBurgundy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.deepBurgundy,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          onPressed: () async {
                            if (currentDriverId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('خطأ: لم يتم التعرف على معرف السائق', style: GoogleFonts.cairo()),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            try {
                              await _rideService.acceptRide(
                                rideId: rideId,
                                driverId: currentDriverId,
                              );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('تم قبول الرحلة بنجاح!', style: GoogleFonts.cairo()),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      e.toString().replaceAll("Exception: ", ""),
                                      style: GoogleFonts.cairo(),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(
                            'قبول الرحلة',
                            style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}