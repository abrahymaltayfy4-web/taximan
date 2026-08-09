import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/ride_service.dart';
import '../../../repositories/ride_repository.dart';
import '../../../theme/app_theme.dart';
import '../cubit/ride_cubit.dart';
import 'active_ride_view.dart';

class AvailableRidesView extends StatelessWidget {
  const AvailableRidesView({super.key});

  @override
  Widget build(BuildContext context) {
    final driverId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return BlocProvider(
      create: (context) => CaptainRideCubit(RideRepository(RideService()))..listenToPendingRides(),
      child: Scaffold(
        backgroundColor: AppTheme.creamBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.deepBurgundy,
          title: Text(
            'الرحلات المتاحة',
            style: GoogleFonts.cairo(
              color: AppTheme.pureWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppTheme.pureWhite),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocConsumer<CaptainRideCubit, CaptainRideState>(
            listener: (context, state) {
              if (state is CaptainActiveRide) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => ActiveRideView(rideId: state.ride.rideId),
                  ),
                );
              } else if (state is CaptainRideError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message, style: GoogleFonts.cairo())),
                );
              }
            },
            builder: (context, state) {
              if (state is CaptainRideLoading) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.deepBurgundy));
              } else if (state is CaptainPendingRidesEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 80.w, color: AppTheme.darkGrey),
                      SizedBox(height: 16.h),
                      Text(
                        'لا توجد رحلات متاحة حالياً',
                        style: GoogleFonts.cairo(
                          fontSize: 20.sp,
                          color: AppTheme.charcoalBlack,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is CaptainPendingRidesLoaded) {
                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: state.rides.length,
                  itemBuilder: (context, index) {
                    final ride = state.rides[index];
                    return Card(
                      elevation: 4,
                      shadowColor: AppTheme.charcoalBlack.withValues(alpha: 0.1),
                      color: AppTheme.pureWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      margin: EdgeInsets.only(bottom: 16.h),
                      child: Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, color: AppTheme.deepBurgundy, size: 24.w),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    ride.customerName,
                                    style: GoogleFonts.cairo(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.charcoalBlack,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: AppTheme.lightGrey,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    '${ride.distanceKm.toStringAsFixed(1)} كم',
                                    style: GoogleFonts.cairo(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.deepBurgundy,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: AppTheme.lightGrey),
                            Row(
                              children: [
                                Icon(Icons.my_location, color: Colors.green, size: 20.w),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    ride.pickupAddress,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14.sp,
                                      color: AppTheme.darkGrey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.red, size: 20.w),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    ride.destinationAddress,
                                    style: GoogleFonts.cairo(
                                      fontSize: 14.sp,
                                      color: AppTheme.darkGrey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.deepBurgundy,
                                  foregroundColor: AppTheme.pureWhite,
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                ),
                                onPressed: () {
                                  context.read<CaptainRideCubit>().acceptRide(ride.rideId, driverId);
                                },
                                child: Text(
                                  'قبول الرحلة',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}