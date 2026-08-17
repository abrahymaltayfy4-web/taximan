// lib/features/home/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:taxi_client_manual/core/services/directions_service.dart';
import '../../../theme/app_theme.dart';

import '../cubit/ride_cubit.dart';
import '../cubit/ride_state.dart';
import '../../ride/views/ride_tracking_view.dart';
import '../../ride_history/views/ride_history_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import 'dart:async';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  GoogleMapController? _mapController;
  final DirectionsService _directionsService = DirectionsService();
  
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(15.369445, 44.191007),
    zoom: 15.0,
  );

  LatLng? _currentPosition;
  LatLng? _destinationPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  double? _calculatedDistanceInKm;
  String? _durationText;
  
  final TextEditingController _pickupController = TextEditingController(text: 'موقعي الحالي');
  final TextEditingController _destinationController = TextEditingController();
  StreamSubscription? _driversSubscription;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: _currentPosition!,
          infoWindow: const InfoWindow(title: 'موقعي الحالي'),
        ),
      );
    });

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition!, zoom: 16.0),
      ),
    );
    _listenToNearbyDrivers();
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = math.cos;
    var a = 0.5 - c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a));
  }

  void _listenToNearbyDrivers() {
    _driversSubscription = FirebaseFirestore.instance
        .collection('drivers')
        .where('status', isEqualTo: 'online')
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      setState(() {
        _markers.removeWhere((m) => m.markerId.value.startsWith('driver_'));
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final location = data['location'];
          if (location is GeoPoint && _currentPosition != null) {
            final driverLatLng = LatLng(location.latitude, location.longitude);
            final distance = _calculateDistance(
              _currentPosition!.latitude, _currentPosition!.longitude,
              driverLatLng.latitude, driverLatLng.longitude,
            );
            if (distance <= 2.0) {
              _markers.add(
                Marker(
                  markerId: MarkerId('driver_${doc.id}'),
                  position: driverLatLng,
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
                  infoWindow: InfoWindow(title: data['name'] ?? 'كابتن', snippet: '${data['carModel'] ?? ''}'),
                ),
              );
            }
          }
        }
      });
    });
  }

  // دالة لجلب المسار الفعلي والمسافة والوقت عبر Directions API
  Future<void> _updateRouteAndDistance() async {
    if (_currentPosition == null || _destinationPosition == null) return;

    final directionsData = await _directionsService.getDirections(
      origin: _currentPosition!,
      destination: _destinationPosition!,
    );

    if (directionsData != null) {
      setState(() {
        List<LatLng> polylineCoordinates = directionsData['polylineCoordinates'];
        _calculatedDistanceInKm = directionsData['distanceValue'];
        _durationText = directionsData['durationText'];

        // 1. تحديث علامة الوجهة
        _markers.removeWhere((m) => m.markerId.value == 'destination');
        _markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: _destinationPosition!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(
              title: 'وجهة الوصول',
              snippet: '${directionsData['distanceText']} - $_durationText',
            ),
          ),
        );

        // 2. رسم مسار الشوارع الحقيقي (Polyline)
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('real_route'),
            points: polylineCoordinates,
            color: AppTheme.deepBurgundy,
            width: 6,
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _driversSubscription?.cancel();
    _pickupController.dispose();
    _destinationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RideCubit(),
      child: Scaffold(
        body: BlocConsumer<RideCubit, RideState>(
          listener: (context, state) {
            if (state is RideRequestedSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم إرسال طلبك بنجاح!', style: GoogleFonts.cairo()),
                  backgroundColor: Colors.green,
                ),
              );
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RideTrackingView(
                    rideId: state.rideId,
                  ),
                ),
              );
            } else if (state is RideError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message, style: GoogleFonts.cairo()),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                // 1. Google Map Background
                GoogleMap(
                  initialCameraPosition: _initialPosition,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  markers: _markers,
                  polylines: _polylines,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                  onTap: (LatLng tappedLatLng) {
                    setState(() {
                      _destinationPosition = tappedLatLng;
                      _destinationController.text = 'خط عرض: ${tappedLatLng.latitude.toStringAsFixed(4)}, خط طول: ${tappedLatLng.longitude.toStringAsFixed(4)}';
                    });
                    _updateRouteAndDistance();
                  },
                ),

                // 2. Top Header Bar
                Positioned(
                  top: 50.h,
                  left: 20.w,
                  right: 20.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.pureWhite,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.charcoalBlack.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.history, color: AppTheme.charcoalBlack),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RideHistoryView()),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: AppTheme.pureWhite,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.charcoalBlack.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Rahal Taxi',
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.deepBurgundy,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.pureWhite,
                          borderRadius: BorderRadius.circular(14.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.charcoalBlack.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications_outlined, color: AppTheme.charcoalBlack),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. Floating Action Button for Location
                Positioned(
                  bottom: 330.h,
                  right: 20.w,
                  child: FloatingActionButton(
                    heroTag: 'current_location_btn',
                    backgroundColor: AppTheme.pureWhite,
                    elevation: 4,
                    onPressed: () {
                      if (_currentPosition != null) {
                        _mapController?.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(target: _currentPosition!, zoom: 16.0),
                          ),
                        );
                      } else {
                        _determinePosition();
                      }
                    },
                    child: const Icon(Icons.my_location, color: AppTheme.deepBurgundy),
                  ),
                ),

                // 4. Bottom Sheet for Ride Booking & Distance info
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: AppTheme.creamBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28.r),
                        topRight: Radius.circular(28.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.charcoalBlack.withOpacity(0.12),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40.w,
                            height: 4.h,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'إلى أين تريد الذهاب اليوم؟',
                          style: GoogleFonts.cairo(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.charcoalBlack,
                          ),
                        ),
                        SizedBox(height: 12.h),

                        TextField(
                          controller: _pickupController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'موقع الانطلاق',
                            prefixIcon: Icon(Icons.my_location, color: AppTheme.deepBurgundy),
                          ),
                        ),
                        SizedBox(height: 10.h),

                        TextField(
                          controller: _destinationController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'وجهة الوصول (اضغط على الخريطة)',
                            prefixIcon: Icon(Icons.location_on, color: Colors.red),
                          ),
                        ),
                        
                        if (_calculatedDistanceInKm != null) ...[
                          SizedBox(height: 12.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'المسافة والوقت المقدر:',
                                style: GoogleFonts.cairo(fontSize: 14.sp, color: AppTheme.darkGrey),
                              ),
                              Text(
                                '${_calculatedDistanceInKm!.toStringAsFixed(2)} كم ($_durationText)',
                                style: GoogleFonts.cairo(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.deepBurgundy,
                                ),
                              ),
                            ],
                          ),
                        ],

                        SizedBox(height: 16.h),

                        ElevatedButton(
                          onPressed: state is RideLoading
                              ? null
                              : () {
                                  if (_destinationPosition == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('يرجى النقر على الخريطة لتحديد وجهة الوصول أولاً', style: GoogleFonts.cairo()),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }

                                  context.read<RideCubit>().requestRide(
                                        pickupLocation: GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
                                        pickupAddress: _pickupController.text.trim(),
                                        destinationLocation: GeoPoint(_destinationPosition!.latitude, _destinationPosition!.longitude),
                                        destinationAddress: _destinationController.text.trim(),
                                        distanceKm: _calculatedDistanceInKm ?? 0.0,
                                      );
                                },
                          child: state is RideLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('اطلب رحال الآن'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}