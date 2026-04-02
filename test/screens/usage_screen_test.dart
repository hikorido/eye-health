import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eye_health/models/usage_data.dart';
import 'package:eye_health/services/preferences_service.dart';
import 'package:eye_health/services/timer_service.dart';
import 'package:eye_health/services/abstract_notification_service.dart';
import 'package:eye_health/services/abstract_usage_stats_service.dart';
import 'package:eye_health/screens/usage_screen.dart';
import 'package:eye_health/theme/app_theme.dart';

class FakeNotificationService implements AbstractNotificationService {
  final _c = StreamController<String>.broadcast();
  @override Future<void> init() async {}
  @override Future<void> scheduleReminder(DateTime at) async {}
  @override Future<void> cancelReminder() async {}
  @override Future<void> showOngoingTimer(int sinceTimestamp) async {}
  @override Future<void> pauseOngoingTimer(int elapsedMs) async {}
  @override Future<void> cancelOngoingTimer() async {}
  @override Stream<String> get actionStream => _c.stream;
  void dispose() => _c.close();
}

class FakeUsageStatsService implements AbstractUsageStatsService {
  final UsageData _data;
  final bool _hasPermission;

  FakeUsageStatsService({
    required UsageData data,
    bool hasPermission = true,
  })  : _data = data,
        _hasPermission = hasPermission;

  @override
  Future<UsageData> fetchTodayUsage() async => _data;

  @override
  Future<bool> hasPermission() async => _hasPermission;

  @override
  Future<void> openPermissionSettings() async {}
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

  tearDown(() {
    timerService.dispose();
    fakeNotifications.dispose();
  });

  Widget buildSubject({
    UsageData? data,
    bool hasPermission = true,
  }) {
    return MaterialApp(
      theme: AppTheme.light(),
      home: UsageScreen(
        usageStatsService: FakeUsageStatsService(
          data: data ??
              UsageData(
                totalMinutes: 204,
                hourlyMinutes: List.generate(
                    24, (i) => i < 8 ? 0 : (i % 3) * 10),
              ),
          hasPermission: hasPermission,
        ),
        timerService: timerService,
      ),
    );
  }

  testWidgets('shows total usage time formatted as Xh Ym', (tester) async {
    await tester.pumpWidget(buildSubject(
      data: UsageData(
        totalMinutes: 204,
        hourlyMinutes: List.filled(24, 0),
      ),
    ));
    await tester.pump();
    // 204 minutes = 3h 24m
    expect(find.text('3h 24m'), findsOneWidget);
  });

  testWidgets('shows permission prompt when permission not granted',
      (tester) async {
    await tester.pumpWidget(buildSubject(hasPermission: false));
    await tester.pump();
    expect(find.text('Grant Permission'), findsOneWidget);
  });

  testWidgets('shows app bar title', (tester) async {
    await tester.pumpWidget(buildSubject());
    expect(find.text("Today's Usage"), findsOneWidget);
  });

  testWidgets('shows break counter on iOS platform (simulated via empty data + no total/chart)', (tester) async {
    // UsageStatsServiceIos always returns empty data.
    // The iOS branch in UsageScreen should show the break label but not "Total screen time today".
    await tester.pumpWidget(buildSubject(
      data: UsageData(totalMinutes: 0, hourlyMinutes: List.filled(24, 0)),
    ));
    await tester.pump();
    // The break card is always shown
    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });

  testWidgets('shows rest breaks count', (tester) async {
    await prefs.setBreaksTakenToday(3);
    final now = DateTime.now();
    await prefs.setBreaksDate(
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}');
    timerService.dispose();
    timerService = TimerService(
      preferencesService: prefs,
      notificationService: fakeNotifications,
    );
    await timerService.init();

    await tester.pumpWidget(buildSubject());
    await tester.pump();
    expect(find.textContaining('3'), findsWidgets);
  });
}
