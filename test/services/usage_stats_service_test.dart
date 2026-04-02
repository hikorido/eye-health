import 'package:flutter_test/flutter_test.dart';
import 'package:eye_health/models/usage_data.dart';
import 'package:eye_health/services/usage_stats_service_android.dart';

void main() {
  group('UsageStatsServiceAndroid.buildUsageData()', () {
    test('returns UsageData.empty() when no events', () {
      final data = UsageStatsServiceAndroid.buildUsageData(
        totalForegroundMs: 0,
        events: [],
      );
      expect(data.totalMinutes, equals(0));
      expect(data.hourlyMinutes, equals(List.filled(24, 0)));
    });

    test('calculates total minutes from totalForegroundMs', () {
      final data = UsageStatsServiceAndroid.buildUsageData(
        totalForegroundMs: 3600000,
        events: [],
      );
      expect(data.totalMinutes, equals(60));
    });

    test('attributes usage to correct hour bucket', () {
      final start = DateTime(2026, 4, 1, 9, 0, 0).millisecondsSinceEpoch;
      final end = DateTime(2026, 4, 1, 9, 30, 0).millisecondsSinceEpoch;
      final data = UsageStatsServiceAndroid.buildUsageData(
        totalForegroundMs: end - start,
        events: [
          {'timeStamp': start.toString(), 'eventType': '1'},
          {'timeStamp': end.toString(), 'eventType': '2'},
        ],
      );
      expect(data.hourlyMinutes[9], equals(30));
    });

    test('splits usage across hour boundaries', () {
      final start = DateTime(2026, 4, 1, 10, 50, 0).millisecondsSinceEpoch;
      final end = DateTime(2026, 4, 1, 11, 10, 0).millisecondsSinceEpoch;
      final data = UsageStatsServiceAndroid.buildUsageData(
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
      final data = UsageStatsServiceAndroid.buildUsageData(
        totalForegroundMs: 0,
        events: [
          {'timeStamp': start.toString(), 'eventType': '1'},
        ],
      );
      expect(data.hourlyMinutes[14], greaterThanOrEqualTo(0));
    });
  });
}
