import 'package:cloud_firestore/cloud_firestore.dart';

/// تمثيل مستند الرحلة في Firestore (DTO)
class RideModel {
  final String rideId;
  final Map<String, dynamic> data;

  const RideModel(this.rideId, this.data);

  GeoPoint? geoPoint(String key) {
    final v = data[key];
    return v is GeoPoint ? v : null;
  }

  DateTime? timestamp(String key) {
    final v = data[key];
    return v is Timestamp ? v.toDate() : null;
  }

  double number(String key) => (data[key] ?? 0.0).toDouble();

  String text(String key) => data[key] ?? '';

  String? optionalText(String key) => data[key];
}
