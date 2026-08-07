import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../theme/app_theme.dart';
import '../cubit/ride_cubit.dart';

class WaitingForDriverView extends StatelessWidget {
  final String rideId;
  final String destinationName;

  const WaitingForDriverView({
    Key? key,
    required this.rideId,
    required this.destinationName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RideCubit(),
      child: WillPopScope(
        onWillPop: () async => false, // منع الرجوع للخلف أثناء البحث عن كابتن
        child: Scaffold(
          backgroundColor: AppTheme.creamBackground,
          body: Builder(
            builder: (context) {
              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: context.read<RideCubit>().streamRideStatus(rideId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.deepBurgundy));
                  }

                  if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
                    return Center(
                      child: Text('جاري جلب تفاصيل الرحلة...', style: GoogleFonts.cairo(fontSize: 16.sp)),
                    );
                  }

                  final rideData = snapshot.data!.data();
                  final status = rideData?['status'] ?? 'pending';

                  if (status == 'accepted') {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('تم قبول الرحلة من قبل الكابتن!', style: GoogleFonts.cairo()),
                          backgroundColor: Colors.green,
                        ),
                      );
                    });
                  }

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120.w,
                          height: 120.h,
                          decoration: BoxDecoration(
                            color: AppTheme.deepBurgundy.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 70.w,
                              height: 70.h,
                              child: const CircularProgressIndicator(
                                color: AppTheme.deepBurgundy,
                                strokeWidth: 4,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40.h),
                        
                        Text(
                          status == 'pending' ? 'جاري البحث عن كابتن قريب منك...' : 'تم قبول الرحلة، الكابتن في الطريق!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.charcoalBlack,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        Container(
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
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.red),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      'الوجهة: $destinationName',
                                      style: GoogleFonts.cairo(fontSize: 14.sp, color: AppTheme.charcoalBlack),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12.h),
                              const Divider(),
                              SizedBox(height: 12.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('حالة الطلب:', style: GoogleFonts.cairo(color: AppTheme.darkGrey)),
                                  Text(
                                    status == 'pending' ? 'قيد الانتظار' : 'مقبولة',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      color: status == 'pending' ? Colors.orange : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40.h),

                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 32.w),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          onPressed: () async {
                            await FirebaseFirestore.instance.collection('rides').doc(rideId).update({'status': 'cancelled'});
                            Navigator.pop(context);
                          },
                          child: Text(
                            'إلغاء الطلب',
                            style: GoogleFonts.cairo(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16.sp),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}