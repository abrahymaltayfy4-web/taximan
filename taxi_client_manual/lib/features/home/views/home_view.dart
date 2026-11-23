// lib/features/home/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/service_locator.dart';

import '../../rides/presentation/ride_cubit.dart';
import '../../rides/presentation/ride_state.dart';
import '../../rides/domain/location_entity.dart';
import '../../rides/presentation/views/ride_tracking_view.dart';
import '../../ride_history/views/ride_history_view.dart';
import '../../profile/views/customer_profile_view.dart';
import '../../place_search/domain/entities/place_details.dart';
import '../../place_search/presentation/cubit/place_search_cubit.dart';
import '../../place_search/presentation/views/place_search_view.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../cubit/location_cubit.dart';
import '../cubit/location_state.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  GoogleMapController? _mapController;

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

  final TextEditingController _pickupController = TextEditingController(
    text: 'موقعي الحالي',
  );
  final TextEditingController _destinationController = TextEditingController();

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _showLocationDialog(
    BuildContext ctx,
    String title,
    String message, {
    bool openSettings = false,
    bool openAppSettings = false,
  }) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (dialogCtx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            title,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Text(message, style: GoogleFonts.cairo()),
          actions: [
            if (openSettings)
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  ctx.read<LocationCubit>().openLocationSettings();
                },
                child: Text(
                  'فتح الإعدادات',
                  style: GoogleFonts.cairo(color: AppTheme.deepBurgundy),
                ),
              ),
            if (openAppSettings)
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  ctx.read<LocationCubit>().openAppSettings();
                },
                child: Text(
                  'إعدادات التطبيق',
                  style: GoogleFonts.cairo(color: AppTheme.deepBurgundy),
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
                ctx.read<LocationCubit>().checkAndRequestPermission();
              },
              child: Text(
                'إعادة المحاولة',
                style: GoogleFonts.cairo(color: AppTheme.deepBurgundy),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMapTap(BuildContext ctx, LatLng tappedLatLng) {
    setState(() {
      if (_isSelectingPickup) {
        // تحديد نقطة البداية
        _pickupPosition = tappedLatLng;
        _pickupController.text =
            'خط عرض: ${tappedLatLng.latitude.toStringAsFixed(4)}, خط طول: ${tappedLatLng.longitude.toStringAsFixed(4)}';

        _markers.removeWhere((m) => m.markerId.value == 'pickup');
        _markers.add(
          Marker(
            markerId: const MarkerId('pickup'),
            position: tappedLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: const InfoWindow(title: 'نقطة الانطلاق'),
          ),
        );

        // الانتقال لاختيار الوجهة*
        _isSelectingPickup = false;
        _isSelectingDestination = true;
      } else {
        // تحديد نقطة الوصول (الافتراضي)
        _destinationPosition = tappedLatLng;
        _destinationController.text =
            'خط عرض: ${tappedLatLng.latitude.toStringAsFixed(4)}, خط طول: ${tappedLatLng.longitude.toStringAsFixed(4)}';

        _markers.removeWhere((m) => m.markerId.value == 'destination');
        _markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: tappedLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: const InfoWindow(title: 'وجهة الوصول'),
          ),
        );

        _isSelectingDestination = false;
      }
    });

    // حساب المسار عبر الـ Cubit إذا تم تحديد كلا النقطتين
    if (_pickupPosition != null && _destinationPosition != null) {
      ctx.read<HomeCubit>().calculateRoute(
            pickup: _pickupPosition!,
            destination: _destinationPosition!,
          );
    }
  }

  void _useCurrentLocationAsPickup(BuildContext ctx) {
    if (_currentPosition == null) return;
    setState(() {
      _pickupPosition = _currentPosition;
      _pickupController.text = 'موقعي الحالي';
      _markers.removeWhere((m) => m.markerId.value == 'pickup');
      _isSelectingPickup = false;
      _isSelectingDestination = true;
    });
    if (_pickupPosition != null && _destinationPosition != null) {
      ctx.read<HomeCubit>().calculateRoute(
            pickup: _pickupPosition!,
            destination: _destinationPosition!,
          );
    }
  }

  /// فتح شاشة البحث عن الأماكن
  /// [fieldType] — نوع الحقل: 'pickup' أو 'destination'
  Future<void> _openPlaceSearch(
    BuildContext ctx,
    String fieldType,
  ) async {
    final PlaceDetails? result = await Navigator.push<PlaceDetails>(
      ctx,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) {
            final cubit = sl<PlaceSearchCubit>();
            // تحسين نتائج البحث بالموقع الحالي
            if (_currentPosition != null) {
              cubit.setCurrentLocation(
                _currentPosition!.latitude,
                _currentPosition!.longitude,
              );
            }
            return cubit;
          },
          child: PlaceSearchView(fieldType: fieldType),
        ),
      ),
    );

    if (result == null || !mounted) return;

    final selectedLatLng = LatLng(result.latitude, result.longitude);

    setState(() {
      if (fieldType == 'pickup') {
        _pickupPosition = selectedLatLng;
        _pickupController.text = result.name;
        _markers.removeWhere((m) => m.markerId.value == 'pickup');
        _markers.add(
          Marker(
            markerId: const MarkerId('pickup'),
            position: selectedLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            infoWindow: InfoWindow(title: result.name),
          ),
        );
        _isSelectingPickup = false;
        _isSelectingDestination = true;
      } else {
        _destinationPosition = selectedLatLng;
        _destinationController.text = result.name;
        _markers.removeWhere((m) => m.markerId.value == 'destination');
        _markers.add(
          Marker(
            markerId: const MarkerId('destination'),
            position: selectedLatLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed,
            ),
            infoWindow: InfoWindow(title: result.name),
          ),
        );
        _isSelectingDestination = false;
      }
    });

    // تحريك الكاميرا للموقع المحدد
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: selectedLatLng, zoom: 16.0),
      ),
    );

    // حساب المسار إذا تم تحديد كلا النقطتين
    if (_pickupPosition != null && _destinationPosition != null && mounted) {
      if (ctx.mounted) {
        ctx.read<HomeCubit>().calculateRoute(
              pickup: _pickupPosition!,
              destination: _destinationPosition!,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<RideCubit>()),
        BlocProvider(create: (context) => sl<HomeCubit>()),
        BlocProvider(
          create: (context) =>
              sl<LocationCubit>()..checkAndRequestPermission(),
        ),
      ],
      child: Scaffold(
        body: MultiBlocListener(
          listeners: [
            // الاستماع لتغييرات الموقع والأذونات
            BlocListener<LocationCubit, LocationState>(
              listener: (context, locState) {
                // معالجة حالات الأذونات
                switch (locState.permissionStatus) {
                  case LocationPermissionStatus.serviceDisabled:
                    _showLocationDialog(
                      context,
                      'خدمة الموقع مغلقة',
                      'يرجى تفعيل خدمة الموقع (GPS) لاستخدام التطبيق',
                      openSettings: true,
                    );
                    break;
                  case LocationPermissionStatus.denied:
                    _showLocationDialog(
                      context,
                      'صلاحية الموقع مرفوضة',
                      'يجب السماح بصلاحية الموقع لاستخدام التطبيق',
                    );
                    break;
                  case LocationPermissionStatus.deniedForever:
                    _showLocationDialog(
                      context,
                      'صلاحية الموقع مرفوضة نهائياً',
                      'يرجى الذهاب إلى إعدادات التطبيق وتفعيل صلاحية الموقع',
                      openAppSettings: true,
                    );
                    break;
                  case LocationPermissionStatus.granted:
                    // الموقع جاهز — تحديث الخريطة
                    if (locState.currentPosition != null) {
                      setState(() {
                        _currentPosition = locState.currentPosition;
                        _pickupPosition = _currentPosition;
                        _markers.add(
                          Marker(
                            markerId: const MarkerId('currentLocation'),
                            position: _currentPosition!,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueGreen,
                            ),
                            infoWindow:
                                const InfoWindow(title: 'موقعي الحالي'),
                          ),
                        );
                      });

                      _mapController?.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                              target: _currentPosition!, zoom: 16.0),
                        ),
                      );

                      // بدء الاستماع للسائقين القريبين
                      context
                          .read<HomeCubit>()
                          .listenToNearbyDrivers(_currentPosition!);
                    }
                    break;
                  case LocationPermissionStatus.initial:
                    break;
                }
              },
            ),
            // الاستماع لتحديث ماركرز السائقين وحالة المسار
            BlocListener<HomeCubit, HomeState>(
              listener: (context, homeState) {
                if (homeState is NearbyDriversUpdated) {
                  setState(() {
                    _markers.removeWhere(
                      (m) => m.markerId.value.startsWith('driver_'),
                    );
                    _markers.addAll(homeState.driverMarkers);
                  });
                } else if (homeState is HomeRouteCalculated) {
                  setState(() {
                    _calculatedDistanceInKm = homeState.distanceKm;
                    _durationText = homeState.durationText;

                    // تحديث علامة الوجهة
                    _markers.removeWhere(
                        (m) => m.markerId.value == 'destination');
                    _markers.add(
                      Marker(
                        markerId: const MarkerId('destination'),
                        position: homeState.destinationPosition,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed,
                        ),
                        infoWindow: InfoWindow(
                          title: 'وجهة الوصول',
                          snippet:
                              '${homeState.distanceText} - ${homeState.durationText}',
                        ),
                      ),
                    );

                    // رسم المسار
                    _polylines.clear();
                    _polylines.add(
                      Polyline(
                        polylineId: const PolylineId('real_route'),
                        points: homeState.routePoints,
                        color: AppTheme.deepBurgundy,
                        width: 6,
                      ),
                    );
                  });
                }
              },
            ),
          ],
          child: BlocConsumer<RideCubit, RideState>(
            listener: (context, state) {
              if (state is RideRequestedSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم إرسال طلبك بنجاح!',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RideTrackingView(rideId: state.rideId),
                  ),
                );
              } else if (state is RideError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(state.message, style: GoogleFonts.cairo()),
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
                    onTap: (latlng) => _onMapTap(context, latlng),
                  ),

                  // شريط الحالة — ما الذي يختاره المستخدم حالياً
                  if (_isSelectingPickup ||
                      (_isSelectingDestination &&
                          _destinationPosition == null))
                    _buildSelectionBanner(),

                  // 2. Top Header Bar
                  _buildTopHeaderBar(context),

                  // 3. Floating Action Button for Location
                  _buildLocationFab(context),

                  // 4. Bottom Sheet for Ride Booking & Distance info
                  _buildBottomSheet(context, state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionBanner() {
    return Positioned(
      top: 100.h,
      left: 40.w,
      right: 40.w,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 10.h,
        ),
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
            Flexible(
              child: Text(
                _isSelectingPickup
                    ? 'اضغط على الخريطة لتحديد نقطة البداية'
                    : 'اضغط على الخريطة لتحديد الوجهة',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeaderBar(BuildContext context) {
    return Positioned(
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
              icon: const Icon(
                Icons.history,
                color: AppTheme.charcoalBlack,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RideHistoryView(),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 8.h,
            ),
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
              'Wasslni Taxi',
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.deepBurgundy,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
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
              icon: const Icon(
                Icons.person_outline,
                color: AppTheme.charcoalBlack,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomerProfileView(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationFab(BuildContext context) {
    return Positioned(
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
                CameraPosition(
                  target: _currentPosition!,
                  zoom: 16.0,
                ),
              ),
            );
          } else {
            context.read<LocationCubit>().checkAndRequestPermission();
          }
        },
        child: const Icon(
          Icons.my_location,
          color: AppTheme.deepBurgundy,
        ),
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context, RideState state) {
    return Positioned(
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
            _buildPickupField(context),
            SizedBox(height: 10.h),

            // حقل الوجهة
            _buildDestinationField(),

            if (_calculatedDistanceInKm != null) ...[
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'المسافة والوقت المقدر:',
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: AppTheme.darkGrey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      '${_calculatedDistanceInKm!.toStringAsFixed(2)} كم ($_durationText)',
                      style: GoogleFonts.cairo(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.deepBurgundy,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            SizedBox(height: 16.h),

            _buildRequestButton(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupField(BuildContext ctx) {
    return Row(
      children: [
        // حقل نقطة الانطلاق — الضغط يفعّل وضع اختيار الخريطة
        Expanded(
          child: GestureDetector(
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
                  labelText: 'نقطة الانطلاق',
                  prefixIcon: const Icon(
                    Icons.my_location,
                    color: Colors.green,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: _isSelectingPickup
                          ? Colors.green
                          : AppTheme.lightGrey,
                      width: _isSelectingPickup ? 2 : 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: _isSelectingPickup
                          ? Colors.green
                          : AppTheme.lightGrey,
                      width: _isSelectingPickup ? 2 : 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),

        // زر البحث
        _buildSearchIconButton(
          onTap: () => _openPlaceSearch(ctx, 'pickup'),
          tooltip: 'بحث عن نقطة الانطلاق',
        ),

        // زر الموقع الحالي
        if (_pickupPosition != _currentPosition) ...[
          SizedBox(width: 6.w),
          _buildActionIconButton(
            icon: Icons.gps_fixed,
            onTap: () => _useCurrentLocationAsPickup(ctx),
            tooltip: 'استخدام موقعي الحالي',
          ),
        ],
      ],
    );
  }

  Widget _buildDestinationField() {
    return Row(
      children: [
        // حقل الوجهة — الضغط يفعّل وضع اختيار الخريطة
        Expanded(
          child: GestureDetector(
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
                  labelText: 'وجهة الوصول (الخريطة أو ابحث)',
                  prefixIcon: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: _isSelectingDestination
                          ? AppTheme.deepBurgundy
                          : AppTheme.lightGrey,
                      width: _isSelectingDestination ? 2 : 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: _isSelectingDestination
                          ? AppTheme.deepBurgundy
                          : AppTheme.lightGrey,
                      width: _isSelectingDestination ? 2 : 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),

        // زر البحث
        _buildSearchIconButton(
          onTap: () => _openPlaceSearch(context, 'destination'),
          tooltip: 'بحث عن الوجهة',
        ),
      ],
    );
  }

  /// زر البحث المشترك — أيقونة بحث داخل مربع مدور
  Widget _buildSearchIconButton({
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: AppTheme.deepBurgundy.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.search_rounded,
            color: AppTheme.deepBurgundy,
            size: 22.sp,
          ),
        ),
      ),
    );
  }

  /// زر إجراء عام — أيقونة صغيرة
  Widget _buildActionIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            icon,
            color: Colors.green.shade700,
            size: 20.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildRequestButton(BuildContext context, RideState state) {
    return ElevatedButton(
      onPressed: state is RideLoading
          ? null
          : () {
              if (_pickupPosition == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'يرجى تحديد نقطة الانطلاق أولاً',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              if (_destinationPosition == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'يرجى النقر على الخريطة لتحديد وجهة الوصول',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              context.read<RideCubit>().requestRide(
                    pickupLocation: LocationEntity(
                      latitude: _pickupPosition!.latitude,
                      longitude: _pickupPosition!.longitude,
                    ),
                    pickupAddress: _pickupController.text.trim(),
                    destinationLocation: LocationEntity(
                      latitude: _destinationPosition!.latitude,
                      longitude: _destinationPosition!.longitude,
                    ),
                    destinationAddress:
                        _destinationController.text.trim(),
                    distanceKm: _calculatedDistanceInKm ?? 0.0,
                  );
            },
      child: state is RideLoading
          ? const CircularProgressIndicator(
              color: Colors.white,
            )
          : const Text('اطلب وصّلني الآن'),
    );
  }
}
