import 'package:eye_health/models/usage_data.dart';

abstract class AbstractUsageStatsService {
  Future<UsageData> fetchTodayUsage();
  Future<bool> hasPermission();
  Future<void> openPermissionSettings();
}
