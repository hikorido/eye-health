import 'package:usage_stats/usage_stats.dart';
import 'package:eye_health/models/usage_data.dart';

class UsageStatsService {
  /// Fetches today's usage data from the system.
  /// Returns [UsageData.empty()] if permission is not granted.
  Future<UsageData> fetchTodayUsage() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final granted = await UsageStats.checkUsagePermission() ?? false;
      if (!granted) return UsageData.empty();

      final usageInfoList = await UsageStats.queryUsageStats(startOfDay, now);

      final totalMs = usageInfoList.fold<int>(0, (sum, info) {
        return sum + (int.tryParse(info.totalTimeInForeground ?? '0') ?? 0);
      });

      final eventList = await UsageStats.queryEvents(startOfDay, now);

      final rawEvents = eventList.map((e) => {
        'timeStamp': e.timeStamp ?? '0',
        'eventType': e.eventType ?? '0',
      }).toList();

      return buildUsageData(totalForegroundMs: totalMs, events: rawEvents);
    } catch (_) {
      return UsageData.empty();
    }
  }

  /// Pure function — builds [UsageData] from raw event maps.
  /// Extracted as static so it can be unit-tested without the plugin.
  static UsageData buildUsageData({
    required int totalForegroundMs,
    required List<Map<String, dynamic>> events,
  }) {
    final hourlyMs = List.filled(24, 0);
    int? openTs;
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final event in events) {
      final ts = int.tryParse(event['timeStamp']?.toString() ?? '') ?? 0;
      final type = event['eventType']?.toString() ?? '0';

      if (type == '1') {
        openTs = ts;
      } else if (type == '2' && openTs != null) {
        _attributeRange(hourlyMs, openTs, ts);
        openTs = null;
      }
    }

    // Attribute open session up to now.
    if (openTs != null) {
      _attributeRange(hourlyMs, openTs, now);
    }

    return UsageData(
      totalMinutes: totalForegroundMs ~/ 60000,
      hourlyMinutes: hourlyMs,
    );
  }

  /// Splits the time range [startMs, endMs) into per-hour minute buckets.
  static void _attributeRange(List<int> buckets, int startMs, int endMs) {
    var cursor = startMs;
    while (cursor < endMs) {
      final dt = DateTime.fromMillisecondsSinceEpoch(cursor);
      final hourStart = DateTime(dt.year, dt.month, dt.day, dt.hour)
          .millisecondsSinceEpoch;
      final hourEnd = hourStart + 3600000;
      final chunkEnd = endMs < hourEnd ? endMs : hourEnd;
      buckets[dt.hour] += (chunkEnd - cursor) ~/ 60000;
      cursor = hourEnd;
    }
  }

  /// Returns true if the app has PACKAGE_USAGE_STATS permission.
  Future<bool> hasPermission() async {
    return await UsageStats.checkUsagePermission() ?? false;
  }

  /// Opens the system Usage Access settings screen.
  Future<void> openPermissionSettings() async {
    await UsageStats.grantUsagePermission();
  }
}
