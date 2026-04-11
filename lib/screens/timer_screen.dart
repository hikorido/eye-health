import 'dart:io';
import 'package:flutter/material.dart';
import 'package:eye_health/services/timer_service.dart';
import 'package:eye_health/theme/app_theme.dart';
import 'package:eye_health/widgets/progress_ring.dart';

class TimerScreen extends StatelessWidget {
  final TimerService timerService;

  const TimerScreen({super.key, required this.timerService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eye Health'),
        backgroundColor: AppColors.topBar,
      ),
      body: ListenableBuilder(
        listenable: timerService,
        builder: (context, _) {
          final isActive = timerService.state.isActive;
          final isAwaitingRest = timerService.isAwaitingRestConfirmation;
          final remaining = timerService.remainingSeconds;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  ProgressRing(
                    totalSeconds: 1200,
                    remainingSeconds: remaining,
                  ),
                  const SizedBox(height: 32),
                  _StatusPill(isActive: isActive),
                  const SizedBox(height: 24),
                  const _ReferenceNumbers(),
                  const SizedBox(height: 24),
                  _HintText(
                    isActive: isActive,
                    isAwaitingRest: isAwaitingRest,
                  ),
                  if (isAwaitingRest) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await timerService.completeRest();
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Already Rested'),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool isActive;

  const _StatusPill({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.accent.withValues(alpha: 0.15)
            : Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppColors.accent : Colors.orange,
          width: 1.5,
        ),
      ),
      child: Text(
        isActive ? 'Session Active' : 'Time to Rest',
        style: TextStyle(
          color: isActive ? AppColors.accent : Colors.orange,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ReferenceNumbers extends StatelessWidget {
  const _ReferenceNumbers();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const _RefItem(value: '20', label: 'min'),
        Container(width: 1, height: 40, color: Colors.grey),
        const _RefItem(value: '20', label: 'sec'),
        Container(width: 1, height: 40, color: Colors.grey),
        const _RefItem(value: '20', label: 'feet'),
      ],
    );
  }
}

class _RefItem extends StatelessWidget {
  final String value;
  final String label;

  const _RefItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold, color: AppColors.accent),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _HintText extends StatelessWidget {
  final bool isActive;
  final bool isAwaitingRest;

  const _HintText({required this.isActive, required this.isAwaitingRest});

  @override
  Widget build(BuildContext context) {
    String inactiveHint = Platform.isAndroid
        ? 'Unlock your phone to start a new 20-minute session.'
        : 'Open the app to start a new 20-minute session.';

    if (isAwaitingRest) {
      inactiveHint = 'Tap "Already Rested" to continue to a new 20-minute session.';
    }

    return Text(
      isActive
          ? 'A notification will appear when it\'s time to rest.\nTap "Done Resting" to start a new session.'
          : inactiveHint,
      textAlign: TextAlign.center,
      style: Theme.of(context)
          .textTheme
          .bodySmall
          ?.copyWith(color: Colors.grey.shade600),
    );
  }
}
