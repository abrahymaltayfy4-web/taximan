import 'package:flutter/foundation.dart';
import '../../features/rides/domain/entities/ride_entity.dart';

/// وسائط شاشة معاينة الرحلة
class RidePreviewArgs {
  final RideEntity ride;
  final VoidCallback onAccept;

  const RidePreviewArgs({required this.ride, required this.onAccept});
}
