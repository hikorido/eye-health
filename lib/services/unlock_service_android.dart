import 'package:flutter/services.dart';
import 'package:eye_health/services/abstract_unlock_service.dart';
import 'package:eye_health/services/timer_service.dart';

class UnlockServiceAndroid implements AbstractUnlockService {
  static const _channel = EventChannel('com.example.eye_health/unlock');

  final TimerService _timerService;

  UnlockServiceAndroid({required TimerService timerService})
      : _timerService = timerService;

  @override
  void startListening() {
    _channel.receiveBroadcastStream().listen(
      (_) => _timerService.onUnlock(),
      onError: (_) {},
    );
  }
}
