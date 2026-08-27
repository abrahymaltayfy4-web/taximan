// lib/features/driver_home/views/driver_home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../cubit/driver_home_cubit.dart';
import '../../../repositories/driver_repository.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/notification_service.dart';
import 'available_rides_view.dart';
import '../../profile/views/captain_profile_view.dart';
import '../../ride_history/views/ride_history_view.dart';
import '../../account/views/account_statement_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../../driver_auth/views/driver_login_view.dart';

class DriverHomeView extends StatelessWidget {
  const DriverHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DriverHomeCubit(
        DriverRepository(FirestoreService()),
      ),
      child: const _DriverHomeBody(),
    );
  }
}

class _DriverHomeBody extends StatefulWidget {
  const _DriverHomeBody();

  @override
  State<_DriverHomeBody> createState() => _DriverHomeBodyState();
}

class _DriverHomeBodyState extends State<_DriverHomeBody> with WidgetsBindingObserver {
  bool _isOnline = false;
  GoogleMapController? _controller;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};

  static const LatLng _initialPosition = LatLng(15.369445, 44.191007);

  // متابعة الرحلات المعلقة لإرسال الإشعارات
  StreamSubscription? _pendingRidesSubscription;
  int _previousRideCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocationPermission();
    // قراءة حالة السائق من Firestore
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<DriverHomeCubit>().loadDriverStatus(uid);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pendingRidesSubscription?.cancel();
    super.dispose();
  }

  /// عند إغلاق التطبيق أو الانتقال للخلفية → حالة offline
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      if (_isOnline) {
        context.read<DriverHomeCubit>().goOffline(uid);
      }
    } else if (state == AppLifecycleState.resumed) {
      // عند العودة للتطبيق — اقرأ الحالة من Firestore
      context.read<DriverHomeCubit>().loadDriverStatus(uid);
    }
  }

  /// بدء الاستماع للرحلات المعلقة عندما يكون الكابتن online
  void _startListeningForRides() {
    _pendingRidesSubscription?.cancel();
    _previousRideCount = 0;
    _pendingRidesSubscription = FirebaseFirestore.instance
        .collection('rides')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      final currentCount = snapshot.docs.length;
      if (currentCount > _previousRideCount && _previousRideCount >= 0) {
        // إشعار جديد
        if (_previousRideCount > 0 || currentCount > 0) {
          final latestDoc = snapshot.docs.isNotEmpty ? snapshot.docs.first.data() : null;
          final customerName = latestDoc?['customerName'] ?? 'عميل';
          NotificationService.showNotification(
            title: 'رحلة جديدة! 🚗',
            body: 'وصل طلب رحلة جديد من $customerName',
          );
        }
      }
      _previousRideCount = currentCount;
    });
  }

  /// إيقاف الاستماع عندما يكون الكابتن offline
  void _stopListeningForRides() {
    _pendingRidesSubscription?.cancel();
    _pendingRidesSubscription = null;
    _previousRideCount = 0;
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

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _markers.removeWhere((m) => m.markerId.value == 'my_location');
          _markers.add(
            Marker(
              markerId: const MarkerId('my_location'),
              position: _currentPosition!,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              infoWindow: const InfoWindow(title: 'موقعي'),
              rotation: position.heading,
            ),
          );
        });

        _controller?.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPosition!, 15),
        );
      }
    } catch (e) {
      // تجاهل
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<DriverHomeCubit, DriverHomeState>(
        listener: (context, state) {
          if (state is DriverLocationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is DriverStatusUpdated) {
            setState(() {
              _isOnline = state.isOnline;
            });
            // بدء أو إيقاف الاستماع للرحلات حسب الحالة
            if (state.isOnline) {
              _startListeningForRides();
            } else {
              _stopListeningForRides();
            }
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _initialPosition,
                  zoom: 15,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                  if (_currentPosition != null) {
                    controller.animateCamera(
                      CameraUpdate.newLatLngZoom(_currentPosition!, 15),
                    );
                  }
                },
              ),

              // الشريط العلوي
              Positioned(
                top: 50,
                left: 16,
                right: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: const Icon(Icons.menu, color: Colors.black),
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: AppTheme.creamBackground,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                              ),
                              builder: (context) {
                                return Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 24.h),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.person, color: AppTheme.deepBurgundy),
                                          title: Text('الملف الشخصي', style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                                          onTap: () {
                                            Navigator.pop(context);
                                            Navigator.push(context, MaterialPageRoute(builder: (_) => const CaptainProfileView()));
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.history, color: AppTheme.deepBurgundy),
                                          title: Text('سجل الرحلات', style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                                          onTap: () {
                                            Navigator.pop(context);
                                            Navigator.push(context, MaterialPageRoute(builder: (_) => const RideHistoryView()));
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.account_balance_wallet, color: AppTheme.deepBurgundy),
                                          title: Text('كشف الحساب', style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                                          onTap: () {
                                            Navigator.pop(context);
                                            Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountStatementView()));
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.logout, color: Colors.red),
                                          title: Text('تسجيل الخروج', style: GoogleFonts.cairo(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.red)),
                                          onTap: () async {
                                            await FirebaseAuth.instance.signOut();
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
                              }
                            );
                          },
                        ),
                      ),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: Icon(
                              Icons.local_taxi,
                              color: _isOnline ? Colors.blue : Colors.grey,
                            ),
                            onPressed: () {
                              if (!_isOnline) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'يجب تفعيل وضع استقبال الطلبات أولاً',
                                      style: GoogleFonts.cairo(),
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AvailableRidesView(),
                                ),
                              );
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
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
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
                                  color: _isOnline ? Colors.green.shade800 : Colors.red.shade800,
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
                bottom: 100,
                right: 16,
                child: FloatingActionButton.small(
                  heroTag: 'location_btn',
                  backgroundColor: AppTheme.pureWhite,
                  onPressed: _getCurrentLocation,
                  child: const Icon(Icons.my_location, color: AppTheme.deepBurgundy),
                ),
              ),

              // زر التبديل السفلي (بدء استقبال الطلبات)
              Positioned(
                bottom: 30,
                left: 24,
                right: 24,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isOnline ? Colors.red : Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    final newStatus = !_isOnline;
                    final driverId = FirebaseAuth.instance.currentUser?.uid ?? '';
                    
                    context.read<DriverHomeCubit>().toggleDriverStatus(driverId, newStatus);
                  },
                  child: Text(
                    _isOnline ? 'إيقاف استقبال الطلبات' : 'بدء استقبال الطلبات',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}