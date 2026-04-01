import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eye_health/services/preferences_service.dart';

void main() {
  group('pending rest complete flag round-trip', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('flag is false by default', () async {
      final prefs = PreferencesService();
      await prefs.init();
      expect(prefs.getPendingRestComplete(), isFalse);
    });

    test('flag survives set → read cycle', () async {
      final prefs = PreferencesService();
      await prefs.init();
      await prefs.setPendingRestComplete(true);

      final prefs2 = PreferencesService();
      await prefs2.init();
      expect(prefs2.getPendingRestComplete(), isTrue);
    });

    test('flag is cleared after being read', () async {
      SharedPreferences.setMockInitialValues(
          {'_pending_rest_complete': true});
      final prefs = PreferencesService();
      await prefs.init();
      expect(prefs.getPendingRestComplete(), isTrue);

      await prefs.setPendingRestComplete(false);
      expect(prefs.getPendingRestComplete(), isFalse);
    });
  });
}
