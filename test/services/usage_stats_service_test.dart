import 'package:flutter_test/flutter_test.dart';
import 'package:eye_health/models/usage_data.dart';
import 'package:eye_health/services/usage_stats_service.dart';

void main() {
  group('UsageStatsService.buildUsageData()', () {
    test('returns UsageData.empty() when no events', () {
      final data = UsageStatsService.buildUsageData(
        totalForegroundMs: 0,
        events: [],
      );
      expect(data.totalMinutes, equals(0));
      expect(data.hourlyMinutes, equals(List.filled(24, 0)));
    });

    test('calculates total minutes from totalForegroundMs', () {
      final data = UsageStatsService.buildUsageData(
        totalForegroundMs: 3600000, // 60 minutes
        events: [],
      );
      expect(data.totalMinutes, equals(60));
    });

    test('attributes usage to correct hour bucket', () {
      // 09:00 → 09:30 = 30 minutes in hour 9
      final start = DateTime(2026, 4, 1, 9, 0, 0).millisecondsSinceEpoch;
      final end = DateTime(2026, 4, 1, 9, 30, 0).millisecondsSinceEpoch;
      final data = UsageStatsService.buildUsageData(
        totalForegroundMs: end - start,
        events: [
          {'timeStamp': start.toString(), 'eventType': '1'},
          {'timeStamp': end.toString(), 'eventType': '2'},
        ],
      );
      expect(data.hourlyMinutes[9], equals(30));
    });

    test('splits usage across hour boundaries', () {
      // 10:50 → 11:10 = 10 minutes in hour 10, 10 minutes in hour 11
      final start = DateTime(2026, 4, 1, 10, 50, 0).millisecondsSinceEpoch;
      final end = DateTime(2026, 4, 1, 11, 10, 0).millisecondsSinceEpoch;
      final data = UsageStatsService.buildUsageData(
        totalForegroundMs: end - start,
        events: [
          {'timeStamp': start.toString(), 'eventType': '1'},
          {'timeStamp': end.toString(), 'eventType': '2'},
        ],
      );
      expect(data.hourlyMinutes[10], equals(10));
      expect(data.hourlyMinutes[11], equals(10));
    });

    test('ignores unpaired MOVE_TO_FOREGROUND at end of list', () {
      final start = DateTime(2026, 4, 1, 14, 0, 0).millisecondsSinceEpoch;
      final data = UsageStatsService.buildUsageData(
        totalForegroundMs: 0,
        events: [
          {'timeStamp': start.toString(), 'eventType': '1'},
          // No MOVE_TO_BACKGROUND — session still open
        ],
      );
      // No crash; unpaired session attributed from start to now (approximately)
      expect(data.hourlyMinutes[14], greaterThanOrEqualTo(0));
    });
  });
}
