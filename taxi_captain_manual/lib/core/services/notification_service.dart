/// عرض إشعار محلي — abstraction حتى لا تعتمد Cubits/Domain على
/// flutter_local_notifications. التنفيذ في [LocalNotificationService].
abstract interface class NotificationService {
  Future<void> initialize();

  Future<void> show({required String title, required String body});
}
