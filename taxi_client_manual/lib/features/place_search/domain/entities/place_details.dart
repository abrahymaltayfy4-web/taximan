import 'package:equatable/equatable.dart';

/// كيان تفاصيل المكان — يحتوي على الإحداثيات والاسم
/// يُرجع من [GetPlaceDetailsUseCase] بعد اختيار اقتراح
class PlaceDetails extends Equatable {
  /// معرّف المكان من Google
  final String placeId;

  /// اسم المكان
  final String name;

  /// العنوان الكامل
  final String formattedAddress;

  /// خط العرض
  final double latitude;

  /// خط الطول
  final double longitude;

  const PlaceDetails({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
        placeId,
        name,
        formattedAddress,
        latitude,
        longitude,
      ];
}
