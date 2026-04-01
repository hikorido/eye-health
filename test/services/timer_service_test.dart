import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eye_health/services/preferences_service.dart';
import 'package:eye_health/services/timer_service.dart';
import 'package:eye_health/services/abstract_notification_service.dart';

class FakeNotificationService implements AbstractNotificationService {
  final _controller = StreamController<String>.broadcast();
  DateTime? scheduledAt;
  bool cancelCalled = false;

  @override
  Future<void> init() async {}

  @override
  Future<void> scheduleReminder(DateTime at) async {
    scheduledAt = at;
  }

  @override
  Future<void> cancelReminder() async {
    cancelCalled = true;
  }

  @override
  Stream<String> get actionStream => _controller.stream;

  void emitAction(String action) => _controller.add(action);

  void dispose() => _controller.close();
}

void main() {
  late PreferencesService prefs;
  late FakeNotificationService notifications;
  late TimerService timerService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = PreferencesService();
    await prefs.init();
    notifications = FakeNotificationService();
    timerService = TimerService(
      preferencesService: prefs,
      notificationService: notifications,
    );
  });

  tearDown(() {
    timerService.dispose();
    notifications.dispose();
  });

  group('TimerService.init()', () {
    test('state has no active session when no timestamp stored', () async {
      await timerService.init();
      expect(timerService.state.isActive, isFalse);
    });

    test('resumes session when stored timestamp is recent', () async {
      final recent = DateTime.now()
          .subtract(const Duration(minutes: 5))
          .millisecondsSinceEpoch;
      await prefs.setSessionStartTimestamp(recent);
      await timerService.init();
      expect(timerService.state.isActive, isTrue);
    });

    test('clears stale session when stored timestamp is older than 20 min',
        () async {
      final stale = DateTime.now()
          .subtract(const Duration(minutes: 25))
          .millisecondsSinceEpoch;
      await prefs.setSessionStartTimestamp(stale);
      await timerService.init();
      expect(timerService.state.isActive, isFalse);
    });

    test('processes pending rest complete flag on init — counts break and starts session', () async {
      await prefs.setPendingRestComplete(true);
      final recent = DateTime.now()
          .subtract(const Duration(minutes: 5))
          .millisecondsSinceEpoch;
      await prefs.setSessionStartTimestamp(recent);
      await timerService.init();
      expect(prefs.getPendingRestComplete(), isFalse);
      expect(timerService.state.breaksTakenToday, greaterThan(0));
      expect(timerService.state.isActive, isTrue);
    });
  });

  group('TimerService.startSession()', () {
    test('sets isActive to true', () async {
      await timerService.init();
      await timerService.startSession();
      expect(timerService.state.isActive, isTrue);
    });

    test('persists timestamp to preferences', () async {
      await timerService.init();
      await timerService.startSession();
      expect(prefs.getSessionStartTimestamp(), isNotNull);
    });

    test('schedules notification 20 minutes in the future', () async {
      await timerService.init();
      final before = DateTime.now();
      await timerService.startSession();
      final scheduled = notifications.scheduledAt!;
      expect(
        scheduled.difference(before).inMinutes,
        greaterThanOrEqualTo(19),
      );
    });

    test('does nothing if session is already active', () async {
      await timerService.init();
      await timerService.startSession();
      final firstTimestamp = prefs.getSessionStartTimestamp();
      await timerService.startSession();
      expect(prefs.getSessionStartTimestamp(), equals(firstTimestamp));
    });
  });

  group('TimerService.completeRest()', () {
    test('clears session, increments break count, and starts new session',
        () async {
      await timerService.init();
      await timerService.startSession();
      final breaksBefore = timerService.state.breaksTakenToday;
      await timerService.completeRest();
      expect(timerService.state.breaksTakenToday, equals(breaksBefore + 1));
      expect(timerService.state.isActive, isTrue);
    });

    test('resets break count when breaksDate is a different day', () async {
      await prefs.setBreaksDate('2026-03-31');
      await prefs.setBreaksTakenToday(5);
      await timerService.init();
      await timerService.startSession();
      await timerService.completeRest();
      expect(timerService.state.breaksTakenToday, equals(1));
    });
  });

  group('TimerService.onUnlock()', () {
    test('starts session if none is active', () async {
      await timerService.init();
      expect(timerService.state.isActive, isFalse);
      await timerService.onUnlock();
      expect(timerService.state.isActive, isTrue);
    });

    test('does not restart session if already active', () async {
      await timerService.init();
      await timerService.startSession();
      final ts = prefs.getSessionStartTimestamp();
      await timerService.onUnlock();
      expect(prefs.getSessionStartTimestamp(), equals(ts));
    });
  });

  group('TimerService.remainingSeconds', () {
    test('returns approximately 1200 seconds for a brand-new session',
        () async {
      await timerService.init();
      await timerService.startSession();
      expect(timerService.remainingSeconds, closeTo(1200, 2));
    });

    test('returns 0 for no active session', () async {
      await timerService.init();
      expect(timerService.remainingSeconds, equals(0));
    });
  });
}
