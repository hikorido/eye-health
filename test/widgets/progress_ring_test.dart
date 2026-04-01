import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eye_health/widgets/progress_ring.dart';

void main() {
  testWidgets('ProgressRing renders time label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ProgressRing(
              totalSeconds: 1200,
              remainingSeconds: 600,
            ),
          ),
        ),
      ),
    );
    expect(find.text('10:00'), findsOneWidget);
  });

  testWidgets('ProgressRing shows 20:00 for full session', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ProgressRing(
              totalSeconds: 1200,
              remainingSeconds: 1200,
            ),
          ),
        ),
      ),
    );
    expect(find.text('20:00'), findsOneWidget);
  });

  testWidgets('ProgressRing shows 0:00 for expired session', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ProgressRing(
              totalSeconds: 1200,
              remainingSeconds: 0,
            ),
          ),
        ),
      ),
    );
    expect(find.text('0:00'), findsOneWidget);
  });

  testWidgets('ProgressRing renders custom painter without errors',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ProgressRing(
              totalSeconds: 1200,
              remainingSeconds: 900,
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
