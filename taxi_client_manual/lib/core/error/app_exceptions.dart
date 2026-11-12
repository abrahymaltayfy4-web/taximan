/// استثناءات مُنمذجة تُرمى من طبقة Data وتُحوَّل إلى Failure عبر ErrorMapper.
/// بديل لـ `throw Exception('نص عربي')` ثم مطابقة النص (كان هشاً).
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

final class RideNotFoundException extends AppException {
  const RideNotFoundException() : super('Ride not found');
}

/// الرحلة لم تعد في حالة pending (قُبلت من كابتن آخر أو أُلغيت)
final class RideUnavailableException extends AppException {
  const RideUnavailableException() : super('Ride is no longer available');
}

final class DriverNotFoundException extends AppException {
  const DriverNotFoundException() : super('Driver profile not found');
}

final class AccountBlockedException extends AppException {
  const AccountBlockedException() : super('Account is blocked');
}

final class WrongAccountTypeException extends AppException {
  const WrongAccountTypeException() : super('Wrong account type');
}
