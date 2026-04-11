import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:eye_health/services/abstract_notification_service.dart';

const _notificationId = 1;
const _channelId = 'eye_health_reminders';
const _channelName = 'Eye Health Reminders';
const _actionIdDoneResting = 'done_resting';
const _keyPendingRest = '_pending_rest_complete';
const _ongoingNotificationId = 2;
const _ongoingChannelId = 'eye_health_ongoing';
const _ongoingChannelName = 'Eye Health Ongoing';
const _unlockResetNotificationId = 3;

@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse response) async {
  if (response.actionId == _actionIdDoneResting) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPendingRest, true);
  }
}

class NotificationServiceAndroid implements AbstractNotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  final _controller = StreamController<String>.broadcast();

  @override
  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (response.actionId == _actionIdDoneResting) {
          _controller.add(_actionIdDoneResting);
        }
      },
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundNotificationResponse,
    );

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: '20-20-20 eye health reminders',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    const ongoingChannel = AndroidNotificationChannel(
      _ongoingChannelId,
      _ongoingChannelName,
      description: 'Live timer showing time since last break',
      importance: Importance.low,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(ongoingChannel);
  }

  @override
  Future<void> scheduleReminder(DateTime at) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: '20-20-20 eye health reminders',
      importance: Importance.high,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction(
          _actionIdDoneResting,
          'Done Resting',
          showsUserInterface: true,
        ),
      ],
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      _notificationId,
      'Time to rest your eyes!',
      'Look 20 feet away for 20 seconds.',
      tz.TZDateTime.from(at, tz.local),
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancelReminder() async {
    await _plugin.cancel(_notificationId);
  }

  @override
  Future<void> showUnlockResetMessage() async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: '20-20-20 eye health reminders',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      _unlockResetNotificationId,
      'Timer reset',
      'Due to unlock, timer reset to 20:00.',
      details,
    );
  }

  @override
  Future<void> showOngoingTimer(int sinceTimestamp) async {
    final androidDetails = AndroidNotificationDetails(
      _ongoingChannelId,
      _ongoingChannelName,
      channelDescription: 'Live timer showing time since last break',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      usesChronometer: true,
      when: sinceTimestamp,
    );
    final details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      _ongoingNotificationId,
      'Eye Health',
      'Time since last break',
      details,
    );
  }

  @override
  Future<void> pauseOngoingTimer(int _elapsedMs) async {
    const androidDetails = AndroidNotificationDetails(
      _ongoingChannelId,
      _ongoingChannelName,
      channelDescription: 'Live timer showing time since last break',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      _ongoingNotificationId,
      'Time to rest!',
      'Look 20 feet away for 20 seconds.',
      details,
    );
  }

  @override
  Future<void> cancelOngoingTimer() async {
    await _plugin.cancel(_ongoingNotificationId);
  }

  @override
  Stream<String> get actionStream => _controller.stream;
}
