import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for settings
abstract class SettingsLocalDataSource {
  Future<ThemeMode> getThemeMode();
  Future<void> setThemeMode(ThemeMode mode);
  Future<String> getLocale();
  Future<void> setLocale(String locale);
  Future<bool> areNotificationsEnabled();
  Future<void> setNotificationsEnabled(bool enabled);
  Future<Color> getPrimaryColor();
  Future<void> setPrimaryColor(Color color);
  Future<Color> getSecondaryColor();
  Future<void> setSecondaryColor(Color color);
  Future<String?> getCompanyLogo();
  Future<void> setCompanyLogo(String url);
  Future<String?> getCompanyName();
  Future<void> setCompanyName(String name);
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const String _themeModeKey = 'theme_mode';
  static const String _localeKey = 'locale';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _primaryColorKey = 'primary_color';
  static const String _secondaryColorKey = 'secondary_color';
  static const String _companyLogoKey = 'company_logo';
  static const String _companyNameKey = 'company_name';

  final SharedPreferences sharedPreferences;

  SettingsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<ThemeMode> getThemeMode() async {
    final mode = sharedPreferences.getString(_themeModeKey);
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    final modeString = mode == ThemeMode.light
        ? 'light'
        : mode == ThemeMode.dark
            ? 'dark'
            : 'system';
    await sharedPreferences.setString(_themeModeKey, modeString);
  }

  @override
  Future<String> getLocale() async {
    return sharedPreferences.getString(_localeKey) ?? 'ar';
  }

  @override
  Future<void> setLocale(String locale) async {
    await sharedPreferences.setString(_localeKey, locale);
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    return sharedPreferences.getBool(_notificationsKey) ?? true;
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    await sharedPreferences.setBool(_notificationsKey, enabled);
  }

  @override
  Future<Color> getPrimaryColor() async {
    final colorValue = sharedPreferences.getInt(_primaryColorKey);
    return colorValue != null
        ? Color(colorValue)
        : const Color(0xFF1E88E5);
  }

  @override
  Future<void> setPrimaryColor(Color color) async {
    await sharedPreferences.setInt(_primaryColorKey, color.value);
  }

  @override
  Future<Color> getSecondaryColor() async {
    final colorValue = sharedPreferences.getInt(_secondaryColorKey);
    return colorValue != null
        ? Color(colorValue)
        : const Color(0xFF26A69A);
  }

  @override
  Future<void> setSecondaryColor(Color color) async {
    await sharedPreferences.setInt(_secondaryColorKey, color.value);
  }

  @override
  Future<String?> getCompanyLogo() async {
    return sharedPreferences.getString(_companyLogoKey);
  }

  @override
  Future<void> setCompanyLogo(String url) async {
    await sharedPreferences.setString(_companyLogoKey, url);
  }

  @override
  Future<String?> getCompanyName() async {
    return sharedPreferences.getString(_companyNameKey);
  }

  @override
  Future<void> setCompanyName(String name) async {
    await sharedPreferences.setString(_companyNameKey, name);
  }
}
