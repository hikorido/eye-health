class UsageData {
  final int totalMinutes;
  final List<int> hourlyMinutes;

  const UsageData({
    required this.totalMinutes,
    required this.hourlyMinutes,
  });

  factory UsageData.empty() {
    return UsageData(
      totalMinutes: 0,
      hourlyMinutes: List.filled(24, 0),
    );
  }
}
