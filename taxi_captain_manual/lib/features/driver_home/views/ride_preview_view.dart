// lib/features/driver_home/views/ride_preview_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../cubit/ride_map_cubit.dart';
import '../cubit/ride_map_state.dart';
import '../../rides/domain/entities/ride_entity.dart';

class RidePreviewView extends StatefulWidget {
  final RideEntity ride;
  final VoidCallback onAccept;

  const RidePreviewView({
    super.key,
    required this.ride,
    required this.onAccept,
  });

  @override
  State<RidePreviewView> createState() => _RidePreviewViewState();
}

class _RidePreviewViewState extends State<RidePreviewView> {
  GoogleMapController? _mapController;
  List<LatLng>? _lastAnimatedRoute;

  LatLng get _pickup => LatLng(
        widget.ride.pickupLocation.latitude,
        widget.ride.pickupLocation.longitude,
      );

  LatLng get _destination => LatLng(
        widget.ride.destinationLocation.latitude,
        widget.ride.destinationLocation.longitude,
      );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RideMapCubit>()..loadPreviewRoute(_pickup, _destination),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: BlocBuilder<RideMapCubit, RideMapState>(
            builder: (context, mapState) {
              // بناء Markers من البيانات
              final markers = <Marker>{
                Marker(
                  markerId: const MarkerId('pickup'),
                  position: _pickup,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                  infoWindow: InfoWindow(
                    title: 'نقطة الانطلاق',
                    snippet: widget.ride.pickupAddress,
                  ),
                ),
                Marker(
                  markerId: const MarkerId('destination'),
                  position: _destination,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  infoWindow: InfoWindow(
                    title: 'وجهة الوصول',
                    snippet: widget.ride.destinationAddress,
                  ),
                ),
                if (mapState.driverPosition != null)
                  Marker(
                    markerId: const MarkerId('driver'),
                    position: mapState.driverPosition!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                    infoWindow: const InfoWindow(title: 'موقعك'),
                  ),
              };

              // بناء Polylines من البيانات
              final polylines = <Polyline>{
                if (mapState.routePoints.isNotEmpty)
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: mapState.routePoints,
                    color: AppTheme.deepBurgundy,
                    width: 5,
                  ),
              };

              // ضبط الكاميرا عند تحميل المسار — مرة واحدة فقط
              if (mapState.routePoints.isNotEmpty && _mapController != null &&
                  !identical(_lastAnimatedRoute, mapState.routePoints)) {
                _lastAnimatedRoute = mapState.routePoints;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final bounds = _getBounds(mapState.routePoints);
                  _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
                });
              }

              return Stack(
                children: [
                  // الخريطة
                  GoogleMap(
                    initialCameraPosition: CameraPosition(target: _pickup, zoom: 13),
                    markers: markers,
                    polylines: polylines,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    onMapCreated: (controller) => _mapController = controller,
                  ),

                  // زر الرجوع
                  Positioned(
                    top: 50.h, right: 16.w,
                    child: CircleAvatar(
                      backgroundColor: AppTheme.pureWhite,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.charcoalBlack),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  // بطاقة تفاصيل الرحلة السفلية
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: AppTheme.creamBackground,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 20, offset: const Offset(0, -5)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // اسم العميل والمسافة
                          Row(children: [
                            CircleAvatar(
                              radius: 24.r,
                              backgroundColor: AppTheme.deepBurgundy.withValues(alpha: 0.1),
                              child: Icon(Icons.person, color: AppTheme.deepBurgundy, size: 28.sp),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.ride.customerName, style: GoogleFonts.cairo(
                                      fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppTheme.charcoalBlack)),
                                  if (mapState.distanceText != null && mapState.durationText != null)
                                    Text('${mapState.distanceText} • ${mapState.durationText}',
                                        style: GoogleFonts.cairo(fontSize: 14.sp, color: AppTheme.darkGrey))
                                  else
                                    Text('${widget.ride.distanceKm.toStringAsFixed(1)} كم',
                                        style: GoogleFonts.cairo(fontSize: 14.sp, color: AppTheme.darkGrey)),
                                ],
                              ),
                            ),
                          ]),
                          SizedBox(height: 16.h),

                          // نقطة البداية
                          Row(children: [
                            Container(width: 12.w, height: 12.w,
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green)),
                            SizedBox(width: 12.w),
                            Expanded(child: Text(widget.ride.pickupAddress,
                                style: GoogleFonts.cairo(fontSize: 14.sp), maxLines: 2, overflow: TextOverflow.ellipsis)),
                          ]),
                          SizedBox(height: 8.h),

                          // نقطة الوصول
                          Row(children: [
                            Container(width: 12.w, height: 12.w,
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red)),
                            SizedBox(width: 12.w),
                            Expanded(child: Text(widget.ride.destinationAddress,
                                style: GoogleFonts.cairo(fontSize: 14.sp), maxLines: 2, overflow: TextOverflow.ellipsis)),
                          ]),
                          SizedBox(height: 20.h),

                          // أزرار القبول والرفض
                          Row(children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppTheme.darkGrey),
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                ),
                                child: Text('رفض', style: GoogleFonts.cairo(
                                    fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppTheme.darkGrey)),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: () => widget.onAccept(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.deepBurgundy, foregroundColor: AppTheme.pureWhite,
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                ),
                                child: Text('قبول الرحلة', style: GoogleFonts.cairo(
                                    fontSize: 16.sp, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ]),
                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;
    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
  }
}
