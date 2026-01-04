import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const _darkOverrideKey = 'dark_mode_override';
  static const _localeKey = 'locale';

  bool _isDarkModeOverride = false;
  bool get isDarkModeOverride => _isDarkModeOverride;

  Locale? _locale;
  Locale? get locale => _locale;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkModeOverride = prefs.getBool(_darkOverrideKey) ?? false;
      
      final localeCode = prefs.getString(_localeKey);
      if (localeCode != null) {
        _locale = Locale(localeCode);
      }
      
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

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale != null) {
        await prefs.setString(_localeKey, locale.languageCode);
      } else {
        await prefs.remove(_localeKey);
      }
    } catch (_) {
      // ignore
    }
    notifyListeners();
  }
}
