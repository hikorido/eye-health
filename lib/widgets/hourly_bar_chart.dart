import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:eye_health/theme/app_theme.dart';

class HourlyBarChart extends StatelessWidget {
  final List<int> hourlyMinutes;

  const HourlyBarChart({
    super.key,
    required this.hourlyMinutes,
  }) : assert(hourlyMinutes.length == 24);

  @override
  Widget build(BuildContext context) {
    final maxMinutes = hourlyMinutes.fold(0, math.max);
    const maxHeight = 80.0;

    return SizedBox(
      height: maxHeight + 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(24, (hour) {
          final minutes = hourlyMinutes[hour];
          final barHeight = maxMinutes > 0
              ? (minutes / maxMinutes) * maxHeight
              : 0.0;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    key: const ValueKey('hourly_bar'),
                    height: barHeight.clamp(2.0, maxHeight),
                    decoration: BoxDecoration(
                      color: minutes > 0
                          ? AppColors.accent.withOpacity(0.8)
                          : AppColors.topBar.withOpacity(0.2),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(2),
                      ),
                    ),
                  ),
                  if (hour % 6 == 0)
                    Text(
                      '$hour',
                      style: const TextStyle(fontSize: 8),
                    )
                  else
                    const SizedBox(height: 12),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
