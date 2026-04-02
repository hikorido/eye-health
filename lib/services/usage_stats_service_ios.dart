import 'package:eye_health/models/usage_data.dart';
import 'package:eye_health/services/abstract_usage_stats_service.dart';

class UsageStatsServiceIos implements AbstractUsageStatsService {
  @override
  Future<UsageData> fetchTodayUsage() async => UsageData.empty();

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<void> openPermissionSettings() async {}
}
