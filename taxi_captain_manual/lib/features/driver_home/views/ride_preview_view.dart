// lib/features/driver_home/views/ride_preview_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/directions_service.dart';
import '../../../theme/app_theme.dart';
import '../../../models/ride_model.dart';

class RidePreviewView extends StatefulWidget {
  final RideModel ride;
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
  final DirectionsService _directionsService = DirectionsService();
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  LatLng? _driverPosition;
  String? _routeDistanceText;
  String? _routeDurationText;

  @override
  void initState() {
    super.initState();
    _setupMapData();
  }

  Future<void> _setupMapData() async {
    final pickup = LatLng(
      widget.ride.pickupLocation.latitude,
      widget.ride.pickupLocation.longitude,
    );
    final destination = LatLng(
      widget.ride.destinationLocation.latitude,
      widget.ride.destinationLocation.longitude,
    );

    // الحصول على موقع الكابتن
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _driverPosition = LatLng(pos.latitude, pos.longitude);
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      // ماركر نقطة البداية
      _markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: pickup,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: 'نقطة الانطلاق', snippet: widget.ride.pickupAddress),
        ),
      );

      // ماركر نقطة الوصول
      _markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: 'وجهة الوصول', snippet: widget.ride.destinationAddress),
        ),
      );

      // ماركر موقع الكابتن
      if (_driverPosition != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('driver'),
            position: _driverPosition!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            infoWindow: const InfoWindow(title: 'موقعك'),
          ),
        );
      }
    });

    // رسم المسار الحقيقي بين البداية والنهاية عبر Directions API
    final directions = await _directionsService.getDirections(
      origin: pickup,
      destination: destination,
    );

    if (directions != null && mounted) {
      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: directions['polylineCoordinates'],
            color: AppTheme.deepBurgundy,
            width: 5,
          ),
        );
        _routeDistanceText = directions['distanceText'];
        _routeDurationText = directions['durationText'];
      });

      // ضبط الكاميرا لإظهار كل المسار
      if (directions['polylineCoordinates'].isNotEmpty) {
        final bounds = _getBounds(directions['polylineCoordinates']);
        _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
      }
    }
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (var point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // الخريطة
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.ride.pickupLocation.latitude,
                  widget.ride.pickupLocation.longitude,
                ),
                zoom: 13,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),

            // زر الرجوع
            Positioned(
              top: 50.h,
              right: 16.w,
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
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppTheme.creamBackground,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // اسم العميل والمسافة
                    Row(
                      children: [
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
                              Text(
                                widget.ride.customerName,
                                style: GoogleFonts.cairo(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.charcoalBlack,
                                ),
                              ),
                              if (_routeDistanceText != null && _routeDurationText != null)
                                Text(
                                  '$_routeDistanceText • $_routeDurationText',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.sp,
                                    color: AppTheme.darkGrey,
                                  ),
                                )
                              else
                                Text(
                                  '${widget.ride.distanceKm.toStringAsFixed(1)} كم',
                                  style: GoogleFonts.cairo(
                                    fontSize: 14.sp,
                                    color: AppTheme.darkGrey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // نقطة البداية
                    Row(
                      children: [
                        Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            widget.ride.pickupAddress,
                            style: GoogleFonts.cairo(fontSize: 14.sp),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    // نقطة الوصول
                    Row(
                      children: [
                        Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            widget.ride.destinationAddress,
                            style: GoogleFonts.cairo(fontSize: 14.sp),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // أزرار القبول والرفض
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppTheme.darkGrey),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Text(
                              'رفض',
                              style: GoogleFonts.cairo(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkGrey,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onAccept();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.deepBurgundy,
                              foregroundColor: AppTheme.pureWhite,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
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
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
