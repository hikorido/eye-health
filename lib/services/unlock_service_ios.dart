import 'package:flutter/widgets.dart';
import 'package:eye_health/services/abstract_unlock_service.dart';
import 'package:eye_health/services/timer_service.dart';

class UnlockServiceIos extends WidgetsBindingObserver
    implements AbstractUnlockService {
  final TimerService _timerService;

  UnlockServiceIos({required TimerService timerService})
      : _timerService = timerService;

  @override
  void startListening() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _timerService.onUnlock();
    }
  }
}
