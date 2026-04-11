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
  bool _restNotified = false;
  bool _awaitingRestConfirmation = false;
  StreamSubscription<String>? _actionSub;

  TimerService({
    required PreferencesService preferencesService,
    required AbstractNotificationService notificationService,
  })  : _prefs = preferencesService,
        _notifications = notificationService;

  SessionState get state => _state;
  bool get isAwaitingRestConfirmation => _awaitingRestConfirmation;

  int get remainingSeconds {
    if (!_state.isActive) return 0;
    final elapsed = DateTime.now().millisecondsSinceEpoch -
        _state.startTimestamp!;
    final remaining =
        _sessionDuration.inMilliseconds - elapsed;
    return remaining > 0 ? (remaining / 1000).ceil() : 0;
  }

  Future<void> init() async {
    final hasPendingRest = _prefs.getPendingRestComplete();
    if (hasPendingRest) await _prefs.setPendingRestComplete(false);

    final storedTs = _prefs.getSessionStartTimestamp();
    if (storedTs != null) {
      final age = DateTime.now().millisecondsSinceEpoch - storedTs;
      if (age < _sessionDuration.inMilliseconds) {
        _state = SessionState(
          startTimestamp: storedTs,
          breaksTakenToday: _getBreaksForToday(),
          breaksDate: _prefs.getBreaksDate(),
        );
        _restNotified = false;
        _awaitingRestConfirmation = false;
        await _notifications.showOngoingTimer(storedTs);
        _startTicker();
      } else {
        await _prefs.clearSessionStartTimestamp();
        _state = SessionState(
          startTimestamp: null,
          breaksTakenToday: _getBreaksForToday(),
          breaksDate: _prefs.getBreaksDate(),
        );
        final elapsed = DateTime.now().millisecondsSinceEpoch - storedTs;
        await _notifications.pauseOngoingTimer(elapsed);
        _restNotified = true;
        _awaitingRestConfirmation = true;
      }
    } else {
      _state = SessionState(
        startTimestamp: null,
        breaksTakenToday: _getBreaksForToday(),
        breaksDate: _prefs.getBreaksDate(),
      );
      _awaitingRestConfirmation = false;
    }

    _actionSub = _notifications.actionStream.listen((action) {
      if (action == 'done_resting') {
        completeRest();
      }
    });

    if (hasPendingRest) await completeRest();
  }

  Future<void> startSession() async {
    await _startOrResetSession(resetIfActive: false);
  }

  Future<void> _startOrResetSession({required bool resetIfActive}) async {
    if (_awaitingRestConfirmation) return;
    if (_state.isActive && !resetIfActive) return;

    _ticker?.cancel();
    _ticker = null;

    await _notifications.cancelReminder();

    final now = DateTime.now();
    final ts = now.millisecondsSinceEpoch;
    await _prefs.setSessionStartTimestamp(ts);
    _state = _state.copyWith(startTimestamp: ts);
    await _notifications.scheduleReminder(
        now.add(_sessionDuration));
    await _notifications.showOngoingTimer(ts);
    _restNotified = false;
    _awaitingRestConfirmation = false;
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

    _awaitingRestConfirmation = false;
    _state = SessionState(
      startTimestamp: null,
      breaksTakenToday: breaks,
      breaksDate: today,
    );
    notifyListeners();

    await startSession();
  }

  Future<void> onUnlock() async {
    if (_awaitingRestConfirmation) {
      await completeRest();
      return;
    }
    final wasActive = _state.isActive;
    await _startOrResetSession(resetIfActive: true);
    if (wasActive) {
      await _notifications.showUnlockResetMessage();
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (remainingSeconds == 0 && !_restNotified && _state.isActive) {
        _restNotified = true;
        _awaitingRestConfirmation = true;
        final elapsed =
            DateTime.now().millisecondsSinceEpoch - _state.startTimestamp!;

        _ticker?.cancel();
        _ticker = null;
        await _prefs.clearSessionStartTimestamp();
        _state = _state.copyWith(startTimestamp: null);

        await _notifications.pauseOngoingTimer(elapsed);
        notifyListeners();
      }
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
