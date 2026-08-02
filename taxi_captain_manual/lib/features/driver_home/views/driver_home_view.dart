// lib/features/driver_home/views/driver_home_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../cubit/driver_home_cubit.dart';
import '../../../repositories/driver_repository.dart';
import '../../../core/services/firestore_service.dart';

class DriverHomeView extends StatelessWidget {
  const DriverHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // توفير الـ Cubit محلياً داخل الشاشة لضمان عدم حدوث خطأ ProviderNotFound
    return BlocProvider(
      create: (context) => DriverHomeCubit(
        DriverRepository(FirestoreService()),
      ),
      child: const _DriverHomeBody(),
    );
  }
}

class _DriverHomeBody extends StatefulWidget {
  const _DriverHomeBody({Key? key}) : super(key: key);

  @override
  State<_DriverHomeBody> createState() => _DriverHomeBodyState();
}

class _DriverHomeBodyState extends State<_DriverHomeBody> {
  bool _isOnline = false;
  GoogleMapController? _controller;

  static const LatLng _initialPosition = LatLng(15.369445, 44.191007);

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
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
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
                        onPressed: () {},
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              color: _isOnline ? Colors.green.shade800 : Colors.red.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                    
                    // الآن سيعمل الـ context بسلام لأن BlocProvider يقع فوق هذا الـ Widget مباشرة
                    context.read<DriverHomeCubit>().toggleDriverStatus(driverId, newStatus);
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
          );
        },
      ),
    );
  }
}