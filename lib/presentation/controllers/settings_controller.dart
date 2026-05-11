import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._preferences);

  final SharedPreferences _preferences;
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  void load() {
    final theme = _preferences.getString(AppConstants.themeModeKey);
    _themeMode = theme == ThemeMode.light.name ? ThemeMode.light : ThemeMode.dark;
    final languageCode = _preferences.getString(AppConstants.localeKey) ?? 'en';
    _locale = Locale(languageCode);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _preferences.setString(AppConstants.themeModeKey, mode.name);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _preferences.setString(AppConstants.localeKey, locale.languageCode);
    notifyListeners();
  }
}

