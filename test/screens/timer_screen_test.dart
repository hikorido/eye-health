import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eye_health/services/preferences_service.dart';
import 'package:eye_health/services/timer_service.dart';
import 'package:eye_health/services/abstract_notification_service.dart';
import 'package:eye_health/screens/timer_screen.dart';
import 'package:eye_health/theme/app_theme.dart';

class FakeNotificationService implements AbstractNotificationService {
  final _controller = StreamController<String>.broadcast();

  @override
  Future<void> init() async {}

  @override
  Future<void> scheduleReminder(DateTime at) async {}

  @override
  Future<void> cancelReminder() async {}

  @override
  Future<void> showUnlockResetMessage() async {}

  @override
  Future<void> showOngoingTimer(int sinceTimestamp) async {}

  @override
  Future<void> pauseOngoingTimer(int elapsedMs) async {}

  @override
  Future<void> cancelOngoingTimer() async {}

  @override
  Stream<String> get actionStream => _controller.stream;

  void dispose() => _controller.close();
}

void main() {
  late PreferencesService prefs;
  late FakeNotificationService fakeNotifications;
  late TimerService timerService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = PreferencesService();
    await prefs.init();
    fakeNotifications = FakeNotificationService();
    timerService = TimerService(
      preferencesService: prefs,
      notificationService: fakeNotifications,
    );
    await timerService.init();
  });

  Widget buildSubject() {
    return MaterialApp(
      theme: AppTheme.light(),
      home: TimerScreen(timerService: timerService),
    );
  }

  testWidgets('shows "Session Active" pill when session is active',
      (tester) async {
    await timerService.startSession();
    await tester.pumpWidget(buildSubject());
    await tester.pump();
    expect(find.text('Session Active'), findsOneWidget);
    timerService.dispose();
    fakeNotifications.dispose();
  });

  testWidgets('shows "Time to Rest" pill when no session is active',
      (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();
    expect(find.text('Time to Rest'), findsOneWidget);
    timerService.dispose();
    fakeNotifications.dispose();
  });

  testWidgets('shows 20/20/20 reference numbers', (tester) async {
    await tester.pumpWidget(buildSubject());
    expect(find.text('20'), findsWidgets);
    timerService.dispose();
    fakeNotifications.dispose();
  });

  testWidgets('shows app bar title', (tester) async {
    await tester.pumpWidget(buildSubject());
    expect(find.text('Eye Health'), findsOneWidget);
    timerService.dispose();
    fakeNotifications.dispose();
  });

  testWidgets('shows "open the app" hint when no session (platform-neutral text)', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump();
    // The hint should not contain Android-specific "Unlock your phone" text
    // when tested in the Flutter test environment (non-Android platform).
    // On non-Android: hint reads "Open the app to start..."
    expect(find.textContaining('Open the app'), findsOneWidget);
    timerService.dispose();
    fakeNotifications.dispose();
  });

  testWidgets('countdown updates after one second tick', (tester) async {
    await timerService.startSession();
    await tester.pumpWidget(buildSubject());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    timerService.dispose();
    fakeNotifications.dispose();
  });
}
