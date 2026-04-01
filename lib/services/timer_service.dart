import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:eye_health/models/session_state.dart';
import 'package:eye_health/services/abstract_notification_service.dart';
import 'package:eye_health/services/preferences_service.dart';

class TimerService extends ChangeNotifier {
  static const _sessionDuration = Duration(minutes: 20);

  final PreferencesService _prefs;
  final AbstractNotificationService _notifications;

  SessionState _state = SessionState(
    startTimestamp: null,
    breaksTakenToday: 0,
    breaksDate: '',
  );

  Timer? _ticker;
  StreamSubscription<String>? _actionSub;

  TimerService({
    required PreferencesService preferencesService,
    required AbstractNotificationService notificationService,
  })  : _prefs = preferencesService,
        _notifications = notificationService;

  SessionState get state => _state;

  int get remainingSeconds {
    if (!_state.isActive) return 0;
    final elapsed = DateTime.now().millisecondsSinceEpoch -
        _state.startTimestamp!;
    final remaining =
        _sessionDuration.inMilliseconds - elapsed;
    return remaining > 0 ? (remaining / 1000).ceil() : 0;
  }

  Future<void> init() async {
    if (_prefs.getPendingRestComplete()) {
      await _prefs.setPendingRestComplete(false);
    }

    final storedTs = _prefs.getSessionStartTimestamp();
    if (storedTs != null) {
      final age =
          DateTime.now().millisecondsSinceEpoch - storedTs;
      if (age < _sessionDuration.inMilliseconds) {
        _state = SessionState(
          startTimestamp: storedTs,
          breaksTakenToday: _getBreaksForToday(),
          breaksDate: _prefs.getBreaksDate(),
        );
        _startTicker();
      } else {
        await _prefs.clearSessionStartTimestamp();
        _state = SessionState(
          startTimestamp: null,
          breaksTakenToday: _getBreaksForToday(),
          breaksDate: _prefs.getBreaksDate(),
        );
      }
    } else {
      _state = SessionState(
        startTimestamp: null,
        breaksTakenToday: _getBreaksForToday(),
        breaksDate: _prefs.getBreaksDate(),
      );
    }

    _actionSub = _notifications.actionStream.listen((action) {
      if (action == 'done_resting') {
        completeRest();
      }
    });
  }

  Future<void> startSession() async {
    if (_state.isActive) return;
    final now = DateTime.now();
    final ts = now.millisecondsSinceEpoch;
    await _prefs.setSessionStartTimestamp(ts);
    _state = _state.copyWith(startTimestamp: ts);
    await _notifications.scheduleReminder(
        now.add(_sessionDuration));
    _startTicker();
    notifyListeners();
  }

  Future<void> completeRest() async {
    await _prefs.clearSessionStartTimestamp();
    _ticker?.cancel();
    _ticker = null;

    final today = _todayString();
    int breaks;
    if (_prefs.getBreaksDate() != today) {
      breaks = 1;
      await _prefs.setBreaksDate(today);
    } else {
      breaks = _prefs.getBreaksTakenToday() + 1;
    }
    await _prefs.setBreaksTakenToday(breaks);

    _state = SessionState(
      startTimestamp: null,
      breaksTakenToday: breaks,
      breaksDate: today,
    );
    notifyListeners();

    await startSession();
  }

  Future<void> onUnlock() async {
    if (!_state.isActive) {
      await startSession();
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker =
        Timer.periodic(const Duration(seconds: 1), (_) {
      notifyListeners();
    });
  }

  int _getBreaksForToday() {
    final today = _todayString();
    if (_prefs.getBreaksDate() != today) return 0;
    return _prefs.getBreaksTakenToday();
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _actionSub?.cancel();
    super.dispose();
  }
}
