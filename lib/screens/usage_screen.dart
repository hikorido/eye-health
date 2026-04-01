import 'package:flutter/material.dart';
import 'package:eye_health/models/usage_data.dart';
import 'package:eye_health/services/timer_service.dart';
import 'package:eye_health/services/usage_stats_service.dart';
import 'package:eye_health/theme/app_theme.dart';
import 'package:eye_health/widgets/hourly_bar_chart.dart';

class UsageScreen extends StatefulWidget {
  final UsageStatsService usageStatsService;
  final TimerService timerService;

  const UsageScreen({
    super.key,
    required this.usageStatsService,
    required this.timerService,
  });

  @override
  State<UsageScreen> createState() => _UsageScreenState();
}

class _UsageScreenState extends State<UsageScreen> {
  UsageData? _data;
  bool _hasPermission = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final granted = await widget.usageStatsService.hasPermission();
    if (!granted) {
      setState(() {
        _hasPermission = false;
        _loading = false;
      });
      return;
    }
    final data = await widget.usageStatsService.fetchTodayUsage();
    if (mounted) {
      setState(() {
        _data = data;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Usage"),
        backgroundColor: AppColors.topBar,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_hasPermission
              ? _PermissionPrompt(
                  onGrant: () async {
                    await widget.usageStatsService.openPermissionSettings();
                    await _load();
                  },
                )
              : _UsageContent(
                  data: _data ?? UsageData.empty(),
                  timerService: widget.timerService,
                ),
    );
  }
}

class _UsageContent extends StatelessWidget {
  final UsageData data;
  final TimerService timerService;

  const _UsageContent({required this.data, required this.timerService});

  @override
  Widget build(BuildContext context) {
    final hours = data.totalMinutes ~/ 60;
    final minutes = data.totalMinutes % 60;
    final totalLabel = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              totalLabel,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold, color: AppColors.accent),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Total screen time today',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hourly Breakdown',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  HourlyBarChart(hourlyMinutes: data.hourlyMinutes),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListenableBuilder(
            listenable: timerService,
            builder: (context, _) {
              final breaks = timerService.state.breaksTakenToday;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.visibility, color: AppColors.accent),
                  title: Text(
                    '$breaks rest ${breaks == 1 ? 'break' : 'breaks'} taken today',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text('Each break: 20 sec at 20 feet'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PermissionPrompt extends StatelessWidget {
  final VoidCallback onGrant;

  const _PermissionPrompt({required this.onGrant});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 56, color: AppColors.accent),
            const SizedBox(height: 16),
            Text(
              'Usage Access Required',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'To show today\'s screen time, please grant '
              'Usage Access permission in Settings > '
              'Digital Wellbeing & Parental Controls > Usage Access.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onGrant,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }
}
