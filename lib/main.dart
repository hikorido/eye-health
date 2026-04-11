import 'dart:io';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'package:eye_health/services/abstract_notification_service.dart';
import 'package:eye_health/services/abstract_unlock_service.dart';
import 'package:eye_health/services/abstract_usage_stats_service.dart';
import 'package:eye_health/services/notification_service_android.dart';
import 'package:eye_health/services/notification_service_ios.dart';
import 'package:eye_health/services/unlock_service_android.dart';
import 'package:eye_health/services/unlock_service_ios.dart';
import 'package:eye_health/services/usage_stats_service_android.dart';
import 'package:eye_health/services/usage_stats_service_ios.dart';
import 'package:eye_health/services/preferences_service.dart';
import 'package:eye_health/services/timer_service.dart';
import 'package:eye_health/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();

  await Workmanager().initialize(callbackDispatcher);

  final prefs = PreferencesService();
  await prefs.init();

  final AbstractNotificationService notifications = Platform.isIOS
      ? NotificationServiceIos()
      : NotificationServiceAndroid();
  await notifications.init();

  final timer = TimerService(
    preferencesService: prefs,
    notificationService: notifications,
  );
  await timer.init();

  final AbstractUnlockService unlockService = Platform.isIOS
      ? UnlockServiceIos(timerService: timer)
      : UnlockServiceAndroid(timerService: timer);
  unlockService.startListening();
  await timer.onUnlock();

  final AbstractUsageStatsService usageStats = Platform.isIOS
      ? UsageStatsServiceIos()
      : UsageStatsServiceAndroid();

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
