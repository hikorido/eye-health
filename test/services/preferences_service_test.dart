import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eye_health/services/preferences_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PreferencesService — session timestamp', () {
    test('getSessionStartTimestamp returns null when not set', () async {
      final prefs = PreferencesService();
      await prefs.init();
      expect(prefs.getSessionStartTimestamp(), isNull);
    });

    test('setSessionStartTimestamp persists value', () async {
      final prefs = PreferencesService();
      await prefs.init();
      await prefs.setSessionStartTimestamp(1000000);
      expect(prefs.getSessionStartTimestamp(), equals(1000000));
    });

    test('clearSessionStartTimestamp removes value', () async {
      final prefs = PreferencesService();
      await prefs.init();
      await prefs.setSessionStartTimestamp(1000000);
      await prefs.clearSessionStartTimestamp();
      expect(prefs.getSessionStartTimestamp(), isNull);
    });
  });

  group('PreferencesService — breaks', () {
    test('getBreaksTakenToday returns 0 when not set', () async {
      final prefs = PreferencesService();
      await prefs.init();
      expect(prefs.getBreaksTakenToday(), equals(0));
    });

    test('setBreaksTakenToday persists value', () async {
      final prefs = PreferencesService();
      await prefs.init();
      await prefs.setBreaksTakenToday(3);
      expect(prefs.getBreaksTakenToday(), equals(3));
    });

    test('getBreaksDate returns empty string when not set', () async {
      final prefs = PreferencesService();
      await prefs.init();
      expect(prefs.getBreaksDate(), equals(''));
    });

    test('setBreaksDate persists value', () async {
      final prefs = PreferencesService();
      await prefs.init();
      await prefs.setBreaksDate('2026-04-01');
      expect(prefs.getBreaksDate(), equals('2026-04-01'));
    });
  });

  group('PreferencesService — pending rest complete flag', () {
    test('getPendingRestComplete returns false when not set', () async {
      final prefs = PreferencesService();
      await prefs.init();
      expect(prefs.getPendingRestComplete(), isFalse);
    });

    test('setPendingRestComplete persists true', () async {
      final prefs = PreferencesService();
      await prefs.init();
      await prefs.setPendingRestComplete(true);
      expect(prefs.getPendingRestComplete(), isTrue);
    });
  });

  group('PreferencesService — theme override', () {
    test('getThemeOverride returns system when not set', () async {
      final prefs = PreferencesService();
      await prefs.init();
      expect(prefs.getThemeOverride(), equals('system'));
    });

    test('setThemeOverride persists value', () async {
      final prefs = PreferencesService();
      await prefs.init();
      await prefs.setThemeOverride('dark');
      expect(prefs.getThemeOverride(), equals('dark'));
    });
  });
}
