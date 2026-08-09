// lib/features/ride/views/ride_tracking_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/services/directions_service.dart';
import '../../../theme/app_theme.dart';
import '../../home/cubit/ride_cubit.dart';
import '../../home/cubit/ride_state.dart';

class RideTrackingView extends StatefulWidget {
  final String rideId;

  const RideTrackingView({Key? key, required this.rideId}) : super(key: key);

  @override
  State<RideTrackingView> createState() => _RideTrackingViewState();
}

class _RideTrackingViewState extends State<RideTrackingView>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  bool _routeDrawn = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _drawRoute(LatLng pickup, LatLng destination) async {
    if (_routeDrawn) return;
    final data = await DirectionsService().getDirections(
      origin: pickup,
      destination: destination,
    );
    if (data != null && mounted) {
      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: data['polylineCoordinates'],
            color: AppTheme.deepBurgundy,
            width: 5,
          ),
        };
        _routeDrawn = true;
      });
      // ضبط الكاميرا لتشمل كل المسار
      if (data['polylineCoordinates'].isNotEmpty) {
        final bounds = _calculateBounds(data['polylineCoordinates']);
        _mapController
            ?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
      }
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;
    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RideCubit()..listenToRideStatus(widget.rideId),
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: AppTheme.creamBackground,
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: BlocConsumer<RideCubit, RideState>(
              listener: (context, state) {
                if (state is RideCancelled) {
                  Navigator.of(context)
                      .popUntil((route) => route.isFirst);
                }
                if (state is RideActive && !_routeDrawn) {
                  final pickup = LatLng(
                    state.ride.pickupLocation.latitude,
                    state.ride.pickupLocation.longitude,
                  );
                  final dest = LatLng(
                    state.ride.destinationLocation.latitude,
                    state.ride.destinationLocation.longitude,
                  );
                  _drawRoute(pickup, dest);
                }
              },
              builder: (context, state) {
                if (state is RidePending) {
                  return _buildPendingView(context);
                } else if (state is RideActive) {
                  return _buildActiveView(context, state);
                } else if (state is RideCompleted) {
                  return _buildCompletedView(context, state);
                } else if (state is RideError) {
                  return _buildErrorView(context, state.message);
                }
                return Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.deepBurgundy,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ───────────────── شاشة الانتظار (Pending) ─────────────────
  Widget _buildPendingView(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الأيقونة المتحركة
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.15),
                    child: Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.deepBurgundy
                            .withValues(alpha: 0.1),
                      ),
                      child: Center(
                        child: Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.deepBurgundy
                                .withValues(alpha: 0.2),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.local_taxi,
                              size: 40.w,
                              color: AppTheme.deepBurgundy,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 40.h),

              Text(
                'جاري البحث عن كابتن قريب منك...',
                style: GoogleFonts.cairo(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.charcoalBlack,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12.h),

              Text(
                'يرجى الانتظار، سيتم إشعارك فور قبول الكابتن',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: const Color(0xFF555555),
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 32.h),

              SizedBox(
                width: 200.w,
                child: LinearProgressIndicator(
                  backgroundColor:
                      AppTheme.deepBurgundy.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.deepBurgundy),
                  minHeight: 3,
                ),
              ),

              SizedBox(height: 48.h),

              // زر إلغاء الطلب
              OutlinedButton.icon(
                onPressed: () {
                  context.read<RideCubit>().cancelRide(widget.rideId);
                },
                icon: const Icon(Icons.close, color: Colors.red),
                label: Text(
                  'إلغاء الطلب',
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    color: Colors.red,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: EdgeInsets.symmetric(
                      horizontal: 32.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────── شاشة التتبع النشطة (Active) ─────────────────
  Widget _buildActiveView(BuildContext context, RideActive state) {
    final ride = state.ride;
    final pickup = LatLng(
      ride.pickupLocation.latitude,
      ride.pickupLocation.longitude,
    );
    final destination = LatLng(
      ride.destinationLocation.latitude,
      ride.destinationLocation.longitude,
    );

    // بناء الماركرز
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('pickup'),
        position: pickup,
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'نقطة الانطلاق',
          snippet: ride.pickupAddress,
        ),
      ),
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'الوجهة',
          snippet: ride.destinationAddress,
        ),
      ),
    };

    // إضافة ماركر السائق
    if (state.driverLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: LatLng(
            state.driverLocation!.latitude,
            state.driverLocation!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueViolet),
          infoWindow: InfoWindow(
            title: ride.driverName ?? 'الكابتن',
          ),
        ),
      );
    }

    // نص الحالة
    String statusText;
    IconData statusIcon;
    Color statusColor;
    switch (ride.status) {
      case 'accepted':
        statusText = 'الكابتن في طريقه إليك';
        statusIcon = Icons.directions_car;
        statusColor = Colors.amber.shade700;
        break;
      case 'driver_arrived':
        statusText = 'الكابتن وصل لموقعك';
        statusIcon = Icons.place;
        statusColor = Colors.green;
        break;
      case 'started':
        statusText = 'الرحلة جارية';
        statusIcon = Icons.navigation;
        statusColor = AppTheme.deepBurgundy;
        break;
      default:
        statusText = 'جاري التحميل...';
        statusIcon = Icons.hourglass_bottom;
        statusColor = const Color(0xFF555555);
    }

    return Stack(
      children: [
        // الخريطة
        GoogleMap(
          initialCameraPosition: CameraPosition(target: pickup, zoom: 14),
          markers: markers,
          polylines: _polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
          },
        ),

        // شريط الحالة العلوي
        Positioned(
          top: 50.h,
          left: 20.w,
          right: 20.w,
          child: Container(
            padding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10.w,
                  height: 10.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                  ),
                ),
                SizedBox(width: 10.w),
                Icon(statusIcon, color: statusColor, size: 22.w),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    statusText,
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.charcoalBlack,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // بطاقة معلومات السائق بالأسفل
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.creamBackground,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(28.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 32.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // مقبض السحب
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E2DC),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(height: 16.h),

                // معلومات السائق
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24.r,
                      backgroundColor: AppTheme.deepBurgundy
                          .withValues(alpha: 0.1),
                      child: Icon(
                        Icons.person,
                        color: AppTheme.deepBurgundy,
                        size: 28.w,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.driverName ?? 'الكابتن',
                            style: GoogleFonts.cairo(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.charcoalBlack,
                            ),
                          ),
                          if (ride.driverCarModel != null)
                            Text(
                              '${ride.driverCarModel} • ${ride.driverCarPlate ?? ''}',
                              style: GoogleFonts.cairo(
                                fontSize: 13.sp,
                                color: const Color(0xFF555555),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),
                Divider(
                    color: const Color(0xFFE5E2DC), height: 1),
                SizedBox(height: 16.h),

                // السعر والمسافة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoChip(
                      Icons.attach_money,
                      '${ride.fare.toStringAsFixed(0)} ريال',
                      AppTheme.deepBurgundy,
                    ),
                    _buildInfoChip(
                      Icons.straighten,
                      '${ride.distanceKm.toStringAsFixed(1)} كم',
                      AppTheme.charcoalBlack,
                    ),
                  ],
                ),

                // زر إلغاء الرحلة (فقط عند القبول)
                if (ride.status == 'accepted') ...[
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        context
                            .read<RideCubit>()
                            .cancelRide(widget.rideId);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'إلغاء الرحلة',
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18.w, color: color),
          SizedBox(width: 6.w),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────── شاشة الإكمال (Completed) ─────────────────
  Widget _buildCompletedView(BuildContext context, RideCompleted state) {
    final ride = state.ride;
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة النجاح
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Icon(
                    Icons.check_circle,
                    size: 60.w,
                    color: Colors.green,
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              Text(
                'تمت الرحلة بنجاح!',
                style: GoogleFonts.cairo(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.charcoalBlack,
                ),
              ),

              SizedBox(height: 32.h),

              // بطاقة الملخص
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                        'الكابتن', ride.driverName ?? '-'),
                    SizedBox(height: 12.h),
                    _buildSummaryRow('السيارة',
                        '${ride.driverCarModel ?? '-'} ${ride.driverCarPlate ?? ''}'),
                    SizedBox(height: 12.h),
                    Divider(color: const Color(0xFFE5E2DC)),
                    SizedBox(height: 12.h),
                    _buildSummaryRow('المسافة',
                        '${ride.distanceKm.toStringAsFixed(1)} كم'),
                    SizedBox(height: 12.h),
                    _buildSummaryRow(
                      'التكلفة',
                      '${ride.fare.toStringAsFixed(0)} ريال',
                      valueColor: AppTheme.deepBurgundy,
                      isBold: true,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),

              // زر العودة
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.deepBurgundy,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'العودة للرئيسية',
                    style: GoogleFonts.cairo(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14.sp,
            color: const Color(0xFF555555),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: isBold ? 18.sp : 14.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppTheme.charcoalBlack,
          ),
        ),
      ],
    );
  }

  // ───────────────── شاشة الخطأ ─────────────────
  Widget _buildErrorView(BuildContext context, String message) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60.w, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              message,
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepBurgundy,
                foregroundColor: Colors.white,
              ),
              child: Text('العودة', style: GoogleFonts.cairo()),
            ),
          ],
        ),
      ),
    );
  }
}