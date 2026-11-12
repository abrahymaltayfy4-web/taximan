/// حالات الرحلة وانتقالاتها المسموحة
enum RideStatus {
  pending('pending'),
  accepted('accepted'),
  driverArrived('driver_arrived'),
  started('started'),
  completed('completed'),
  cancelled('cancelled');

  final String value;
  const RideStatus(this.value);

  static RideStatus fromString(String? value) {
    return RideStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => RideStatus.pending,
    );
  }

  /// الانتقالات المسموحة من هذه الحالة
  List<RideStatus> get allowedTransitions => switch (this) {
    pending => [accepted, cancelled],
    accepted => [driverArrived, cancelled],
    driverArrived => [started],
    started => [completed],
    completed => [],
    cancelled => [],
  };

  /// هل يُسمح بالانتقال لحالة معينة؟
  bool canTransitionTo(RideStatus next) => allowedTransitions.contains(next);

  /// هل الرحلة نشطة (لم تنتهِ)؟
  bool get isActive => this != completed && this != cancelled;
}
