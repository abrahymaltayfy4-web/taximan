// lib/features/home/models/ride_model.dart
class RideModel {
  final String? rideId;
  final String clientId;
  final String clientName;
  final String pickupLocation;
  final String destinationLocation;
  final String status; // 'pending', 'accepted', 'completed', 'cancelled'
  final double? fare;
  
  RideModel({
    this.rideId,
    required this.clientId,
    required this.clientName,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.status,
    this.fare,
  });

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'clientName': clientName,
      'pickupLocation': pickupLocation,
      'destinationLocation': destinationLocation,
      'status': status,
      'fare': fare,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}