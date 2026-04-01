import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keySessionStart = 'session_start_timestamp';
  static const _keyBreaksToday = 'breaks_taken_today';
  static const _keyBreaksDate = 'breaks_date';
  static const _keyPendingRest = '_pending_rest_complete';
  static const _keyThemeOverride = 'theme_override';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  int? getSessionStartTimestamp() => _prefs.getInt(_keySessionStart);

  Future<void> setSessionStartTimestamp(int ts) =>
      _prefs.setInt(_keySessionStart, ts);

  Future<void> clearSessionStartTimestamp() =>
      _prefs.remove(_keySessionStart);

  int getBreaksTakenToday() => _prefs.getInt(_keyBreaksToday) ?? 0;

  Future<void> setBreaksTakenToday(int count) =>
      _prefs.setInt(_keyBreaksToday, count);

  String getBreaksDate() => _prefs.getString(_keyBreaksDate) ?? '';

  Future<void> setBreaksDate(String date) =>
      _prefs.setString(_keyBreaksDate, date);

  bool getPendingRestComplete() =>
      _prefs.getBool(_keyPendingRest) ?? false;

  Future<void> setPendingRestComplete(bool value) =>
      _prefs.setBool(_keyPendingRest, value);

  String getThemeOverride() =>
      _prefs.getString(_keyThemeOverride) ?? 'system';

  Future<void> setThemeOverride(String value) =>
      _prefs.setString(_keyThemeOverride, value);
}
