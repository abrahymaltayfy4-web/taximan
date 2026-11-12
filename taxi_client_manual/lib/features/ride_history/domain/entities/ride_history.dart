import 'package:equatable/equatable.dart';
import '../../../rides/domain/entities/ride_entity.dart';

/// نطاق سجل الرحلات
enum RideHistoryFilter {
  today,
  week,
  month;

  /// بداية النطاق بالنسبة إلى [now]
  DateTime startDate(DateTime now) {
    return switch (this) {
      RideHistoryFilter.today => DateTime(now.year, now.month, now.day),
      // آخر 7 أيام
      RideHistoryFilter.week => now.subtract(const Duration(days: 7)),
      // من بداية الشهر الحالي
      RideHistoryFilter.month => DateTime(now.year, now.month, 1),
    };
  }
}

/// سجل الرحلات المكتملة مع الإجماليات
class RideHistory extends Equatable {
  final List<RideEntity> rides;
  final double totalFare;

  const RideHistory({required this.rides, required this.totalFare});

  int get totalRides => rides.length;

  factory RideHistory.fromRides(List<RideEntity> rides) {
    return RideHistory(
      rides: rides,
      totalFare: rides.fold<double>(0, (sum, r) => sum + r.fare),
    );
  }

  @override
  List<Object?> get props => [rides, totalFare];
}
