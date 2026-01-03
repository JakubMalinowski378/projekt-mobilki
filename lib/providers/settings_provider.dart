import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const _darkOverrideKey = 'dark_mode_override';

  bool _isDarkModeOverride = false;
  bool get isDarkModeOverride => _isDarkModeOverride;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkModeOverride = prefs.getBool(_darkOverrideKey) ?? false;
      notifyListeners();
    } catch (_) {
      // ignore errors and keep default
    }
  }

  Future<void> setDarkModeOverride(bool value) async {
    _isDarkModeOverride = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_darkOverrideKey, value);
    } catch (_) {
      // ignore
    }
    notifyListeners();
  }
}
