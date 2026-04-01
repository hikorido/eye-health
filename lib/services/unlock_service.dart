import 'package:flutter/services.dart';
import 'package:eye_health/services/timer_service.dart';

class UnlockService {
  static const _channel = EventChannel('com.example.eye_health/unlock');

  final TimerService _timerService;

  UnlockService({required TimerService timerService})
      : _timerService = timerService;

  void startListening() {
    _channel.receiveBroadcastStream().listen(
      (_) => _timerService.onUnlock(),
      onError: (_) {}, // Ignore channel errors (e.g. in unit tests)
    );
  }
}
