/// أسماء مجموعات Firestore ومستنداتها — مصدر واحد بدل الـ magic strings.
/// تُستخدم في طبقة Data فقط.
abstract final class FirestoreCollections {
  static const String drivers = 'drivers';
  static const String clients = 'clients';
  static const String rides = 'rides';
  static const String transactions = 'transactions';
  static const String settings = 'settings';
  static const String notifications = 'notifications';

  /// مستند إعدادات التسعير داخل [settings]
  static const String pricingDoc = 'pricing';
}
