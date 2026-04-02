import 'package:flutter_test/flutter_test.dart';
import 'package:eye_health/services/abstract_usage_stats_service.dart';
import 'package:eye_health/services/usage_stats_service_ios.dart';

void main() {
  group('UsageStatsServiceIos', () {
    late UsageStatsServiceIos service;

    setUp(() {
      service = UsageStatsServiceIos();
    });

    test('implements AbstractUsageStatsService', () {
      expect(service, isA<AbstractUsageStatsService>());
    });

    test('fetchTodayUsage returns empty data', () async {
      final data = await service.fetchTodayUsage();
      expect(data.totalMinutes, equals(0));
      expect(data.hourlyMinutes, equals(List.filled(24, 0)));
    });

    test('hasPermission returns true', () async {
      final result = await service.hasPermission();
      expect(result, isTrue);
    });

    test('openPermissionSettings completes without error', () async {
      await expectLater(service.openPermissionSettings(), completes);
    });
  });
}
