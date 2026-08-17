import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../theme/app_theme.dart';
import '../cubit/ride_history_cubit.dart';
import '../repositories/client_ride_history_repository.dart';
import '../services/client_ride_history_service.dart';

class RideHistoryView extends StatelessWidget {
  const RideHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ClientRideHistoryCubit(ClientRideHistoryRepository(ClientRideHistoryService()))..loadHistory('today'),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: AppTheme.creamBackground,
          appBar: AppBar(
            backgroundColor: AppTheme.deepBurgundy,
            title: Text(
              'سجل رحلاتي',
              style: GoogleFonts.cairo(color: AppTheme.pureWhite),
            ),
            iconTheme: const IconThemeData(color: AppTheme.pureWhite),
            centerTitle: true,
            elevation: 0,
          ),
          body: BlocBuilder<ClientRideHistoryCubit, ClientRideHistoryState>(
            builder: (context, state) {
              if (state is ClientRideHistoryLoading) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.deepBurgundy));
              } else if (state is ClientRideHistoryError) {
                return Center(
                  child: Text(
                    state.message,
                    style: GoogleFonts.cairo(color: Colors.red, fontSize: 16.sp),
                  ),
                );
              } else if (state is ClientRideHistoryLoaded) {
                return Column(
                  children: [
                    _buildSummaryCards(state),
                    _buildFilterChips(context, state.filterType),
                    Expanded(
                      child: state.rides.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.history_toggle_off, size: 64.w, color: AppTheme.lightGrey),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'لا توجد رحلات في هذه الفترة',
                                    style: GoogleFonts.cairo(fontSize: 18.sp, color: AppTheme.darkGrey),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                              itemCount: state.rides.length,
                              itemBuilder: (context, index) {
                                final ride = state.rides[index];
                                return Card(
                                  margin: EdgeInsets.only(bottom: 12.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                                  elevation: 2,
                                  shadowColor: AppTheme.charcoalBlack.withValues(alpha: 0.1),
                                  color: AppTheme.pureWhite,
                                  child: Padding(
                                    padding: EdgeInsets.all(16.w),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              DateFormat('yyyy/MM/dd - HH:mm').format(ride.createdAt),
                                              style: GoogleFonts.cairo(color: AppTheme.darkGrey, fontSize: 12.sp),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                              decoration: BoxDecoration(
                                                color: AppTheme.deepBurgundy.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8.r),
                                              ),
                                              child: Text(
                                                '${ride.fare.toStringAsFixed(2)} ريال',
                                                style: GoogleFonts.cairo(
                                                  color: AppTheme.deepBurgundy,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          'الكابتن: ${ride.driverName ?? "غير معروف"}',
                                          style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.sp,
                                            color: AppTheme.charcoalBlack,
                                          ),
                                        ),
                                        SizedBox(height: 12.h),
                                        Row(
                                          children: [
                                            Icon(Icons.circle, color: Colors.green, size: 12.w),
                                            SizedBox(width: 8.w),
                                            Expanded(
                                              child: Text(
                                                ride.pickupAddress,
                                                style: GoogleFonts.cairo(fontSize: 14.sp),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.h),
                                        Row(
                                          children: [
                                            Icon(Icons.location_on, color: Colors.red, size: 12.w),
                                            SizedBox(width: 8.w),
                                            Expanded(
                                              child: Text(
                                                ride.destinationAddress,
                                                style: GoogleFonts.cairo(fontSize: 14.sp),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.h),
                                        Row(
                                          children: [
                                            Icon(Icons.map, color: AppTheme.darkGrey, size: 12.w),
                                            SizedBox(width: 8.w),
                                            Text(
                                              '${ride.distanceKm.toStringAsFixed(1)} كم',
                                              style: GoogleFonts.cairo(fontSize: 14.sp, color: AppTheme.darkGrey),
                                            ),
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
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(ClientRideHistoryLoaded state) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              title: 'عدد الرحلات',
              value: state.totalRides.toString(),
              icon: Icons.directions_car,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: _SummaryCard(
              title: 'المبلغ الإجمالي',
              value: '${state.totalFare.toStringAsFixed(2)} ر.س',
              icon: Icons.attach_money,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, String currentFilter) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _FilterChip(
            label: 'اليوم',
            isSelected: currentFilter == 'today',
            onTap: () => context.read<ClientRideHistoryCubit>().loadHistory('today'),
          ),
          _FilterChip(
            label: 'الأسبوع',
            isSelected: currentFilter == 'week',
            onTap: () => context.read<ClientRideHistoryCubit>().loadHistory('week'),
          ),
          _FilterChip(
            label: 'الشهر',
            isSelected: currentFilter == 'month',
            onTap: () => context.read<ClientRideHistoryCubit>().loadHistory('month'),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.charcoalBlack.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.deepBurgundy, size: 28.w),
          SizedBox(height: 8.h),
          Text(title, style: GoogleFonts.cairo(fontSize: 14.sp, color: AppTheme.darkGrey)),
          SizedBox(height: 4.h),
          Text(value, style: GoogleFonts.cairo(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppTheme.charcoalBlack)),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.deepBurgundy : AppTheme.lightGrey,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            color: isSelected ? AppTheme.pureWhite : AppTheme.charcoalBlack,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
