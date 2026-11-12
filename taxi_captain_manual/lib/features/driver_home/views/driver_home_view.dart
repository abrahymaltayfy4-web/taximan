// lib/features/driver_home/views/driver_home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../cubit/driver_home_cubit.dart';
import '../cubit/driver_home_state.dart';
import '../cubit/location_cubit.dart';
import '../cubit/location_state.dart';
import '../../../core/di/service_locator.dart';
import 'available_rides_view.dart';
import '../../profile/views/captain_profile_view.dart';
import '../../ride_history/views/ride_history_view.dart';
import '../../account/views/account_statement_view.dart';
import '../../driver_auth/views/driver_login_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class DriverHomeView extends StatelessWidget {
  const DriverHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<DriverHomeCubit>()),
        BlocProvider(create: (_) => sl<LocationCubit>()..checkAndRequestPermission()),
      ],
      child: const _DriverHomeBody(),
    );
  }
}

class _DriverHomeBody extends StatefulWidget {
  const _DriverHomeBody();

  @override
  State<_DriverHomeBody> createState() => _DriverHomeBodyState();
}

class _DriverHomeBodyState extends State<_DriverHomeBody>
    with WidgetsBindingObserver {
  bool _isOnline = false;
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};

  static const LatLng _initialPosition = LatLng(15.369445, 44.191007);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<DriverHomeCubit>().loadDriverStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// عند إغلاق التطبيق أو الانتقال للخلفية → حالة offline
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cubit = context.read<DriverHomeCubit>();
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (_isOnline) cubit.goOffline();
    } else if (state == AppLifecycleState.resumed) {
      cubit.loadDriverStatus();
    }
  }

  /// عرض حوار صلاحيات الموقع حسب الحالة
  void _showLocationPermissionDialog(
    BuildContext context,
    LocationPermissionStatus status,
  ) {
    String title;
    String message;
    bool openSettings = false;
    bool openAppSettings = false;

    switch (status) {
      case LocationPermissionStatus.serviceDisabled:
        title = 'خدمة الموقع مغلقة';
        message = 'يرجى تفعيل خدمة الموقع (GPS) لاستخدام التطبيق';
        openSettings = true;
      case LocationPermissionStatus.denied:
        title = 'صلاحية الموقع مرفوضة';
        message = 'يجب السماح بصلاحية الموقع لاستخدام التطبيق';
      case LocationPermissionStatus.deniedForever:
        title = 'صلاحية الموقع مرفوضة نهائياً';
        message = 'يرجى الذهاب إلى إعدادات التطبيق وتفعيل صلاحية الموقع';
        openAppSettings = true;
      default:
        return;
    }

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
                  context.read<LocationCubit>().openLocationSettings();
                },
                child: Text('فتح الإعدادات',
                    style: GoogleFonts.cairo(color: AppTheme.deepBurgundy)),
              ),
            if (openAppSettings)
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.read<LocationCubit>().openAppSettings();
                },
                child: Text('إعدادات التطبيق',
                    style: GoogleFonts.cairo(color: AppTheme.deepBurgundy)),
              ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<LocationCubit>().checkAndRequestPermission();
              },
              child: Text('إعادة المحاولة',
                  style: GoogleFonts.cairo(color: AppTheme.deepBurgundy)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          // الاستماع لحالة الموقع
          BlocListener<LocationCubit, LocationState>(
            listener: (context, locState) {
              if (locState.permissionStatus != LocationPermissionStatus.granted &&
                  locState.permissionStatus != LocationPermissionStatus.initial) {
                _showLocationPermissionDialog(context, locState.permissionStatus);
              }
              if (locState.currentPosition != null) {
                setState(() {
                  _markers.removeWhere((m) => m.markerId.value == 'my_location');
                  _markers.add(
                    Marker(
                      markerId: const MarkerId('my_location'),
                      position: locState.currentPosition!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueAzure),
                      infoWindow: const InfoWindow(title: 'موقعي'),
                    ),
                  );
                });
                _controller?.animateCamera(
                  CameraUpdate.newLatLngZoom(locState.currentPosition!, 15),
                );
              }
            },
          ),
          // الاستماع لحالة السائق
          BlocListener<DriverHomeCubit, DriverHomeState>(
            listener: (context, state) {
              if (state is DriverLocationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                );
              } else if (state is DriverStatusUpdated) {
                setState(() => _isOnline = state.isOnline);
              }
            },
          ),
        ],
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _initialPosition, zoom: 15,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: _markers,
              onMapCreated: (controller) {
                _controller = controller;
                final pos = context.read<LocationCubit>().state.currentPosition;
                if (pos != null) {
                  controller.animateCamera(CameraUpdate.newLatLngZoom(pos, 15));
                }
              },
            ),

            // الشريط العلوي
            Positioned(
              top: 50, left: 16, right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black),
                      onPressed: () => _showMenuBottomSheet(context),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(Icons.local_taxi,
                              color: _isOnline ? Colors.blue : Colors.grey),
                          onPressed: () {
                            if (!_isOnline) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('يجب تفعيل وضع استقبال الطلبات أولاً',
                                      style: GoogleFonts.cairo()),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              return;
                            }
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const AvailableRidesView(),
                            ));
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10, offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12, height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isOnline ? Colors.green : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isOnline ? 'متصل الآن' : 'غير متصل',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                color: _isOnline
                                    ? Colors.green.shade800
                                    : Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // زر تحديد الموقع الحالي
            Positioned(
              bottom: 100, right: 16,
              child: FloatingActionButton.small(
                heroTag: 'location_btn',
                backgroundColor: AppTheme.pureWhite,
                onPressed: () => context.read<LocationCubit>().getCurrentPosition(),
                child: const Icon(Icons.my_location, color: AppTheme.deepBurgundy),
              ),
            ),

            // زر التبديل السفلي (بدء استقبال الطلبات)
            Positioned(
              bottom: 30, left: 24, right: 24,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isOnline ? Colors.red : Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
                onPressed: () {
                  context.read<DriverHomeCubit>().toggleDriverStatus(!_isOnline);
                },
                child: Text(
                  _isOnline ? 'إيقاف استقبال الطلبات' : 'بدء استقبال الطلبات',
                  style: GoogleFonts.cairo(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// عرض قائمة الخيارات السفلية
  void _showMenuBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.creamBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: AppTheme.deepBurgundy),
                  title: Text('الملف الشخصي',
                      style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  onTap: () { Navigator.pop(sheetContext); Navigator.push(context, MaterialPageRoute(builder: (_) => const CaptainProfileView())); },
                ),
                ListTile(
                  leading: const Icon(Icons.history, color: AppTheme.deepBurgundy),
                  title: Text('سجل الرحلات',
                      style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  onTap: () { Navigator.pop(sheetContext); Navigator.push(context, MaterialPageRoute(builder: (_) => const RideHistoryView())); },
                ),
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet, color: AppTheme.deepBurgundy),
                  title: Text('كشف الحساب',
                      style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  onTap: () { Navigator.pop(sheetContext); Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountStatementView())); },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text('تسجيل الخروج',
                      style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.red)),
                  onTap: () async {
                    await context.read<DriverHomeCubit>().signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const DriverLoginView()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
