import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eye_health/widgets/hourly_bar_chart.dart';

void main() {
  testWidgets('HourlyBarChart renders 24 bars', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HourlyBarChart(
            hourlyMinutes: List.filled(24, 10),
          ),
        ),
      ),
    );
    final bars = find.byKey(const ValueKey('hourly_bar'));
    expect(bars, findsNWidgets(24));
  });

  testWidgets('HourlyBarChart renders without error for all-zero data',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HourlyBarChart(
            hourlyMinutes: List.filled(24, 0),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('HourlyBarChart renders without error for mixed data',
      (tester) async {
    final data = List.generate(24, (i) => i * 2);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HourlyBarChart(hourlyMinutes: data),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
