import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../cubit/ride_history_cubit.dart';

class RideHistoryView extends StatelessWidget {
  const RideHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RideHistoryCubit()..loadRideHistory('اليوم'),
      child: Scaffold(
        backgroundColor: AppTheme.creamBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.deepBurgundy,
          title: Text('سجل الرحلات', style: GoogleFonts.cairo(color: AppTheme.pureWhite, fontWeight: FontWeight.bold)),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppTheme.pureWhite),
        ),
        body: Directionality(
          textDirection: ui.TextDirection.rtl,
          child: BlocBuilder<RideHistoryCubit, RideHistoryState>(
            builder: (context, state) {
              if (state is RideHistoryLoading) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.deepBurgundy));
              } else if (state is RideHistoryError) {
                return Center(child: Text(state.message, style: GoogleFonts.cairo(color: Colors.red)));
              } else if (state is RideHistoryLoaded) {
                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      color: AppTheme.pureWhite,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildSummaryCard(Icons.directions_car, state.totalRides.toString(), 'الرحلات'),
                              _buildSummaryCard(Icons.attach_money, '${state.totalFare.toStringAsFixed(1)} ر.س', 'الأرباح'),
                              _buildSummaryCard(Icons.straighten, '${state.totalDistance.toStringAsFixed(1)} كم', 'المسافة'),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildFilterChip(context, 'اليوم', state.filterType),
                              SizedBox(width: 8.w),
                              _buildFilterChip(context, 'الأسبوع', state.filterType),
                              SizedBox(width: 8.w),
                              _buildFilterChip(context, 'الشهر', state.filterType),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: state.rides.isEmpty
                          ? Center(child: Text('لا توجد رحلات', style: GoogleFonts.cairo(fontSize: 18.sp)))
                          : ListView.builder(
                              padding: EdgeInsets.all(16.w),
                              itemCount: state.rides.length,
                              itemBuilder: (context, index) {
                                final ride = state.rides[index];
                                final date = DateFormat('yyyy/MM/dd hh:mm a').format(ride.createdAt);
                                return Card(
                                  color: AppTheme.pureWhite,
                                  elevation: 2,
                                  margin: EdgeInsets.only(bottom: 12.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.w),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(date, style: GoogleFonts.cairo(color: AppTheme.darkGrey, fontSize: 12.sp)),
                                            Text('${ride.fare.toStringAsFixed(2)} ر.س', style: GoogleFonts.cairo(color: AppTheme.deepBurgundy, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(ride.customerName, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                                        const Divider(),
                                        Row(
                                          children: [
                                            Icon(Icons.my_location, size: 16.w, color: Colors.green),
                                            SizedBox(width: 4.w),
                                            Expanded(child: Text(ride.pickupAddress, style: GoogleFonts.cairo(fontSize: 12.sp), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                          ],
                                        ),
                                        SizedBox(height: 4.h),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on, size: 16.w, color: Colors.red),
                                            SizedBox(width: 4.w),
                                            Expanded(child: Text(ride.destinationAddress, style: GoogleFonts.cairo(fontSize: 12.sp), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(IconData icon, String value, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: AppTheme.lightGrey,
          radius: 24.r,
          child: Icon(icon, color: AppTheme.deepBurgundy),
        ),
        SizedBox(height: 8.h),
        Text(value, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16.sp)),
        Text(label, style: GoogleFonts.cairo(color: AppTheme.darkGrey, fontSize: 12.sp)),
      ],
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String currentFilter) {
    final isSelected = label == currentFilter;
    return ChoiceChip(
      label: Text(label, style: GoogleFonts.cairo(color: isSelected ? AppTheme.pureWhite : AppTheme.charcoalBlack)),
      selected: isSelected,
      selectedColor: AppTheme.deepBurgundy,
      backgroundColor: AppTheme.lightGrey,
      onSelected: (_) {
        context.read<RideHistoryCubit>().loadRideHistory(label);
      },
    );
  }
}
