import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const _themeModeKey = 'theme_mode';
  static const _localeKey = 'locale';
  static const _currencyKey = 'target_currency';
  static const _notificationsKey = 'notifications_enabled';
  static const _biometricKey = 'biometric_enabled';
  static const _shakeAnimationKey = 'shake_animation_enabled';

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Locale? _locale;
  Locale? get locale => _locale;

  String _targetCurrency = 'PLN';
  String get targetCurrency => _targetCurrency;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  bool _biometricEnabled = true;
  bool get biometricEnabled => _biometricEnabled;

  bool _shakeAnimationEnabled = true;
  bool get shakeAnimationEnabled => _shakeAnimationEnabled;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeModeKey);
      if (themeModeString != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeModeString,
          orElse: () => ThemeMode.system,
        );
      }

      final localeCode = prefs.getString(_localeKey);
      if (localeCode != null) {
        _locale = Locale(localeCode);
      }

      _targetCurrency = prefs.getString(_currencyKey) ?? 'PLN';
      _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
      _biometricEnabled = prefs.getBool(_biometricKey) ?? true;
      _shakeAnimationEnabled = prefs.getBool(_shakeAnimationKey) ?? true;

      notifyListeners();
    } catch (_) {
      // ignore errors and keep default
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode.toString());
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

  Future<void> setTargetCurrency(String currency) async {
    _targetCurrency = currency;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currencyKey, currency);
    } catch (_) {
      // ignore
    }
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsKey, value);
    } catch (_) {
      // ignore
    }
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool value) async {
    _biometricEnabled = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricKey, value);
    } catch (_) {
      // ignore
    }
    notifyListeners();
  }

  Future<void> setShakeAnimationEnabled(bool value) async {
    _shakeAnimationEnabled = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_shakeAnimationKey, value);
    } catch (_) {
      // ignore
    }
    notifyListeners();
  }
}
