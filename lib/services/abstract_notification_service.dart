abstract class AbstractNotificationService {
  Future<void> init();
  Future<void> scheduleReminder(DateTime at);
  Future<void> cancelReminder();
  Stream<String> get actionStream;
}
