import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class AppSettingsController extends ChangeNotifier {
  AppSettingsController(this._preferences)
    : _themeMode = switch (_preferences.getString(_themeKey)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static const _themeKey = 'settings.theme_mode';

  final SharedPreferences _preferences;
  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> toggle(Brightness currentBrightness) async {
    _themeMode = currentBrightness == Brightness.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    await _preferences.setString(_themeKey, _themeMode.name);
    notifyListeners();
  }
}
