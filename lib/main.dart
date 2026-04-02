import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'package:eye_health/services/notification_service.dart';
import 'package:eye_health/services/preferences_service.dart';
import 'package:eye_health/services/timer_service.dart';
import 'package:eye_health/services/abstract_unlock_service.dart';
import 'package:eye_health/services/unlock_service_android.dart';
import 'package:eye_health/services/usage_stats_service.dart';
import 'package:eye_health/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  await Workmanager().initialize(callbackDispatcher);

  final prefs = PreferencesService();
  await prefs.init();

  final notifications = NotificationService();
  await notifications.init();

  final timer = TimerService(
    preferencesService: prefs,
    notificationService: notifications,
  );
  await timer.init();

  final AbstractUnlockService unlockService = UnlockServiceAndroid(timerService: timer);
  unlockService.startListening();

  final usageStats = UsageStatsService();

  runApp(EyeHealthApp(
    timerService: timer,
    usageStatsService: usageStats,
  ));
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    return Future.value(true);
  });
}
