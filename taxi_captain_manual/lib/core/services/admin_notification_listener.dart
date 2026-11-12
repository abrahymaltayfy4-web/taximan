/// يستمع لإشعارات الأدمن ويعرضها محلياً — abstraction.
/// التنفيذ في [FirestoreAdminNotificationListener].
abstract interface class AdminNotificationListener {
  /// [targetAll] = 'all_drivers' للكابتن أو 'all_users' للعميل
  /// [targetSpecific] = 'specific_driver' أو 'specific_user'
  void startListening({
    required String targetAll,
    required String targetSpecific,
  });

  void stopListening();
}
