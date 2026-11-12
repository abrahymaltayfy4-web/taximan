import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/domain/ride_status.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../driver_home/cubit/ride_map_cubit.dart';
import '../../../driver_home/cubit/ride_map_state.dart';
import '../cubit/captain_ride_cubit.dart';
import '../cubit/captain_ride_state.dart';

class ActiveRideView extends StatefulWidget {
  final String rideId;

  const ActiveRideView({
    super.key,
    required this.rideId,
  });

  @override
  State<ActiveRideView> createState() => _ActiveRideViewState();
}

class _ActiveRideViewState extends State<ActiveRideView> {
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    // جلب موقع الكابتن عبر RideMapCubit
    context.read<RideMapCubit>().loadDriverPosition();
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
    return PopScope(
      canPop: false,
      child: Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: MultiBlocListener(
              listeners: [
                // الاستماع لتحديثات الخريطة (المسارات)
                BlocListener<RideMapCubit, RideMapState>(
                  listener: (context, mapState) {
                    if (mapState.routePoints.isNotEmpty) {
                      final color = mapState.activeRouteType == RideMapRouteType.toPickup
                          ? Colors.blue
                          : AppTheme.deepBurgundy;
                      final polylineId = mapState.activeRouteType == RideMapRouteType.toPickup
                          ? 'route_to_pickup'
                          : 'route_to_destination';

                      setState(() {
                        _polylines.clear();
                        _polylines.add(
                          Polyline(
                            polylineId: PolylineId(polylineId),
                            color: color,
                            width: 5,
                            points: mapState.routePoints,
                          ),
                        );
                      });

                      if (mapState.routePoints.isNotEmpty) {
                        final bounds = _getBounds(mapState.routePoints);
                        _mapController?.animateCamera(
                          CameraUpdate.newLatLngBounds(bounds, 80),
                        );
                      }
                    }
                  },
                ),
                // الاستماع لتحديثات حالة الرحلة
                BlocListener<CaptainRideCubit, CaptainRideState>(
                  listener: (context, state) {
                    if (state is CaptainRideCompleted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => AlertDialog(
                          title: Text(
                            'تم إنهاء الرحلة',
                            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                          ),
                          content: Text(
                            'تمت الرحلة بنجاح!',
                            style: GoogleFonts.cairo(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'حسناً',
                                style: GoogleFonts.cairo(
                                  color: AppTheme.deepBurgundy,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (state is CaptainActiveRide) {
                      final pickup = LatLng(
                        state.ride.pickupLocation.latitude,
                        state.ride.pickupLocation.longitude,
                      );
                      final destination = LatLng(
                        state.ride.destinationLocation.latitude,
                        state.ride.destinationLocation.longitude,
                      );

                      // رسم المسار حسب حالة الرحلة عبر RideMapCubit
                      if (state.ride.status == RideStatus.accepted.name ||
                          state.ride.status == RideStatus.driverArrived.name) {
                        context.read<RideMapCubit>().loadRouteToPickup(pickup);
                      } else if (state.ride.status == RideStatus.started.name) {
                        context.read<RideMapCubit>().loadRouteToDestination(pickup, destination);
                      }
                    }
                  },
                ),
              ],
              child: BlocBuilder<CaptainRideCubit, CaptainRideState>(
                builder: (context, state) {
                  if (state is CaptainRideLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.deepBurgundy,
                      ),
                    );
                  } else if (state is CaptainRideError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          color: Colors.red,
                        ),
                      ),
                    );
                  } else if (state is CaptainActiveRide) {
                    return _buildActiveContent(context, state);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildActiveContent(BuildContext context, CaptainActiveRide state) {
    final ride = state.ride;
    final pickup = LatLng(
      ride.pickupLocation.latitude,
      ride.pickupLocation.longitude,
    );
    final destination = LatLng(
      ride.destinationLocation.latitude,
      ride.destinationLocation.longitude,
    );
    final driverPosition = context.read<RideMapCubit>().state.driverPosition;

    // تحديث الماركرز
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: pickup,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'نقطة الانطلاق',
          snippet: ride.pickupAddress,
        ),
      ),
    );
    _markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: 'وجهة الوصول',
          snippet: ride.destinationAddress,
        ),
      ),
    );
    if (driverPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: driverPosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'موقعك'),
        ),
      );
    }

    String statusText = '';
    Color statusColor = Colors.grey;
    String buttonText = '';
    Color buttonColor = AppTheme.deepBurgundy;
    VoidCallback? onButtonPress;

    if (ride.status == RideStatus.accepted.name) {
      statusText = 'في الطريق لموقع العميل';
      statusColor = Colors.amber;
      buttonText = 'وصلت لموقع العميل';
      onButtonPress = () => context
          .read<CaptainRideCubit>()
          .updateRideStatus(ride.rideId, RideStatus.driverArrived.name);
    } else if (ride.status == RideStatus.driverArrived.name) {
      statusText = 'وصلت لموقع العميل';
      statusColor = Colors.green;
      buttonText = 'بدء الرحلة';
      onButtonPress = () {
        context.read<RideMapCubit>().resetRoutes();
        context.read<CaptainRideCubit>().updateRideStatus(
          ride.rideId,
          RideStatus.started.name,
        );
      };
    } else if (ride.status == RideStatus.started.name) {
      statusText = 'الرحلة جارية';
      statusColor = AppTheme.deepBurgundy;
      buttonText = 'إنهاء الرحلة';
      buttonColor = Colors.red.shade800;
      onButtonPress = () => context
          .read<CaptainRideCubit>()
          .completeRide(ride.rideId, ride.driverId ?? '');
    }

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: pickup, zoom: 14),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (controller) => _mapController = controller,
          polylines: _polylines,
          markers: _markers,
        ),
        Positioned(
          top: 50.h, left: 20.w, right: 20.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppTheme.pureWhite,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.charcoalBlack.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12.w, height: 12.w,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor),
                ),
                SizedBox(width: 8.w),
                Text(
                  statusText,
                  style: GoogleFonts.cairo(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.charcoalBlack,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.creamBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.charcoalBlack.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppTheme.lightGrey,
                      radius: 20.r,
                      child: Icon(Icons.person, color: AppTheme.deepBurgundy, size: 24.w),
                    ),
                    SizedBox(width: 12.w),
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
                    if (ride.customerPhone.isNotEmpty)
                      IconButton(
                        onPressed: () => launchUrl(Uri.parse('tel:${ride.customerPhone}')),
                        icon: Icon(Icons.phone, color: Colors.green, size: 24.w),
                      ),
                  ],
                ),
                SizedBox(height: 16.h),
                const Divider(color: AppTheme.lightGrey),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Icon(Icons.my_location, color: Colors.green, size: 20.w),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(ride.pickupAddress,
                        style: GoogleFonts.cairo(fontSize: 14.sp, color: AppTheme.darkGrey),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.red, size: 20.w),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(ride.destinationAddress,
                        style: GoogleFonts.cairo(fontSize: 14.sp, color: AppTheme.darkGrey),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('التكلفة المقدرة: ${ride.fare.toStringAsFixed(2)} ريال',
                      style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppTheme.deepBurgundy)),
                    Text('${ride.distanceKm.toStringAsFixed(1)} كم',
                      style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppTheme.charcoalBlack)),
                  ],
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: AppTheme.pureWhite,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    onPressed: onButtonPress,
                    child: Text(buttonText,
                      style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
