import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:taxi_captain_manual/features/driver_home/cubit/driver_home_cubit.dart';

class DriverHomeView extends StatefulWidget {
  const DriverHomeView({Key? key}) : super(key: key);

  @override
  State<DriverHomeView> createState() => _DriverHomeViewState();
}

class _DriverHomeViewState extends State<DriverHomeView> {
  bool _isOnline = false;
  GoogleMapController? _controller;

  // الموقع الافتراضي (يمكن ربطه بـ Geolocator لاحقاً لتحديث الكاميرا)
  static const LatLng _initialPosition = LatLng(15.369445, 44.191007);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // خريطة جوجل
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _initialPosition,
              zoom: 15,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
          ),

          // شريط علوي لحالة الكابتن والتحكم بالاتصال
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // زر القائمة الجانبية أو الملف الشخصي
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: () {
                      // فتح القائمة الجانبية
                    },
                  ),
                ),
                // حالة الاتصال الحالية
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
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
                        style: TextStyle(
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
          ),

          // زر التبديل السفلي (متصل / غير متصل) لاستقبال الطلبات
          Positioned(
            bottom: 30,
            left: 24,
            right: 24,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isOnline ? Colors.red : Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
                // shape: RoundedRectangleMapFix.roundedButton(), // أو استخدام RoundedRectangleBorder
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              onPressed: () {
                final newStatus = !_isOnline;
                // استدعاء الـ Cubit لتحديث الحالة وتفعيل GPS
                context.read<DriverHomeCubit>().toggleDriverStatus(
                  'driver_id_here',
                  newStatus,
                );

                setState(() {
                  _isOnline = newStatus;
                });
                // هنا يتم إرسال الحالة الجديدة إلى Firebase لتحديث توفر الكابتن
              },
              child: Text(
                _isOnline ? 'إيقاف استقبال الطلبات' : 'بدء استقبال الطلبات',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
