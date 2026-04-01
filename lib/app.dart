import 'package:flutter/material.dart';
import 'package:eye_health/services/timer_service.dart';
import 'package:eye_health/services/usage_stats_service.dart';
import 'package:eye_health/theme/app_theme.dart';
import 'package:eye_health/screens/timer_screen.dart';
import 'package:eye_health/screens/usage_screen.dart';

class EyeHealthApp extends StatelessWidget {
  final TimerService timerService;
  final UsageStatsService usageStatsService;

  const EyeHealthApp({
    super.key,
    required this.timerService,
    required this.usageStatsService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eye Health',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: _MainScaffold(
        timerService: timerService,
        usageStatsService: usageStatsService,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class _MainScaffold extends StatefulWidget {
  final TimerService timerService;
  final UsageStatsService usageStatsService;

  const _MainScaffold({
    required this.timerService,
    required this.usageStatsService,
  });

  @override
  State<_MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<_MainScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      TimerScreen(timerService: widget.timerService),
      UsageScreen(
        usageStatsService: widget.usageStatsService,
        timerService: widget.timerService,
      ),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Usage',
          ),
        ],
      ),
    );
  }
}
