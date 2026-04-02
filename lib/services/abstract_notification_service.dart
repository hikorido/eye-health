abstract class AbstractNotificationService {
  Future<void> init();
  Future<void> scheduleReminder(DateTime at);
  Future<void> cancelReminder();
  Future<void> showOngoingTimer(int sinceTimestamp);
  Future<void> pauseOngoingTimer(int elapsedMs);
  Future<void> cancelOngoingTimer();
  Stream<String> get actionStream;
}
