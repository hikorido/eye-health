import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eye_health/services/abstract_unlock_service.dart';
import 'package:eye_health/services/unlock_service_ios.dart';
import 'package:eye_health/services/timer_service.dart';
import 'package:eye_health/services/preferences_service.dart';
import 'package:eye_health/services/abstract_notification_service.dart';

class FakeNotificationService implements AbstractNotificationService {
  final _c = StreamController<String>.broadcast();
  @override Future<void> init() async {}
  @override Future<void> scheduleReminder(DateTime at) async {}
  @override Future<void> cancelReminder() async {}
  @override Stream<String> get actionStream => _c.stream;
  void dispose() => _c.close();
}

Future<(TimerService, FakeNotificationService)> _makeServices() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = PreferencesService();
  await prefs.init();
  final fakeNotifications = FakeNotificationService();
  final timerService = TimerService(
    preferencesService: prefs,
    notificationService: fakeNotifications,
  );
  await timerService.init();
  return (timerService, fakeNotifications);
}

void main() {
  testWidgets('UnlockServiceIos implements AbstractUnlockService', (tester) async {
    final (timerService, fakeNotifications) = await _makeServices();
    final service = UnlockServiceIos(timerService: timerService);
    expect(service, isA<AbstractUnlockService>());
    timerService.dispose();
    fakeNotifications.dispose();
  });

  testWidgets('startListening — calls timerService.onUnlock when app resumes', (tester) async {
    final (timerService, fakeNotifications) = await _makeServices();
    final service = UnlockServiceIos(timerService: timerService);
    service.startListening();

    expect(timerService.state.isActive, isFalse);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(timerService.state.isActive, isTrue);
    timerService.dispose();
    fakeNotifications.dispose();
  });

  testWidgets('startListening — does not start session on pause', (tester) async {
    final (timerService, fakeNotifications) = await _makeServices();
    final service = UnlockServiceIos(timerService: timerService);
    service.startListening();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();

    expect(timerService.state.isActive, isFalse);
    timerService.dispose();
    fakeNotifications.dispose();
  });
}
