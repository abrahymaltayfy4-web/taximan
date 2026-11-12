/// حالة حساب المستخدم (سائق أو عميل)
enum AccountStatus {
  active('active'),
  pending('pending'),
  rejected('rejected'),
  suspended('suspended'),
  blocked('blocked'),
  disabled('disabled');

  final String value;
  const AccountStatus(this.value);

  /// تحويل من String (Firestore) إلى enum
  static AccountStatus fromString(String? value) {
    return AccountStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => AccountStatus.active,
    );
  }

  /// هل يُسمح بالدخول للتطبيق؟
  bool get canLogin => this == active || this == suspended;

  /// هل يُسمح بقبول/طلب رحلات؟
  bool get canUseRides => this == active;

  /// رسالة التوضيح للمستخدم
  String get userMessage => switch (this) {
    active => '',
    pending => 'حسابك قيد المراجعة. سيتم إعلامك عند الموافقة.',
    rejected => 'تم رفض طلب تسجيلك. تواصل مع الإدارة.',
    suspended => 'حسابك موقوف مؤقتاً. تواصل مع الإدارة.',
    blocked => 'حسابك محظور. تواصل مع الإدارة.',
    disabled => 'حسابك معطل. تواصل مع الإدارة.',
  };
}
