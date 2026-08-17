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
import '../../profile/views/customer_profile_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import 'dart:async';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

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
  LatLng? _pickupPosition;
  LatLng? _destinationPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  double? _calculatedDistanceInKm;
  String? _durationText;
  
  // حالة اختيار النقاط
  bool _isSelectingPickup = false;
  bool _isSelectingDestination = true; // افتراضي: اختيار الوجهة
  
  final TextEditingController _pickupController = TextEditingController(text: 'موقعي الحالي');
  final TextEditingController _destinationController = TextEditingController();
  StreamSubscription? _driversSubscription;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        _showLocationDialog(
          'خدمة الموقع مغلقة',
          'يرجى تفعيل خدمة الموقع (GPS) لاستخدام التطبيق',
          openSettings: true,
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          _showLocationDialog(
            'صلاحية الموقع مرفوضة',
            'يجب السماح بصلاحية الموقع لاستخدام التطبيق',
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        _showLocationDialog(
          'صلاحية الموقع مرفوضة نهائياً',
          'يرجى الذهاب إلى إعدادات التطبيق وتفعيل صلاحية الموقع',
          openAppSettings: true,
        );
      }
      return;
    }

    _determinePosition();
  }

  void _showLocationDialog(String title, String message, {bool openSettings = false, bool openAppSettings = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: Text(message, style: GoogleFonts.cairo()),
          actions: [
            if (openSettings)
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Geolocator.openLocationSettings();
                },
                child: Text('فتح الإعدادات', style: GoogleFonts.cairo(color: AppTheme.deepBurgundy)),
              ),
            if (openAppSettings)
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Geolocator.openAppSettings();
                },
                child: Text('إعدادات التطبيق', style: GoogleFonts.cairo(color: AppTheme.deepBurgundy)),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _checkLocationPermission();
              },
              child: Text('إعادة المحاولة', style: GoogleFonts.cairo(color: AppTheme.deepBurgundy)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _determinePosition() async {
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _pickupPosition = _currentPosition;
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: _currentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
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
        // حفظ الماركرز غير السائقين (موقع المستخدم، نقطة البداية، الوجهة)
        final nonDriverMarkers = _markers.where(
          (m) => !m.markerId.value.startsWith('driver_'),
        ).toSet();
        
        // إعادة بناء الـ Set بالكامل لضمان حذف السائقين الذين أصبحوا offline
        _markers.clear();
        _markers.addAll(nonDriverMarkers);
        
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
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
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
    if (_pickupPosition == null || _destinationPosition == null) return;

    final directionsData = await _directionsService.getDirections(
      origin: _pickupPosition!,
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

  void _onMapTap(LatLng tappedLatLng) {
    setState(() {
      if (_isSelectingPickup) {
        // تحديد نقطة البداية
        _pickupPosition = tappedLatLng;
        _pickupController.text = 'خط عرض: ${tappedLatLng.latitude.toStringAsFixed(4)}, خط طول: ${tappedLatLng.longitude.toStringAsFixed(4)}';
        
        _markers.removeWhere((m) => m.markerId.value == 'pickup');
        _markers.add(
          Marker(
            markerId: const MarkerId('pickup'),
            position: tappedLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: const InfoWindow(title: 'نقطة الانطلاق'),
          ),
        );

        // الانتقال لاختيار الوجهة
        _isSelectingPickup = false;
        _isSelectingDestination = true;
      } else {
        // تحديد نقطة الوصول (الافتراضي)
        _destinationPosition = tappedLatLng;
        _destinationController.text = 'خط عرض: ${tappedLatLng.latitude.toStringAsFixed(4)}, خط طول: ${tappedLatLng.longitude.toStringAsFixed(4)}';

        _markers.removeWhere((m) => m.markerId.value == 'destination');
        _markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: tappedLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: const InfoWindow(title: 'وجهة الوصول'),
          ),
        );

        _isSelectingDestination = false;
      }
    });
    
    // رسم المسار إذا تم تحديد كلا النقطتين
    if (_pickupPosition != null && _destinationPosition != null) {
      _updateRouteAndDistance();
    }
  }

  void _useCurrentLocationAsPickup() {
    if (_currentPosition == null) return;
    setState(() {
      _pickupPosition = _currentPosition;
      _pickupController.text = 'موقعي الحالي';
      _markers.removeWhere((m) => m.markerId.value == 'pickup');
      _isSelectingPickup = false;
      _isSelectingDestination = true;
    });
    if (_pickupPosition != null && _destinationPosition != null) {
      _updateRouteAndDistance();
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
                  onTap: _onMapTap,
                ),

                // شريط الحالة — ما الذي يختاره المستخدم حالياً
                if (_isSelectingPickup || (_isSelectingDestination && _destinationPosition == null))
                  Positioned(
                    top: 100.h,
                    left: 40.w,
                    right: 40.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: _isSelectingPickup ? Colors.green : AppTheme.deepBurgundy,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isSelectingPickup ? Icons.my_location : Icons.location_on,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _isSelectingPickup
                                ? 'اضغط على الخريطة لتحديد نقطة البداية'
                                : 'اضغط على الخريطة لتحديد الوجهة',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                              color: AppTheme.charcoalBlack.withValues(alpha: 0.08),
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
                              color: AppTheme.charcoalBlack.withValues(alpha: 0.08),
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
                              color: AppTheme.charcoalBlack.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.person_outline, color: AppTheme.charcoalBlack),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CustomerProfileView()),
                            );
                          },
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
                        _checkLocationPermission();
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
                          color: AppTheme.charcoalBlack.withValues(alpha: 0.12),
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

                        // حقل نقطة البداية مع إمكانية تغييرها
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSelectingPickup = true;
                              _isSelectingDestination = false;
                            });
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: _pickupController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'نقطة الانطلاق (اضغط للتغيير)',
                                prefixIcon: const Icon(Icons.my_location, color: Colors.green),
                                suffixIcon: _pickupPosition != _currentPosition
                                    ? IconButton(
                                        icon: const Icon(Icons.gps_fixed, color: AppTheme.deepBurgundy, size: 20),
                                        onPressed: _useCurrentLocationAsPickup,
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: _isSelectingPickup ? Colors.green : AppTheme.lightGrey,
                                    width: _isSelectingPickup ? 2 : 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: _isSelectingPickup ? Colors.green : AppTheme.lightGrey,
                                    width: _isSelectingPickup ? 2 : 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),

                        // حقل الوجهة
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSelectingPickup = false;
                              _isSelectingDestination = true;
                            });
                          },
                          child: AbsorbPointer(
                            child: TextField(
                              controller: _destinationController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'وجهة الوصول (اضغط على الخريطة)',
                                prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: _isSelectingDestination ? AppTheme.deepBurgundy : AppTheme.lightGrey,
                                    width: _isSelectingDestination ? 2 : 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: _isSelectingDestination ? AppTheme.deepBurgundy : AppTheme.lightGrey,
                                    width: _isSelectingDestination ? 2 : 1,
                                  ),
                                ),
                              ),
                            ),
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
                                  if (_pickupPosition == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('يرجى تحديد نقطة الانطلاق أولاً', style: GoogleFonts.cairo()),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }
                                  if (_destinationPosition == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('يرجى النقر على الخريطة لتحديد وجهة الوصول', style: GoogleFonts.cairo()),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }

                                  context.read<RideCubit>().requestRide(
                                        pickupLocation: GeoPoint(_pickupPosition!.latitude, _pickupPosition!.longitude),
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