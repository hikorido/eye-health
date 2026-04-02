import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:eye_health/services/abstract_notification_service.dart';

const _notificationId = 1;
const _categoryId = 'eye_health_category';
const _actionIdDoneResting = 'done_resting';
const _keyPendingRest = '_pending_rest_complete';

@pragma('vm:entry-point')
void onIosBackgroundNotificationResponse(NotificationResponse response) async {
  if (response.actionId == _actionIdDoneResting) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPendingRest, true);
  }
}

class NotificationServiceIos implements AbstractNotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  final _controller = StreamController<String>.broadcast();

  @override
  Future<void> init() async {
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: [
        DarwinNotificationCategory(
          _categoryId,
          actions: [
            DarwinNotificationAction.plain(
              _actionIdDoneResting,
              'Done Resting',
              options: {DarwinNotificationActionOption.foreground},
            ),
          ],
        ),
      ],
    );
    const initSettings = InitializationSettings(darwin: darwinInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.actionId == _actionIdDoneResting) {
          _controller.add(_actionIdDoneResting);
        }
      },
      onDidReceiveBackgroundNotificationResponse:
          onIosBackgroundNotificationResponse,
    );
  }

  @override
  Future<void> scheduleReminder(DateTime at) async {
    const darwinDetails = DarwinNotificationDetails(
      categoryIdentifier: _categoryId,
    );
    const details = NotificationDetails(iOS: darwinDetails);

    await _plugin.zonedSchedule(
      _notificationId,
      'Time to rest your eyes!',
      'Look 20 feet away for 20 seconds.',
      tz.TZDateTime.from(at, tz.local),
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  Future<void> cancelReminder() async {
    await _plugin.cancel(_notificationId);
  }

  @override
  Stream<String> get actionStream => _controller.stream;
}
