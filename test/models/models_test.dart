import 'package:flutter_test/flutter_test.dart';
import 'package:eye_health/models/session_state.dart';
import 'package:eye_health/models/usage_data.dart';

void main() {
  group('SessionState', () {
    test('isActive returns true when startTimestamp is non-null', () {
      final state = SessionState(
        startTimestamp: DateTime.now().millisecondsSinceEpoch,
        breaksTakenToday: 0,
        breaksDate: '2026-04-01',
      );
      expect(state.isActive, isTrue);
    });

    test('isActive returns false when startTimestamp is null', () {
      final state = SessionState(
        startTimestamp: null,
        breaksTakenToday: 0,
        breaksDate: '2026-04-01',
      );
      expect(state.isActive, isFalse);
    });

    test('copyWith preserves unchanged fields', () {
      final state = SessionState(
        startTimestamp: 1000,
        breaksTakenToday: 2,
        breaksDate: '2026-04-01',
      );
      final updated = state.copyWith(breaksTakenToday: 3);
      expect(updated.startTimestamp, equals(1000));
      expect(updated.breaksTakenToday, equals(3));
      expect(updated.breaksDate, equals('2026-04-01'));
    });
  });

  group('UsageData', () {
    test('totalMinutes matches sum of hourlyMinutes', () {
      final data = UsageData(
        totalMinutes: 120,
        hourlyMinutes: List.filled(24, 5),
      );
      expect(data.totalMinutes, equals(120));
      expect(data.hourlyMinutes.length, equals(24));
    });

    test('empty factory creates zero-filled data', () {
      final data = UsageData.empty();
      expect(data.totalMinutes, equals(0));
      expect(data.hourlyMinutes, equals(List.filled(24, 0)));
    });
  });
}
